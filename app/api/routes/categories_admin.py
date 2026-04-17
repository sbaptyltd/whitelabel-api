from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import asc, desc
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import Category
from app.schemas.category_admin import (
    CategoryAdminCreate,
    CategoryAdminResponse,
    CategoryAdminUpdate,
)

def _ensure_super_user(current_user):
    if getattr(current_user, "role", "user") != "super_user":
        raise HTTPException(status_code=403, detail="Access denied")
    
router = APIRouter(prefix="/api/categories/admin", tags=["categories_admin"])


@router.get("", response_model=list[CategoryAdminResponse])
def list_categories_admin(
    search: Optional[str] = Query(default=None),
    is_active: Optional[bool] = Query(default=None),
    sort_by: str = Query(default="sort_order"),
    sort_dir: str = Query(default="asc"),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    _ensure_super_user(current_user)
    query = db.query(Category).filter(Category.tenant_id == current_user.tenant_id)

    if search:
        query = query.filter(Category.category_name.ilike(f"%{search}%"))

    if is_active is not None:
        query = query.filter(Category.is_active == is_active)

    sort_column = {
        "category_name": Category.category_name,
        "created_at": Category.created_at,
        "updated_at": Category.updated_at,
        "sort_order": Category.sort_order,
    }.get(sort_by, Category.sort_order)

    query = query.order_by(
        desc(sort_column) if sort_dir.lower() == "desc" else asc(sort_column)
    )

    return query.all()


@router.get("/{category_id}", response_model=CategoryAdminResponse)
def get_category_admin(
    category_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    category = (
        db.query(Category)
        .filter(
            Category.id == category_id,
            Category.tenant_id == current_user.tenant_id,
        )
        .first()
    )

    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    return category


@router.post("", response_model=CategoryAdminResponse)
def create_category_admin(
    payload: CategoryAdminCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    category = Category(
        tenant_id=current_user.tenant_id,
        category_name=payload.category_name.strip(),
        category_slug=payload.category_slug.strip().lower(),
        description=payload.description,
        image_url=payload.image_url,
        sort_order=payload.sort_order,
        is_active=payload.is_active,
    )

    try:
        db.add(category)
        db.commit()
        db.refresh(category)
        return category
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail="Category slug already exists for this tenant",
        )


@router.put("/{category_id}", response_model=CategoryAdminResponse)
def update_category_admin(
    category_id: int,
    payload: CategoryAdminUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    category = (
        db.query(Category)
        .filter(
            Category.id == category_id,
            Category.tenant_id == current_user.tenant_id,
        )
        .first()
    )

    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    update_data = payload.model_dump(exclude_unset=True)

    if "category_name" in update_data and update_data["category_name"] is not None:
        update_data["category_name"] = update_data["category_name"].strip()

    if "category_slug" in update_data and update_data["category_slug"] is not None:
        update_data["category_slug"] = update_data["category_slug"].strip().lower()

    for field, value in update_data.items():
        setattr(category, field, value)

    try:
        db.commit()
        db.refresh(category)
        return category
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail="Category slug already exists for this tenant",
        )


@router.delete("/{category_id}")
def delete_category_admin(
    category_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    category = (
        db.query(Category)
        .filter(
            Category.id == category_id,
            Category.tenant_id == current_user.tenant_id,
        )
        .first()
    )

    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    db.delete(category)
    db.commit()

    return {"message": "Category deleted successfully"}