
from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import Cart, CartItem, Product
from app.schemas.cart import AddCartItemRequest, UpdateCartItemRequest, RemoveCartItemRequest

router = APIRouter(prefix="/api/cart", tags=["cart"])

def _get_or_create_cart(db: Session, tenant_id: int, user_id: int):
    cart = db.query(Cart).filter(Cart.tenant_id == tenant_id, Cart.user_id == user_id, Cart.status == "ACTIVE").first()
    if not cart:
        cart = Cart(tenant_id=tenant_id, user_id=user_id, status="ACTIVE")
        db.add(cart)
        db.flush()
    return cart

@router.get("")
def get_cart(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    cart = db.query(Cart).filter(Cart.tenant_id == current_user.tenant_id, Cart.user_id == current_user.id, Cart.status == "ACTIVE").first()
    if not cart:
        return {"items": [], "total_amount": 0.0}
    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()
    return {
        "items": [{
            "product_id": int(i.product_id),
            "product_name": i.product_name_snapshot,
            "image_url": i.product_image_snapshot,
            "unit_price": float(i.unit_price_snapshot),
            "quantity": i.quantity,
            "line_total": float(i.line_total),
        } for i in items],
        "total_amount": float(sum(i.line_total for i in items))
    }

@router.post("/add")
def add_to_cart(payload: AddCartItemRequest, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    cart = _get_or_create_cart(db, current_user.tenant_id, current_user.id)
    product = db.query(Product).filter(Product.id == payload.product_id, Product.tenant_id == current_user.tenant_id, Product.is_active == True).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    price = product.sale_price if product.sale_price is not None else product.base_price
    item = db.query(CartItem).filter(CartItem.cart_id == cart.id, CartItem.product_id == product.id).first()
    if item:
        item.quantity += payload.quantity
        item.line_total = Decimal(item.quantity) * Decimal(price)
    else:
        item = CartItem(
            cart_id=cart.id,
            tenant_id=current_user.tenant_id,
            user_id=current_user.id,
            product_id=product.id,
            product_name_snapshot=product.product_name,
            product_image_snapshot=product.image_url,
            unit_price_snapshot=price,
            quantity=payload.quantity,
            line_total=Decimal(payload.quantity) * Decimal(price),
        )
        db.add(item)
    db.commit()
    return {"message": "Added to cart"}

@router.post("/update")
def update_cart(payload: UpdateCartItemRequest, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    cart = _get_or_create_cart(db, current_user.tenant_id, current_user.id)
    item = db.query(CartItem).filter(CartItem.cart_id == cart.id, CartItem.product_id == payload.product_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Cart item not found")
    if payload.quantity <= 0:
        db.delete(item)
    else:
        item.quantity = payload.quantity
        item.line_total = Decimal(payload.quantity) * Decimal(item.unit_price_snapshot)
    db.commit()
    return {"message": "Cart updated"}

@router.post("/remove")
def remove_cart(payload: RemoveCartItemRequest, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    cart = _get_or_create_cart(db, current_user.tenant_id, current_user.id)
    item = db.query(CartItem).filter(CartItem.cart_id == cart.id, CartItem.product_id == payload.product_id).first()
    if item:
        db.delete(item)
        db.commit()
    return {"message": "Removed from cart"}
