from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import AppNotification, Order, OrderItem, User

try:
    from app.services.push_notifications import send_push_notification
except Exception:
    send_push_notification = None


router = APIRouter(prefix="/api/store", tags=["store-orders"])


def _require_store_user(current_user):
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Store access only")

    if not current_user.store_id:
        raise HTTPException(
            status_code=400,
            detail="Store user has no store_id assigned",
        )


def _notify_user(
    db: Session,
    tenant_id: int,
    user_id: int,
    order_id: int,
    title: str,
    message: str,
    notification_type: str,
):
    db.add(
        AppNotification(
            tenant_id=tenant_id,
            user_id=user_id,
            order_id=order_id,
            title=title,
            message=message,
            notification_type=notification_type,
            is_read=False,
        )
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


def _get_store_order_or_404(
    db: Session,
    current_user,
    order_id: int,
):
    order = (
        db.query(Order)
        .filter(
            Order.id == order_id,
            Order.tenant_id == current_user.tenant_id,
            Order.store_id == current_user.store_id,
        )
        .first()
    )

    if not order:
        raise HTTPException(status_code=404, detail="Order not found for this store")

    return order


@router.get("/orders")
def get_store_orders(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_store_user(current_user)

    rows = (
        db.query(
            Order,
            func.count(OrderItem.id).label("items_count"),
        )
        .outerjoin(OrderItem, OrderItem.order_id == Order.id)
        .filter(
            Order.tenant_id == current_user.tenant_id,
            Order.store_id == current_user.store_id,
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
            "customer_mobile": order.customer_mobile,
            "customer_email": order.customer_email,
            "delivery_address_text": order.delivery_address_text,
            "delivery_pincode": order.delivery_pincode,
            "store_id": int(order.store_id) if order.store_id else None,
            "delivery_partner_id": int(order.delivery_partner_id)
            if order.delivery_partner_id
            else None,
            "placed_at": order.placed_at.isoformat() if order.placed_at else None,
            "created_at": order.created_at.isoformat() if order.created_at else None,
        }
        for order, items_count in rows
    ]


@router.get("/orders/{order_id}")
def get_store_order_detail(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_store_user(current_user)

    order = _get_store_order_or_404(db, current_user, order_id)

    items = (
        db.query(OrderItem)
        .filter(
            OrderItem.order_id == order.id,
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
        "customer_mobile": order.customer_mobile,
        "customer_email": order.customer_email,
        "delivery_address_text": order.delivery_address_text,
        "delivery_pincode": order.delivery_pincode,
        "notes": order.notes,
        "store_id": int(order.store_id) if order.store_id else None,
        "delivery_partner_id": int(order.delivery_partner_id)
        if order.delivery_partner_id
        else None,
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


@router.put("/orders/{order_id}/packing")
def mark_order_packing(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_store_user(current_user)

    order = _get_store_order_or_404(db, current_user, order_id)

    if order.payment_status != "SUCCESS":
        raise HTTPException(status_code=400, detail="Payment not successful yet")

    if order.order_status not in ["CONFIRMED", "PAID", "PENDING"]:
        raise HTTPException(
            status_code=400,
            detail=f"Order cannot be marked packing from {order.order_status}",
        )

    order.order_status = "PROCESSING"
    db.commit()
    db.refresh(order)

    return {
        "message": "Order marked as Packing",
        "order_id": int(order.id),
        "order_status": order.order_status,
        "status": order.order_status,
    }


@router.put("/orders/{order_id}/ready")
def mark_order_ready(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_store_user(current_user)

    order = _get_store_order_or_404(db, current_user, order_id)

    if order.order_status != "PROCESSING":
        raise HTTPException(
            status_code=400,
            detail="Only PROCESSING orders can be marked ready",
        )

    order.order_status = "READY"

    _notify_delivery_users_order_ready(db, order)

    db.commit()
    db.refresh(order)

    return {
        "message": "Order marked as Ready",
        "order_id": int(order.id),
        "order_status": order.order_status,
        "status": order.order_status,
    }