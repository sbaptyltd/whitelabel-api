from fastapi import APIRouter, Depends, Query, HTTPException

from sqlalchemy.orm import Session
from sqlalchemy import bindparam, or_, func, text

import os
import json
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


def _public_url_from_gs_uri(gs_uri: str | None) -> str | None:
    if not gs_uri:
        return None

    if not gs_uri.startswith("gs://"):
        return gs_uri

    try:
        path = gs_uri.replace("gs://", "", 1)
        bucket_name, blob_name = path.split("/", 1)
        return f"https://storage.googleapis.com/{bucket_name}/{blob_name}"
    except Exception as e:
        print(f"Public URL conversion failed for {gs_uri}: {e}")
        return None


def _image_url_from_gs_uri(gs_uri: str | None) -> str | None:
    use_public = os.getenv("GCS_PUBLIC_IMAGES", "false").lower() == "true"

    if use_public:
        return _public_url_from_gs_uri(gs_uri)

    return _signed_url_from_gs_uri(gs_uri)


def _gallery_urls_from_json(raw_gallery) -> list[str]:
    """Return gallery image URLs from products.gallery_json.

    Supports MySQL JSON returned as a Python list, JSON string, comma-separated
    string, or list of objects like {"url": "..."}. Also converts gs:// paths
    to public/signed URLs using the same image helper as image_url.
    """
    if not raw_gallery:
        return []

    gallery = raw_gallery

    if isinstance(gallery, str):
        gallery = gallery.strip()
        if not gallery:
            return []

        try:
            gallery = json.loads(gallery)
        except Exception:
            gallery = [x.strip() for x in gallery.split(",") if x.strip()]

    if not isinstance(gallery, list):
        return []

    urls: list[str] = []

    for item in gallery:
        value = None

        if isinstance(item, str):
            value = item
        elif isinstance(item, dict):
            value = item.get("image_url") or item.get("url") or item.get("src")

        if not value:
            continue

        final_url = _image_url_from_gs_uri(str(value).strip())
        if final_url and final_url not in urls:
            urls.append(final_url)

    return urls


def _get_tenant_by_code(db: Session, tenant_code: str):
    tenant = (
        db.query(Tenant)
        .filter(Tenant.tenant_code == tenant_code, Tenant.app_status == "ACTIVE")
        .first()
    )
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    return tenant


def _eta_text(min_days, max_days, delivery_name: str | None = None) -> str:
    min_days = int(min_days or 0)
    max_days = int(max_days or 0)

    if min_days == 0 and max_days == 0:
        return "Today"

    if min_days == max_days:
        return f"{min_days} business day" if min_days == 1 else f"{min_days} business days"

    return f"{min_days}-{max_days} business days"


def _delivery_options_for_product_store(
    db: Session,
    tenant_id: int,
    store_id: int,
    product_id: int,
):
    rows = db.execute(
        text(
            """
            SELECT
                pdo.id AS delivery_option_id,
                pdo.delivery_fee,
                pdo.is_free,
                pdo.cutoff_time,
                dm.id AS delivery_method_id,
                dm.code AS delivery_method_code,
                dm.name AS delivery_method_name,
                dm.description AS delivery_description,
                dm.min_days,
                dm.max_days
            FROM product_delivery_options pdo
            JOIN delivery_methods dm
              ON dm.id = pdo.delivery_method_id
             AND dm.tenant_id = pdo.tenant_id
            WHERE pdo.tenant_id = :tenant_id
              AND pdo.store_id = :store_id
              AND pdo.product_id = :product_id
              AND pdo.is_active = 1
              AND dm.is_active = 1
            ORDER BY
              CASE dm.code
                WHEN 'EXPRESS' THEN 1
                WHEN 'STANDARD' THEN 2
                WHEN 'ECONOMY' THEN 3
                WHEN 'CLICK_COLLECT' THEN 4
                ELSE 9
              END,
              pdo.delivery_fee ASC
            """
        ),
        {
            "tenant_id": tenant_id,
            "store_id": store_id,
            "product_id": product_id,
        },
    ).mappings().all()

    options = []

    for r in rows:
        eta = _eta_text(r["min_days"], r["max_days"], r["delivery_method_name"])
        fee = float(r["delivery_fee"] or 0)
        is_free = bool(r["is_free"]) or fee == 0

        options.append(
            {
                "delivery_option_id": int(r["delivery_option_id"]),
                "delivery_method_id": int(r["delivery_method_id"]),
                "code": r["delivery_method_code"],
                "name": r["delivery_method_name"],
                "description": r["delivery_description"],
                "fee": fee,
                "delivery_fee": fee,
                "is_free": is_free,
                "eta": eta,
                "eta_text": eta,
                "min_days": int(r["min_days"] or 0),
                "max_days": int(r["max_days"] or 0),
                "cutoff_time": str(r["cutoff_time"]) if r["cutoff_time"] is not None else None,
            }
        )

    return options


def _size_counts_for_products(
    db: Session,
    tenant_id: int,
    product_ids: list[int],
) -> dict[int, int]:
    """Return active Size option-value counts for a page of products."""
    unique_product_ids = sorted(set(product_ids))
    if not unique_product_ids:
        return {}

    statement = text(
        """
        SELECT
            po.product_id,
            COUNT(DISTINCT pov.id) AS size_count
        FROM product_options po
        JOIN product_option_values pov
          ON pov.option_id = po.id
         AND pov.tenant_id = po.tenant_id
         AND pov.is_active = 1
        WHERE po.tenant_id = :tenant_id
          AND po.product_id IN :product_ids
          AND po.is_active = 1
          AND LOWER(TRIM(po.option_name)) IN ('size', 'sizes')
        GROUP BY po.product_id
        """
    ).bindparams(bindparam("product_ids", expanding=True))

    rows = db.execute(
        statement,
        {
            "tenant_id": tenant_id,
            "product_ids": unique_product_ids,
        },
    ).mappings().all()

    return {
        int(row["product_id"]): int(row["size_count"] or 0)
        for row in rows
    }



def _variant_payload_for_product(
    db: Session,
    tenant_id: int,
    product_id: int,
    store_id: int | None = None,
):
    """Return selectable options and purchasable variants for one product.

    When store_id is supplied, price/stock come from store_product_variants.
    A variant that is not mapped to that store is returned with zero store stock
    so the UI can show it as unavailable instead of overselling it.
    """

    option_rows = db.execute(
        text(
            """
            SELECT
                po.id AS option_id,
                po.option_name,
                po.display_type,
                po.sort_order AS option_sort_order,
                pov.id AS option_value_id,
                pov.option_value,
                pov.swatch_hex,
                pov.image_url AS option_value_image_url,
                pov.sort_order AS value_sort_order
            FROM product_options po
            LEFT JOIN product_option_values pov
              ON pov.option_id = po.id
             AND pov.tenant_id = po.tenant_id
             AND pov.is_active = 1
            WHERE po.tenant_id = :tenant_id
              AND po.product_id = :product_id
              AND po.is_active = 1
            ORDER BY
                po.sort_order ASC,
                po.id ASC,
                pov.sort_order ASC,
                pov.id ASC
            """
        ),
        {
            "tenant_id": tenant_id,
            "product_id": product_id,
        },
    ).mappings().all()

    options_by_id = {}
    for r in option_rows:
        option_id = int(r["option_id"])

        if option_id not in options_by_id:
            options_by_id[option_id] = {
                "id": option_id,
                "option_id": option_id,
                "name": r["option_name"],
                "option_name": r["option_name"],
                "display_type": r["display_type"] or "TEXT",
                "sort_order": int(r["option_sort_order"] or 0),
                "values": [],
            }

        if r["option_value_id"] is not None:
            options_by_id[option_id]["values"].append(
                {
                    "id": int(r["option_value_id"]),
                    "option_value_id": int(r["option_value_id"]),
                    "value": r["option_value"],
                    "option_value": r["option_value"],
                    "swatch_hex": r["swatch_hex"],
                    "image_url": _image_url_from_gs_uri(r["option_value_image_url"]),
                    "sort_order": int(r["value_sort_order"] or 0),
                }
            )

    options = list(options_by_id.values())

    params = {
        "tenant_id": tenant_id,
        "product_id": product_id,
    }

    if store_id is not None:
        params["store_id"] = store_id
        store_select = """
            spv.id AS store_variant_id,
            spv.stock_qty AS store_stock_qty,
            spv.reserved_qty AS store_reserved_qty,
            spv.local_price AS store_local_price,
        """
        store_join = """
            LEFT JOIN store_product_variants spv
              ON spv.product_variant_id = pv.id
             AND spv.tenant_id = pv.tenant_id
             AND spv.store_id = :store_id
             AND spv.is_active = 1
        """
    else:
        store_select = """
            NULL AS store_variant_id,
            NULL AS store_stock_qty,
            NULL AS store_reserved_qty,
            NULL AS store_local_price,
        """
        store_join = ""

    variant_rows = db.execute(
        text(
            f"""
            SELECT
                pv.id AS variant_id,
                pv.variant_title,
                pv.sku,
                pv.barcode,
                pv.base_price,
                pv.sale_price,
                pv.currency_code,
                pv.stock_qty AS variant_stock_qty,
                pv.image_url,
                pv.gallery_json,
                pv.weight_grams,
                pv.delivery_surcharge,
                pv.sort_order,
                pv.is_default,
                pv.is_active,
                {store_select}
                pvv.option_id,
                pvv.option_value_id,
                po.option_name,
                pov.option_value
            FROM product_variants pv
            {store_join}
            LEFT JOIN product_variant_values pvv
              ON pvv.variant_id = pv.id
            LEFT JOIN product_options po
              ON po.id = pvv.option_id
             AND po.tenant_id = pv.tenant_id
            LEFT JOIN product_option_values pov
              ON pov.id = pvv.option_value_id
             AND pov.option_id = pvv.option_id
             AND pov.tenant_id = pv.tenant_id
            WHERE pv.tenant_id = :tenant_id
              AND pv.product_id = :product_id
              AND pv.is_active = 1
            ORDER BY
                pv.sort_order ASC,
                pv.id ASC,
                po.sort_order ASC,
                po.id ASC
            """
        ),
        params,
    ).mappings().all()

    variants_by_id = {}

    for r in variant_rows:
        variant_id = int(r["variant_id"])

        if variant_id not in variants_by_id:
            if store_id is not None:
                mapped_to_store = r["store_variant_id"] is not None
                stock_qty = int(r["store_stock_qty"] or 0) if mapped_to_store else 0
                reserved_qty = int(r["store_reserved_qty"] or 0) if mapped_to_store else 0
                local_price = r["store_local_price"] if mapped_to_store else None
            else:
                mapped_to_store = True
                stock_qty = int(r["variant_stock_qty"] or 0)
                reserved_qty = 0
                local_price = None

            available_stock = max(stock_qty - reserved_qty, 0)
            default_price = r["sale_price"] if r["sale_price"] is not None else r["base_price"]
            final_price = local_price if local_price is not None else default_price

            gallery_images = _gallery_urls_from_json(r["gallery_json"])

            variants_by_id[variant_id] = {
                "id": variant_id,
                "variant_id": variant_id,
                "title": r["variant_title"],
                "variant_title": r["variant_title"],
                "sku": r["sku"],
                "barcode": r["barcode"],
                "price": float(final_price or 0),
                "base_price": float(r["base_price"] or 0),
                "sale_price": float(r["sale_price"]) if r["sale_price"] is not None else None,
                "local_price": float(local_price) if local_price is not None else None,
                "currency_code": r["currency_code"],
                "stock_qty": stock_qty,
                "reserved_qty": reserved_qty,
                "available_stock": available_stock,
                "is_available": available_stock > 0,
                "is_available_at_store": mapped_to_store if store_id is not None else True,
                "image_url": _image_url_from_gs_uri(r["image_url"]),
                "gallery_json": gallery_images,
                "gallery_images": gallery_images,
                "images": gallery_images,
                "weight_grams": int(r["weight_grams"]) if r["weight_grams"] is not None else None,
                "delivery_surcharge": float(r["delivery_surcharge"] or 0),
                "sort_order": int(r["sort_order"] or 0),
                "is_default": bool(r["is_default"]),
                "is_active": bool(r["is_active"]),
                "option_value_ids": [],
                "option_values": [],
                "selected_options": {},
            }

        variant = variants_by_id[variant_id]

        if r["option_value_id"] is not None:
            option_id = int(r["option_id"])
            option_value_id = int(r["option_value_id"])

            if option_value_id not in variant["option_value_ids"]:
                variant["option_value_ids"].append(option_value_id)
                variant["option_values"].append(
                    {
                        "option_id": option_id,
                        "option_name": r["option_name"],
                        "option_value_id": option_value_id,
                        "value": r["option_value"],
                        "option_value": r["option_value"],
                    }
                )

            if r["option_name"]:
                variant["selected_options"][r["option_name"]] = r["option_value"]

    variants = list(variants_by_id.values())

    prices = [v["price"] for v in variants]
    price_min = min(prices) if prices else None
    price_max = max(prices) if prices else None
    total_stock = sum(v["stock_qty"] for v in variants)
    total_available_stock = sum(v["available_stock"] for v in variants)

    default_variant_id = None
    for v in variants:
        if v["is_default"]:
            default_variant_id = v["id"]
            break

    if default_variant_id is None:
        for v in variants:
            if v["available_stock"] > 0:
                default_variant_id = v["id"]
                break

    if default_variant_id is None and variants:
        default_variant_id = variants[0]["id"]

    return {
        "options": options,
        "variants": variants,
        "variant_count": len(variants),
        "default_variant_id": default_variant_id,
        "variant_price_min": price_min,
        "variant_price_max": price_max,
        "variant_stock_qty": total_stock,
        "variant_available_stock": total_available_stock,
    }


def _apply_variant_payload(product_dict: dict, variant_payload: dict) -> dict:
    product_dict.update(variant_payload)

    variants = variant_payload.get("variants") or []

    if variants:
        price_min = variant_payload.get("variant_price_min")
        product_dict["price"] = (
            float(price_min)
            if price_min is not None
            else product_dict.get("price", 0)
        )
        product_dict["stock_qty"] = int(
            variant_payload.get("variant_stock_qty") or 0
        )
        product_dict["available_stock"] = int(
            variant_payload.get("variant_available_stock") or 0
        )

    return product_dict


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

    image_url = _image_url_from_gs_uri(product.image_url)
    gallery_images = _gallery_urls_from_json(getattr(product, "gallery_json", None))

    return {
        "id": int(product.id),
        "product_id": int(product.id),
        "tenant_id": int(product.tenant_id),
        "category_id": int(product.category_id) if product.category_id is not None else None,
        "category_name": category_name,
        "subcategory_id": None,
        "subcategory_name": None,
        "product_name": product.product_name,
        "name": product.product_name,
        "slug": product.product_slug,
        "short_description": product.short_description,
        "long_description": product.long_description,
        "brand_name": product.brand_name,
        "image_url": image_url,
        "gallery_json": gallery_images,
        "gallery_images": gallery_images,
        "images": gallery_images,
        "price": float(final_price or 0),
        "base_price": float(product.base_price or 0),
        "sale_price": float(product.sale_price) if product.sale_price is not None else None,
        "local_price": float(local_price) if local_price is not None else None,
        "currency_code": product.currency_code,
        "stock_qty": int(stock_qty or 0),
        "reserved_qty": int(reserved or 0),
        "available_stock": int(available_stock),
        "has_variants": bool(getattr(product, "has_variants", False)),
        "requires_variant_selection": bool(getattr(product, "has_variants", False)),
        "options": [],
        "variants": [],
        "variant_count": 0,
        "default_variant_id": None,
        "variant_price_min": None,
        "variant_price_max": None,
        "is_featured": bool(product.is_featured),
        "is_active": bool(product.is_active),
        "store_id": None,
        "store_name": None,
        "ships_from": None,
        "sold_by": None,
        "seller_contact_email": None,
        "delivery_options": [],
    }


@router.get("/categories")
def categories(
    tenant_code: str = Query(...),
    parent_id: int | None = Query(default=None),
    category_level: str | None = Query(default=None),
    db: Session = Depends(get_db),
):
    tenant = _get_tenant_by_code(db, tenant_code)

    query = (
        db.query(Category)
        .filter(
            Category.tenant_id == tenant.id,
            Category.is_active == True,
        )
    )

    if parent_id is not None:
        query = query.filter(Category.parent_id == parent_id)

    if category_level:
        query = query.filter(Category.category_level == category_level.upper())

    rows = (
        query.order_by(
            Category.sort_order.asc(),
            Category.category_name.asc(),
            Category.id.asc(),
        )
        .all()
    )

    def resolve_image_url(value):
        if not value:
            return None

        value = str(value).strip()

        if value.startswith("http://") or value.startswith("https://"):
            return value

        if value.startswith("gs://"):
            return _image_url_from_gs_uri(value)

        return value

    return [
        {
            "id": int(r.id),
            "name": r.category_name,
            "category_name": r.category_name,
            "slug": r.category_slug,
            "category_slug": r.category_slug,
            "parent_id": int(r.parent_id) if getattr(r, "parent_id", None) else None,
            "category_level": getattr(r, "category_level", None),
            "sort_order": int(r.sort_order) if getattr(r, "sort_order", None) is not None else 0,
            "image_url": resolve_image_url(getattr(r, "image_url", None)),
        }
        for r in rows
    ]

@router.get("/products")
def products(
    tenant_code: str = Query(...),
    pincode: str | None = Query(default=None),
    store_id: int | None = Query(default=None),
    featured: bool | None = Query(default=None),
    category_id: int | None = Query(default=None),
    subcategory_id: int | None = Query(default=None),
    search: str | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    tenant = _get_tenant_by_code(db, tenant_code)
    offset = (page - 1) * page_size

    # Marketplace mode:
    # - pincode returns products from all active stores serving this pincode
    # - store_id keeps backward compatibility and filters one store only
    if pincode is not None or store_id is not None:
        where_clauses = [
            "p.tenant_id = :tenant_id",
            "p.is_active = 1",
            "sp.tenant_id = :tenant_id",
            "sp.is_active = 1",
            "s.tenant_id = :tenant_id",
            "s.is_active = 1",
            "(sp.stock_qty - sp.reserved_qty) >= 0",
        ]

        params = {
            "tenant_id": tenant.id,
            "limit": page_size,
            "offset": offset,
        }

        if store_id is not None:
            where_clauses.append("sp.store_id = :store_id")
            params["store_id"] = store_id

        if pincode is not None and pincode.strip():
            where_clauses.append(
                """
                EXISTS (
                    SELECT 1
                    FROM store_pincodes spi
                    WHERE spi.tenant_id = :tenant_id
                      AND spi.store_id = sp.store_id
                      AND spi.pincode = :pincode
                      AND spi.is_active = 1
                )
                """
            )
            params["pincode"] = pincode.strip()

        if featured is True:
            where_clauses.append("p.is_featured = 1")

        selected_category_id = subcategory_id if subcategory_id is not None else category_id

        if selected_category_id is not None:
            where_clauses.append(
                """
                (
                    p.category_id = :category_id
                    OR c.parent_id = :category_id
                )
                """
            )
            params["category_id"] = selected_category_id

        if search and search.strip():
            where_clauses.append(
                """
                (
                    p.product_name LIKE :search
                    OR p.brand_name LIKE :search
                    OR p.short_description LIKE :search
                    OR p.long_description LIKE :search
                    OR s.store_name LIKE :search
                    OR COALESCE(s.seller_display_name, '') LIKE :search
                )
                """
            )
            params["search"] = f"%{search.strip()}%"

        where_sql = " AND ".join(where_clauses)

        total = db.execute(
            text(
                f"""
                SELECT COUNT(*) AS total
                FROM products p
                JOIN store_products sp
                  ON sp.product_id = p.id
                 AND sp.tenant_id = p.tenant_id
                JOIN stores s
                  ON s.id = sp.store_id
                 AND s.tenant_id = sp.tenant_id
                LEFT JOIN categories c
                  ON c.id = p.category_id
                 AND c.tenant_id = p.tenant_id
                LEFT JOIN categories pc
                  ON pc.id = c.parent_id
                 AND pc.tenant_id = c.tenant_id
                WHERE {where_sql}
                """
            ),
            params,
        ).scalar() or 0

        rows = db.execute(
            text(
                f"""
                SELECT
                    p.id,
                    p.tenant_id,
                    p.category_id,
                    c.category_name,
                    c.parent_id AS parent_category_id,
                    pc.category_name AS parent_category_name,
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
                    p.has_variants,
                    p.is_featured,
                    p.is_active,
                    sp.store_id,
                    sp.stock_qty,
                    sp.reserved_qty,
                    sp.local_price,
                    (sp.stock_qty - sp.reserved_qty) AS available_stock,
                    s.store_name,
                    s.store_email,
                    s.seller_display_name,
                    s.ships_from_name,
                    s.seller_contact_email
                FROM products p
                JOIN store_products sp
                  ON sp.product_id = p.id
                 AND sp.tenant_id = p.tenant_id
                JOIN stores s
                  ON s.id = sp.store_id
                 AND s.tenant_id = sp.tenant_id
                LEFT JOIN categories c
                  ON c.id = p.category_id
                 AND c.tenant_id = p.tenant_id
                LEFT JOIN categories pc
                  ON pc.id = c.parent_id
                 AND pc.tenant_id = c.tenant_id
                WHERE {where_sql}
                ORDER BY p.sort_order ASC, p.id DESC
                LIMIT :limit OFFSET :offset
                """
            ),
            params,
        ).mappings().all()

        size_counts = _size_counts_for_products(
            db=db,
            tenant_id=int(tenant.id),
            product_ids=[int(r["id"]) for r in rows],
        )

        items = []
        for r in rows:
            image_url = _image_url_from_gs_uri(r["image_url"])
            gallery_images = _gallery_urls_from_json(r.get("gallery_json"))

            default_price = r["sale_price"] if r["sale_price"] is not None else r["base_price"]
            final_price = r["local_price"] if r["local_price"] is not None else default_price

            # If current category is a SUB category, parent is main category.
            if r["parent_category_id"] is not None:
                main_category_id = int(r["parent_category_id"])
                main_category_name = r["parent_category_name"]
                subcategory_id_value = int(r["category_id"]) if r["category_id"] is not None else None
                subcategory_name = r["category_name"]
            else:
                main_category_id = int(r["category_id"]) if r["category_id"] is not None else None
                main_category_name = r["category_name"]
                subcategory_id_value = None
                subcategory_name = None

            delivery_options = _delivery_options_for_product_store(
                db=db,
                tenant_id=tenant.id,
                store_id=int(r["store_id"]),
                product_id=int(r["id"]),
            )

            sold_by = r["seller_display_name"] or r["store_name"]
            ships_from = r["ships_from_name"] or r["store_name"]
            seller_contact_email = r["seller_contact_email"] or r["store_email"]

            items.append(
                {
                    "id": int(r["id"]),
                    "product_id": int(r["id"]),
                    "tenant_id": int(r["tenant_id"]),
                    "category_id": main_category_id,
                    "category_name": main_category_name,
                    "subcategory_id": subcategory_id_value,
                    "subcategory_name": subcategory_name,
                    "product_name": r["product_name"],
                    "name": r["product_name"],
                    "slug": r["product_slug"],
                    "short_description": r["short_description"],
                    "long_description": r["long_description"],
                    "brand_name": r["brand_name"],
                    "image_url": image_url,
                    "gallery_json": gallery_images,
                    "gallery_images": gallery_images,
                    "images": gallery_images,
                    "price": float(final_price or 0),
                    "base_price": float(r["base_price"] or 0),
                    "sale_price": float(r["sale_price"]) if r["sale_price"] is not None else None,
                    "local_price": float(r["local_price"]) if r["local_price"] is not None else None,
                    "currency_code": r["currency_code"],
                    "stock_qty": int(r["stock_qty"] or 0),
                    "reserved_qty": int(r["reserved_qty"] or 0),
                    "available_stock": int(r["available_stock"] or 0),
                    "has_variants": bool(r["has_variants"]),
                    "requires_variant_selection": bool(r["has_variants"]),
                    "options": [],
                    "variants": [],
                    "variant_count": 0,
                    "size_count": size_counts.get(int(r["id"]), 0),
                    "default_variant_id": None,
                    "variant_price_min": None,
                    "variant_price_max": None,
                    "is_featured": bool(r["is_featured"]),
                    "is_active": bool(r["is_active"]),
                    "store_id": int(r["store_id"]),
                    "store_name": r["store_name"],
                    "ships_from": ships_from,
                    "sold_by": sold_by,
                    "seller_contact_email": seller_contact_email,
                    "delivery_options": delivery_options,
                }
            )

        return {
            "items": items,
            "page": page,
            "page_size": page_size,
            "has_more": offset + len(items) < total,
            "total": total,
            "store_id": store_id,
            "pincode": pincode,
            "mode": "marketplace_by_pincode" if pincode else "store",
        }

    # Legacy no-store/no-pincode mode.
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

    size_counts = _size_counts_for_products(
        db=db,
        tenant_id=int(tenant.id),
        product_ids=[int(product.id) for product, _ in rows],
    )

    items = []
    for product, category_name in rows:
        item = _to_product_dict(product, category_name)
        item["size_count"] = size_counts.get(int(product.id), 0)
        items.append(item)

    return {
        "items": items,
        "page": page,
        "page_size": page_size,
        "has_more": offset + len(items) < total,
        "total": total,
        "store_id": None,
        "pincode": None,
        "mode": "legacy",
    }



@router.get("/products/{product_id}/variants")
def product_variants(
    product_id: int,
    tenant_code: str = Query(...),
    store_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
):
    tenant = _get_tenant_by_code(db, tenant_code)

    product = (
        db.query(Product)
        .filter(
            Product.id == product_id,
            Product.tenant_id == tenant.id,
            Product.is_active == True,
        )
        .first()
    )

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    if not bool(getattr(product, "has_variants", False)):
        return {
            "product_id": int(product.id),
            "has_variants": False,
            "requires_variant_selection": False,
            "options": [],
            "variants": [],
            "variant_count": 0,
            "default_variant_id": None,
            "variant_price_min": None,
            "variant_price_max": None,
            "variant_stock_qty": 0,
            "variant_available_stock": 0,
        }

    payload = _variant_payload_for_product(
        db=db,
        tenant_id=int(tenant.id),
        product_id=int(product.id),
        store_id=store_id,
    )

    return {
        "product_id": int(product.id),
        "has_variants": True,
        "requires_variant_selection": True,
        **payload,
    }



@router.get("/products/{product_id}")
def product_by_id(
    product_id: int,
    tenant_code: str = Query(...),
    store_id: int | None = Query(default=None),
    pincode: str | None = Query(default=None),
    db: Session = Depends(get_db),
):
    tenant = _get_tenant_by_code(db, tenant_code)

    if store_id is not None or pincode is not None:
        where_clauses = [
            "p.id = :product_id",
            "p.tenant_id = :tenant_id",
            "p.is_active = 1",
            "sp.tenant_id = :tenant_id",
            "sp.is_active = 1",
            "s.tenant_id = :tenant_id",
            "s.is_active = 1",
        ]

        params = {
            "product_id": product_id,
            "tenant_id": tenant.id,
        }

        if store_id is not None:
            where_clauses.append("sp.store_id = :store_id")
            params["store_id"] = store_id

        if pincode is not None and pincode.strip():
            where_clauses.append(
                """
                EXISTS (
                    SELECT 1
                    FROM store_pincodes spi
                    WHERE spi.tenant_id = :tenant_id
                      AND spi.store_id = sp.store_id
                      AND spi.pincode = :pincode
                      AND spi.is_active = 1
                )
                """
            )
            params["pincode"] = pincode.strip()

        where_sql = " AND ".join(where_clauses)

        r = db.execute(
            text(
                f"""
                SELECT
                    p.id,
                    p.tenant_id,
                    p.category_id,
                    c.category_name,
                    c.parent_id AS parent_category_id,
                    pc.category_name AS parent_category_name,
                    p.product_name,
                    p.brand_name,
                    p.product_slug,
                    p.short_description,
                    p.long_description,
                    p.image_url,
                    p.gallery_json,
                    p.base_price,
                    p.sale_price,
                    p.currency_code,
                    p.has_variants,
                    p.is_featured,
                    p.is_active,
                    sp.store_id,
                    sp.stock_qty,
                    sp.reserved_qty,
                    sp.local_price,
                    (sp.stock_qty - sp.reserved_qty) AS available_stock,
                    s.store_name,
                    s.store_email,
                    s.seller_display_name,
                    s.ships_from_name,
                    s.seller_contact_email
                FROM products p
                JOIN store_products sp
                  ON sp.product_id = p.id
                 AND sp.tenant_id = p.tenant_id
                JOIN stores s
                  ON s.id = sp.store_id
                 AND s.tenant_id = sp.tenant_id
                LEFT JOIN categories c
                  ON c.id = p.category_id
                 AND c.tenant_id = p.tenant_id
                LEFT JOIN categories pc
                  ON pc.id = c.parent_id
                 AND pc.tenant_id = c.tenant_id
                WHERE {where_sql}
                LIMIT 1
                """
            ),
            params,
        ).mappings().first()

        if not r:
            raise HTTPException(status_code=404, detail="Product not found for this store/pincode")

        image_url = _image_url_from_gs_uri(r["image_url"])
        gallery_images = _gallery_urls_from_json(r.get("gallery_json"))
        default_price = r["sale_price"] if r["sale_price"] is not None else r["base_price"]
        final_price = r["local_price"] if r["local_price"] is not None else default_price

        if r["parent_category_id"] is not None:
            main_category_id = int(r["parent_category_id"])
            main_category_name = r["parent_category_name"]
            subcategory_id_value = int(r["category_id"]) if r["category_id"] is not None else None
            subcategory_name = r["category_name"]
        else:
            main_category_id = int(r["category_id"]) if r["category_id"] is not None else None
            main_category_name = r["category_name"]
            subcategory_id_value = None
            subcategory_name = None

        delivery_options = _delivery_options_for_product_store(
            db=db,
            tenant_id=tenant.id,
            store_id=int(r["store_id"]),
            product_id=int(r["id"]),
        )

        sold_by = r["seller_display_name"] or r["store_name"]
        ships_from = r["ships_from_name"] or r["store_name"]
        seller_contact_email = r["seller_contact_email"] or r["store_email"]

        result = {
            "id": int(r["id"]),
            "product_id": int(r["id"]),
            "tenant_id": int(r["tenant_id"]),
            "category_id": main_category_id,
            "category_name": main_category_name,
            "subcategory_id": subcategory_id_value,
            "subcategory_name": subcategory_name,
            "product_name": r["product_name"],
            "name": r["product_name"],
            "slug": r["product_slug"],
            "short_description": r["short_description"],
            "long_description": r["long_description"],
            "brand_name": r["brand_name"],
            "image_url": image_url,
            "gallery_json": gallery_images,
            "gallery_images": gallery_images,
            "images": gallery_images,
            "price": float(final_price or 0),
            "base_price": float(r["base_price"] or 0),
            "sale_price": float(r["sale_price"]) if r["sale_price"] is not None else None,
            "local_price": float(r["local_price"]) if r["local_price"] is not None else None,
            "currency_code": r["currency_code"],
            "stock_qty": int(r["stock_qty"] or 0),
            "reserved_qty": int(r["reserved_qty"] or 0),
            "available_stock": int(r["available_stock"] or 0),
            "has_variants": bool(r["has_variants"]),
            "requires_variant_selection": bool(r["has_variants"]),
            "options": [],
            "variants": [],
            "variant_count": 0,
            "default_variant_id": None,
            "variant_price_min": None,
            "variant_price_max": None,
            "is_featured": bool(r["is_featured"]),
            "is_active": bool(r["is_active"]),
            "store_id": int(r["store_id"]),
            "store_name": r["store_name"],
            "ships_from": ships_from,
            "sold_by": sold_by,
            "seller_contact_email": seller_contact_email,
            "delivery_options": delivery_options,
        }

        if bool(r["has_variants"]):
            variant_payload = _variant_payload_for_product(
                db=db,
                tenant_id=int(r["tenant_id"]),
                product_id=int(r["id"]),
                store_id=int(r["store_id"]),
            )
            _apply_variant_payload(result, variant_payload)

        return result

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
    result = _to_product_dict(product, category_name)

    if bool(getattr(product, "has_variants", False)):
        variant_payload = _variant_payload_for_product(
            db=db,
            tenant_id=int(product.tenant_id),
            product_id=int(product.id),
            store_id=None,
        )
        _apply_variant_payload(result, variant_payload)

    return result
