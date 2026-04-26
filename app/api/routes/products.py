from fastapi import APIRouter, Depends, Query, HTTPException

from sqlalchemy.orm import Session
from sqlalchemy import or_, func, text

import os
from datetime import timedelta

import google.auth
from google.auth.transport.requests import Request
from google.cloud import storage

from app.db.session import get_db
from app.models.commerce import Category, Product, Tenant

router = APIRouter(prefix="/api", tags=["catalog"])
storage_client = storage.Client()


def _signed_url_from_gs_uri(gs_uri: str | None) -> str | None:
    if not gs_uri:
        return None

    if not gs_uri.startswith("gs://"):
        return gs_uri

    try:
        path = gs_uri.replace("gs://", "", 1)
        bucket_name, blob_name = path.split("/", 1)

        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)

        credentials, _ = google.auth.default(
            scopes=["https://www.googleapis.com/auth/cloud-platform"]
        )

        credentials.refresh(Request())

        service_account_email = os.getenv(
            "SIGNED_URL_SERVICE_ACCOUNT",
            "184732521634-compute@developer.gserviceaccount.com",
        )

        return blob.generate_signed_url(
            version="v4",
            expiration=timedelta(hours=6),
            method="GET",
            service_account_email=service_account_email,
            access_token=credentials.token,
        )

    except Exception as e:
        print(f"Signed URL failed for {gs_uri}: {e}")
        return None


def _get_tenant_by_code(db: Session, tenant_code: str):
    tenant = (
        db.query(Tenant)
        .filter(Tenant.tenant_code == tenant_code, Tenant.app_status == "ACTIVE")
        .first()
    )
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    return tenant


def _to_product_dict(
    product: Product,
    category_name: str | None = None,
    store_stock_qty: int | None = None,
    reserved_qty: int | None = None,
    local_price=None,
):
    default_price = product.sale_price if product.sale_price is not None else product.base_price
    final_price = local_price if local_price is not None else default_price

    stock_qty = store_stock_qty if store_stock_qty is not None else product.stock_qty
    reserved = reserved_qty if reserved_qty is not None else 0
    available_stock = max((stock_qty or 0) - (reserved or 0), 0)

    image_url = _signed_url_from_gs_uri(product.image_url)

    return {
        "id": int(product.id),
        "tenant_id": int(product.tenant_id),
        "category_id": int(product.category_id) if product.category_id is not None else None,
        "category_name": category_name,
        "product_name": product.product_name,
        "name": product.product_name,
        "slug": product.product_slug,
        "short_description": product.short_description,
        "long_description": product.long_description,
        "brand_name": product.brand_name,
        "image_url": image_url,
        "price": float(final_price or 0),
        "base_price": float(product.base_price or 0),
        "sale_price": float(product.sale_price) if product.sale_price is not None else None,
        "local_price": float(local_price) if local_price is not None else None,
        "currency_code": product.currency_code,
        "stock_qty": int(stock_qty or 0),
        "reserved_qty": int(reserved or 0),
        "available_stock": int(available_stock),
        "is_featured": bool(product.is_featured),
        "is_active": bool(product.is_active),
    }


@router.get("/categories")
def categories(
    tenant_code: str = Query(...),
    db: Session = Depends(get_db),
):
    tenant = _get_tenant_by_code(db, tenant_code)

    rows = (
        db.query(Category)
        .filter(
            Category.tenant_id == tenant.id,
            Category.is_active == True,
        )
        .order_by(Category.sort_order.asc(), Category.id.asc())
        .all()
    )

    return [
        {
            "id": int(r.id),
            "name": r.category_name,
            "category_name": r.category_name,
            "slug": r.category_slug,
            "image_url": r.image_url,
        }
        for r in rows
    ]


@router.get("/products")
def products(
    tenant_code: str = Query(...),
    store_id: int | None = Query(default=None),
    featured: bool | None = Query(default=None),
    category_id: int | None = Query(default=None),
    search: str | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    tenant = _get_tenant_by_code(db, tenant_code)
    offset = (page - 1) * page_size

    # New store-wise inventory path
    if store_id is not None:
        where_clauses = [
            "p.tenant_id = :tenant_id",
            "p.is_active = 1",
            "sp.tenant_id = :tenant_id",
            "sp.store_id = :store_id",
            "sp.is_active = 1",
            "(sp.stock_qty - sp.reserved_qty) > 0",
        ]

        params = {
            "tenant_id": tenant.id,
            "store_id": store_id,
            "limit": page_size,
            "offset": offset,
        }

        if featured is True:
            where_clauses.append("p.is_featured = 1")

        if category_id is not None:
            where_clauses.append("p.category_id = :category_id")
            params["category_id"] = category_id

        if search and search.strip():
            where_clauses.append(
                """
                (
                    p.product_name LIKE :search
                    OR p.brand_name LIKE :search
                    OR p.short_description LIKE :search
                    OR p.long_description LIKE :search
                )
                """
            )
            params["search"] = f"%{search.strip()}%"

        where_sql = " AND ".join(where_clauses)

        count_sql = text(
            f"""
            SELECT COUNT(*) AS total
            FROM products p
            JOIN store_products sp
              ON sp.product_id = p.id
             AND sp.tenant_id = p.tenant_id
            LEFT JOIN categories c
              ON c.id = p.category_id
            WHERE {where_sql}
            """
        )

        total = db.execute(count_sql, params).scalar() or 0

        data_sql = text(
            f"""
            SELECT
                p.id,
                p.tenant_id,
                p.category_id,
                c.category_name,
                p.product_name,
                p.brand_name,
                p.product_slug,
                p.short_description,
                p.long_description,
                p.sku,
                p.barcode,
                p.image_url,
                p.gallery_json,
                p.base_price,
                p.sale_price,
                p.currency_code,
                p.is_featured,
                p.is_active,
                sp.stock_qty,
                sp.reserved_qty,
                sp.local_price,
                (sp.stock_qty - sp.reserved_qty) AS available_stock
            FROM products p
            JOIN store_products sp
              ON sp.product_id = p.id
             AND sp.tenant_id = p.tenant_id
            LEFT JOIN categories c
              ON c.id = p.category_id
            WHERE {where_sql}
            ORDER BY p.id DESC
            LIMIT :limit OFFSET :offset
            """
        )

        rows = db.execute(data_sql, params).mappings().all()

        items = []
        for r in rows:
            image_url = _signed_url_from_gs_uri(r["image_url"])

            default_price = (
                r["sale_price"] if r["sale_price"] is not None else r["base_price"]
            )
            final_price = (
                r["local_price"] if r["local_price"] is not None else default_price
            )

            items.append(
                {
                    "id": int(r["id"]),
                    "tenant_id": int(r["tenant_id"]),
                    "category_id": int(r["category_id"]) if r["category_id"] is not None else None,
                    "category_name": r["category_name"],
                    "product_name": r["product_name"],
                    "name": r["product_name"],
                    "slug": r["product_slug"],
                    "short_description": r["short_description"],
                    "long_description": r["long_description"],
                    "brand_name": r["brand_name"],
                    "image_url": image_url,
                    "price": float(final_price or 0),
                    "base_price": float(r["base_price"] or 0),
                    "sale_price": float(r["sale_price"]) if r["sale_price"] is not None else None,
                    "local_price": float(r["local_price"]) if r["local_price"] is not None else None,
                    "currency_code": r["currency_code"],
                    "stock_qty": int(r["stock_qty"] or 0),
                    "reserved_qty": int(r["reserved_qty"] or 0),
                    "available_stock": int(r["available_stock"] or 0),
                    "is_featured": bool(r["is_featured"]),
                    "is_active": bool(r["is_active"]),
                }
            )

        return {
            "items": items,
            "page": page,
            "page_size": page_size,
            "has_more": offset + len(items) < total,
            "total": total,
            "store_id": store_id,
        }

    # Old fallback path when store_id is not passed
    query = (
        db.query(Product, Category.category_name)
        .outerjoin(Category, Product.category_id == Category.id)
        .filter(
            Product.tenant_id == tenant.id,
            Product.is_active == True,
        )
    )

    if featured is True:
        query = query.filter(Product.is_featured == True)

    if category_id is not None:
        query = query.filter(Product.category_id == category_id)

    if search and search.strip():
        term = f"%{search.strip()}%"
        query = query.filter(
            or_(
                Product.product_name.ilike(term),
                Product.brand_name.ilike(term),
                Product.short_description.ilike(term),
                Product.long_description.ilike(term),
            )
        )

    total = query.with_entities(func.count(Product.id)).scalar() or 0

    rows = (
        query.order_by(Product.id.desc())
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
        "store_id": None,
    }


@router.get("/products/{product_id}")
def product_by_id(
    product_id: int,
    tenant_code: str = Query(...),
    store_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
):
    tenant = _get_tenant_by_code(db, tenant_code)

    if store_id is not None:
        sql = text(
            """
            SELECT
                p.id,
                p.tenant_id,
                p.category_id,
                c.category_name,
                p.product_name,
                p.brand_name,
                p.product_slug,
                p.short_description,
                p.long_description,
                p.image_url,
                p.base_price,
                p.sale_price,
                p.currency_code,
                p.is_featured,
                p.is_active,
                sp.stock_qty,
                sp.reserved_qty,
                sp.local_price,
                (sp.stock_qty - sp.reserved_qty) AS available_stock
            FROM products p
            JOIN store_products sp
              ON sp.product_id = p.id
             AND sp.tenant_id = p.tenant_id
            LEFT JOIN categories c
              ON c.id = p.category_id
            WHERE p.id = :product_id
              AND p.tenant_id = :tenant_id
              AND p.is_active = 1
              AND sp.store_id = :store_id
              AND sp.is_active = 1
            LIMIT 1
            """
        )

        r = db.execute(
            sql,
            {
                "product_id": product_id,
                "tenant_id": tenant.id,
                "store_id": store_id,
            },
        ).mappings().first()

        if not r:
            raise HTTPException(status_code=404, detail="Product not found for this store")

        image_url = _signed_url_from_gs_uri(r["image_url"])
        default_price = r["sale_price"] if r["sale_price"] is not None else r["base_price"]
        final_price = r["local_price"] if r["local_price"] is not None else default_price

        return {
            "id": int(r["id"]),
            "tenant_id": int(r["tenant_id"]),
            "category_id": int(r["category_id"]) if r["category_id"] is not None else None,
            "category_name": r["category_name"],
            "product_name": r["product_name"],
            "name": r["product_name"],
            "slug": r["product_slug"],
            "short_description": r["short_description"],
            "long_description": r["long_description"],
            "brand_name": r["brand_name"],
            "image_url": image_url,
            "price": float(final_price or 0),
            "base_price": float(r["base_price"] or 0),
            "sale_price": float(r["sale_price"]) if r["sale_price"] is not None else None,
            "local_price": float(r["local_price"]) if r["local_price"] is not None else None,
            "currency_code": r["currency_code"],
            "stock_qty": int(r["stock_qty"] or 0),
            "reserved_qty": int(r["reserved_qty"] or 0),
            "available_stock": int(r["available_stock"] or 0),
            "is_featured": bool(r["is_featured"]),
            "is_active": bool(r["is_active"]),
            "store_id": store_id,
        }

    row = (
        db.query(Product, Category.category_name)
        .outerjoin(Category, Product.category_id == Category.id)
        .filter(
            Product.id == product_id,
            Product.tenant_id == tenant.id,
            Product.is_active == True,
        )
        .first()
    )

    if not row:
        raise HTTPException(status_code=404, detail="Product not found")

    product, category_name = row
    return _to_product_dict(product, category_name)