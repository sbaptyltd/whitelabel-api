
from decimal import Decimal
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import Category, Product

router = APIRouter(prefix="/api", tags=["catalog"])

def _to_product_dict(product: Product):
    price = product.sale_price if product.sale_price is not None else product.base_price
    return {
        "id": int(product.id),
        "name": product.product_name,
        "slug": product.product_slug,
        "short_description": product.short_description,
        "long_description": product.long_description,
        "image_url": product.image_url,
        "price": float(price or 0),
        "base_price": float(product.base_price or 0),
        "sale_price": float(product.sale_price) if product.sale_price is not None else None,
        "currency_code": product.currency_code,
        "stock_qty": product.stock_qty,
        "is_featured": bool(product.is_featured),
    }

@router.get("/categories")
def categories(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    rows = db.query(Category).filter(Category.tenant_id == current_user.tenant_id, Category.is_active == True).order_by(Category.sort_order.asc()).all()
    return [{"id": int(r.id), "name": r.category_name, "slug": r.category_slug, "image_url": r.image_url} for r in rows]

@router.get("/products")
def products(featured: bool | None = Query(default=None), db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    q = db.query(Product).filter(Product.tenant_id == current_user.tenant_id, Product.is_active == True)
    if featured is True:
        q = q.filter(Product.is_featured == True)
    rows = q.order_by(Product.id.desc()).all()
    return [_to_product_dict(r) for r in rows]

@router.get("/products/{product_id}")
def product_by_id(product_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    row = db.query(Product).filter(Product.id == product_id, Product.tenant_id == current_user.tenant_id, Product.is_active == True).first()
    if not row:
        raise HTTPException(status_code=404, detail="Product not found")
    return _to_product_dict(row)
