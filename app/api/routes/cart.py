from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import Cart, CartItem, Product
from app.schemas.cart import (
    AddCartItemRequest,
    UpdateCartItemRequest,
    RemoveCartItemRequest,
)

router = APIRouter(prefix="/api/cart", tags=["cart"])


def _get_or_create_cart(db: Session, tenant_id: int, user_id: int):
    cart = (
        db.query(Cart)
        .filter(
            Cart.tenant_id == tenant_id,
            Cart.user_id == user_id,
            Cart.status == "ACTIVE",
        )
        .first()
    )

    if not cart:
        cart = Cart(tenant_id=tenant_id, user_id=user_id, status="ACTIVE")
        db.add(cart)
        db.flush()

    return cart


def _get_store_product(
    db: Session,
    tenant_id: int,
    store_id: int,
    product_id: int,
):
    row = db.execute(
        text(
            """
            SELECT
                sp.store_id,
                sp.product_id,
                sp.stock_qty,
                sp.reserved_qty,
                sp.local_price,
                sp.is_active,
                p.product_name,
                p.image_url,
                p.base_price,
                p.sale_price,
                p.is_active AS product_active
            FROM store_products sp
            JOIN products p
              ON p.id = sp.product_id
             AND p.tenant_id = sp.tenant_id
            WHERE sp.tenant_id = :tenant_id
              AND sp.store_id = :store_id
              AND sp.product_id = :product_id
            LIMIT 1
            """
        ),
        {
            "tenant_id": tenant_id,
            "store_id": store_id,
            "product_id": product_id,
        },
    ).mappings().first()

    if not row or not row["is_active"] or not row["product_active"]:
        raise HTTPException(status_code=404, detail="Product not available in this store")

    return row


def _available_stock(row) -> int:
    return int(row["stock_qty"] or 0) - int(row["reserved_qty"] or 0)


def _final_price(row) -> Decimal:
    if row["local_price"] is not None:
        return Decimal(row["local_price"])

    if row["sale_price"] is not None:
        return Decimal(row["sale_price"])

    return Decimal(row["base_price"] or 0)


@router.get("")
def get_cart(
    store_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    cart = (
        db.query(Cart)
        .filter(
            Cart.tenant_id == current_user.tenant_id,
            Cart.user_id == current_user.id,
            Cart.status == "ACTIVE",
        )
        .first()
    )

    if not cart:
        return {"items": [], "total_amount": 0.0}

    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()

    cart_items = []
    total = Decimal("0.00")

    for i in items:
        available_stock = None

        if store_id is not None:
            sp = _get_store_product(
                db=db,
                tenant_id=current_user.tenant_id,
                store_id=store_id,
                product_id=i.product_id,
            )
            available_stock = _available_stock(sp)

        total += Decimal(i.line_total)

        cart_items.append(
            {
                "product_id": int(i.product_id),
                "product_name": i.product_name_snapshot,
                "image_url": i.product_image_snapshot,
                "unit_price": float(i.unit_price_snapshot),
                "quantity": int(i.quantity),
                "line_total": float(i.line_total),
                "available_stock": available_stock,
            }
        )

    return {
        "items": cart_items,
        "total_amount": float(total),
        "store_id": store_id,
    }


@router.post("/add")
def add_to_cart(
    payload: AddCartItemRequest,
    store_id: int = Query(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if payload.quantity <= 0:
        raise HTTPException(status_code=400, detail="Quantity must be greater than zero")

    cart = _get_or_create_cart(db, current_user.tenant_id, current_user.id)

    store_product = _get_store_product(
        db=db,
        tenant_id=current_user.tenant_id,
        store_id=store_id,
        product_id=payload.product_id,
    )

    price = _final_price(store_product)

    item = (
        db.query(CartItem)
        .filter(
            CartItem.cart_id == cart.id,
            CartItem.product_id == payload.product_id,
        )
        .first()
    )

    existing_qty = int(item.quantity) if item else 0
    new_qty = existing_qty + payload.quantity

    if new_qty > _available_stock(store_product):
        raise HTTPException(
            status_code=400,
            detail=f"Only {_available_stock(store_product)} available in this store",
        )

    if item:
        item.quantity = new_qty
        item.unit_price_snapshot = price
        item.line_total = Decimal(new_qty) * price
    else:
        item = CartItem(
            cart_id=cart.id,
            tenant_id=current_user.tenant_id,
            user_id=current_user.id,
            product_id=payload.product_id,
            product_name_snapshot=store_product["product_name"],
            product_image_snapshot=store_product["image_url"],
            unit_price_snapshot=price,
            quantity=payload.quantity,
            line_total=Decimal(payload.quantity) * price,
        )
        db.add(item)

    db.commit()

    return {
        "message": "Added to cart",
        "store_id": store_id,
        "product_id": payload.product_id,
        "quantity": new_qty,
    }


@router.post("/update")
def update_cart(
    payload: UpdateCartItemRequest,
    store_id: int = Query(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    cart = _get_or_create_cart(db, current_user.tenant_id, current_user.id)

    item = (
        db.query(CartItem)
        .filter(
            CartItem.cart_id == cart.id,
            CartItem.product_id == payload.product_id,
        )
        .first()
    )

    if not item:
        raise HTTPException(status_code=404, detail="Cart item not found")

    if payload.quantity <= 0:
        db.delete(item)
        db.commit()
        return {"message": "Cart item removed"}

    store_product = _get_store_product(
        db=db,
        tenant_id=current_user.tenant_id,
        store_id=store_id,
        product_id=payload.product_id,
    )

    if payload.quantity > _available_stock(store_product):
        raise HTTPException(
            status_code=400,
            detail=f"Only {_available_stock(store_product)} available in this store",
        )

    price = _final_price(store_product)

    item.quantity = payload.quantity
    item.unit_price_snapshot = price
    item.line_total = Decimal(payload.quantity) * price

    db.commit()

    return {
        "message": "Cart updated",
        "store_id": store_id,
        "product_id": payload.product_id,
        "quantity": payload.quantity,
    }


@router.post("/remove")
def remove_cart(
    payload: RemoveCartItemRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    cart = _get_or_create_cart(db, current_user.tenant_id, current_user.id)

    item = (
        db.query(CartItem)
        .filter(
            CartItem.cart_id == cart.id,
            CartItem.product_id == payload.product_id,
        )
        .first()
    )

    if item:
        db.delete(item)
        db.commit()

    return {"message": "Removed from cart"}