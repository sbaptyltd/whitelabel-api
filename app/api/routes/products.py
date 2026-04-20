from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import Category, Product

router = APIRouter(prefix="/api", tags=["catalog"])


def _to_product_dict(product: Product, category_name: str | None = None):
    price = product.sale_price if product.sale_price is not None else product.base_price
    return {
        "id": int(product.id),
        "category_id": int(product.category_id) if product.category_id is not None else None,
        "category_name": category_name,
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
    rows = (
        db.query(Category)
        .filter(
            Category.tenant_id == current_user.tenant_id,
            Category.is_active == True,
        )
        .order_by(Category.sort_order.asc(), Category.category_name.asc())
        .all()
    )
    return [
        {
            "id": int(r.id),
            "name": r.category_name,
            "slug": r.category_slug,
            "image_url": r.image_url,
        }
        for r in rows
    ]


@router.get("/products")
def products(
    featured: bool | None = Query(default=None),
    category_id: int | None = Query(default=None),
    search: str | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    query = (
        db.query(Product, Category.category_name)
        .outerjoin(
            Category,
            (Category.id == Product.category_id)
            & (Category.tenant_id == current_user.tenant_id),
        )
        .filter(
            Product.tenant_id == current_user.tenant_id,
            Product.is_active == True,
        )
    )

    if featured is True:
        query = query.filter(Product.is_featured == True)

    if category_id is not None:
        query = query.filter(Product.category_id == category_id)

    cleaned_search = (search or "").strip()
    if cleaned_search:
        search_term = f"%{cleaned_search}%"
        query = query.filter(
            or_(
                Product.product_name.ilike(search_term),
                Product.product_slug.ilike(search_term),
                Product.brand_name.ilike(search_term),
                Product.short_description.ilike(search_term),
            )
        )

    total = query.count()
    offset = (page - 1) * page_size
    rows = (
        query.order_by(Product.sort_order.asc(), Product.id.desc())
        .offset(offset)
        .limit(page_size)
        .all()
    )

    items = [_to_product_dict(product, category_name) for product, category_name in rows]

    return {
        "items": items,
        "page": page,
        "page_size": page_size,
        "has_more": offset + len(items) < total,
        "total": total,
    }


@router.get("/products/{product_id}")
def product_by_id(product_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    row = (
        db.query(Product, Category.category_name)
        .outerjoin(
            Category,
            (Category.id == Product.category_id)
            & (Category.tenant_id == current_user.tenant_id),
        )
        .filter(
            Product.id == product_id,
            Product.tenant_id == current_user.tenant_id,
            Product.is_active == True,
        )
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="Product not found")
    product, category_name = row
    return _to_product_dict(product, category_name)
