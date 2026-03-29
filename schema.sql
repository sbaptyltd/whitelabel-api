CREATE DATABASE IF NOT EXISTS white_label_commerce
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE white_label_commerce;

CREATE TABLE IF NOT EXISTS tenants (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_code VARCHAR(100) NOT NULL,
    tenant_name VARCHAR(255) NOT NULL,
    domain_name VARCHAR(255) NULL,
    app_status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_code (tenant_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_app_config (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    app_name VARCHAR(255) NOT NULL,
    app_tagline VARCHAR(255) NULL,
    app_logo_url TEXT NULL,
    splash_image_url TEXT NULL,
    currency_code VARCHAR(10) NOT NULL DEFAULT 'AUD',
    currency_symbol VARCHAR(10) NOT NULL DEFAULT '$',
    support_email VARCHAR(255) NULL,
    support_phone VARCHAR(50) NULL,
    primary_color VARCHAR(20) NULL,
    secondary_color VARCHAR(20) NULL,
    accent_color VARCHAR(20) NULL,
    text_color VARCHAR(20) NULL,
    background_color VARCHAR(20) NULL,
    button_radius INT NOT NULL DEFAULT 12,
    enable_sms TINYINT(1) NOT NULL DEFAULT 1,
    enable_email TINYINT(1) NOT NULL DEFAULT 1,
    enable_guest_checkout TINYINT(1) NOT NULL DEFAULT 0,
    enable_cod TINYINT(1) NOT NULL DEFAULT 0,
    enable_online_payment TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_app_config_tenant (tenant_id),
    CONSTRAINT fk_tenant_app_config_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_banners (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NULL,
    subtitle VARCHAR(255) NULL,
    image_url TEXT NOT NULL,
    action_type VARCHAR(50) NULL,
    action_value VARCHAR(255) NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_tenant_banners_tenant_active (tenant_id, is_active, sort_order),
    CONSTRAINT fk_tenant_banners_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    full_name VARCHAR(255) NULL,
    mobile_number VARCHAR(30) NOT NULL,
    email VARCHAR(255) NULL,
    country_code VARCHAR(10) NULL,
    is_mobile_verified TINYINT(1) NOT NULL DEFAULT 0,
    status ENUM('ACTIVE', 'BLOCKED', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_users_tenant_mobile (tenant_id, mobile_number),
    KEY idx_users_tenant_status (tenant_id, status),
    CONSTRAINT fk_users_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS otp_requests (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    mobile_number VARCHAR(30) NOT NULL,
    otp_code VARCHAR(10) NOT NULL,
    purpose ENUM('LOGIN', 'SIGNUP', 'RESET') NOT NULL DEFAULT 'LOGIN',
    is_used TINYINT(1) NOT NULL DEFAULT 0,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_otp_mobile_expiry (mobile_number, expires_at),
    KEY idx_otp_tenant_mobile (tenant_id, mobile_number),
    CONSTRAINT fk_otp_requests_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    category_name VARCHAR(255) NOT NULL,
    category_slug VARCHAR(255) NOT NULL,
    image_url TEXT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_categories_tenant_slug (tenant_id, category_slug),
    KEY idx_categories_tenant_active (tenant_id, is_active, sort_order),
    CONSTRAINT fk_categories_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS products (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NULL,
    product_name VARCHAR(255) NOT NULL,
    product_slug VARCHAR(255) NOT NULL,
    short_description VARCHAR(255) NULL,
    long_description TEXT NULL,
    sku VARCHAR(100) NULL,
    barcode VARCHAR(100) NULL,
    image_url TEXT NULL,
    gallery_json JSON NULL,
    base_price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    sale_price DECIMAL(12,2) NULL,
    currency_code VARCHAR(10) NOT NULL DEFAULT 'AUD',
    stock_qty INT NOT NULL DEFAULT 0,
    is_featured TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_products_tenant_slug (tenant_id, product_slug),
    KEY idx_products_tenant_active (tenant_id, is_active, is_featured),
    KEY idx_products_tenant_category (tenant_id, category_id),
    CONSTRAINT fk_products_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS product_prices (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    sale_price DECIMAL(12,2) NULL,
    start_at DATETIME NULL,
    end_at DATETIME NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_product_prices_product_active (product_id, is_active, start_at, end_at),
    CONSTRAINT fk_product_prices_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_product_prices_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS carts (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    status ENUM('ACTIVE', 'CHECKED_OUT', 'ABANDONED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_carts_tenant_user_status (tenant_id, user_id, status),
    CONSTRAINT fk_carts_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cart_items (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    cart_id BIGINT UNSIGNED NOT NULL,
    tenant_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    product_name_snapshot VARCHAR(255) NOT NULL,
    product_image_snapshot TEXT NULL,
    unit_price_snapshot DECIMAL(12,2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    line_total DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_cart_item_unique_product (cart_id, product_id),
    CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS orders (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    cart_id BIGINT UNSIGNED NULL,
    order_number VARCHAR(100) NOT NULL,
    order_status ENUM('PENDING','PAID','CONFIRMED','PROCESSING','SHIPPED','DELIVERED','CANCELLED','FAILED') NOT NULL DEFAULT 'PENDING',
    payment_status ENUM('PENDING','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
    subtotal_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    delivery_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    currency_code VARCHAR(10) NOT NULL DEFAULT 'AUD',
    delivery_address_text TEXT NULL,
    customer_mobile VARCHAR(30) NULL,
    customer_email VARCHAR(255) NULL,
    notes TEXT NULL,
    placed_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_orders_tenant_order_number (tenant_id, order_number),
    CONSTRAINT fk_orders_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_orders_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id BIGINT UNSIGNED NOT NULL,
    tenant_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NULL,
    product_name_snapshot VARCHAR(255) NOT NULL,
    product_image_snapshot TEXT NULL,
    sku_snapshot VARCHAR(100) NULL,
    unit_price_snapshot DECIMAL(12,2) NOT NULL,
    quantity INT NOT NULL,
    line_total DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS payments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    order_id BIGINT UNSIGNED NOT NULL,
    payment_provider VARCHAR(100) NOT NULL,
    payment_reference VARCHAR(255) NULL,
    payment_intent_id VARCHAR(255) NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency_code VARCHAR(10) NOT NULL DEFAULT 'AUD',
    payment_status ENUM('CREATED','PENDING','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'CREATED',
    raw_response_json JSON NULL,
    paid_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_payments_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_payments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notification_templates (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    template_type ENUM('EMAIL_ORDER_CONFIRMATION','SMS_ORDER_CONFIRMATION','OTP_SMS','OTP_EMAIL') NOT NULL,
    subject VARCHAR(255) NULL,
    body TEXT NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_notification_templates_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notification_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tenant_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    order_id BIGINT UNSIGNED NULL,
    channel ENUM('EMAIL','SMS') NOT NULL,
    recipient VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NULL,
    message_body TEXT NOT NULL,
    delivery_status ENUM('PENDING','SENT','FAILED') NOT NULL DEFAULT 'PENDING',
    provider_message_id VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_notification_logs_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_notification_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_notification_logs_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
