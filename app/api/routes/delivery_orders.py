from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import Order, OrderItem

router = APIRouter(prefix="/api/delivery", tags=["delivery-orders"])


def _require_delivery_user(current_user):
    if current_user.role != "delivery":
        raise HTTPException(status_code=403, detail="Delivery access only")

    if not current_user.delivery_partner_id:
        raise HTTPException(
            status_code=400,
            detail="Delivery user has no delivery_partner_id assigned",
        )


@router.get("/orders")
def get_delivery_orders(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_delivery_user(current_user)

    rows = (
        db.query(
            Order,
            func.count(OrderItem.id).label("items_count"),
        )
        .outerjoin(OrderItem, OrderItem.order_id == Order.id)
        .filter(
            Order.tenant_id == current_user.tenant_id,
            Order.delivery_partner_id == current_user.delivery_partner_id,
            Order.order_status.in_(["SHIPPED", "OUT_FOR_DELIVERY"]),
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
def get_delivery_order_detail(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_delivery_user(current_user)

    order = (
        db.query(Order)
        .filter(
            Order.id == order_id,
            Order.tenant_id == current_user.tenant_id,
            Order.delivery_partner_id == current_user.delivery_partner_id,
        )
        .first()
    )

    if not order:
        raise HTTPException(status_code=404, detail="Order not found for this delivery user")

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


@router.put("/orders/{order_id}/out-for-delivery")
def mark_out_for_delivery(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_delivery_user(current_user)

    order = (
        db.query(Order)
        .filter(
            Order.id == order_id,
            Order.tenant_id == current_user.tenant_id,
            Order.delivery_partner_id == current_user.delivery_partner_id,
        )
        .first()
    )

    if not order:
        raise HTTPException(status_code=404, detail="Order not found for this delivery user")

    if order.order_status != "SHIPPED":
        raise HTTPException(
            status_code=400,
            detail="Only READY/SHIPPED orders can be marked out for delivery",
        )

    order.order_status = "OUT_FOR_DELIVERY"
    db.commit()

    return {
        "message": "Order marked out for delivery",
        "order_id": int(order.id),
        "order_status": order.order_status,
        "status": order.order_status,
    }


@router.put("/orders/{order_id}/delivered")
def mark_delivered(
    order_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _require_delivery_user(current_user)

    order = (
        db.query(Order)
        .filter(
            Order.id == order_id,
            Order.tenant_id == current_user.tenant_id,
            Order.delivery_partner_id == current_user.delivery_partner_id,
        )
        .first()
    )

    if not order:
        raise HTTPException(status_code=404, detail="Order not found for this delivery user")

    if order.order_status != "OUT_FOR_DELIVERY":
        raise HTTPException(
            status_code=400,
            detail="Only OUT_FOR_DELIVERY orders can be marked delivered",
        )

    order.order_status = "DELIVERED"
    db.commit()

    return {
        "message": "Order delivered",
        "order_id": int(order.id),
        "order_status": order.order_status,
        "status": order.order_status,
    }