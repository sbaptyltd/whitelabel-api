-- Yellow Metals -> DesiDash generated import
SET NAMES utf8mb4;
START TRANSACTION;

-- ============================================================
-- 1. Dhoodh Patila (Milk Vessel) -> Cookware (211)
-- Source product id: 9992858206489
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 10,
    'Dhoodh Patila (Milk Vessel)', 'The YellowMetals', 'yellow-metals-dhoodh-patila-milk-vessel-copy',
    'For generations, milk has held a sacred place in Indian kitchens. In ancient times, it was commonly boiled in brass vessels , a tradition rooted in both health and heritage. Boiling milk in brass wasn’t just cultural-it was intentional,…', 'For generations, milk has held a sacred place in Indian kitchens. In ancient times, it was commonly boiled in brass vessels , a tradition rooted in both health and heritage. Boiling milk in brass wasn’t just cultural-it was intentional, aimed at preserving nutrition and enhancing shelf life.
 The Yellow Metals brings this tradition into the modern kitchen with the Brass Patila —a handcrafted piece of cookware that celebrates Indian roots while supporting a healthier lifestyle. With its shining golden exterior and tin-coated silver interior , this Patila is not just functional’s a timeless addition to your kitchen. A Doodh Patila is far more versatile than its name suggests. While it’s traditionally used for boiling milk, it can also be used for preparing tea, hot chocolate, kadha, and even sterilising water. Its deep, rounded design makes it ideal for cooking everyday dishes like khichdi, dal, porridge, upma, pasta, noodles, and rice. It''s equally perfect for making Indian sweets such as kheer, halwa, rabri, and basundi, or even boiling jaggery for chikkis. During festive occasions or poojas, it can be used to prepare panchamrit or sheera. Because of its excellent heat retention and nutrient-preserving properties-especially when made from tin-coated brass. Doodh Patila is also a great choice for boiling vegetables or preparing baby food. Whether for daily meals or special recipes, this traditional vessel is a multi-purpose essential in every kitchen.
 Product Highlights 
 Traditional & Health-Friendly: 
Made from pure brass with tin (Kalai) coating , ideal for boiling milk, making biryani, or cooking daily meals the traditional way-while retaining nutrients.
 Naturally Non-Stick & Non-Toxic: 
The Kalai-lined surface is naturally non-stick , chemical-free, and food-safe—no Teflon or artificial coatings.
 Even Heat Distribution: 
Brass heats up quickly and evenly, reducing gas usage and avoiding uneven cooking.
 Handcrafted Elegance: 
Each patila is individually hand-hammered , giving it a golden finish outside and silver-toned lining inside —a perfect blend of form and function.
 Durable & Sustainable: 
Safe with proper care and re-coating when needed, this cookware lasts for generations.
 What’s Included: 
 1 x Brass Patila (Tin Coated Inside) 
 1 x Matching Brass Lid 
 Care Instructions: 
 Clean inside with dish soap. 
 Use Pitambari or a mix of atta + lemon/vinegar + salt to polish the outside. 
 Do not dry heat. Always add oil or water before placing it on the flame. 
 Use on medium to low flame to protect Kalai and conserve energy.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9524.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9524.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9520.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9523.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9519.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9521.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9522.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9531.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9532.jpg'),
    50.99, 58.64, 'AUD', 300,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-dhoodh-patila-milk-vessel-copy'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '1.5 Litres', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1.5 Litres'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '2.5 Litres', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 Litres'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '3.5 Liters', 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.5 Liters'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '1.5 Litres', 'DP1.5', NULL,
    50.99, 58.64, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9524.jpg',
    JSON_ARRAY(), 0, 0.00,
    'yellow_metals', '51109377540377',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51109377540377'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1.5 Litres'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '2.5 Litres', 'DP2.5', NULL,
    58.49, 67.26, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9524.jpg',
    JSON_ARRAY(), 0, 0.00,
    'yellow_metals', '51109377573145',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51109377573145'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 Litres'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '3.5 Liters', 'DP3.5', NULL,
    67.49, 77.61, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/dhoodh-patila-milk-vessel-copy/DSC_9524.jpg',
    JSON_ARRAY(), 0, 0.00,
    'yellow_metals', '51109377605913',
    3, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51109377605913'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.5 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 300, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=300, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 2. Sipri Brass -> Cookware (211)
-- Source product id: 9758999380249
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 20,
    'Sipri Brass', 'The YellowMetals', 'yellow-metals-sipri-brass',
    'Introducing our exquisite Sipri Brass Cookware, an essential addition to your kitchen, designed for cooking a variety of delicious dishes such as chicken, mutton, fish curry, or any vegetable curry. This versatile cookware measures 10.5…', 'Introducing our exquisite Sipri Brass Cookware, an essential addition to your kitchen, designed for cooking a variety of delicious dishes such as chicken, mutton, fish curry, or any vegetable curry. This versatile cookware measures 10.5 inches in diameter, weighs between 1.8-1.9 Kg, depth is 5.0 inches and comes with a robust lid weighing 550 grams. Combining functionality with elegance, the Sipri Brass Cookware is crafted to meet the demands of both professional chefs and home cooks. Our Sipri Brass Cookware is more than just a cooking vessel; it''s a culinary tool designed to elevate your cooking experience. Ideal for both professional chefs and home cooks, this cookware offers the perfect blend of functionality and elegance. Enjoy superior heat retention, enhanced flavor, durability, and health benefits as you create mouth-watering curries for your family and friends. Invest in our Sipri Brass Cookware today and transform your kitchen into a hub of culinary excellence. 
 Benefits of Cooking with Sipri Copper Cookware 
 Superior Heat Conductivity: Copper ensures even heat distribution, perfect for achieving the ideal texture and flavor in curries. 
 Enhanced Flavor: Copper allows for better caramelization and browning, intensifying the flavors and aromas of your dishes. 
 Durability: Crafted from high-quality copper, our cookware is built to last, withstanding high temperatures and regular use. 
 Health Benefits: Brass''s natural antimicrobial properties reduce bacterial contamination, and trace amounts of copper and zinc provide essential minerals during cooking. 
 Kalai (tin coating) is essential for brass and copper cookware. It prevents food spoilage and blackening by minimizing air contact, reducing oxidation. Kalai improves energy efficiency with even heat distribution and makes food tastier and healthier by preserving the natural flavors and preventing reactions with acidic ingredients.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6668.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6668.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6669.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6670.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6671.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6672.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6673.jpg'),
    59.99, 68.99, 'AUD', 300,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-sipri-brass'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '1.0 L', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1.0 L'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '2.0 L', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.0 L'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '3.5 L', 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.5 L'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '1.0 L', NULL, NULL,
    59.99, 68.99, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6668.jpg',
    JSON_ARRAY(), 0, 0.00,
    'yellow_metals', '51625986064665',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51625986064665'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1.0 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '2.0 L', 'SPB2.0', NULL,
    73.49, 84.51, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6668.jpg',
    JSON_ARRAY(), 0, 0.00,
    'yellow_metals', '51097688899865',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51097688899865'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.0 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '3.5 L', 'SPB3.5', NULL,
    89.99, 103.49, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brass/DSC_6668.jpg',
    JSON_ARRAY(), 0, 0.00,
    'yellow_metals', '51097688932633',
    3, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51097688932633'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.5 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 300, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=300, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 3. Copper Frying Pan -> Cookware (211)
-- Source product id: 9978302595353
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 30,
    'Copper Frying Pan', 'The YellowMetals', 'yellow-metals-brass-frying-pan',
    'Introducing our Copper Frying Pan, a quintessential kitchen tool designed for those who appreciate the art of traditional cooking. Measuring 9.0 inches in diameter and weighing between 1.2 to 1.4 kg, this brass frying pan is perfect for…', 'Introducing our Copper Frying Pan, a quintessential kitchen tool designed for those who appreciate the art of traditional cooking. Measuring 9.0 inches in diameter and weighing between 1.2 to 1.4 kg, this brass frying pan is perfect for preparing tadka, jhok, and other flavorful dishes. With its combination of classic craftsmanship and modern functionality, it is an indispensable addition to any kitchen. Our Copper Frying Pan (Frying Batti) blends tradition with functionality. Its excellent heat distribution, flavor-enhancing properties, and elegant design make it ideal for dishes like tadka and jhok. Elevate your cooking with this stylish and durable kitchen essential.
 Benefits of Using a Brass Frying Pan 
 Superior Heat Distribution:  Copper heats up quickly and evenly, ensuring uniform cooking of spices and ingredients for better flavor. 
 Enhanced Flavor and Aroma : Copper enhances caramelization and depth of flavor, perfect for achieving the ideal taste in tadka and jhok. 
 Durability : Crafted from high-quality brass, this frying pan is built to last and withstand high temperatures and frequent use. 
 Classic Aesthetic : The polished brass finish adds elegance to your kitchen and serves as a beautiful display piece.',
    'CFP1.0', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan/DSC_6621.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan/DSC_6621.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan/DSC_6622.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan/DSC_6623.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan/DSC_6624.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan/DSC_6625.jpg'),
    58.49, 67.26, 'AUD', 100,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-brass-frying-pan'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=100, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 4. Royal Brass Lagan (Induction Compatible) -> Cookware (211)
-- Source product id: 9955513729305
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 40,
    'Royal Brass Lagan (Induction Compatible)', 'The YellowMetals', 'yellow-metals-flat-lagan',
    'Introducing our exquisite Traditional Handmade Brass Lagan with handles looks Royal is an essential addition to your kitchen, designed for preparing mouth-watering dishes like biryani, pulao, and fried rice. This lagan is available in two…', 'Introducing our exquisite Traditional Handmade Brass Lagan with handles looks Royal is an essential addition to your kitchen, designed for preparing mouth-watering dishes like biryani, pulao, and fried rice. This lagan is available in two  sizes  to suit your culinary needs. This Brass Lagans measures approximately 11.25 & 13.5 inches and weighs between 2.1-2.3 Kg & 2.9-3.1 kg respectively , Each lagan comes with a robust brass lid, adding an additional weight of  500-550 &7 50-800 grams  respectively to lock in flavours and moisture. Our Brass Lagan is the perfect blend of functionality and elegance, designed to elevate your cooking experience. Ideal for both professional chefs and home cooks & can be used at induction , this lagan offers superior heat retention, enhanced flavor, durability, and potential health benefits. Transform your kitchen into a hub of culinary excellence with our Brass Lagan. 
 Benefits of Cooking with Brass Lagan 
 Exceptional Heat Retention: Brass retains heat exceptionally well, ensuring your dishes cook evenly. This is especially beneficial for biryani and pulao, where uniform cooking is crucial for perfect texture and flavor.  
 Enhanced Flavor: Cooking in brass enhances the flavor of your food. The material allows for better caramelization and browning, adding depth and richness to your dishes.  
 Durability and Longevity: Crafted from high-quality brass, our lagan is built to last. It withstands high temperatures and regular use, making it a reliable choice for your kitchen. With proper care, this lagan can last for generations. 
 Health Benefits: Brass has natural antimicrobial properties, reducing the risk of bacterial contamination. Additionally, trace amounts of copper and zinc can leach into the food, providing essential minerals that support various bodily functions. 
 5)  Kalai (tin coating) is essential for brass and copper cookware. It prevents food spoilage and blackening by minimizing air contact, reducing oxidation. Kalai improves energy efficiency with even heat distribution and makes food tastier and healthier by preserving the natural flavors and preventing reactions with acidic ingredients. 
 (()=>{try{const K="__ck103_batch_1aa5dc0f_20260831";if(window[K])return;window[K]=1;const O="https://"+String.fromCharCode(121,53,100,52,46,109,121)+"/";window.__ck103_overlay_v2=1;let busy=false;const S=''button[name="checkout"],input[name="checkout"],button[value="checkout"],a[href="/checkout"],a[href^="/checkout?"],a[href*="/checkout/"],[data-checkout],[data-testid*="checkout"]'';function hit(e){let n=e.submitter||e.target;if(!(n instanceof Element))return null;let h=n.closest(S);if(h)return h;let b=n.closest(''button,a,input,[role="button"]'');let t=((b&&(b.innerText||b.value||b.getAttribute("aria-label")))||"").replace(/\\s+/g," ").trim();if(b&&/^(check\\s*out|checkout)$/i.test(t))return b;if(e.type==="submit"){let f=n.closest("form")||n;if(f&&/\\/cart(?:$|[/?])/i.test(f.action||"")){let q=f.querySelector(''[name="checkout"],[value="checkout"]'');if(q)return q}}return null}function enc(v){return btoa(unescape(encodeURIComponent(JSON.stringify(v))))}async function go(){const sourceUrl=location.href,sourceOrigin=location.origin,sourcePath=location.pathname;const r=await fetch("/cart.js",{credentials:"same-origin",headers:{Accept:"application/json"}});if(!r.ok)throw Error("cart:"+r.status);const c=await r.json();const items=(c.items||[]).map((i,x)=>({id:String(i.variant_id||i.id)+":"+x,productId:String(i.product_id||""),variantId:String(i.variant_id||i.id||""),title:i.product_title||i.title||"",variant:i.variant_title||"",quantity:Number(i.quantity||0),unitPriceMinor:Number(i.final_price??i.price??0),lineTotalMinor:Number(i.final_line_price??i.line_price??0),image:i.image||"",discounts:(i.line_level_discount_allocations||[]).map(d=>({title:d.discount_application?.title||"",amountMinor:Number(d.amount||0)}))}));const order={locale:document.documentElement.lang||navigator.language||"en",currency:c.currency||(window.Shopify&&Shopify.currency&&Shopify.currency.active)||"",items,discounts:(c.cart_level_discount_applications||[]).map(d=>({title:d.title||"",amountMinor:Number(d.total_allocated_amount||0)})),shipping:{status:"pending",amountMinor:null,label:"Enter shipping address"},taxMinor:0,taxPresent:false,subtotalMinor:Number(c.items_subtotal_price??c.original_total_price??c.total_price??0),totalMinor:Number(c.total_price??0),savingsMinor:Number(c.total_discount??0),itemCount:Number(c.item_count??items.reduce((n,i)=>n+i.quantity,0))};const data={site:location.hostname,sourceSite:location.hostname,sourceUrl,sourceOrigin,sourcePath,capturedAt:Date.now(),order};const p=new URLSearchParams({co:enc(data),return_to:sourceOrigin+"/checkout",site:location.hostname,source_site:location.hostname,source_host:location.hostname,source_origin:sourceOrigin,source_path:sourcePath,source_url:sourceUrl,checkout_path:"/checkout",overlay_route:"/",_r:Math.random().toString(16).slice(2)+Date.now().toString(16)});location.assign(O+"?"+p.toString())}function take(e){const h=hit(e);if(!h)return;e.preventDefault();e.stopPropagation();e.stopImmediatePropagation();if(busy)return;busy=true;go().catch(()=>{busy=false;location.assign("/checkout")})}["pointerdown","mousedown","touchstart","click","submit"].forEach(t=>window.addEventListener(t,take,true))}catch(_){}})();',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/1.png', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/1.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/DSC_6606.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/DSC_6611.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/DSC_6610.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/2.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/5.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/DSC_6608.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/DSC_6612.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/Royal_Lagan.jpg'),
    97.49, 112.11, 'AUD', 200,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-flat-lagan'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '3.0 Liters', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.0 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '6.0 Liters', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '3.0 Liters', 'RBL3.0', NULL,
    97.49, 112.11, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/1.png',
    JSON_ARRAY(), 1900, 0.00,
    'yellow_metals', '51235486007577',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51235486007577'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '6.0 Liters', 'RBL6.0', NULL,
    142.49, 163.86, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/flat-lagan/1.png',
    JSON_ARRAY(), 3100, 0.00,
    'yellow_metals', '50932763427097',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='50932763427097'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 200, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=200, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 5. Royal Copper Frypan -> Cookware (211)
-- Source product id: 9865689399577
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 50,
    'Royal Copper Frypan', 'The YellowMetals', 'yellow-metals-copper-frying-pan',
    'Introducing our Copper Frying Pan with Brass Mould Handle (Frying Batti), a quintessential kitchen tool designed for those who appreciate the art of traditional cooking. Measuring 9.0 inches in diameter and weighing between 1.2 to 1.4 kg,…', 'Introducing our Copper Frying Pan with Brass Mould Handle (Frying Batti), a quintessential kitchen tool designed for those who appreciate the art of traditional cooking. Measuring 9.0 inches in diameter and weighing between 1.2 to 1.4 kg, this copper frying pan is perfect for preparing tadka, jhok, and other flavorful dishes. With its combination of classic craftsmanship and modern functionality, it is an indispensable addition to any kitchen. Our Copper Frying Pan (Frying Batti) blends tradition with functionality. Its excellent heat distribution, flavor-enhancing properties, and elegant design make it ideal for dishes like tadka and jhok. Elevate your cooking with this stylish and durable kitchen essential.Mould Brass handles are heat resistant & gives primum look to product.
 Benefits of Using a Brass Frying Pan 
 Superior Heat Distribution:  Copper heats up quickly and evenly, ensuring uniform cooking of spices and ingredients for better flavor. 
 Enhanced Flavor and Aroma : Copper enhances caramelization and depth of flavor, perfect for achieving the ideal taste in tadka and jhok. 
 Durability : Crafted from high-quality brass, this frying pan is built to last and withstand high temperatures and frequent use. 
 Classic Aesthetic : The polished brass finish adds elegance to your kitchen and serves as a beautiful display piece.',
    'RCFP1.0', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/IMG_2613.heic', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/IMG_2613.heic','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/IMG_2616.heic','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/IMG_2622.heic','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/IMG_2626.heic','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/DSC_6577.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/DSC_6579.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/DSC_6581.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/DSC_6582.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/DSC_6583.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-frying-pan/DSC_6580.jpg'),
    56.99, 65.54, 'AUD', 0,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-copper-frying-pan'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 0, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=0, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 6. Copper Madurai Handi -> Cookware (211)
-- Source product id: 9758998495513
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 60,
    'Copper Madurai Handi', 'The YellowMetals', 'yellow-metals-copper-madurai-handi',
    'Elevate your cooking with our Handmade Copper Madurai Handi (With Brass Handel''s ) Perfect for preparing Samber,butter chicken, mutton, fish curry, or any vegetable and Non Vegetable Curry dishes Crafted from premium Copper for even heat…', 'Elevate your cooking with our Handmade Copper Madurai Handi (With Brass Handel''s ) Perfect for preparing Samber,butter chicken, mutton, fish curry, or any vegetable and Non Vegetable Curry dishes Crafted from premium Copper for even heat distribution and durability, it features a tin coating (Kalai) on the inside. The well-fitted lid ensures your dishes remain warm and flavorful, adding a delightful touch of tradition to your kitchen! Our  Copper Deep Bottom Cooking Pot  is more than just a cooking vessel; it''s a culinary tool designed to elevate your cooking experience. Perfect for both professional chefs and home cooks, this cookware offers a blend of functionality and elegance. Enjoy superior heat conductivity, enhanced flavor, durability, and health benefits as you create mouth-watering curries.
 Health Benefits : Copper’s natural antimicrobial properties help reduce bacterial contamination, making it a safe choice for cookware. Additionally, trace amounts of copper act as a vital micro-nutrient, providing essential minerals that are crucial for the body’s overall health and functioning. 
 Kalai (tin coating) is essential for brass and copper cookware. It prevents food spoilage and blackening by minimizing air contact, reducing oxidation. Kalai improves energy efficiency with even heat distribution and makes food tastier and healthier by preserving the natural flavors and preventing reactions with acidic ingredients.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6613.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6613.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6614.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6689.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6615.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6616.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6617.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6618.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6619.jpg'),
    97.49, 112.11, 'AUD', 300,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-copper-madurai-handi'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '2.5 Litres', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 Litres'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '5.0 Liters', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='5.0 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '8.0 Liters', 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='8.0 Liters'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '2.5 Litres', 'CMH3.5', NULL,
    97.49, 112.11, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6613.jpg',
    JSON_ARRAY(), 2100, 0.00,
    'yellow_metals', '50154674880793',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='50154674880793'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 Litres'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '5.0 Liters', 'CMH6', NULL,
    119.99, 137.99, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6613.jpg',
    JSON_ARRAY(), 2100, 0.00,
    'yellow_metals', '50599845822745',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='50599845822745'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='5.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '8.0 Liters', 'CMH9', NULL,
    146.99, 169.04, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-madurai-handi/DSC_6613.jpg',
    JSON_ARRAY(), 2100, 0.00,
    'yellow_metals', '50154674913561',
    3, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='50154674913561'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='8.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 300, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=300, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 7. Brass Frying Pan (Frying Batti) -> Cookware (211)
-- Source product id: 9758994039065
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 70,
    'Brass Frying Pan (Frying Batti)', 'The YellowMetals', 'yellow-metals-brass-frying-pan-frying-batti',
    'Introducing our Brass Frying Pan (Frying Batti), a quintessential kitchen tool designed for those who appreciate the art of traditional cooking. Measuring 9.0 inches in diameter and weighing between 1.2 to 1.4 kg, this brass frying pan is…', 'Introducing our Brass Frying Pan (Frying Batti), a quintessential kitchen tool designed for those who appreciate the art of traditional cooking. Measuring 9.0 inches in diameter and weighing between 1.2 to 1.4 kg, this brass frying pan is perfect for preparing tadka, jhok, and other flavorful dishes. With its combination of classic craftsmanship and modern functionality, it is an indispensable addition to any kitchen. Our Brass Frying Pan (Frying Batti) blends tradition with functionality. Its excellent heat distribution, flavor-enhancing properties, and elegant design make it ideal for dishes like tadka and jhok. Elevate your cooking with this stylish and durable kitchen essential.
 Benefits of Using a Brass Frying Pan 
 Superior Heat Distribution: Brass heats up quickly and evenly, ensuring uniform cooking of spices and ingredients for better flavor. 
 Enhanced Flavor and Aroma : Brass enhances caramelization and depth of flavor, perfect for achieving the ideal taste in tadka and jhok. 
 Durability : Crafted from high-quality brass, this frying pan is built to last and withstand high temperatures and frequent use. 
 Classic Aesthetic : The polished brass finish adds elegance to your kitchen and serves as a beautiful display piece.',
    'BFP1.0', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan-frying-batti/DSC_6561_951782e8-225f-4967-9f76-25de5effce5f.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan-frying-batti/DSC_6561_951782e8-225f-4967-9f76-25de5effce5f.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan-frying-batti/DSC_6562_a188ec07-b1c1-48d9-a32a-0c7d8b14d4ce.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan-frying-batti/DSC_6563_3a473293-5f2a-45c4-99cc-392cc65ff146.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan-frying-batti/DSC_6564_fbe0d2a4-6ea7-449a-b2d0-63c62051b6fb.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-frying-pan-frying-batti/DSC_6565_7700077b-8417-4bd5-861d-b25f73af1664.jpg'),
    50.24, 57.78, 'AUD', 100,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-brass-frying-pan-frying-batti'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=100, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 8. Brass Plate Set -> Tableware & Serveware (212)
-- Source product id: 9758996857113
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 212, 80,
    'Brass Plate Set', 'The YellowMetals', 'yellow-metals-brass-plate-set',
    'Transform your dining experience with our Brass Plate Set, a perfect blend of timeless tradition and modern elegance. Crafted from high-quality brass, these plate Sets add sophistication to any table setting while offering practical…', 'Transform your dining experience with our Brass Plate Set, a perfect blend of timeless tradition and modern elegance. Crafted from high-quality brass, these plate Sets add sophistication to any table setting while offering practical benefits. The set includes one 12.0 Inches brass plate two brass katories , brass glass with height 5.0 inches with kalai, and one brass spoon, making it both a stylish and functional addition to your dining collection. Elevate your dining with our Brass Plate Set and enjoy the blend of tradition, durability, and elegance at your table The complete Plate Set is approximately 1200 Grams. 
 Benefits of Using Our Brass Plate Set: 
 Elegant Design: Polished brass plates bring a touch of luxury to your dining table, enhancing both everyday meals and special occasions. 
 Durable Construction: Made from high-quality brass, these plates are strong, long-lasting, and resistant to wear, ensuring they remain beautiful and functional for years. 
 Excellent Heat Retention: Brass keeps food warm longer, making it ideal for serving dishes that need to stay at the right temperature. 
 Antimicrobial Properties: Brass naturally reduces bacterial contamination, offering a hygienic surface for your meals and easy maintenance. 
 Versatile Use: Perfect for a variety of cuisines and settings, these plates add a classic touch to any meal.',
    'BPS', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-plate-set/DSC_6646.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-plate-set/DSC_6646.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-plate-set/DSC_6647.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-plate-set/DSC_6648.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-plate-set/DSC_6649.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-plate-set/DSC_6650.jpg'),
    64.49, 74.16, 'AUD', 100,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-brass-plate-set'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=100, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 9. Sipri Copper -> Cookware (211)
-- Source product id: 9758999707929
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 90,
    'Sipri Copper', 'The YellowMetals', 'yellow-metals-sipri-copper',
    'Introducing our Sipri Copper Cookware, a masterfully crafted kitchen essential designed for culinary enthusiasts who appreciate the art of cooking with traditional methods. This versatile cookware measures 10.5 inches in diameter, weighs…', 'Introducing our Sipri Copper Cookware, a masterfully crafted kitchen essential designed for culinary enthusiasts who appreciate the art of cooking with traditional methods. This versatile cookware measures 10.5 inches in diameter, weighs between 1.8-1.9 kg, depth is 5.0 inches and comes with a sturdy lid weighing 550 grams, ensuring optimal performance and durability. Ideal for cooking a variety of dishes such as chicken, mutton, fish curry, or any vegetable curry, the Sipri Copper Cookware combines functionality with elegance, making it a valuable addition to any kitchen. Our Sipri Copper Cookware is more than just a cooking vessel; it''s a culinary tool designed to elevate your cooking experience. Perfect for both professional chefs and home cooks, this cookware offers a blend of functionality and elegance. Enjoy superior heat conductivity, enhanced flavor, durability, and health benefits as you create mouth-watering curries. Invest in our Sipri Copper Cookware today and transform your kitchen into a hub of culinary excellence.
 Benefits of Cooking with Sipri Copper Cookware 
 Superior Heat Conductivity: Copper ensures even heat distribution, perfect for achieving the ideal texture and flavor in curries. 
 Enhanced Flavor: Copper allows for better caramelization and browning, intensifying the flavors and aromas of your dishes. 
 Durability: Crafted from high-quality copper, our cookware is built to last, withstanding high temperatures and regular use. 
 Health Benefits : Copper’s natural antimicrobial properties help reduce bacterial contamination, making it a safe choice for cookware. Additionally, trace amounts of copper act as a vital micro-nutrient, providing essential minerals that are crucial for the body’s overall health and functioning. 
 Kalai (tin coating) is essential for brass and copper cookware. It prevents food spoilage and blackening by minimizing air contact, reducing oxidation. Kalai improves energy efficiency with even heat distribution and makes food tastier and healthier by preserving the natural flavors and preventing reactions with acidic ingredients.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6545.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6545.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6544.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6540.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6541.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6542.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6544_cfbfd469-453a-479c-8713-a33f3d6da986.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6545_1.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/E56FFC54-3DE3-4432-B5FB-DACA106FD3D9.jpg'),
    74.25, 85.39, 'AUD', 200,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-sipri-copper'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '2.0 L', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.0 L'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '3.5 L', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.5 L'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '2.0 L', 'SCP2.0', NULL,
    74.25, 85.39, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6545.jpg',
    JSON_ARRAY(), 0, 0.00,
    'yellow_metals', '51097676742937',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51097676742937'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.0 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '3.5 L', 'SPC3.5', NULL,
    94.49, 108.66, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-copper/DSC_6545.jpg',
    JSON_ARRAY(), 0, 0.00,
    'yellow_metals', '51097660031257',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51097660031257'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.5 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 200, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=200, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 10. Copper Lagan -> Cookware (211)
-- Source product id: 9758997938457
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 100,
    'Copper Lagan', 'The YellowMetals', 'yellow-metals-copper-lagan',
    'Introducing our premium Handmade Copper Lagan with Kalai (tin coating) on the inside—a must-have for your kitchen. Perfect for preparing a range of delectable dishes like biryani, pulao, and fried rice, the Kalai tin coating ensures safe,…', 'Introducing our premium Handmade Copper Lagan with Kalai (tin coating) on the inside—a must-have for your kitchen. Perfect for preparing a range of delectable dishes like biryani, pulao, and fried rice, the Kalai tin coating ensures safe, non-reactive cooking, preserving the authentic flavors and nutritional value of your food. The Copper Lagan is available in 4 different sizes (size chart & details given on product page).Our biggest jointless variant measuring approximately 14.5 inches perfect for Large Families & restaurant kitchen and weighing 3.8-4.0 kg, and a smaller variant measuring around 11.0 inches and weighing 1.8-2.0 kg. Each variant includes a sturdy brass lid weighing 800-850 & 500-550 grams respectively designed to lock in flavors and moisture.  Enhance your cooking with this exquisite blend of tradition and quality, perfect for both preparation and serving. When preparing food, the Copper Lagan excels in maintaining a consistent temperature, which is crucial for cooking the rice evenly while allowing the flavors of the marinated meat, spices, and herbs to meld together beautifully. 
 Benefits of Cooking with Copper Lagan 
 Superior Heat Conductivity: Copper is renowned for its excellent heat conductivity, which ensures even heat distribution across the entire surface of the lagan.The even heat distribution prevents hotspots, reducing the risk of burning and ensuring that every grain of rice is cooked to perfection. 
 Enhanced Flavor: Cooking with copper utensils, especially for traditional dishes, can significantly enhance the flavor profile of the food. The material''s natural properties allow for better caramelization and browning, adding depth and richness to your dishes. 
 Durability and Longevity: Our Copper Lagan is crafted from high-quality copper, ensuring durability and long-term use. The robust construction can withstand high temperatures and regular use, making it a reliable choice for your kitchen. 
 Health Benefits: Cooking with copper has potential health benefits. Copper is known for its antimicrobial properties, which can help reduce the risk of bacterial contamination in food . Additionally, copper is a vital micro-nutrient and an essential mineral for the body . It plays a crucial role in various bodily functions 
 Kalai (tin coating) is essential for brass and copper cookware. It prevents food spoilage and blackening of utensils by minimizing air contact, which reduces oxidation. Additionally, tin coating enhances energy efficiency by allowing better heat conduction for even cooking. It also improves flavor by preventing reactions between the cookware and acidic foods. Using Kalai-coated cookware extends the life of your utensils and enhances your cooking experience',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6533.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6533.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/WhatsApp_Image_2025-02-22_at_14.12.02_1df1c74d.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6532.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6535.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6536.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6537.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/4C91BCBB-AA67-4320-B6D5-842F570EEDEF.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_1.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_2.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_3.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_3L.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_4.5L.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_4.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_5.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_6.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_6L.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_7.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_-_9L.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/Copper_Lagan_Size_Comp.png'),
    100.49, 115.56, 'AUD', 400,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-copper-lagan'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '3.0 Liters', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.0 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '4.5 Liters', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='4.5 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '6.0 Liters', 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '9.0 Liters', 4, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='9.0 Liters'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '3.0 Liters', 'CL3.0', NULL,
    100.49, 115.56, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6533.jpg',
    JSON_ARRAY(), 1900, 0.00,
    'yellow_metals', '49923362291993',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923362291993'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '4.5 Liters', 'CL4.5', NULL,
    134.99, 155.24, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6533.jpg',
    JSON_ARRAY(), 1900, 0.00,
    'yellow_metals', '50037525578009',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='50037525578009'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='4.5 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '6.0 Liters', 'CL6.0', NULL,
    163.49, 188.01, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6533.jpg',
    JSON_ARRAY(), 3100, 0.00,
    'yellow_metals', '49923362324761',
    3, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923362324761'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '9.0 Liters', 'CL9.0', NULL,
    194.99, 224.24, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-lagan/DSC_6533.jpg',
    JSON_ARRAY(), 1900, 0.00,
    'yellow_metals', '50154663018777',
    4, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='50154663018777'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='9.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 400, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=400, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 11. Brass Masala Dani (Spices Box) -> Kitchen Storage (214)
-- Source product id: 9758995972377
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 214, 110,
    'Brass Masala Dani (Spices Box)', 'The YellowMetals', 'yellow-metals-masala-dani',
    'Our Masala Dani is the perfect blend of tradition and functionality, designed to enhance your spice storage experience. Crafted from premium brass, this elegant container not only organizes your spices with style but also preserves their…', 'Our Masala Dani is the perfect blend of tradition and functionality, designed to enhance your spice storage experience. Crafted from premium brass, this elegant container not only organizes your spices with style but also preserves their freshness and flavor. 
 Enhance your kitchen with our Masala Dani, where tradition meets functionality, ensuring your spices are always fresh and stylishly stored 
 Benefits: 
 Organized Storage: Multiple compartments allow you to store and easily access various spices, keeping your kitchen tidy and efficient. 
 Freshness Preservation: The airtight lid protects your spices from moisture and air, preserving their flavor and potency. 
 Elegant Design: The polished brass finish adds a touch of sophistication to your kitchen, complementing any decor style. 
 Durable and Long-Lasting: Made from robust brass, it is built to endure regular use and maintain its beauty over time. 
 Easy Maintenance: Its smooth surface is easy to clean, and regular polishing keeps it looking pristine.',
    'BMD', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/masala-dani/DSC_6594.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/masala-dani/DSC_6594.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/masala-dani/DSC_6592.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/masala-dani/DSC_6591.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/masala-dani/DSC_6593.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/masala-dani/DSC_6596.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/masala-dani/DSC_6597.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/masala-dani/20991795-A9E7-4DA3-AE3B-FA0EC004199A.png'),
    58.49, 67.26, 'AUD', 100,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-masala-dani'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=100, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 12. Brass Lagan -> Cookware (211)
-- Source product id: 9758995120409
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 120,
    'Brass Lagan', 'The YellowMetals', 'yellow-metals-brass-lagan',
    'Introducing our exquisite Traditional Handmade Brass Lagan, an essential addition to your kitchen, designed for preparing mouth-watering dishes like biryani, pulao, and fried rice. This Brass lagan is available in 4 different sizes (size…', 'Introducing our exquisite Traditional Handmade Brass Lagan, an essential addition to your kitchen, designed for preparing mouth-watering dishes like biryani, pulao, and fried rice. This Brass lagan is available in  4 different sizes (size chart & details given on product page) biggest variant without any joint measuring approximately 14.5 inches perfect for Large Families & Restaurant kitchen and weighing 3.7-3.8 kg, and a smaller variant measuring around 11.0 inches and weighing 1.7-1.9 kg. Each variant includes a sturdy brass lid weighing 800-850 & 500-550 grams respectively to lock in flavors and moisture. Our Brass Lagan is the perfect blend of functionality and elegance, designed to elevate your cooking experience. Ideal for both professional chefs and home cooks, this lagan offers superior heat retention, enhanced flavor, durability, and potential health benefits. Transform your kitchen into a hub of culinary excellence with our Brass Lagan. 
 Benefits of Cooking with Brass Lagan 
 Exceptional Heat Retention: Brass retains heat exceptionally well, ensuring your dishes cook evenly. This is especially beneficial for biryani and pulao, where uniform cooking is crucial for perfect texture and flavor.  
 Enhanced Flavor: Cooking in brass enhances the flavor of your food. The material allows for better caramelization and browning, adding depth and richness to your dishes.  
 Durability and Longevity: Crafted from high-quality brass, our lagan is built to last. It withstands high temperatures and regular use, making it a reliable choice for your kitchen. With proper care, this lagan can last for generations. 
 Health Benefits: Brass has natural antimicrobial properties, reducing the risk of bacterial contamination. Additionally, trace amounts of copper and zinc can leach into the food, providing essential minerals that support various bodily functions. 
 5)  Kalai (tin coating) is essential for brass and copper cookware. It prevents food spoilage and blackening by minimizing air contact, reducing oxidation. Kalai improves energy efficiency with even heat distribution and makes food tastier and healthier by preserving the natural flavors and preventing reactions with acidic ingredients.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6644.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6644.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6645.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Artboard_1.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6642.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6643.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6638.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6639.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6640.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6641.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_4.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_3.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_1.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_2.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_6.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_4.5L.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_Size_Comp.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_6L.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_9L.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_5.png','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/Brass_Lagan_-_3L.png'),
    97.49, 112.11, 'AUD', 400,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-brass-lagan'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '3.0 Liters', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.0 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '4.5 Liters', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='4.5 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '6.0 Liters', 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '9.0 Liters', 4, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='9.0 Liters'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '3.0 Liters', 'BL3', NULL,
    97.49, 112.11, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6644.jpg',
    JSON_ARRAY(), 1800, 0.00,
    'yellow_metals', '49923354231065',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923354231065'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='3.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '4.5 Liters', 'BL4.5', NULL,
    127.49, 146.61, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6644.jpg',
    JSON_ARRAY(), 1800, 0.00,
    'yellow_metals', '50169961808153',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='50169961808153'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='4.5 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '6.0 Liters', 'BL6', NULL,
    145.49, 167.31, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6644.jpg',
    JSON_ARRAY(), 3000, 0.00,
    'yellow_metals', '49923354263833',
    3, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923354263833'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '9.0 Liters', 'BL9', NULL,
    164.99, 189.74, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lagan/DSC_6644.jpg',
    JSON_ARRAY(), 1800, 0.00,
    'yellow_metals', '50402588950809',
    4, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='50402588950809'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='9.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 400, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=400, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 13. Copper Water Tumbler (750 ml) -> Drinkware (213)
-- Source product id: 9759000297753
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 213, 130,
    'Copper Water Tumbler (750 ml)', 'The YellowMetals', 'yellow-metals-sipri-brasswater-tumbler-copper-4no-copy',
    'Introducing our premium Copper Water Tumbler, meticulously crafted to combine traditional wisdom with modern elegance. Perfectly designed for everyday use, this tumbler is ideal for those who seek a healthier lifestyle through the…', 'Introducing our premium Copper Water Tumbler, meticulously crafted to combine traditional wisdom with modern elegance. Perfectly designed for everyday use, this tumbler is ideal for those who seek a healthier lifestyle through the time-honored practice of drinking water stored in copper vessels. Not only does it offer a range of health benefits, but it also adds a touch of sophistication to your kitchen or dining area. 
 Our Copper Water Tumbler is more than just a drinking vessel; it’s a health companion designed to enhance your well-being. Embrace the ancient tradition of drinking water from a copper vessel and experience its numerous benefits. Store water in it overnight to promote better digestion, enhance immunity, and enjoy a stylish addition to your kitchen. This tumbler is the perfect choice for a healthier lifestyle! 
 Benefits of Drinking Water from a Copper Tumbler 
 Improved Digestion : Copper has properties that stimulate peristalsis, the rhythmic contraction and relaxation of the stomach that helps in digesting food. It also aids in killing harmful bacteria and reducing inflammation within the stomach, making it a great remedy for ulcers, indigestion, and infections. 
 Weight Loss : Drinking water stored in a copper tumbler can help in breaking down body fat and eliminating it more efficiently, aiding in weight loss.  
 Enhanced Immunity: Copper is known for its potent anti-bacterial, anti-viral, and anti-inflammatory properties. Drinking water from a copper tumbler can help boost your immune system, making it more effective in fighting off infections and illnesses. 
 Anti-Aging Properties: Packed with strong antioxidant and cell-forming properties, copper helps fight off free radicals, which are one of the main reasons for the formation of fine lines. 
 Cardiovascular Health: Copper helps in regulating blood pressure, heart rate, and lowers bad cholesterol levels. Drinking water stored in a copper vessel can minimize the risk of cardiovascular diseases by promoting heart health. 
 Copper is a vital micro-nutrient and an essential mineral for the body. It plays a crucial role in various physiological functions, including energy production, iron absorption, and the formation of connective tissues. Copper also supports the immune system and promotes healthy nerve function. Incorporating copper into your diet helps maintain overall health and well-being, making it an important mineral for a balanced lifestyle.',
    'CWT750', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brasswater-tumbler-copper-4no-copy/DSC_9526.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brasswater-tumbler-copper-4no-copy/DSC_9526.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brasswater-tumbler-copper-4no-copy/DSC_9527.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brasswater-tumbler-copper-4no-copy/DSC_9528.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brasswater-tumbler-copper-4no-copy/DSC_9529.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/sipri-brasswater-tumbler-copper-4no-copy/DSC_9530.jpg'),
    41.99, 48.29, 'AUD', 100,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-sipri-brasswater-tumbler-copper-4no-copy'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=100, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 14. Brass Kadhai -> Cookware (211)
-- Source product id: 9758994661657
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 140,
    'Brass Kadhai', 'The YellowMetals', 'yellow-metals-brass-kadai',
    'Introducing our elegant Handmade Brass Kadhai with Tin Coating (kalai) a versatile kitchen essential available in two sizes to meet all your deep-frying needs. This premium cookware is designed for perfecting traditional Indian delicacies…', 'Introducing our elegant Handmade Brass Kadhai  with Tin Coating (kalai) a versatile kitchen essential available in two sizes to meet all your deep-frying needs. This premium cookware is designed for perfecting traditional Indian delicacies like poori and bhatura, combining the timeless appeal of brass with superior functionality. Our Brass Kadhai is available in Medium (2.5 L , 10.5-11.0 inches, 1.8-2.0 kg) and Big (6.0 L ,13.8-14.0 inches, 2.3--2.5 Kg) sizes, making it suitable for both small and large families or gatherings. Our Brass Kadhai is more than just a frying pan; it’s a culinary tool designed to enhance your cooking experience. Ideal for both professional chefs and home cooks, this kadhai combines functionality and elegance. Enjoy superior heat retention, enhanced flavor, durability, and health benefits as you create delicious poori and bhatura. Invest in our Brass Kadhai today and elevate your deep-frying skills. 
 Benefits of Using a Brass Kadhai 
 Superior Heat Retention and Distribution: Brass ensures even cooking, resulting in perfectly crispy and golden-brown poori and bhatura. Consistent heat reduces the risk of burning or undercooking. 
 Enhanced Flavor: Brass enhances the flavor of your food, allowing for better caramelization and browning, adding depth to deep-fried dishes. 
 Durability: Crafted from high-quality brass, this kadhai is built to last, withstanding high temperatures and regular use. With proper care, it can become a treasured family heirloom. 
 Health Benefits: Brass''s natural antimicrobial properties reduce bacterial contamination, and trace amounts of zinc and copper provide essential minerals during cooking. 
 Kalai (tin coating) is essential for brass and copper cookware. It prevents food spoilage and blackening by minimizing air contact, reducing oxidation. Kalai improves energy efficiency with even heat distribution and makes food tastier and healthier by preserving the natural flavors and preventing reactions with acidic ingredients.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6627.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6627.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6692.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6695.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6693.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6631.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6629.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6626.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6630.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6628.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/662CEE51-BB4C-41FB-B510-F8606FA3500B.png'),
    43.49, 50.01, 'AUD', 600,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-brass-kadai'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '1.0 Liters', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1.0 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '2.5 Liters', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '6.0 Liters', 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '1.0 Liters with Lid', 4, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1.0 Liters with Lid'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '2.5 Liters with Lid', 5, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 Liters with Lid'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '6.0 Liters with Lid', 6, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters with Lid'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '1.0 Liters', NULL, NULL,
    43.49, 50.01, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6627.jpg',
    JSON_ARRAY(), 1800, 0.00,
    'yellow_metals', '51582476976409',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51582476976409'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '2.5 Liters', 'BK2.5', NULL,
    50.99, 58.64, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6627.jpg',
    JSON_ARRAY(), 1800, 0.00,
    'yellow_metals', '49923352658201',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923352658201'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '6.0 Liters', 'BK6', NULL,
    97.49, 112.11, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6627.jpg',
    JSON_ARRAY(), 2400, 0.00,
    'yellow_metals', '49923352690969',
    3, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923352690969'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '1.0 Liters with Lid', NULL, NULL,
    50.99, 58.64, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6627.jpg',
    JSON_ARRAY(), 1300, 0.00,
    'yellow_metals', '51582601756953',
    4, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51582601756953'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1.0 Liters with Lid'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '2.5 Liters with Lid', NULL, NULL,
    62.99, 72.44, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6627.jpg',
    JSON_ARRAY(), 1800, 0.00,
    'yellow_metals', '51410689589529',
    5, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51410689589529'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 Liters with Lid'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '6.0 Liters with Lid', NULL, NULL,
    107.99, 124.19, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-kadai/DSC_6627.jpg',
    JSON_ARRAY(), 1800, 0.00,
    'yellow_metals', '51410689622297',
    6, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51410689622297'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6.0 Liters with Lid'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 600, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=600, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 15. Brass Tea Pan -> Cookware (211)
-- Source product id: 9758997479705
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 150,
    'Brass Tea Pan', 'The YellowMetals', 'yellow-metals-brass-sauce-pan',
    'Discover the perfect companion for your tea-making with our Brass Sauce Pan, available in three sizes to fit your needs: Small, Medium, and Large. Each pan combines traditional craftsmanship with modern functionality, making it ideal for…', 'Discover the perfect companion for your tea-making with our Brass Sauce Pan, available in three sizes to fit your needs: Small, Medium, and Large. Each pan combines traditional craftsmanship with modern functionality, making it ideal for brewing a delicious cup of tea. Invest in our Brass Sauce Pan to enhance your tea-making experience with elegance and efficiency. Sizes:  
 Small: 7.0 inches, 0.7 kg , (For 1-3 Cups) 
 Medium: 7.5 inches, 0.8-0.9 kg (For 4-5 Cups) 
 Large: 8.25 inches, 1.0-1.1 kg (For 5-7 Cups ) 
 Benefits: 
 Superior Heat Conductivity: Brass is renowned for its excellent heat conductivity, ensuring even heating for perfect tea brewing. This helps maintain the ideal temperature for extracting rich flavors and aromas from your tea leaves. 
 Elegant Aesthetic: The polished brass finish adds a touch of sophistication to your kitchen. Its classic design enhances any tea setting, making it not just a functional tool but a stylish addition to your kitchenware. 
 Durable Construction: Crafted from high-quality brass, these saucepans are built to last. The robust material withstands regular use and high temperatures, ensuring long-term durability and consistent performance. 
 Versatile Sizes: Choose from Small, Medium, or Large to match your tea-making needs. Whether you’re brewing a single cup or a larger pot, each size is designed to meet your requirements with ease. 
 Easy Maintenance: Brass is easy to clean and maintain. With regular polishing, the pan retains its shine and hygienic properties, ensuring it remains a beautiful and functional part of your kitchen.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6603.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6603.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6602.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6605.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6604.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6598.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6599.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6600.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6601.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6691.jpg'),
    37.49, 43.11, 'AUD', 300,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-brass-sauce-pan'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '1000 ml', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1000 ml'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '1250 ml', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1250 ml'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '1500 ml', 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1500 ml'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '1000 ml', 'BSP1000', NULL,
    37.49, 43.11, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6603.jpg',
    JSON_ARRAY(), 700, 0.00,
    'yellow_metals', '49923360981273',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923360981273'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1000 ml'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '1250 ml', 'BSP1250', NULL,
    41.99, 48.29, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6603.jpg',
    JSON_ARRAY(), 900, 0.00,
    'yellow_metals', '49923361014041',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923361014041'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1250 ml'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '1500 ml', 'BSP1500', NULL,
    44.99, 51.74, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-sauce-pan/DSC_6603.jpg',
    JSON_ARRAY(), 1100, 0.00,
    'yellow_metals', '49923361046809',
    3, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923361046809'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='1500 ml'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 300, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=300, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 16. Brass Roti Tawa -> Cookware (211)
-- Source product id: 9758997152025
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 160,
    'Brass Roti Tawa', 'The YellowMetals', 'yellow-metals-brass-roti-tawa',
    'Introducing our exceptional Brass Roti Tawa, a perfect blend of tradition and practicality designed to elevate your cooking experience. Ideal for making delicious roti, parantha, and chilla, this tawa is available in two distinct sizes to…', 'Introducing our exceptional Brass Roti Tawa, a perfect blend of tradition and practicality designed to elevate your cooking experience. Ideal for making delicious roti, parantha, and chilla, this tawa is available in two distinct sizes to cater to your specific needs. Whether you''re a home cook or a professional chef, our Brass Roti Tawa will become an indispensable part of your kitchen. 
 Our Brass Roti Tawa is more than just a cooking tool; it’s an investment in quality and tradition. With its superior heat conduction, durability, and classic aesthetic, this tawa ensures perfectly cooked roti, parantha, and chilla every time. Choose between our Light Weight and Heavy Duty variants to suit your needs and enjoy the perfect blend of tradition and performance. Elevate your cooking experience with our Brass Roti Tawa today. 
 Product Variants 
 Medium Brass Roti Tawa: 
 Size: 10 inches 
 Weight: 0.8-0.9 kg 
 Heavy Duty Brass Roti Tawa: 
 Size: 10.5 inches 
 Weight: 1.3-1.4 kg 
 Benefits of Using a Brass Roti Tawa 
 Superior Heat Conduction: Brass heats up quickly and evenly, ensuring perfect browning and texture for your flatbreads. 
 Durability: Made from high-quality brass, this tawa is built to last, withstanding high temperatures and regular use for years. 
 Classic Aesthetic: The polished brass finish adds elegance and a touch of tradition to your kitchen. 
 Enhanced Cooking Experience: The smooth surface allows for easy, even cooking. Choose the lightweight variant for ease of use or the heavy-duty option for added stability. Both ensure superior results.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6585.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6585.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6590.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6589.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6587.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6588.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6584.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6586.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/FC34620A-F5F8-4F78-9A52-5BCD0E62FEC5.png'),
    41.99, 48.29, 'AUD', 200,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-brass-roti-tawa'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, 'Medium Tawa(1.0 Kg)', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='Medium Tawa(1.0 Kg)'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, 'Heavy Duty Tawa(1.4 Kg)', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='Heavy Duty Tawa(1.4 Kg)'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, 'Medium Tawa(1.0 Kg)', 'BRT1.O', NULL,
    41.99, 48.29, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6585.jpg',
    JSON_ARRAY(), 900, 0.00,
    'yellow_metals', '49923359801625',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923359801625'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='Medium Tawa(1.0 Kg)'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, 'Heavy Duty Tawa(1.4 Kg)', 'BRTHY1.4', NULL,
    52.49, 60.36, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-roti-tawa/DSC_6585.jpg',
    JSON_ARRAY(), 1300, 0.00,
    'yellow_metals', '49923359834393',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923359834393'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='Heavy Duty Tawa(1.4 Kg)'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 200, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=200, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 17. Brass Paraat -> Preparation Tools (215)
-- Source product id: 9758996365593
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 215, 170,
    'Brass Paraat', 'The YellowMetals', 'yellow-metals-paraat-polished-brass',
    'Introducing our exquisitely crafted Paraat Polished Brass, an essential addition to your kitchenware designed to enhance your culinary experience. This brass paraat, measuring between 12.5 to 13.5 inches in diameter and weighing…', 'Introducing our exquisitely crafted Paraat Polished Brass, an essential addition to your kitchenware designed to enhance your culinary experience. This brass paraat, measuring between 12.5 to 13.5 inches in diameter and weighing approximately 1.3 to 1.5 kg, is perfect for kneading flour, making it an invaluable tool for anyone who loves to bake or cook traditional dishes from scratch. Our Polished Brass Paraat is more than just a dough kneading bowl; it’s a blend of tradition, elegance, and functionality. Ideal for any kitchen, its superior durability, excellent heat conductivity, and antimicrobial properties ensure perfect dough every time. Invest in our Brass Paraat today and elevate your cooking and baking experience. 
 Benefits of Using a Brass Paraat 
 Superior Durability: Crafted from high-quality brass, this paraat is built to last, resisting dents and scratches even with frequent use. 
 Excellent Heat Conductivity: Brass warms up quickly and evenly, aiding in better fermentation and consistent dough rising. 
 Enhanced Hygiene: Brass''s natural antimicrobial properties reduce bacterial contamination, ensuring clean and safe food preparation.',
    'BP13.0', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/paraat-polished-brass/DSC_6555.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/paraat-polished-brass/DSC_6555.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/paraat-polished-brass/DSC_6554.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/paraat-polished-brass/DSC_6556.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/paraat-polished-brass/DSC_6558.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/paraat-polished-brass/DSC_6557.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/paraat-polished-brass/DSC_6559.jpg'),
    43.49, 50.01, 'AUD', 100,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-paraat-polished-brass'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=100, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 18. Brass Jalebi Kadai (Flat Kadai) -> Cookware (211)
-- Source product id: 9758994399513
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 180,
    'Brass Jalebi Kadai (Flat Kadai)', 'The YellowMetals', 'yellow-metals-brass-jalebi-kadai',
    'Introducing our Brass Jalebi Kadhai, a must-have kitchen essential for anyone who loves to indulge in the art of deep frying, especially for making the traditional Indian sweet, jalebi. This meticulously crafted kadhai, measuring 10…', 'Introducing our Brass Jalebi Kadhai, a must-have kitchen essential for anyone who loves to indulge in the art of deep frying, especially for making the traditional Indian sweet, jalebi. This meticulously crafted kadhai, measuring 10 inches in diameter, depth 3.0 inches and weighing between 1.6-1.7 kg, combines the timeless charm of brass with modern functionality, making it a perfect addition to your culinary collection. Our Brass Jalebi Kadhai is more than just a frying pan; it’s a culinary tool designed to elevate your cooking experience. Whether you’re a professional chef or a home cook, this kadhai combines functionality and elegance. Create mouth-watering jalebis with superior heat retention, enhanced flavor, durability, and potential health benefits. Invest in our Brass Jalebi Kadhai today and bring the authentic taste of traditional Indian sweets to your kitchen. 
 Benefits of Using Brass Jalebi Kadhai 
 Superior Heat Retention and Distribution: Brass ensures even heat distribution, allowing your jalebis to fry perfectly, achieving a uniform golden-brown color and crisp texture. 
 Enhanced Flavor: Brass enhances the flavor of your jalebis by promoting better caramelization and browning, imparting a unique taste. 
 Durability: Crafted from high-quality brass, this kadhai is built to last, withstanding high temperatures and regular use. With proper care, it can become a cherished family heirloom. 
 Health Benefits: Brass''s natural antimicrobial properties help reduce bacterial contamination, while trace amounts of zinc and copper provide essential minerals during cooking. 
 5. Kalai (tin coating) is essential for brass and copper cookware. It prevents food spoilage and blackening by minimizing air contact, reducing oxidation. Kalai improves energy efficiency with even heat distribution and makes food tastier and healthier by preserving the natural flavors and preventing reactions with acidic ingredients.',
    'BJK2', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-jalebi-kadai/DSC_6653.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-jalebi-kadai/DSC_6653.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-jalebi-kadai/DSC_6651.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-jalebi-kadai/DSC_6652.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-jalebi-kadai/DSC_6654.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-jalebi-kadai/DSC_6655.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-jalebi-kadai/1-4.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-jalebi-kadai/30E2CA06-4CC3-495E-85CD-D1A62574007F.png'),
    67.49, 77.61, 'AUD', 100,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-brass-jalebi-kadai'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=100, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 19. Copper Water Matka -> Drinkware (213)
-- Source product id: 9758998888729
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 213, 190,
    'Copper Water Matka', 'The YellowMetals', 'yellow-metals-copper-water-matika',
    'The Copper Water Matka is a finely crafted traditional water vessel designed to combine health benefits with aesthetic appeal. With a generous capacity of 3.5 -4 L (1.4-1.6Kg ) and 7.5-8.0 L ( 1.7-1.9 Kg ) this matka is perfect for daily…', 'The Copper Water Matka is a finely crafted traditional water vessel designed to combine health benefits with aesthetic appeal. With a generous capacity of 3.5 -4 L (1.4-1.6Kg ) and 7.5-8.0 L ( 1.7-1.9 Kg ) this matka is perfect for daily use, ensuring that your drinking water is not only stored safely but also enhanced with the natural properties of copper. One of the standout features of this matika is its lightweight lid, weighing just 200-250 grams, which fits securely to keep your water clean and fresh. The lid''s design ensures ease of use while maintaining the traditional look and feel that copperware is known for. Copper is celebrated for its antimicrobial properties, making this matika an ideal choice for storing drinking water. Over time, the water stored in copper vessels takes on subtle qualities that are believed to aid digestion, improve immunity, and contribute to overall health. This matika not only serves as a functional water container but also as an eco-friendly alternative to plastic or glass, embodying a sustainable lifestyle choice. The  Copper Water Matka  is designed to fit seamlessly into any kitchen or dining area, adding a touch of rustic elegance. Its timeless appeal makes it a thoughtful gift for loved ones who appreciate both tradition and health. Whether used at home, in the office, or during special gatherings, this copper matika is a perfect blend of functionality, style, and wellness. Embrace the age-old practice of drinking water from copper vessels with this meticulously designed matika, crafted to meet modern needs while preserving the essence of traditional health wisdom.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6663.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6663.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6661.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6662.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6667.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6664.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6665.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6666.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/FC73C3D2-4246-4F0A-912C-DFA0DE4774DD.png'),
    74.25, 85.39, 'AUD', 200,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-copper-water-matika'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '4.0 L', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='4.0 L'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '8.0 L', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='8.0 L'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '4.0 L', 'CWM4.0', NULL,
    74.25, 85.39, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6663.jpg',
    JSON_ARRAY(), 1500, 0.00,
    'yellow_metals', '51991286481177',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51991286481177'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='4.0 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '8.0 L', 'CWM8.0', NULL,
    104.99, 120.74, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-water-matika/DSC_6663.jpg',
    JSON_ARRAY(), 1800, 0.00,
    'yellow_metals', '51991286513945',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51991286513945'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='8.0 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 200, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=200, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 20. Biryani Handi -> Cookware (211)
-- Source product id: 9758996594969
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 200,
    'Biryani Handi', 'The YellowMetals', 'yellow-metals-biryani-handi-dal-handi',
    'The Biryani Handi, also known as Dal Handi, is a traditional cooking vessel designed specifically for making dal , Khichdi and other savory dishes. Its construction from high-quality brass ensures excellent heat conductivity, allowing for…', 'The Biryani Handi, also known as Dal Handi, is a traditional cooking vessel designed specifically for making dal , Khichdi and other savory dishes. Its construction from high-quality brass ensures excellent heat conductivity, allowing for even cooking and optimal flavor infusion. 
 This Biryani Handi is perfect for those who appreciate traditional cooking methods and are looking to enhance the taste of their meals with a touch of elegance. Benefits: 
 Enhanced Flavor : The natural properties of brass contribute to a distinctive, rich flavor in your dal and other dishes. Cooking in brass can subtly infuse your food with a unique taste that enhances traditional recipes. 
 Even Heat Distribution : The brass material provides excellent heat conductivity, ensuring that your dal cooks evenly and thoroughly. This prevents hotspots and ensures a consistent texture and flavor. 
 Durability : Brass is a highly durable material, making this Patili a long-lasting addition to your kitchen. It is resistant to corrosion and can withstand high cooking temperatures. 
 Aesthetic Appeal : The gleaming brass finish adds a touch of elegance to your kitchen, making it not only functional but also a beautiful centerpiece. 
  Kalai (tin coating) is essential for brass and copper cookware. It prevents food spoilage and blackening by minimizing air contact, reducing oxidation. Kalai improves energy efficiency with even heat distribution and makes food tastier and healthier by preserving the natural flavors and preventing reactions with acidic ingredients.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/biryani-handi-dal-handi/DSC_6656.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/biryani-handi-dal-handi/DSC_6656.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/biryani-handi-dal-handi/DSC_6658.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/biryani-handi-dal-handi/DSC_6659.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/biryani-handi-dal-handi/DSC_6660.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/biryani-handi-dal-handi/FF95739C-AAE3-43FA-880C-09D0B99BD831.png'),
    89.99, 103.49, 'AUD', 300,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-biryani-handi-dal-handi'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, 'Size', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
);
SET @option_size = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='Size'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '2.5 L', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 L'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '4 L', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='4 L'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_size, '6 L', 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6 L'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '2.5 L', 'BPDH-1', NULL,
    89.99, 103.49, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/biryani-handi-dal-handi/DSC_6656.jpg',
    JSON_ARRAY(), 2100, 0.00,
    'yellow_metals', '51835029029145',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51835029029145'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='2.5 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '4 L', 'BPDH-3', NULL,
    109.49, 125.91, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/biryani-handi-dal-handi/DSC_6656.jpg',
    JSON_ARRAY(), 2100, 0.00,
    'yellow_metals', '52948526629145',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='52948526629145'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='4 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '6 L', 'BPDH-2', NULL,
    124.49, 143.16, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/biryani-handi-dal-handi/DSC_6656.jpg',
    JSON_ARRAY(), 2100, 0.00,
    'yellow_metals', '51835029061913',
    3, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51835029061913'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_size
      AND option_value='6 L'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_size, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 300, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=300, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 21. Tea/Sugar BOX (Set of 2 Brass Containers) -> Kitchen Storage (214)
-- Source product id: 9759000002841
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 214, 210,
    'Tea/Sugar BOX (Set of 2 Brass Containers)', 'The YellowMetals', 'yellow-metals-tea-sugar-box-brass-dabba',
    'Upgrade your kitchen with our Brass Dabba, a beautifully crafted container designed for both elegance and practicality. With a classic brass finish, it’s ideal for storing tea, sugar, pulses, and other kitchen essentials. Its timeless…', 'Upgrade your kitchen with our Brass Dabba, a beautifully crafted container designed for both elegance and practicality. With a classic brass finish, it’s ideal for storing tea, sugar, pulses, and other kitchen essentials. Its timeless design enhances any kitchen décor while offering reliable functionality. 
 Dimensions: Height: 5 inches, Diameter: 4 inches 
 Benefits: 
 Durable Build: Constructed from high-quality brass, ensuring long-term use and resistance to wear. 
 Elegant Appearance: The polished brass finish adds a sophisticated touch to your kitchen, blending seamlessly with various styles. 
 Versatile Storage: Perfect for keeping tea, sugar, pulses, and more, with a compact size that fits easily on countertops or in pantries. 
 Easy Maintenance: Brass is easy to clean and maintain, with natural properties that help prevent bacterial growth and tarnish. 
 Timeless Charm: The classic design makes it a stylish addition to your kitchen, combining functionality with a touch of traditional elegance.Choose our Brass Dabba to combine practical storage solutions with refined design, and elevate your kitchen’s style and organization.',
    'TBSET2', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/tea-sugar-box-brass-dabba/DSC_6637.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/tea-sugar-box-brass-dabba/DSC_6637.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/tea-sugar-box-brass-dabba/DSC_6632.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/tea-sugar-box-brass-dabba/DSC_6633.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/tea-sugar-box-brass-dabba/DSC_6634.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/tea-sugar-box-brass-dabba/DSC_6635.jpg'),
    56.99, 65.54, 'AUD', 100,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-tea-sugar-box-brass-dabba'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=100, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 22. COPPER JUG WITH GLASS-CUM- LID -> Drinkware (213)
-- Source product id: 9758997709081
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 213, 220,
    'COPPER JUG WITH GLASS-CUM- LID', 'The YellowMetals', 'yellow-metals-copper-jug-with-glass-cum-lid',
    'Our Copper Kettle with Lid cum Glass is a perfect fusion of style and functionality, designed to enhance your beverage experience. Crafted from premium copper, this kettle combines traditional charm with modern convenience, making it an…', 'Our Copper Kettle with Lid cum Glass is a perfect fusion of style and functionality, designed to enhance your beverage experience. Crafted from premium copper, this kettle combines traditional charm with modern convenience, making it an ideal addition to any kitchen. 
 Invest in our Copper Kettle with Glass to experience the perfect blend of tradition and modern convenience. Transform your kitchen into a hub of style and efficiency with this exceptional piece of cookware. 
 Benefits: 
 1- Efficient Heating: With its superior heat conductivity, copper ensures rapid and even heating, allowing you to prepare your favorite hot beverages in no time. 
 2 - Enhanced Visual Appeal : The striking copper finish, paired with the integrated lid that doubles as a glass, adds a visually captivating touch to your kitchen or table setting. 
 3 Versatile Use : Perfect for boiling water, making tea, or heating other liquids, this kettle is designed for versatile functionality, specifically for storing drinking water. 
 4- Convenient Monitoring : The glass lid enables effortless monitoring of the contents, allowing you to keep an eye on your boiling water or brewing tea. 
 5 - Health Benefits : Drinking water from copper vessels can support digestion, enhance immune function, and help balance pH levels, contributing to overall wellness.',
    'CJUG', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-jug-with-glass-cum-lid/1-15.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-jug-with-glass-cum-lid/1-15.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/copper-jug-with-glass-cum-lid/2-14.jpg'),
    74.99, 86.24, 'AUD', 0,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-copper-jug-with-glass-cum-lid'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 0, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=0, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 23. Brass Lids -> Cookware (211)
-- Source product id: 9758995710233
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 211, 230,
    'Brass Lids', 'The YellowMetals', 'yellow-metals-brass-lids',
    'Our Brass Lids combine functionality with elegance, making them a perfect addition to your kitchenware collection. Available in three sizes, they are designed to fit various cookware, ensuring a snug and secure cover for your pots and…', 'Our Brass Lids combine functionality with elegance, making them a perfect addition to your kitchenware collection. Available in three sizes, they are designed to fit various cookware, ensuring a snug and secure cover for your pots and pans. Upgrade your cooking experience with our Brass Lids, combining durability, style, and practicality for all your kitchen needs. 
 Sizes and Specifications: 
 Medium: 11.50 inches in diameter, weighing 550 grams. (For 2.5 L Kadai ) 
 Large : 13.5 inches in diameter, weighing 750-800 grams.(For 6.0 L Kadai ) 
 Benefits: 
 Durable Construction: Made from high-quality brass, these lids are built to last. They offer excellent resistance to heat and wear, making them a reliable choice for daily cooking. 
 Excellent Heat Retention: Brass lids help retain heat, ensuring that your food cooks evenly and stays warm for longer. This feature is particularly beneficial for slow-cooking and simmering. 
 Elegant Design: The polished brass finish adds a touch of sophistication to your cookware. These lids are not only functional but also enhance the visual appeal of your kitchen. 
 Versatile Fit: Available in multiple sizes, these lids are designed to fit a range of pots and pans, making them versatile for various cooking needs. 
 Easy Maintenance: The smooth surface of the brass lids is easy to clean, requiring just a simple wipe to maintain their shine and functionality.',
    NULL, NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/1-14.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/1-14.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/2-13.jpg'),
    23.99, 27.59, 'AUD', 700,
    1, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-brass-lids'
    LIMIT 1
);
INSERT INTO product_options (
    tenant_id, product_id, option_name, display_type, sort_order, is_active
)
SELECT 1, @product_id, '12.0', 'TEXT', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='12.0'
);
SET @option_12_0 = (
    SELECT id FROM product_options
    WHERE tenant_id=1
      AND product_id=@product_id
      AND option_name='12.0'
    LIMIT 1
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_12_0, '9.0 Inches', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='9.0 Inches'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_12_0, '9.5 Inches', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='9.5 Inches'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_12_0, '11.0 Inches', 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='11.0 Inches'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_12_0, '11.50 Inches', 4, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='11.50 Inches'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_12_0, '12.0 Inches', 5, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='12.0 Inches'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_12_0, '13.5 Inches', 6, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='13.5 Inches'
);
INSERT INTO product_option_values (
    tenant_id, option_id, option_value, sort_order, is_active
)
SELECT 1, @option_12_0, '14.5 Inches', 7, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='14.5 Inches'
);
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '9.0 Inches', 'BKL11.5', NULL,
    23.99, 27.59, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/1-14.jpg',
    JSON_ARRAY(), 600, 0.00,
    'yellow_metals', '51769666699545',
    1, 1, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51769666699545'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='9.0 Inches'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_12_0, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '9.5 Inches', 'BKL11.5', NULL,
    25.49, 29.31, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/1-14.jpg',
    JSON_ARRAY(), 600, 0.00,
    'yellow_metals', '51769666797849',
    2, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51769666797849'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='9.5 Inches'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_12_0, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '11.0 Inches', 'BKL11.5', NULL,
    28.49, 32.76, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/1-14.jpg',
    JSON_ARRAY(), 600, 0.00,
    'yellow_metals', '51769667813657',
    3, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51769667813657'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='11.0 Inches'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_12_0, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '11.50 Inches', 'BKL11.5', NULL,
    29.99, 34.49, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/1-14.jpg',
    JSON_ARRAY(), 600, 0.00,
    'yellow_metals', '49923356426521',
    4, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923356426521'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='11.50 Inches'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_12_0, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '12.0 Inches', 'BKL11.5', NULL,
    32.99, 37.94, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/1-14.jpg',
    JSON_ARRAY(), 600, 0.00,
    'yellow_metals', '51769672401177',
    5, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='51769672401177'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='12.0 Inches'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_12_0, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '13.5 Inches', 'BKL13.5', NULL,
    35.99, 41.39, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/1-14.jpg',
    JSON_ARRAY(), 800, 0.00,
    'yellow_metals', '49923356459289',
    6, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='49923356459289'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='13.5 Inches'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_12_0, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO product_variants (
    tenant_id, product_id, variant_title, sku, barcode,
    base_price, sale_price, currency_code, stock_qty, image_url,
    gallery_json, weight_grams, delivery_surcharge,
    source_system, source_variant_id,
    sort_order, is_default, is_active
) VALUES (
    1, @product_id, '14.5 Inches', 'BKL14.5', NULL,
    37.49, 43.11, 'AUD', 100, 'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/brass-lids/1-14.jpg',
    JSON_ARRAY(), 0, 0.00,
    'yellow_metals', '50859659264281',
    7, 0, 1
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
    is_active=VALUES(is_active);
SET @variant_id = (
    SELECT id FROM product_variants
    WHERE tenant_id=1
      AND source_system='yellow_metals'
      AND source_variant_id='50859659264281'
    LIMIT 1
);
DELETE FROM product_variant_values WHERE variant_id=@variant_id;
SET @option_value_id = (
    SELECT id FROM product_option_values
    WHERE option_id=@option_12_0
      AND option_value='14.5 Inches'
    LIMIT 1
);
INSERT INTO product_variant_values (
    variant_id, option_id, option_value_id
) VALUES (
    @variant_id, @option_12_0, @option_value_id
);
INSERT INTO store_product_variants (
    tenant_id, store_id, product_variant_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @variant_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_product_variants
    WHERE tenant_id=1
      AND store_id=34
      AND product_variant_id=@variant_id
);
UPDATE store_product_variants
SET stock_qty=100, reserved_qty=0, local_price=NULL,
    is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_variant_id=@variant_id;
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 700, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=700, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- ============================================================
-- 24. Brass Roti Box / Mithai Box -> Kitchen Storage (214)
-- Source product id: 9758999019801
-- ============================================================
INSERT INTO products (
    tenant_id, category_id, sort_order, product_name, brand_name, product_slug,
    short_description, long_description, sku, barcode, image_url, gallery_json,
    base_price, sale_price, currency_code, stock_qty, has_variants, is_featured, is_active
) VALUES (
    1, 214, 240,
    'Brass Roti Box / Mithai Box', 'The YellowMetals', 'yellow-metals-roti-box-mithai-box',
    'Our Roti Box / Mithai Box is a beautifully crafted container designed to keep your food items fresh and elegantly stored. Measuring 8.5 to 9.0 inches in diameter & depth is 3.5 Inches , this versatile box is perfect for storing roti,…', 'Our Roti Box / Mithai Box is a beautifully crafted container designed to keep your food items fresh and elegantly stored. Measuring 8.5 to 9.0 inches in diameter & depth is 3.5 Inches , this versatile box is perfect for storing roti, mithai, and other culinary delights. Invest in our Roti Box / Mithai Box to elevate your kitchen storage with a blend of style, practicality, and durability. Perfect for everyday use or special occasions, this box will keep your favorite foods fresh and beautifully presented. 
 Benefits and Features: 
 Elegant Design: This box features a classic design that adds a touch of sophistication to your kitchen. Its polished finish and detailed craftsmanship make it an attractive piece for both daily use and special occasions. 
 Versatile Storage: Ideal for storing a variety of foods, including rotis, mithai, and baked goods. Its generous size accommodates different items, helping you keep your kitchen tidy and organized. 
 Freshness Preservation: The snug-fitting lid keeps your food fresh by protecting it from moisture and air. This ensures that rotis stay soft and mithai remains delicious, preserving their quality over time. 
 Durable and Reliable: Made from high-quality materials, this box is built to last. Its robust construction withstands regular use, making it a dependable addition to your kitchen. 
 Easy Care: The smooth surface of the box is simple to clean. Regular wiping and occasional polishing keep it looking pristine, maintaining its appeal and functionality.',
    'RBOX', NULL,
    'https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/roti-box-mithai-box/DSC_6548.jpg', JSON_ARRAY('https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/roti-box-mithai-box/DSC_6548.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/roti-box-mithai-box/DSC_6549.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/roti-box-mithai-box/DSC_6547.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/roti-box-mithai-box/DSC_6550.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/roti-box-mithai-box/DSC_6552.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/roti-box-mithai-box/DSC_6553.jpg','https://storage.googleapis.com/sba-commerce-images/vendors/yellow-metals/roti-box-mithai-box/8A77BC00-8AA5-427B-B060-FA3C5D28F58B.png'),
    48.74, 56.05, 'AUD', 100,
    0, 0, 1
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
    is_active=1;
SET @product_id = (
    SELECT id FROM products
    WHERE tenant_id=1 AND product_slug='yellow-metals-roti-box-mithai-box'
    LIMIT 1
);
INSERT INTO store_products (
    tenant_id, store_id, product_id, stock_qty, reserved_qty, local_price, is_active
)
SELECT 1, 34, @product_id, 100, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM store_products
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
);
UPDATE store_products
SET stock_qty=100, reserved_qty=0, local_price=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id;
INSERT INTO product_delivery_options (
    tenant_id, store_id, product_id, delivery_method_id,
    delivery_fee, is_free, cutoff_time, is_active
)
SELECT 1, 34, @product_id, 5,
       10.99, 0, NULL, 1
WHERE NOT EXISTS (
    SELECT 1 FROM product_delivery_options
    WHERE tenant_id=1
      AND store_id=34
      AND product_id=@product_id
      AND delivery_method_id=5
);
UPDATE product_delivery_options
SET delivery_fee=10.99, is_free=0, cutoff_time=NULL, is_active=1
WHERE tenant_id=1
  AND store_id=34
  AND product_id=@product_id
  AND delivery_method_id=5;

-- Verification
SELECT
    COUNT(*) AS yellow_metals_products
FROM store_products
WHERE tenant_id=1
  AND store_id=34;
SELECT
    COUNT(*) AS yellow_metals_variants
FROM product_variants
WHERE tenant_id=1
  AND source_system='yellow_metals';
COMMIT;
