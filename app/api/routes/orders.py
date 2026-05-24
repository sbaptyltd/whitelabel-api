import os
from decimal import Decimal, ROUND_HALF_UP
from datetime import datetime

import stripe
from pydantic import BaseModel

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, text
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import (
    AppNotification,
    Cart,
    CartItem,
    NotificationLog,
    Order,
    OrderItem,
    Payment,
    User,
    UserAddress,
)
from app.schemas.cart import CreateOrderRequest, ConfirmPaymentRequest

try:
    from app.services.push_notifications import send_push_notification
except Exception:
    send_push_notification = None

try:
    from app.services.email_notifications import (
        send_store_new_order_email,
        send_delivery_ready_email,
        send_customer_invoice_email,
    )
except Exception as e:
    print(f"[EMAIL_NOTIFICATION_IMPORT_FAILED] error={e}")
    send_store_new_order_email = None
    send_delivery_ready_email = None
    send_customer_invoice_email = None


router = APIRouter(prefix="/api", tags=["orders"])


STORE_ROLES = ["store", "store_admin", "store_user", "store_owner", "super_user", "admin"]
DELIVERY_ROLES = ["delivery", "delivery_partner", "driver", "super_user", "admin"]

VALID_STORE_STATUSES = [
    "PENDING",
    "CONFIRMED",
    "ACCEPTED",
    "PREPARING",
    "READY",
    "OUT_FOR_DELIVERY",
    "DISPATCHED",
    "DELIVERED",
    "REJECTED",
    "CANCELLED",
]


class CreatePaymentIntentFromCartRequest(BaseModel):
    store_id: int
    delivery_pincode: str | None = None


class CreateOrderAfterPaymentRequest(BaseModel):
    store_id: int
    delivery_pincode: str
    delivery_address_text: str
    customer_email: str | None = None
    notes: str | None = ""
    payment_provider: str = "stripe"
    payment_intent_id: str



class SaveUserAddressRequest(BaseModel):
    customer_email: str | None = None
    phone: str | None = None
    address_type: str | None = "HOME"
    line1: str
    line2: str | None = None
    suburb: str | None = None
    city: str | None = None
    state: str | None = None
    postcode: str | None = None
    country: str | None = "Australia"

def _stripe_to_dict(value):
    if hasattr(value, "to_dict_recursive"):
        return value.to_dict_recursive()
    if isinstance(value, dict):
        return value
    try:
        return dict(value)
    except Exception:
        return {"value": str(value)}


def _stripe_metadata_to_dict(intent):
    metadata = getattr(intent, "metadata", {}) or {}

    if hasattr(metadata, "to_dict_recursive"):
        return metadata.to_dict_recursive()

    try:
        return dict(metadata)
    except Exception:
        return {}


def _require_stripe_secret_key():
    stripe.api_key = (os.getenv("STRIPE_SECRET_KEY") or "").strip()

    if not stripe.api_key:
        raise HTTPException(status_code=500, detail="Stripe secret key missing")

    return stripe.api_key


def _amount_to_cents(amount: Decimal) -> int:
    return int(
        (amount * Decimal("100")).quantize(
            Decimal("1"),
            rounding=ROUND_HALF_UP,
        )
    )

def _get_checkout_fee_breakdown(db: Session, tenant_id: int, subtotal: Decimal) -> dict:
    """
    Reads configurable checkout fees from tenant_fee_config and returns a safe breakdown.

    Rules:
    - platform_fee comes from tenant_fee_config.platform_fee
    - delivery_fee comes from tenant_fee_config.delivery_fee
    - if subtotal >= free_delivery_min_amount, delivery_fee becomes 0.00
    """
    subtotal = Decimal(subtotal or 0).quantize(Decimal("0.01"))

    row = db.execute(
        text(
            """
            SELECT
                platform_fee,
                delivery_fee,
                free_delivery_min_amount
            FROM tenant_fee_config
            WHERE tenant_id = :tenant_id
              AND is_active = 1
            LIMIT 1
            """
        ),
        {"tenant_id": tenant_id},
    ).mappings().first()

    if not row:
        platform_fee = Decimal("0.00")
        delivery_fee = Decimal("0.00")
        free_delivery_min_amount = Decimal("0.00")
    else:
        platform_fee = Decimal(row["platform_fee"] or 0).quantize(Decimal("0.01"))
        delivery_fee = Decimal(row["delivery_fee"] or 0).quantize(Decimal("0.01"))
        free_delivery_min_amount = Decimal(row["free_delivery_min_amount"] or 0).quantize(Decimal("0.01"))

    free_delivery_applied = False

    if free_delivery_min_amount > 0 and subtotal >= free_delivery_min_amount:
        delivery_fee = Decimal("0.00")
        free_delivery_applied = True

    discount_amount = Decimal("0.00")
    tax_amount = Decimal("0.00")

    total_amount = (
        subtotal
        + platform_fee
        + delivery_fee
        + tax_amount
        - discount_amount
    ).quantize(Decimal("0.01"))

    return {
        "subtotal_amount": subtotal,
        "platform_fee_amount": platform_fee,
        "delivery_amount": delivery_fee,
        "tax_amount": tax_amount,
        "discount_amount": discount_amount,
        "total_amount": total_amount,
        "free_delivery_min_amount": free_delivery_min_amount,
        "free_delivery_applied": free_delivery_applied,
    }


def _set_order_platform_fee(order: Order, platform_fee_amount: Decimal) -> None:
    """
    Safe setter because older SQLAlchemy model files may not yet have platform_fee_amount.
    If the model has the column, this sets it normally.
    A raw SQL update is also done after flush in order creation functions.
    """
    if hasattr(order, "platform_fee_amount"):
        order.platform_fee_amount = platform_fee_amount


def _order_platform_fee_value(db: Session, order: Order) -> float:
    """
    Returns platform_fee_amount safely even if the SQLAlchemy Order model
    is older and does not expose the platform_fee_amount column yet.
    """
    value = getattr(order, "platform_fee_amount", None)

    if value is not None:
        return float(value or 0)

    row = db.execute(
        text(
            """
            SELECT platform_fee_amount
            FROM orders
            WHERE id = :order_id
            LIMIT 1
            """
        ),
        {"order_id": order.id},
    ).mappings().first()

    if not row:
        return 0.0

    return float(row["platform_fee_amount"] or 0)


def _create_app_notification(
    db: Session,
    tenant_id: int,
    user_id: int,
    title: str,
    message: str,
    notification_type: str,
    order_id: int | None = None,
):
    notification = AppNotification(
        tenant_id=tenant_id,
        user_id=user_id,
        order_id=order_id,
        title=title,
        message=message,
        notification_type=notification_type,
        is_read=False,
    )
    db.add(notification)
    return notification


def _notify_user(
    db: Session,
    tenant_id: int,
    user_id: int,
    title: str,
    message: str,
    notification_type: str,
    order_id: int | None = None,
):
    _create_app_notification(
        db=db,
        tenant_id=tenant_id,
        user_id=user_id,
        title=title,
        message=message,
        notification_type=notification_type,
        order_id=order_id,
    )

    if send_push_notification:
        try:
            send_push_notification(
                db=db,
                user_id=user_id,
                title=title,
                body=message,
            )
        except Exception as e:
            print(f"[PUSH_NOTIFICATION_FAILED] user_id={user_id} error={e}")


def _safe_send_email_notification(email_func, db: Session, order: Order, label: str):
    """
    Sends role-based emails without breaking the order/status flow if SMTP fails.
    The email service also writes NotificationLog rows as SENT/FAILED.
    """
    if not email_func:
        print(f"[EMAIL_NOTIFICATION_SKIPPED] label={label} reason=email service unavailable")
        return

    try:
        email_func(db, order)
    except Exception as e:
        print(f"[EMAIL_NOTIFICATION_FAILED] label={label} order_id={getattr(order, 'id', None)} error={e}")


def _notify_store_users_new_order(db: Session, order: Order):
    if not order.store_id:
        return

    store_users = (
        db.query(User)
        .filter(
            User.tenant_id == order.tenant_id,
            User.role.in_(["store", "store_admin", "store_user", "store_owner"]),
            User.store_id == order.store_id,
            User.status == "ACTIVE",
        )
        .all()
    )

    for store_user in store_users:
        _notify_user(
            db=db,
            tenant_id=order.tenant_id,
            user_id=store_user.id,
            order_id=order.id,
            title="New Order Received",
            message=f"Order {order.order_number} has been received for your store.",
            notification_type="new_order",
        )

    # Email to store manager/store users after successful payment.
    # Email uses Product.base_price via email_notifications.py.
    _safe_send_email_notification(
        send_store_new_order_email,
        db=db,
        order=order,
        label="store_new_order",
    )


def _notify_delivery_users_order_ready(db: Session, order: Order):
    delivery_users = (
        db.query(User)
        .filter(
            User.tenant_id == order.tenant_id,
            User.role.in_(["delivery", "delivery_partner", "driver"]),
            User.status == "ACTIVE",
        )
        .all()
    )

    for delivery_user in delivery_users:
        _notify_user(
            db=db,
            tenant_id=order.tenant_id,
            user_id=delivery_user.id,
            order_id=order.id,
            title="Order Ready for Pickup",
            message=f"Order {order.order_number} is ready for delivery pickup.",
            notification_type="order_ready_for_delivery",
        )

    # Email to delivery role when store marks order READY.
    _safe_send_email_notification(
        send_delivery_ready_email,
        db=db,
        order=order,
        label="delivery_ready",
    )


def _notify_customer_order_delivered(db: Session, order: Order):
    _notify_user(
        db=db,
        tenant_id=order.tenant_id,
        user_id=order.user_id,
        order_id=order.id,
        title="Order Delivered",
        message=f"Your order {order.order_number} has been delivered.",
        notification_type="order_delivered",
    )

    # Customer invoice email uses OrderItem.unit_price_snapshot/line_total,
    # which is the customer sale price snapshot.
    _safe_send_email_notification(
        send_customer_invoice_email,
        db=db,
        order=order,
        label="customer_invoice",
    )


def _notify_store_users_order_delivered(db: Session, order: Order):
    if not order.store_id:
        return

    store_users = (
        db.query(User)
        .filter(
            User.tenant_id == order.tenant_id,
            User.role.in_(["store", "store_admin", "store_user", "store_owner"]),
            User.store_id == order.store_id,
            User.status == "ACTIVE",
        )
        .all()
    )

    for store_user in store_users:
        _notify_user(
            db=db,
            tenant_id=order.tenant_id,
            user_id=store_user.id,
            order_id=order.id,
            title="Order Delivered",
            message=f"Order {order.order_number} has been delivered successfully.",
            notification_type="order_delivered_store",
        )


def _active_cart(db: Session, tenant_id: int, user_id: int):
    return (
        db.query(Cart)
        .filter(
            Cart.tenant_id == tenant_id,
            Cart.user_id == user_id,
            Cart.status == "ACTIVE",
        )
        .first()
    )


def _require_store_user(current_user):
    role = getattr(current_user, "role", None)
    store_id = getattr(current_user, "store_id", None)
    user_id = getattr(current_user, "id", None)
    mobile = getattr(current_user, "mobile_number", None)

    print(f"[STORE_AUTH] user_id={user_id} mobile={mobile} role={role} store_id={store_id}")

    if role not in STORE_ROLES:
        raise HTTPException(
            status_code=403,
            detail=f"Not allowed for store operations. user_id={user_id}, mobile={mobile}, role={role}, store_id={store_id}",
        )

    return True


def _require_delivery_user(current_user):
    role = getattr(current_user, "role", None)
    user_id = getattr(current_user, "id", None)
    mobile = getattr(current_user, "mobile_number", None)
    delivery_partner_id = getattr(current_user, "delivery_partner_id", None)

    print(
        f"[DELIVERY_AUTH] user_id={user_id} mobile={mobile} "
        f"role={role} delivery_partner_id={delivery_partner_id}"
    )

    if role not in DELIVERY_ROLES:
        raise HTTPException(
            status_code=403,
            detail=(
                f"Not allowed for delivery operations. "
                f"user_id={user_id}, mobile={mobile}, role={role}, "
                f"delivery_partner_id={delivery_partner_id}"
            ),
        )

    return True


def _get_user_store_id(current_user):
    return getattr(current_user, "store_id", None)


def _store_order_query(db: Session, current_user, order_id: int | None = None):
    _require_store_user(current_user)

    query = db.query(Order).filter(Order.tenant_id == current_user.tenant_id)

    user_store_id = _get_user_store_id(current_user)

    if user_store_id is not None:
        query = query.filter(Order.store_id == user_store_id)

    if order_id is not None:
        query = query.filter(Order.id == order_id)

    return query


def _get_store_order_or_404(db: Session, current_user, order_id: int):
    order = _store_order_query(db, current_user, order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found for this store")

    return order


def _change_order_status(
    db: Session,
    current_user,
    order_id: int,
    new_status: str,
    allowed_from: list[str],
):
    order = _get_store_order_or_404(db, current_user, order_id)

    current_status = order.order_status

    if current_status not in allowed_from:
        raise HTTPException(
            status_code=400,
            detail=f"Order cannot move from {current_status} to {new_status}",
        )

    order.order_status = new_status
    db.commit()
    db.refresh(order)

    return {
        "message": f"Order status updated to {new_status}",
        "order_id": int(order.id),
        "order_number": order.order_number,
        "order_status": order.order_status,
        "status": order.order_status,
        "payment_status": order.payment_status,
        "store_id": int(order.store_id) if order.store_id else None,
        "delivery_partner_id": int(order.delivery_partner_id) if order.delivery_partner_id else None,
    }


def _validate_store(db: Session, tenant_id: int, store_id: int):
    row = db.execute(
        text(
            """
            SELECT id, store_name
            FROM stores
            WHERE id = :store_id
              AND tenant_id = :tenant_id
              AND is_active = 1
            LIMIT 1
            """
        ),
        {"tenant_id": tenant_id, "store_id": store_id},
    ).mappings().first()

    if not row:
        raise HTTPException(status_code=400, detail="Invalid or inactive store")

    return row


def _reserve_store_stock(db: Session, tenant_id: int, store_id: int, product_id: int, quantity: int):
    result = db.execute(
        text(
            """
            UPDATE store_products
            SET reserved_qty = reserved_qty + :quantity
            WHERE tenant_id = :tenant_id
              AND store_id = :store_id
              AND product_id = :product_id
              AND is_active = 1
              AND (stock_qty - reserved_qty) >= :quantity
            """
        ),
        {
            "tenant_id": tenant_id,
            "store_id": store_id,
            "product_id": product_id,
            "quantity": quantity,
        },
    )

    if result.rowcount == 0:
        product_row = db.execute(
            text(
                """
                SELECT product_name
                FROM products
                WHERE id = :product_id
                  AND tenant_id = :tenant_id
                LIMIT 1
                """
            ),
            {"tenant_id": tenant_id, "product_id": product_id},
        ).mappings().first()

        product_name = product_row["product_name"] if product_row else f"Product {product_id}"
        raise HTTPException(status_code=400, detail=f"Not enough stock for {product_name}")



@router.get("/checkout/summary")
def checkout_summary(
    store_id: int,
    delivery_pincode: str | None = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """
    Returns checkout price breakdown for Flutter before Stripe payment.
    Source of truth is backend DB config, not Flutter hardcoding.
    """
    cart = _active_cart(db, current_user.tenant_id, current_user.id)

    if not cart:
        raise HTTPException(status_code=400, detail="Cart is empty")

    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()

    if not items:
        raise HTTPException(status_code=400, detail="Cart is empty")

    _validate_store(db, current_user.tenant_id, store_id)

    subtotal = sum(Decimal(i.line_total) for i in items)
    fees = _get_checkout_fee_breakdown(db, current_user.tenant_id, subtotal)

    return {
        "subtotal_amount": float(fees["subtotal_amount"]),
        "platform_fee_amount": float(fees["platform_fee_amount"]),
        "delivery_amount": float(fees["delivery_amount"]),
        "tax_amount": float(fees["tax_amount"]),
        "discount_amount": float(fees["discount_amount"]),
        "total_amount": float(fees["total_amount"]),
        "free_delivery_min_amount": float(fees["free_delivery_min_amount"]),
        "free_delivery_applied": bool(fees["free_delivery_applied"]),
        "currency_code": "AUD",
        "store_id": int(store_id),
        "delivery_pincode": delivery_pincode,
    }



@router.get("/checkout/last-details")
def get_last_checkout_details(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """
    Returns the latest checkout details from the user's previous order.
    This is used by Flutter to auto-fill checkout without saving address/email locally.
    """
    order = (
        db.query(Order)
        .filter(
            Order.user_id == current_user.id,
            Order.tenant_id == current_user.tenant_id,
        )
        .order_by(Order.id.desc())
        .first()
    )

    if not order:
        return {
            "delivery_address_text": "",
            "customer_email": getattr(current_user, "email", None) or "",
            "customer_mobile": getattr(current_user, "mobile_number", None) or "",
            "delivery_pincode": "",
        }

    return {
        "delivery_address_text": order.delivery_address_text or "",
        "customer_email": order.customer_email or getattr(current_user, "email", None) or "",
        "customer_mobile": order.customer_mobile or getattr(current_user, "mobile_number", None) or "",
        "delivery_pincode": order.delivery_pincode or "",
    }


@router.post("/payments/create-payment-intent-from-cart")
def create_payment_intent_from_cart(
    payload: CreatePaymentIntentFromCartRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """
    Creates Stripe PaymentIntent directly from the active cart.
    IMPORTANT: This does NOT create an order, so cancelled/failed payments do not create PENDING orders.
    """
    _require_stripe_secret_key()

    print("[ORDERS_PY_VERSION] metadata-fix-v4-fallback")

    cart = _active_cart(db, current_user.tenant_id, current_user.id)

    if not cart:
        raise HTTPException(status_code=400, detail="Cart is empty")

    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()

    if not items:
        raise HTTPException(status_code=400, detail="Cart is empty")

    _validate_store(db, current_user.tenant_id, payload.store_id)

    subtotal = sum(Decimal(i.line_total) for i in items)
    fees = _get_checkout_fee_breakdown(db, current_user.tenant_id, subtotal)
    amount_cents = _amount_to_cents(fees["total_amount"])

    if amount_cents <= 0:
        raise HTTPException(status_code=400, detail="Invalid cart amount")

    payment_metadata = {
        "tenant_id": str(current_user.tenant_id),
        "user_id": str(current_user.id),
        "cart_id": str(cart.id),
        "store_id": str(payload.store_id),
        "delivery_pincode": payload.delivery_pincode or "",
        "subtotal_amount": str(fees["subtotal_amount"]),
        "platform_fee_amount": str(fees["platform_fee_amount"]),
        "delivery_amount": str(fees["delivery_amount"]),
        "total_amount": str(fees["total_amount"]),
        "free_delivery_applied": str(fees["free_delivery_applied"]).lower(),
    }

    try:
        print(
            f"[CREATE_PI_INPUT] "
            f"tenant_id={current_user.tenant_id} "
            f"user_id={current_user.id} "
            f"cart_id={cart.id} "
            f"store_id={payload.store_id} "
            f"pincode={payload.delivery_pincode} "
            f"metadata_to_send={payment_metadata}"
        )

        intent = stripe.PaymentIntent.create(
            amount=amount_cents,
            currency="aud",
            metadata=payment_metadata,
            automatic_payment_methods={"enabled": True},
        )

        created_metadata = _stripe_metadata_to_dict(intent)

        # Extra safety: if Stripe response does not show metadata, force-update it once.
        # This protects the checkout flow from SDK/API response shape issues.
        if not created_metadata.get("cart_id") or not created_metadata.get("store_id"):
            print(
                f"[PAYMENT_INTENT_METADATA_FORCE_UPDATE] "
                f"id={intent.id} expected_metadata={payment_metadata} stripe_metadata_before={created_metadata}"
            )
            intent = stripe.PaymentIntent.modify(intent.id, metadata=payment_metadata)
            created_metadata = _stripe_metadata_to_dict(intent)

        print(
            f"[PAYMENT_INTENT_CREATED] "
            f"id={intent.id} "
            f"store_id={payload.store_id} "
            f"cart_id={cart.id} "
            f"user_id={current_user.id} "
            f"tenant_id={current_user.tenant_id} "
            f"metadata={created_metadata}"
        )

        return {
            "client_secret": intent.client_secret,
            "payment_intent_id": intent.id,
            # Backward-compatible amount field. This is now the grand total charged by Stripe.
            "amount": float(fees["total_amount"]),
            "subtotal_amount": float(fees["subtotal_amount"]),
            "platform_fee_amount": float(fees["platform_fee_amount"]),
            "delivery_amount": float(fees["delivery_amount"]),
            "tax_amount": float(fees["tax_amount"]),
            "discount_amount": float(fees["discount_amount"]),
            "total_amount": float(fees["total_amount"]),
            "free_delivery_min_amount": float(fees["free_delivery_min_amount"]),
            "free_delivery_applied": bool(fees["free_delivery_applied"]),
            "currency_code": "AUD",
            "cart_id": int(cart.id),
            "store_id": int(payload.store_id),
            "tenant_id": int(current_user.tenant_id),
            "user_id": int(current_user.id),
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Payment intent creation failed: {str(e)}",
        )


@router.post("/checkout/create-order-after-payment")
def create_order_after_payment(
    payload: CreateOrderAfterPaymentRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """
    Creates a CONFIRMED order only after Stripe payment has succeeded.

    Stable flow:
    - Flutter creates PaymentIntent from the active cart.
    - The backend stores tenant/user/cart/store in Stripe metadata.
    - After payment succeeds, this endpoint reads cart_id and store_id back from Stripe metadata.

    This avoids tenant/user/cart/store mismatch from stale Flutter local storage or a refreshed JWT.
    """
    _require_stripe_secret_key()

    if not payload.payment_intent_id:
        raise HTTPException(status_code=400, detail="payment_intent_id is required")

    try:
        intent = stripe.PaymentIntent.retrieve(payload.payment_intent_id)
    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=f"Unable to retrieve Stripe payment intent: {str(e)}",
        )

    metadata = _stripe_metadata_to_dict(intent)

    print(
        f"[STRIPE_METADATA_CHECK] "
        f"current_tenant={getattr(current_user, 'tenant_id', None)} "
        f"current_user={getattr(current_user, 'id', None)} "
        f"payload_store_id={payload.store_id} "
        f"payment_intent_id={payload.payment_intent_id} "
        f"stripe_status={getattr(intent, 'status', None)} "
        f"stripe_metadata={metadata}"
    )

    if intent.status != "succeeded":
        raise HTTPException(
            status_code=400,
            detail=f"Payment not successful. Stripe status: {intent.status}",
        )

    metadata_cart_id = int(metadata.get("cart_id", 0) or 0)
    metadata_store_id = int(metadata.get("store_id", 0) or 0)
    metadata_tenant_id = int(metadata.get("tenant_id", 0) or 0)
    metadata_user_id = int(metadata.get("user_id", 0) or 0)

    # If metadata is missing, try one forced retrieve/update path first.
    # If still missing, fall back to the current active cart + payload.store_id so checkout can complete.
    if metadata_cart_id <= 0 or metadata_store_id <= 0:
        print(
            f"[PAYMENT_METADATA_MISSING_WARNING] "
            f"payment_intent_id={payload.payment_intent_id} "
            f"metadata={metadata} "
            f"fallback_user_id={current_user.id} "
            f"fallback_tenant_id={current_user.tenant_id} "
            f"fallback_store_id={payload.store_id}"
        )

    if metadata_store_id <= 0:
        metadata_store_id = int(payload.store_id or 0)

    if metadata_tenant_id <= 0:
        metadata_tenant_id = int(current_user.tenant_id)

    if metadata_user_id <= 0:
        metadata_user_id = int(current_user.id)

    # Idempotency: if this payment already produced an order, return that order.
    existing_payment = (
        db.query(Payment)
        .filter(Payment.payment_intent_id == payload.payment_intent_id)
        .first()
    )

    if existing_payment:
        existing_order = db.query(Order).filter(Order.id == existing_payment.order_id).first()
        if existing_order:
            return {
                "message": "Order already created",
                "order_id": int(existing_order.id),
                "order_number": existing_order.order_number,
                "order_status": existing_order.order_status,
                "payment_status": existing_order.payment_status,
                "amount": float(existing_order.total_amount),
                "currency_code": existing_order.currency_code,
                "subtotal_amount": float(existing_order.subtotal_amount),
                "platform_fee_amount": _order_platform_fee_value(db, existing_order),
                "delivery_amount": float(existing_order.delivery_amount),
                "tax_amount": float(existing_order.tax_amount),
                "discount_amount": float(existing_order.discount_amount),
                "total_amount": float(existing_order.total_amount),
                "store_id": int(existing_order.store_id) if existing_order.store_id else None,
                "delivery_pincode": existing_order.delivery_pincode,
                "delivery_address_text": existing_order.delivery_address_text,
                "customer_mobile": existing_order.customer_mobile,
                "customer_email": existing_order.customer_email,
            }

    if metadata_cart_id > 0:
        cart_query = db.query(Cart).filter(Cart.id == metadata_cart_id)

        if metadata_tenant_id > 0:
            cart_query = cart_query.filter(Cart.tenant_id == metadata_tenant_id)

        if metadata_user_id > 0:
            cart_query = cart_query.filter(Cart.user_id == metadata_user_id)

        cart = cart_query.first()
    else:
        cart = _active_cart(db, current_user.tenant_id, current_user.id)

    if not cart:
        raise HTTPException(status_code=400, detail="Payment cart not found")

    if cart.status != "ACTIVE":
        # Allow idempotency via existing_payment above, but block creating a second order from an old/closed cart.
        raise HTTPException(status_code=400, detail=f"Cart is not active. Current status: {cart.status}")

    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()

    if not items:
        raise HTTPException(status_code=400, detail="Cart is empty")

    try:
        _validate_store(db, cart.tenant_id, metadata_store_id)

        subtotal = sum(Decimal(i.line_total) for i in items)
        fees = _get_checkout_fee_breakdown(db, cart.tenant_id, subtotal)
        expected_amount_cents = _amount_to_cents(fees["total_amount"])

        if int(intent.amount) != expected_amount_cents:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Payment amount does not match checkout total. "
                    f"stripe_amount_cents={int(intent.amount)}, "
                    f"expected_amount_cents={expected_amount_cents}"
                ),
            )

        for item in items:
            _reserve_store_stock(
                db=db,
                tenant_id=cart.tenant_id,
                store_id=metadata_store_id,
                product_id=item.product_id,
                quantity=item.quantity,
            )

        order = Order(
            tenant_id=cart.tenant_id,
            user_id=cart.user_id,
            cart_id=cart.id,
            order_number=f"ORD{int(datetime.utcnow().timestamp())}",
            order_status="CONFIRMED",
            payment_status="SUCCESS",
            subtotal_amount=fees["subtotal_amount"],
            tax_amount=fees["tax_amount"],
            delivery_amount=fees["delivery_amount"],
            discount_amount=fees["discount_amount"],
            total_amount=fees["total_amount"],
            currency_code="AUD",
            delivery_address_text=payload.delivery_address_text,
            customer_mobile=getattr(current_user, "mobile_number", None),
            customer_email=payload.customer_email or getattr(current_user, "email", None),
            notes=payload.notes,
            placed_at=datetime.utcnow(),
            store_id=metadata_store_id,
            delivery_pincode=payload.delivery_pincode or metadata.get("delivery_pincode", ""),
        )

        _set_order_platform_fee(order, fees["platform_fee_amount"])

        db.add(order)
        db.flush()

        db.execute(
            text(
                """
                UPDATE orders
                SET platform_fee_amount = :platform_fee_amount
                WHERE id = :order_id
                """
            ),
            {
                "platform_fee_amount": fees["platform_fee_amount"],
                "order_id": order.id,
            },
        )

        for item in items:
            db.add(
                OrderItem(
                    order_id=order.id,
                    tenant_id=cart.tenant_id,
                    user_id=cart.user_id,
                    product_id=item.product_id,
                    product_name_snapshot=item.product_name_snapshot,
                    product_image_snapshot=item.product_image_snapshot,
                    sku_snapshot=None,
                    unit_price_snapshot=item.unit_price_snapshot,
                    quantity=item.quantity,
                    line_total=item.line_total,
                )
            )

        # IMPORTANT: make OrderItem rows visible to email_notifications.py
        # before store email is generated inside this transaction.
        db.flush()

        db.add(
            Payment(
                tenant_id=cart.tenant_id,
                user_id=cart.user_id,
                order_id=order.id,
                payment_provider=payload.payment_provider,
                payment_reference=payload.payment_intent_id,
                payment_intent_id=payload.payment_intent_id,
                amount=fees["total_amount"],
                currency_code="AUD",
                payment_status="SUCCESS",
                raw_response_json=_stripe_to_dict(intent),
                paid_at=datetime.utcnow(),
            )
        )

        cart.status = "CHECKED_OUT"

        _notify_store_users_new_order(db, order)

        db.commit()
        db.refresh(order)

        return {
            "message": "Order created after successful payment",
            "order_id": int(order.id),
            "order_number": order.order_number,
            "order_status": order.order_status,
            "payment_status": order.payment_status,
            "amount": float(order.total_amount),
            "subtotal_amount": float(order.subtotal_amount),
            "platform_fee_amount": float(fees["platform_fee_amount"]),
            "delivery_amount": float(order.delivery_amount),
            "tax_amount": float(order.tax_amount),
            "discount_amount": float(order.discount_amount),
            "total_amount": float(order.total_amount),
            "currency_code": order.currency_code,
            "store_id": int(order.store_id) if order.store_id else None,
            "delivery_pincode": order.delivery_pincode,
            "delivery_address_text": order.delivery_address_text,
            "customer_mobile": order.customer_mobile,
            "customer_email": order.customer_email,
            "delivery_address_text": order.delivery_address_text,
            "customer_mobile": order.customer_mobile,
            "customer_email": order.customer_email,
        }

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Order creation after payment failed: {str(e)}",
        )


@router.post("/checkout/create-order")
def create_order(
    payload: CreateOrderRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    cart = _active_cart(db, current_user.tenant_id, current_user.id)

    if not cart:
        raise HTTPException(status_code=400, detail="Cart is empty")

    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()

    if not items:
        raise HTTPException(status_code=400, detail="Cart is empty")

    store_id = getattr(payload, "store_id", None)
    delivery_pincode = getattr(payload, "delivery_pincode", None)

    if not store_id:
        raise HTTPException(status_code=400, detail="store_id is required to place order")

    _validate_store(db, current_user.tenant_id, store_id)

    subtotal = sum(Decimal(i.line_total) for i in items)
    fees = _get_checkout_fee_breakdown(db, current_user.tenant_id, subtotal)

    try:
        for item in items:
            _reserve_store_stock(
                db=db,
                tenant_id=current_user.tenant_id,
                store_id=store_id,
                product_id=item.product_id,
                quantity=item.quantity,
            )

        order = Order(
            tenant_id=current_user.tenant_id,
            user_id=current_user.id,
            cart_id=cart.id,
            order_number=f"ORD{int(datetime.utcnow().timestamp())}",
            order_status="PENDING",
            payment_status="PENDING",
            subtotal_amount=fees["subtotal_amount"],
            tax_amount=fees["tax_amount"],
            delivery_amount=fees["delivery_amount"],
            discount_amount=fees["discount_amount"],
            total_amount=fees["total_amount"],
            currency_code="AUD",
            delivery_address_text=payload.delivery_address_text,
            customer_mobile=current_user.mobile_number,
            customer_email=payload.customer_email or current_user.email,
            notes=payload.notes,
            placed_at=datetime.utcnow(),
            store_id=store_id,
            delivery_pincode=delivery_pincode,
        )

        _set_order_platform_fee(order, fees["platform_fee_amount"])

        db.add(order)
        db.flush()

        db.execute(
            text(
                """
                UPDATE orders
                SET platform_fee_amount = :platform_fee_amount
                WHERE id = :order_id
                """
            ),
            {
                "platform_fee_amount": fees["platform_fee_amount"],
                "order_id": order.id,
            },
        )

        #_notify_store_users_new_order(db, order)

        for item in items:
            db.add(
                OrderItem(
                    order_id=order.id,
                    tenant_id=current_user.tenant_id,
                    user_id=current_user.id,
                    product_id=item.product_id,
                    product_name_snapshot=item.product_name_snapshot,
                    product_image_snapshot=item.product_image_snapshot,
                    sku_snapshot=None,
                    unit_price_snapshot=item.unit_price_snapshot,
                    quantity=item.quantity,
                    line_total=item.line_total,
                )
            )

        db.add(
            Payment(
                tenant_id=current_user.tenant_id,
                user_id=current_user.id,
                order_id=order.id,
                payment_provider=payload.payment_provider,
                amount=fees["total_amount"],
                currency_code="AUD",
                payment_status="CREATED",
            )
        )

        cart.status = "CHECKED_OUT"

        db.commit()
        db.refresh(order)

        return {
            "order_id": int(order.id),
            "order_number": order.order_number,
            "amount": float(order.total_amount),
            "subtotal_amount": float(order.subtotal_amount),
            "platform_fee_amount": float(fees["platform_fee_amount"]),
            "delivery_amount": float(order.delivery_amount),
            "tax_amount": float(order.tax_amount),
            "discount_amount": float(order.discount_amount),
            "total_amount": float(order.total_amount),
            "currency_code": order.currency_code,
            "payment_provider": payload.payment_provider,
            "payment_status": "CREATED",
            "order_status": order.order_status,
            "store_id": int(order.store_id) if order.store_id else None,
            "delivery_pincode": order.delivery_pincode,
        }

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Order creation failed: {str(e)}")


@router.post("/checkout/payment/confirm")
def confirm_payment(
    payload: ConfirmPaymentRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    order = (
        db.query(Order)
        .filter(
            Order.id == payload.order_id,
            Order.user_id == current_user.id,
            Order.tenant_id == current_user.tenant_id,
        )
        .first()
    )

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    payment = db.query(Payment).filter(Payment.order_id == order.id).first()

    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")

    payment.payment_reference = payload.payment_reference
    payment.payment_intent_id = payload.payment_intent_id
    payment.raw_response_json = payload.raw_response_json
    payment.payment_status = "SUCCESS"
    payment.paid_at = datetime.utcnow()

    order.payment_status = "SUCCESS"
    order.order_status = "CONFIRMED"

    # Send store push notification ONLY after successful payment confirmation.
    _notify_store_users_new_order(db, order)


    db.commit()

    return {
        "message": "Payment confirmed",
        "order_id": int(order.id),
        "order_status": order.order_status,
        "payment_status": order.payment_status,
        "store_id": int(order.store_id) if order.store_id else None,
    }


@router.get("/orders/current")
def current_orders(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    rows = (
        db.query(Order, func.count(OrderItem.id).label("items_count"))
        .outerjoin(OrderItem, OrderItem.order_id == Order.id)
        .filter(
            Order.user_id == current_user.id,
            Order.tenant_id == current_user.tenant_id,
            Order.order_status.in_(
                [
                    "PENDING",
                    "PAID",
                    "CONFIRMED",
                    "PROCESSING",
                    "ACCEPTED",
                    "PREPARING",
                    "READY",
                    "OUT_FOR_DELIVERY",
                    "DISPATCHED",
                ]
            ),
        )
        .group_by(Order.id)
        .order_by(Order.id.desc())
        .all()
    )

    return [
        {
            "order_id": int(order.id),
            "order_number": order.order_number,
            "order_status": order.order_status,
            "status": order.order_status,
            "payment_status": order.payment_status,
            "total_amount": float(order.total_amount),
            "currency_code": order.currency_code,
            "items_count": int(items_count or 0),
            "store_id": int(order.store_id) if order.store_id else None,
            "delivery_pincode": order.delivery_pincode,
            "placed_at": order.placed_at.isoformat() if order.placed_at else None,
            "created_at": order.created_at.isoformat() if order.created_at else None,
        }
        for order, items_count in rows
    ]


@router.get("/orders/history")
@router.get("/orders/my-orders")
def order_history(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    rows = (
        db.query(Order, func.count(OrderItem.id).label("items_count"))
        .outerjoin(OrderItem, OrderItem.order_id == Order.id)
        .filter(Order.user_id == current_user.id, Order.tenant_id == current_user.tenant_id)
        .group_by(Order.id)
        .order_by(Order.id.desc())
        .all()
    )

    return [
        {
            "order_id": int(order.id),
            "order_number": order.order_number,
            "order_status": order.order_status,
            "status": order.order_status,
            "payment_status": order.payment_status,
            "subtotal_amount": float(order.subtotal_amount),
            "platform_fee_amount": _order_platform_fee_value(db, order),
            "tax_amount": float(order.tax_amount),
            "delivery_amount": float(order.delivery_amount),
            "discount_amount": float(order.discount_amount),
            "total_amount": float(order.total_amount),
            "currency_code": order.currency_code,
            "items_count": int(items_count or 0),
            "store_id": int(order.store_id) if order.store_id else None,
            "delivery_pincode": order.delivery_pincode,
            "placed_at": order.placed_at.isoformat() if order.placed_at else None,
            "created_at": order.created_at.isoformat() if order.created_at else None,
        }
        for order, items_count in rows
    ]


@router.get("/store/orders")
def store_orders(
    status: str | None = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_store_user(current_user)

    query = (
        db.query(Order, func.count(OrderItem.id).label("items_count"))
        .outerjoin(OrderItem, OrderItem.order_id == Order.id)
        .filter(Order.tenant_id == current_user.tenant_id)
    )

    user_store_id = _get_user_store_id(current_user)

    if user_store_id is not None:
        query = query.filter(Order.store_id == user_store_id)

    if status:
        status_upper = status.upper()
        if status_upper not in VALID_STORE_STATUSES:
            raise HTTPException(status_code=400, detail="Invalid order status")
        query = query.filter(Order.order_status == status_upper)

    rows = query.group_by(Order.id).order_by(Order.id.desc()).all()

    return [
        {
            "order_id": int(order.id),
            "order_number": order.order_number,
            "order_status": order.order_status,
            "status": order.order_status,
            "payment_status": order.payment_status,
            "subtotal_amount": float(order.subtotal_amount),
            "platform_fee_amount": _order_platform_fee_value(db, order),
            "tax_amount": float(order.tax_amount),
            "delivery_amount": float(order.delivery_amount),
            "discount_amount": float(order.discount_amount),
            "total_amount": float(order.total_amount),
            "currency_code": order.currency_code,
            "items_count": int(items_count or 0),
            "store_id": int(order.store_id) if order.store_id else None,
            "delivery_partner_id": int(order.delivery_partner_id) if order.delivery_partner_id else None,
            "delivery_pincode": order.delivery_pincode,
            "delivery_address_text": order.delivery_address_text,
            "customer_mobile": order.customer_mobile,
            "customer_email": order.customer_email,
            "notes": order.notes,
            "placed_at": order.placed_at.isoformat() if order.placed_at else None,
            "created_at": order.created_at.isoformat() if order.created_at else None,
        }
        for order, items_count in rows
    ]


@router.get("/store/orders/{order_id}")
def store_order_detail(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    order = _get_store_order_or_404(db, current_user, order_id)

    items = (
        db.query(OrderItem)
        .filter(OrderItem.order_id == order.id, OrderItem.tenant_id == current_user.tenant_id)
        .order_by(OrderItem.id.asc())
        .all()
    )

    return {
        "order_id": int(order.id),
        "order_number": order.order_number,
        "order_status": order.order_status,
        "status": order.order_status,
        "payment_status": order.payment_status,
        "subtotal_amount": float(order.subtotal_amount),
        "platform_fee_amount": _order_platform_fee_value(db, order),
        "tax_amount": float(order.tax_amount),
        "delivery_amount": float(order.delivery_amount),
        "discount_amount": float(order.discount_amount),
        "total_amount": float(order.total_amount),
        "currency_code": order.currency_code,
        "store_id": int(order.store_id) if order.store_id else None,
        "delivery_partner_id": int(order.delivery_partner_id) if order.delivery_partner_id else None,
        "delivery_pincode": order.delivery_pincode,
        "delivery_address_text": order.delivery_address_text,
        "customer_mobile": order.customer_mobile,
        "customer_email": order.customer_email,
        "notes": order.notes,
        "placed_at": order.placed_at.isoformat() if order.placed_at else None,
        "created_at": order.created_at.isoformat() if order.created_at else None,
        "items": [
            {
                "order_item_id": int(item.id),
                "product_id": int(item.product_id) if item.product_id else None,
                "product_name": item.product_name_snapshot,
                "product_image": item.product_image_snapshot,
                "sku": item.sku_snapshot,
                "unit_price": float(item.unit_price_snapshot),
                "quantity": int(item.quantity),
                "line_total": float(item.line_total),
            }
            for item in items
        ],
    }


@router.post("/store/orders/{order_id}/accept")
def accept_store_order(order_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return _change_order_status(db, current_user, order_id, "ACCEPTED", ["PENDING", "CONFIRMED"])


@router.post("/store/orders/{order_id}/reject")
def reject_store_order(order_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return _change_order_status(db, current_user, order_id, "REJECTED", ["PENDING", "CONFIRMED"])


@router.post("/store/orders/{order_id}/cancel")
def cancel_store_order(order_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return _change_order_status(db, current_user, order_id, "CANCELLED", ["PENDING", "CONFIRMED", "ACCEPTED", "PREPARING"])


@router.post("/store/orders/{order_id}/preparing")
def mark_store_order_preparing(order_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return _change_order_status(db, current_user, order_id, "PREPARING", ["ACCEPTED"])


@router.post("/store/orders/{order_id}/ready")
def mark_store_order_ready(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    order = _get_store_order_or_404(db, current_user, order_id)

    if order.order_status not in ["ACCEPTED", "PREPARING"]:
        raise HTTPException(
            status_code=400,
            detail=f"Order cannot move from {order.order_status} to READY",
        )

    order.order_status = "READY"

    # Send push notification to delivery role users when store marks order as READY.
    _notify_delivery_users_order_ready(db, order)

    db.commit()
    db.refresh(order)

    return {
        "message": "Order status updated to READY",
        "order_id": int(order.id),
        "order_number": order.order_number,
        "order_status": order.order_status,
        "status": order.order_status,
        "payment_status": order.payment_status,
        "store_id": int(order.store_id) if order.store_id else None,
        "delivery_partner_id": int(order.delivery_partner_id) if order.delivery_partner_id else None,
    }


# Kept for old Flutter/store flow, but delivery flow should use OUT_FOR_DELIVERY.
@router.post("/store/orders/{order_id}/dispatch")
def dispatch_store_order(order_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return _change_order_status(db, current_user, order_id, "DISPATCHED", ["READY"])


# Kept for old Flutter/store flow, but delivery flow should mark delivered.
@router.post("/store/orders/{order_id}/deliver")
def deliver_store_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    order = _get_store_order_or_404(db, current_user, order_id)

    if order.order_status not in ["DISPATCHED", "READY", "OUT_FOR_DELIVERY"]:
        raise HTTPException(
            status_code=400,
            detail=f"Order cannot move from {order.order_status} to DELIVERED",
        )

    order.order_status = "DELIVERED"

    _notify_customer_order_delivered(db, order)
    _notify_store_users_order_delivered(db, order)

    db.commit()
    db.refresh(order)

    return {
        "message": "Order delivered",
        "order_id": int(order.id),
        "order_number": order.order_number,
        "order_status": order.order_status,
        "status": order.order_status,
        "payment_status": order.payment_status,
        "store_id": int(order.store_id) if order.store_id else None,
        "delivery_partner_id": int(order.delivery_partner_id) if order.delivery_partner_id else None,
    }


@router.get("/delivery/orders")
def delivery_orders(
    status: str | None = "READY",
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_delivery_user(current_user)

    query = db.query(Order).filter(Order.tenant_id == current_user.tenant_id)

    if status:
        query = query.filter(Order.order_status == status.upper())

    orders = query.order_by(Order.id.desc()).all()

    return [
        {
            "order_id": int(order.id),
            "order_number": order.order_number,
            "order_status": order.order_status,
            "status": order.order_status,
            "payment_status": order.payment_status,
            "total_amount": float(order.total_amount),
            "currency_code": order.currency_code,
            "store_id": int(order.store_id) if order.store_id else None,
            "delivery_partner_id": int(order.delivery_partner_id) if order.delivery_partner_id else None,
            "delivery_pincode": order.delivery_pincode,
            "delivery_address_text": order.delivery_address_text,
            "customer_mobile": order.customer_mobile,
            "customer_email": order.customer_email,
            "notes": order.notes,
            "placed_at": order.placed_at.isoformat() if order.placed_at else None,
            "created_at": order.created_at.isoformat() if order.created_at else None,
        }
        for order in orders
    ]


@router.post("/delivery/orders/{order_id}/out-for-delivery")
def mark_order_out_for_delivery(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_delivery_user(current_user)

    order = (
        db.query(Order)
        .filter(Order.id == order_id, Order.tenant_id == current_user.tenant_id)
        .first()
    )

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if order.order_status != "READY":
        raise HTTPException(
            status_code=400,
            detail=f"Order cannot move from {order.order_status} to OUT_FOR_DELIVERY",
        )

    order.order_status = "OUT_FOR_DELIVERY"

    if getattr(current_user, "delivery_partner_id", None):
        order.delivery_partner_id = current_user.delivery_partner_id

    db.commit()
    db.refresh(order)

    return {
        "message": "Order marked out for delivery",
        "order_id": int(order.id),
        "order_number": order.order_number,
        "order_status": order.order_status,
        "status": order.order_status,
        "delivery_partner_id": int(order.delivery_partner_id) if order.delivery_partner_id else None,
    }


@router.post("/delivery/orders/{order_id}/delivered")
def mark_order_delivered_by_driver(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_delivery_user(current_user)

    order = (
        db.query(Order)
        .filter(Order.id == order_id, Order.tenant_id == current_user.tenant_id)
        .first()
    )

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if order.order_status != "OUT_FOR_DELIVERY":
        raise HTTPException(
            status_code=400,
            detail=f"Order cannot move from {order.order_status} to DELIVERED",
        )

    order.order_status = "DELIVERED"

    if getattr(current_user, "delivery_partner_id", None):
        order.delivery_partner_id = current_user.delivery_partner_id

    _notify_customer_order_delivered(db, order)
    _notify_store_users_order_delivered(db, order)

    db.commit()
    db.refresh(order)

    return {
        "message": "Order delivered",
        "order_id": int(order.id),
        "order_number": order.order_number,
        "order_status": order.order_status,
        "status": order.order_status,
    }


@router.get("/orders/{order_id}")
def order_detail(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    order = (
        db.query(Order)
        .filter(Order.id == order_id, Order.user_id == current_user.id, Order.tenant_id == current_user.tenant_id)
        .first()
    )

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    items = (
        db.query(OrderItem)
        .filter(OrderItem.order_id == order.id, OrderItem.tenant_id == current_user.tenant_id)
        .order_by(OrderItem.id.asc())
        .all()
    )

    return {
        "order_id": int(order.id),
        "order_number": order.order_number,
        "order_status": order.order_status,
        "status": order.order_status,
        "payment_status": order.payment_status,
        "subtotal_amount": float(order.subtotal_amount),
        "platform_fee_amount": _order_platform_fee_value(db, order),
        "tax_amount": float(order.tax_amount),
        "delivery_amount": float(order.delivery_amount),
        "discount_amount": float(order.discount_amount),
        "total_amount": float(order.total_amount),
        "currency_code": order.currency_code,
        "store_id": int(order.store_id) if order.store_id else None,
        "delivery_partner_id": int(order.delivery_partner_id) if order.delivery_partner_id else None,
        "delivery_pincode": order.delivery_pincode,
        "delivery_address_text": order.delivery_address_text,
        "customer_mobile": order.customer_mobile,
        "customer_email": order.customer_email,
        "notes": order.notes,
        "placed_at": order.placed_at.isoformat() if order.placed_at else None,
        "created_at": order.created_at.isoformat() if order.created_at else None,
        "items": [
            {
                "order_item_id": int(item.id),
                "product_id": int(item.product_id) if item.product_id else None,
                "product_name": item.product_name_snapshot,
                "product_image": item.product_image_snapshot,
                "sku": item.sku_snapshot,
                "unit_price": float(item.unit_price_snapshot),
                "quantity": int(item.quantity),
                "line_total": float(item.line_total),
            }
            for item in items
        ],
    }


@router.get("/users/default-address")
def get_default_address(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    address = (
        db.query(UserAddress)
        .filter(
            UserAddress.tenant_id == current_user.tenant_id,
            UserAddress.user_id == current_user.id,
            UserAddress.is_default == True,
        )
        .order_by(UserAddress.updated_at.desc())
        .first()
    )

    if not address:
        return {"exists": False}

    return {
        "exists": True,
        "id": int(address.id),
        "tenant_id": int(address.tenant_id),
        "user_id": int(address.user_id),
        "customer_email": address.customer_email,
        "phone": address.phone,
        "address_type": address.address_type,
        "line1": address.line1,
        "line2": address.line2,
        "suburb": address.suburb,
        "city": address.city,
        "state": address.state,
        "postcode": address.postcode,
        "country": address.country,
        "is_default": bool(address.is_default),
    }


@router.post("/users/default-address")
def save_default_address(
    payload: SaveUserAddressRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if not payload.line1 or not payload.line1.strip():
        raise HTTPException(status_code=400, detail="Address line1 is required")

    # Ensure only one default address for this user.
    existing_defaults = (
        db.query(UserAddress)
        .filter(
            UserAddress.tenant_id == current_user.tenant_id,
            UserAddress.user_id == current_user.id,
            UserAddress.is_default == True,
        )
        .all()
    )

    address = existing_defaults[0] if existing_defaults else None

    # If duplicates already exist from old data, keep the newest/first one and unset the rest.
    for duplicate in existing_defaults[1:]:
        duplicate.is_default = False

    if not address:
        address = UserAddress(
            tenant_id=current_user.tenant_id,
            user_id=current_user.id,
            is_default=True,
            address_type=(payload.address_type or "HOME").upper(),
        )
        db.add(address)

    address.customer_email = payload.customer_email
    address.phone = payload.phone
    address.address_type = (payload.address_type or "HOME").upper()
    address.line1 = payload.line1.strip()
    address.line2 = payload.line2
    address.suburb = payload.suburb
    address.city = payload.city
    address.state = payload.state
    address.postcode = payload.postcode
    address.country = payload.country or "Australia"
    address.is_default = True

    db.commit()
    db.refresh(address)

    return {
        "message": "Default address saved",
        "exists": True,
        "id": int(address.id),
        "customer_email": address.customer_email,
        "phone": address.phone,
        "address_type": address.address_type,
        "line1": address.line1,
        "line2": address.line2,
        "suburb": address.suburb,
        "city": address.city,
        "state": address.state,
        "postcode": address.postcode,
        "country": address.country,
        "is_default": bool(address.is_default),
    }


@router.get("/me")
def me(current_user=Depends(get_current_user)):
    return {
        "user_id": int(current_user.id),
        "tenant_id": int(current_user.tenant_id),
        "full_name": current_user.full_name,
        "mobile_number": current_user.mobile_number,
        "email": current_user.email,
        "role": current_user.role,
        "store_id": int(current_user.store_id) if getattr(current_user, "store_id", None) else None,
        "delivery_partner_id": int(current_user.delivery_partner_id) if getattr(current_user, "delivery_partner_id", None) else None,
    }