#!/usr/bin/env python3
"""
Yellow Metals -> DesiDash import builder

What this script does
---------------------
1. Reads yellow_metals_catalog.json downloaded from:
   https://theyellowmetals.com/products.json?limit=250
2. Categorises products into DesiDash category IDs 211-215.
3. Converts Shopify INR prices (paise) to AUD using --inr-to-aud-rate.
4. Sets customer sale_price = AUD base_price * 1.15.
5. Uses stock 100 for available source variants, 0 for unavailable variants.
6. Optionally downloads and uploads product images into:
   gs://sba-commerce-images/vendors/yellow-metals/<handle>/
7. Writes an idempotent-ish MySQL import file that upserts products/variants/store mappings
   and refreshes option-value links.
8. Brass Lagan is included safely and will update rather than duplicate.

Recommended first run:
    python scripts/import_yellow_metals.py --dry-run --inr-to-aud-rate 0.015

Then:
    python scripts/import_yellow_metals.py --upload-images --generate-sql --inr-to-aud-rate 0.015

Generated files:
    yellow_metals_preview.json
    yellow_metals_import.sql
"""

from __future__ import annotations

import argparse
import html
import json
import re
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

TENANT_ID = 1
STORE_ID = 34
DELIVERY_METHOD_ID = 5
DELIVERY_FEE = 10.99
SOURCE_SYSTEM = "yellow_metals"
BUCKET = "sba-commerce-images"
PUBLIC_ROOT = f"https://storage.googleapis.com/{BUCKET}"

CATEGORY_IDS = {
    "Cookware": 211,
    "Tableware & Serveware": 212,
    "Drinkware": 213,
    "Kitchen Storage": 214,
    "Preparation Tools": 215,
}

# Explicit mapping keeps catalogue placement deterministic.
CATEGORY_BY_HANDLE = {
    "dhoodh-patila-milk-vessel-copy": "Cookware",
    "sipri-brass": "Cookware",
    "brass-frying-pan": "Cookware",  # Copper Frying Pan handle
    "flat-lagan": "Cookware",
    "copper-frying-pan": "Cookware",
    "copper-madurai-handi": "Cookware",
    "brass-frying-pan-frying-batti": "Cookware",
    "brass-plate-set": "Tableware & Serveware",
    "sipri-copper": "Cookware",
    "copper-lagan": "Cookware",
    "masala-dani": "Kitchen Storage",
    "brass-lagan": "Cookware",
    "sipri-brasswater-tumbler-copper-4no-copy": "Drinkware",
    "brass-kadai": "Cookware",
    "brass-sauce-pan": "Cookware",
    "brass-roti-tawa": "Cookware",
    "paraat-polished-brass": "Preparation Tools",
    "brass-jalebi-kadai": "Cookware",
    "copper-water-matika": "Drinkware",
    "biryani-handi-dal-handi": "Cookware",
    "tea-sugar-box-brass-dabba": "Kitchen Storage",
    "copper-jug-with-glass-cum-lid": "Drinkware",
    "brass-lids": "Cookware",
    "roti-box-mithai-box": "Kitchen Storage",
}


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--catalog", default="yellow_metals_catalog.json")
    p.add_argument("--inr-to-aud-rate", type=float, required=True)
    p.add_argument("--markup", type=float, default=0.15)
    p.add_argument("--stock-available", type=int, default=100)
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--upload-images", action="store_true")
    p.add_argument("--generate-sql", action="store_true")
    p.add_argument("--preview", default="yellow_metals_preview.json")
    p.add_argument("--sql-output", default="yellow_metals_import.sql")
    return p.parse_args()


def money_from_shopify(value):
    if value in (None, ""):
        return None
    # products.json normally returns prices as strings like "6499.00";
    # product.js returns integer paise. Support both.
    if isinstance(value, int):
        return value / 100.0
    if isinstance(value, float):
        # A float from JSON products endpoint is already rupees.
        return value
    s = str(value).strip()
    try:
        n = float(s)
    except ValueError:
        return None
    # If no decimal point and clearly paise-sized, treat as paise.
    if "." not in s and n >= 100000:
        return n / 100.0
    return n


def aud_prices(inr_price, rate, markup):
    base = round(inr_price * rate + 1e-9, 2)
    sale = round(base * (1.0 + markup) + 1e-9, 2)
    return base, sale


def plain_text(raw_html):
    if not raw_html:
        return ""
    s = re.sub(r"<\s*br\s*/?>", "\n", raw_html, flags=re.I)
    s = re.sub(r"</\s*p\s*>", "\n", s, flags=re.I)
    s = re.sub(r"<[^>]+>", " ", s)
    s = html.unescape(s)
    s = re.sub(r"[ \t\r\f\v]+", " ", s)
    s = re.sub(r"\n\s*\n+", "\n", s)
    return s.strip()


def short_description(text, limit=240):
    text = re.sub(r"\s+", " ", text).strip()
    if len(text) <= limit:
        return text
    cut = text[: limit - 1].rsplit(" ", 1)[0]
    return cut + "…"


def sql_str(value):
    if value is None:
        return "NULL"
    # MySQL-compatible SQL literal. Double apostrophes and backslashes.
    s = str(value).replace("\\", "\\\\").replace("'", "''")
    return f"'{s}'"


def sql_json_array(values):
    if not values:
        return "JSON_ARRAY()"
    return "JSON_ARRAY(" + ",".join(sql_str(v) for v in values) + ")"


def file_name_from_url(url, fallback):
    path = urlparse(url).path
    name = Path(path).name
    return name or fallback


def source_image_url(raw):
    if not raw:
        return None
    if isinstance(raw, dict):
        raw = raw.get("src") or raw.get("url")
    if not raw:
        return None
    raw = str(raw)
    if raw.startswith("//"):
        return "https:" + raw
    return raw


def get_product_images(product):
    out = []
    for i, img in enumerate(product.get("images") or []):
        src = source_image_url(img)
        if src and src not in out:
            out.append(src)

    featured = source_image_url(product.get("featured_image"))
    if featured and featured not in out:
        out.insert(0, featured)

    return out


def gcs_urls_for_product(product):
    handle = product["handle"]
    urls = []
    source_urls = get_product_images(product)
    for i, src in enumerate(source_urls):
        name = file_name_from_url(src, f"image-{i+1}.jpg")
        urls.append(f"{PUBLIC_ROOT}/vendors/yellow-metals/{handle}/{name}")
    return urls


def variant_image_source(product, variant):
    featured = source_image_url(variant.get("featured_image"))
    if featured:
        return featured

    image_id = variant.get("image_id")
    if image_id:
        for img in product.get("images") or []:
            if isinstance(img, dict) and str(img.get("id")) == str(image_id):
                return source_image_url(img)

    images = get_product_images(product)
    return images[0] if images else None


def gcs_url_for_source(handle, src, fallback="variant.jpg"):
    if not src:
        return None
    name = file_name_from_url(src, fallback)
    return f"{PUBLIC_ROOT}/vendors/yellow-metals/{handle}/{name}"


def meaningful_variants(product):
    variants = product.get("variants") or []
    if len(variants) <= 1:
        return False
    # Multiple actual source variants means customer selection is meaningful.
    return True


def option_names(product):
    result = []
    for opt in product.get("options") or []:
        if isinstance(opt, dict):
            name = (opt.get("name") or "").strip()
        else:
            name = str(opt).strip()
        if name and name.lower() != "title":
            result.append(name)
    return result


def option_values_for_variant(product, variant):
    names = option_names(product)
    values = []
    for idx, name in enumerate(names, start=1):
        value = variant.get(f"option{idx}")
        if value is None:
            opts = variant.get("options")
            if isinstance(opts, list) and idx - 1 < len(opts):
                value = opts[idx - 1]
        if value not in (None, "", "Default Title"):
            values.append((name, str(value)))
    return values


def category_for(product):
    handle = product.get("handle", "")
    category = CATEGORY_BY_HANDLE.get(handle)
    if not category:
        raise ValueError(f"No category mapping for handle: {handle}")
    return category, CATEGORY_IDS[category]


def make_preview(products, rate, markup, stock_available):
    preview = []
    for p in products:
        cat_name, cat_id = category_for(p)
        variants = p.get("variants") or []
        has_variants = meaningful_variants(p)
        rows = []
        for v in variants:
            inr = money_from_shopify(v.get("price"))
            if inr is None:
                raise ValueError(f"Missing price for {p['title']} / {v.get('title')}")
            base, sale = aud_prices(inr, rate, markup)
            rows.append({
                "source_variant_id": str(v.get("id")),
                "title": v.get("title"),
                "sku": v.get("sku"),
                "available": bool(v.get("available", True)),
                "stock_qty": stock_available if bool(v.get("available", True)) else 0,
                "inr_price": inr,
                "base_price_aud": base,
                "sale_price_aud": sale,
                "options": dict(option_values_for_variant(p, v)),
            })

        preview.append({
            "source_product_id": str(p.get("id")),
            "title": p.get("title"),
            "handle": p.get("handle"),
            "category": cat_name,
            "category_id": cat_id,
            "has_variants": has_variants,
            "variant_count": len(variants),
            "variants": rows,
            "image_count": len(get_product_images(p)),
        })
    return preview


def upload_images(products):
    tmp_root = Path(tempfile.mkdtemp(prefix="yellow_metals_"))
    print(f"[images] temp directory: {tmp_root}")

    for product in products:
        handle = product["handle"]
        source_urls = get_product_images(product)
        if not source_urls:
            print(f"[images] {handle}: no images")
            continue

        folder = tmp_root / handle
        folder.mkdir(parents=True, exist_ok=True)
        destination = f"gs://{BUCKET}/vendors/yellow-metals/{handle}/"

        for idx, src in enumerate(source_urls, start=1):
            name = file_name_from_url(src, f"image-{idx}.jpg")
            local = folder / name
            print(f"[download] {product['title']} -> {name}")
            urllib.request.urlretrieve(src, local)

        print(f"[upload] {product['title']} -> {destination}")
        subprocess.run(
            ["gcloud", "storage", "cp", "--recursive", str(folder) + "/*", destination],
            check=True,
            shell=(sys.platform == "win32"),
        )


def generate_sql(products, rate, markup, stock_available):
    out = []
    emit = out.append

    emit("-- Yellow Metals -> DesiDash generated import")
    emit("SET NAMES utf8mb4;")
    emit("START TRANSACTION;")
    emit("")

    for p_index, p in enumerate(products, start=1):
        title = p["title"]
        handle = p["handle"]
        slug = f"yellow-metals-{handle}"
        category_name, category_id = category_for(p)
        variants = p.get("variants") or []
        has_variants = meaningful_variants(p)
        description = plain_text(p.get("body_html") or p.get("description") or "")
        short_desc = short_description(description)
        gcs_images = gcs_urls_for_product(p)
        parent_image = gcs_images[0] if gcs_images else None

        price_rows = []
        for v in variants:
            inr = money_from_shopify(v.get("price"))
            if inr is None:
                continue
            base, sale = aud_prices(inr, rate, markup)
            stock = stock_available if bool(v.get("available", True)) else 0
            price_rows.append((v, inr, base, sale, stock))

        if not price_rows:
            raise ValueError(f"No priced variants for {title}")

        parent_base = min(r[2] for r in price_rows)
        parent_sale = min(r[3] for r in price_rows)
        parent_stock = sum(r[4] for r in price_rows) if has_variants else price_rows[0][4]
        parent_sku = None if has_variants else (price_rows[0][0].get("sku") or None)

        emit(f"-- ============================================================")
        emit(f"-- {p_index}. {title} -> {category_name} ({category_id})")
        emit(f"-- Source product id: {p.get('id')}")
        emit(f"-- ============================================================")

        emit(f"""INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    {TENANT_ID}, {category_id}, {p_index * 10},
    {sql_str(title)}, 'The YellowMetals', {sql_str(slug)},
    {sql_str(short_desc)}, {sql_str(description)},
    {sql_str(parent_sku)}, NULL,
    {sql_str(parent_image)}, {sql_json_array(gcs_images)},
    {parent_base:.2f}, {parent_sale:.2f}, 'AUD', {parent_stock},
    {1 if has_variants else 0}, 0, 1
)
ON DUPLICATE KEY UPDATE
    category_id=VALUES(category_id),
    sort_order=VALUES(sort_order),
    product_name=VALUES(product_name),
    brand_name=VALUES(brand_name),
    short_description=VALUES(short_description),
    long_description=VALUES(long_description),
    sku=VALUES(sku),
    image_url=VALUES(image_url),
    gallery_json=VALUES(gallery_json),
    base_price=VALUES(base_price),
    sale_price=VALUES(sale_price),
    currency_code='AUD',
    stock_qty=VALUES(stock_qty),
    has_variants=VALUES(has_variants),
    is_active=1;""")

        emit(f"""SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id={TENANT_ID} AND product_slug={sql_str(slug)}
    LIMIT 1
);""")

        if has_variants:
            # Create options
            names = option_names(p)
            for opt_index, opt_name in enumerate(names, start=1):
                emit(f"""INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT {TENANT_ID}, @product_id, {sql_str(opt_name)}, 'TEXT', {opt_index}, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id={TENANT_ID}
      AND product_id=@product_id
      AND option_name={sql_str(opt_name)}
);""")
                safe = re.sub(r"[^A-Za-z0-9]", "_", opt_name).lower()
                emit(f"""SET @option_{safe} = (
    SELECT id FROM product_options
    WHERE tenant_id={TENANT_ID}
      AND product_id=@product_id
      AND option_name={sql_str(opt_name)}
    LIMIT 1
);""")

            # Gather option values in source order.
            values_by_option = {name: [] for name in names}
            for v, *_ in price_rows:
                for name, value in option_values_for_variant(p, v):
                    if value not in values_by_option[name]:
                        values_by_option[name].append(value)

            for opt_name in names:
                safe = re.sub(r"[^A-Za-z0-9]", "_", opt_name).lower()
                for value_index, value in enumerate(values_by_option[opt_name], start=1):
                    emit(f"""INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT {TENANT_ID}, @option_{safe}, {sql_str(value)}, {value_index}, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_{safe}
      AND option_value={sql_str(value)}
);""")

            # Variants + links + store stock.
            for v_index, (v, inr, base, sale, stock) in enumerate(price_rows, start=1):
                source_variant_id = str(v.get("id"))
                variant_title = v.get("title") or f"Variant {v_index}"
                sku = v.get("sku") or None
                image_src = variant_image_source(p, v)
                variant_image = gcs_url_for_source(handle, image_src, f"variant-{v_index}.jpg")
                grams = v.get("grams")
                grams_sql = "NULL" if grams in (None, "") else str(int(grams))

                emit(f"""INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    {TENANT_ID}, @product_id, {sql_str(variant_title)}, {sql_str(sku)}, NULL,
    {base:.2f}, {sale:.2f}, 'AUD', {stock}, {sql_str(variant_image)},
    JSON_ARRAY(), {grams_sql}, 0.00,
    {sql_str(SOURCE_SYSTEM)}, {sql_str(source_variant_id)},
    {v_index}, {1 if v_index == 1 else 0}, {1 if bool(v.get("available", True)) else 0}
)
ON DUPLICATE KEY UPDATE
    product_id=VALUES(product_id),
    variant_title=VALUES(variant_title),
    sku=VALUES(sku),
    base_price=VALUES(base_price),
    sale_price=VALUES(sale_price),
    currency_code='AUD',
    stock_qty=VALUES(stock_qty),
    image_url=VALUES(image_url),
    weight_grams=VALUES(weight_grams),
    sort_order=VALUES(sort_order),
    is_default=VALUES(is_default),
    is_active=VALUES(is_active);""")

                emit(f"""SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id={TENANT_ID}
      AND source_system={sql_str(SOURCE_SYSTEM)}
      AND source_variant_id={sql_str(source_variant_id)}
    LIMIT 1
);""")

                emit("DELETE FROM product_variant_values WHERE variant_id=@variant_id;")
                for opt_name, value in option_values_for_variant(p, v):
                    safe = re.sub(r"[^A-Za-z0-9]", "_", opt_name).lower()
                    emit(f"""SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_{safe}
      AND option_value={sql_str(value)}
    LIMIT 1
);""")
                    emit(f"""INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_{safe}, @option_value_id
);""")

                emit(f"""INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT {TENANT_ID}, {STORE_ID}, @variant_id, {stock}, 0, NULL, {1 if bool(v.get("available", True)) else 0}
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id={TENANT_ID}
      AND store_id={STORE_ID}
      AND product_variant_id=@variant_id
);""")
                emit(f"""UPDATE store_product_variants
SET stock_qty={stock}, reserved_qty=0, local_price=NULL,
    is_active={1 if bool(v.get("available", True)) else 0}
WHERE tenant_id={TENANT_ID}
  AND store_id={STORE_ID}
  AND product_variant_id=@variant_id;""")

        # Parent store mapping.
        emit(f"""INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT {TENANT_ID}, {STORE_ID}, @product_id, {parent_stock}, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id={TENANT_ID}
      AND store_id={STORE_ID}
      AND product_id=@product_id
);""")
        emit(f"""UPDATE store_products
SET stock_qty={parent_stock}, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id={TENANT_ID}
  AND store_id={STORE_ID}
  AND product_id=@product_id;""")

        # International delivery.
        emit(f"""INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT {TENANT_ID}, {STORE_ID}, @product_id, {DELIVERY_METHOD_ID},
       {DELIVERY_FEE:.2f}, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id={TENANT_ID}
      AND store_id={STORE_ID}
      AND product_id=@product_id
      AND delivery_method_id={DELIVERY_METHOD_ID}
);""")
        emit(f"""UPDATE product_delivery_options
SET delivery_fee={DELIVERY_FEE:.2f}, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id={TENANT_ID}
  AND store_id={STORE_ID}
  AND product_id=@product_id
  AND delivery_method_id={DELIVERY_METHOD_ID};""")
        emit("")

    emit("-- Verification")
    emit(f"""SELECT
    COUNT(*) AS yellow_metals_products
FROM store_products
WHERE tenant_id={TENANT_ID}
  AND store_id={STORE_ID};""")
    emit(f"""SELECT
    COUNT(*) AS yellow_metals_variants
FROM product_variants
WHERE tenant_id={TENANT_ID}
  AND source_system={sql_str(SOURCE_SYSTEM)};""")
    emit("COMMIT;")
    emit("")

    return "\n".join(out)


def main():
    args = parse_args()
    catalog_path = Path(args.catalog)
    if not catalog_path.exists():
        raise SystemExit(f"Catalog not found: {catalog_path}")

    payload = json.loads(catalog_path.read_text(encoding="utf-8-sig"))
    products = payload.get("products") if isinstance(payload, dict) else None
    if not isinstance(products, list):
        raise SystemExit("Expected JSON object with a 'products' array.")

    # Validate exact expected source size but don't refuse future catalogue growth.
    print(f"[catalog] products found: {len(products)}")

    # Deterministic source order.
    preview = make_preview(products, args.inr_to_aud_rate, args.markup, args.stock_available)
    Path(args.preview).write_text(json.dumps(preview, indent=2, ensure_ascii=False), encoding="utf-8")

    parent_count = len(preview)
    variant_parent_count = sum(1 for p in preview if p["has_variants"])
    source_variant_count = sum(p["variant_count"] for p in preview)
    available_variant_count = sum(
        1 for p in preview for v in p["variants"] if v["available"]
    )

    print(f"[preview] parent products: {parent_count}")
    print(f"[preview] products with variants: {variant_parent_count}")
    print(f"[preview] source variants: {source_variant_count}")
    print(f"[preview] available source variants: {available_variant_count}")
    print(f"[preview] written: {args.preview}")

    print("\nCATEGORY SUMMARY")
    counts = {}
    for p in preview:
        counts[p["category"]] = counts.get(p["category"], 0) + 1
    for name in CATEGORY_IDS:
        print(f"  {name:24} {counts.get(name, 0)}")

    print("\nPRODUCT SUMMARY")
    for p in preview:
        marker = "VARIANT" if p["has_variants"] else "SINGLE "
        print(f"  {marker} | {p['category']:<24} | {p['variant_count']:>2} | {p['title']}")

    if args.upload_images:
        upload_images(products)

    if args.generate_sql:
        sql = generate_sql(products, args.inr_to_aud_rate, args.markup, args.stock_available)
        Path(args.sql_output).write_text(sql, encoding="utf-8")
        print(f"\n[sql] written: {args.sql_output}")

    if args.dry_run:
        print("\nDRY RUN ONLY: no database changes were made.")
    elif not args.generate_sql:
        print("\nNo SQL was generated. Add --generate-sql when ready.")


if __name__ == "__main__":
    main()
