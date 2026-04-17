from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import asc, desc, or_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import Category, Product
from app.schemas.product_admin import (
    ProductAdminCreate,
    ProductAdminResponse,
    ProductAdminUpdate,
)

router = APIRouter(prefix="/api/products/admin", tags=["products_admin"])


def _ensure_super_user(current_user):
    if getattr(current_user, "role", "user") != "super_user":
        raise HTTPException(status_code=403, detail="Access denied")
    
@router.get("", response_model=list[ProductAdminResponse])
def list_products_admin(
    search: Optional[str] = Query(default=None),
    category_id: Optional[int] = Query(default=None),
    is_active: Optional[bool] = Query(default=None),
    is_featured: Optional[bool] = Query(default=None),
    sort_by: str = Query(default="sort_order"),
    sort_dir: str = Query(default="asc"),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _ensure_super_user(current_user)
    query = db.query(Product).filter(Product.tenant_id == current_user.tenant_id)

    if search:
        search_term = f"%{search}%"
        query = query.filter(
            or_(
                Product.product_name.ilike(search_term),
                Product.product_slug.ilike(search_term),
                Product.sku.ilike(search_term),
                Product.brand_name.ilike(search_term),
            )
        )

    if category_id is not None:
        query = query.filter(Product.category_id == category_id)

    if is_active is not None:
        query = query.filter(Product.is_active == is_active)

    if is_featured is not None:
        query = query.filter(Product.is_featured == is_featured)

    sort_column = {
        "product_name": Product.product_name,
        "created_at": Product.created_at,
        "updated_at": Product.updated_at,
        "sort_order": Product.sort_order,
        "base_price": Product.base_price,
        "stock_qty": Product.stock_qty,
    }.get(sort_by, Product.sort_order)

    query = query.order_by(
        desc(sort_column) if sort_dir.lower() == "desc" else asc(sort_column)
    )

    return query.all()


@router.get("/{product_id}", response_model=ProductAdminResponse)
def get_product_admin(
    product_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    product = (
        db.query(Product)
        .filter(
            Product.id == product_id,
            Product.tenant_id == current_user.tenant_id,
        )
        .first()
    )

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    return product


@router.post("", response_model=ProductAdminResponse)
def create_product_admin(
    payload: ProductAdminCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if payload.category_id is not None:
        category = (
            db.query(Category)
            .filter(
                Category.id == payload.category_id,
                Category.tenant_id == current_user.tenant_id,
            )
            .first()
        )
        if not category:
            raise HTTPException(status_code=400, detail="Invalid category_id")

    product = Product(
        tenant_id=current_user.tenant_id,
        category_id=payload.category_id,
        sort_order=payload.sort_order,
        product_name=payload.product_name.strip(),
        brand_name=payload.brand_name.strip() if payload.brand_name else None,
        product_slug=payload.product_slug.strip().lower(),
        short_description=payload.short_description,
        long_description=payload.long_description,
        sku=payload.sku.strip() if payload.sku else None,
        barcode=payload.barcode.strip() if payload.barcode else None,
        image_url=payload.image_url,
        gallery_json=payload.gallery_json,
        base_price=payload.base_price,
        sale_price=payload.sale_price,
        currency_code=payload.currency_code.upper(),
        stock_qty=payload.stock_qty,
        is_featured=payload.is_featured,
        is_active=payload.is_active,
    )

    try:
        db.add(product)
        db.commit()
        db.refresh(product)
        return product
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail="Product slug or SKU already exists for this tenant",
        )


@router.put("/{product_id}", response_model=ProductAdminResponse)
def update_product_admin(
    product_id: int,
    payload: ProductAdminUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    product = (
        db.query(Product)
        .filter(
            Product.id == product_id,
            Product.tenant_id == current_user.tenant_id,
        )
        .first()
    )

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    update_data = payload.model_dump(exclude_unset=True)

    if "category_id" in update_data and update_data["category_id"] is not None:
        category = (
            db.query(Category)
            .filter(
                Category.id == update_data["category_id"],
                Category.tenant_id == current_user.tenant_id,
            )
            .first()
        )
        if not category:
            raise HTTPException(status_code=400, detail="Invalid category_id")

    if "product_name" in update_data and update_data["product_name"] is not None:
        update_data["product_name"] = update_data["product_name"].strip()

    if "brand_name" in update_data and update_data["brand_name"] is not None:
        update_data["brand_name"] = update_data["brand_name"].strip()

    if "product_slug" in update_data and update_data["product_slug"] is not None:
        update_data["product_slug"] = update_data["product_slug"].strip().lower()

    if "sku" in update_data and update_data["sku"] is not None:
        update_data["sku"] = update_data["sku"].strip()

    if "barcode" in update_data and update_data["barcode"] is not None:
        update_data["barcode"] = update_data["barcode"].strip()

    if "currency_code" in update_data and update_data["currency_code"] is not None:
        update_data["currency_code"] = update_data["currency_code"].upper()

    for field, value in update_data.items():
        setattr(product, field, value)

    try:
        db.commit()
        db.refresh(product)
        return product
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail="Product slug or SKU already exists for this tenant",
        )


@router.delete("/{product_id}")
def delete_product_admin(
    product_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    product = (
        db.query(Product)
        .filter(
            Product.id == product_id,
            Product.tenant_id == current_user.tenant_id,
        )
        .first()
    )

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    db.delete(product)
    db.commit()

    return {"message": "Product deleted successfully"}