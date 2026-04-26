from decimal import Decimal
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, text
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import (
    Cart,
    CartItem,
    NotificationLog,
    Order,
    OrderItem,
    Payment,
)
from app.schemas.cart import CreateOrderRequest, ConfirmPaymentRequest


router = APIRouter(prefix="/api", tags=["orders"])


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
        {
            "tenant_id": tenant_id,
            "store_id": store_id,
        },
    ).mappings().first()

    if not row:
        raise HTTPException(status_code=400, detail="Invalid or inactive store")

    return row


def _reserve_store_stock(
    db: Session,
    tenant_id: int,
    store_id: int,
    product_id: int,
    quantity: int,
):
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
            {
                "tenant_id": tenant_id,
                "product_id": product_id,
            },
        ).mappings().first()

        product_name = product_row["product_name"] if product_row else f"Product {product_id}"

        raise HTTPException(
            status_code=400,
            detail=f"Not enough stock for {product_name}",
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
        raise HTTPException(
            status_code=400,
            detail="store_id is required to place order",
        )

    _validate_store(db, current_user.tenant_id, store_id)

    subtotal = sum(Decimal(i.line_total) for i in items)

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
            subtotal_amount=subtotal,
            tax_amount=Decimal("0.00"),
            delivery_amount=Decimal("0.00"),
            discount_amount=Decimal("0.00"),
            total_amount=subtotal,
            currency_code="AUD",
            delivery_address_text=payload.delivery_address_text,
            customer_mobile=current_user.mobile_number,
            customer_email=payload.customer_email or current_user.email,
            notes=payload.notes,
            placed_at=datetime.utcnow(),
            store_id=store_id,
            delivery_pincode=delivery_pincode,
        )

        db.add(order)
        db.flush()

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
                amount=subtotal,
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

    db.add(
        NotificationLog(
            tenant_id=current_user.tenant_id,
            user_id=current_user.id,
            order_id=order.id,
            channel="EMAIL",
            recipient=order.customer_email or "unknown@example.com",
            subject="Order confirmed",
            message_body=f"Order {order.order_number} confirmed",
            delivery_status="PENDING",
        )
    )

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
        db.query(
            Order,
            func.count(OrderItem.id).label("items_count"),
        )
        .outerjoin(OrderItem, OrderItem.order_id == Order.id)
        .filter(
            Order.user_id == current_user.id,
            Order.tenant_id == current_user.tenant_id,
            Order.order_status.in_(
                ["PENDING", "PAID", "CONFIRMED", "PROCESSING", "SHIPPED"]
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
        db.query(
            Order,
            func.count(OrderItem.id).label("items_count"),
        )
        .outerjoin(OrderItem, OrderItem.order_id == Order.id)
        .filter(
            Order.user_id == current_user.id,
            Order.tenant_id == current_user.tenant_id,
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
            "subtotal_amount": float(order.subtotal_amount),
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


@router.get("/orders/{order_id}")
def order_detail(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    order = (
        db.query(Order)
        .filter(
            Order.id == order_id,
            Order.user_id == current_user.id,
            Order.tenant_id == current_user.tenant_id,
        )
        .first()
    )

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    items = (
        db.query(OrderItem)
        .filter(
            OrderItem.order_id == order.id,
            OrderItem.user_id == current_user.id,
            OrderItem.tenant_id == current_user.tenant_id,
        )
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
        "tax_amount": float(order.tax_amount),
        "delivery_amount": float(order.delivery_amount),
        "discount_amount": float(order.discount_amount),
        "total_amount": float(order.total_amount),
        "currency_code": order.currency_code,
        "store_id": int(order.store_id) if order.store_id else None,
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


@router.get("/me")
def me(current_user=Depends(get_current_user)):
    return {
        "user_id": int(current_user.id),
        "tenant_id": int(current_user.tenant_id),
        "full_name": current_user.full_name,
        "mobile_number": current_user.mobile_number,
        "email": current_user.email,
        "role": current_user.role,
    }