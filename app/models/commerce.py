from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Boolean,
    Column,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
    TIMESTAMP,
    JSON,
    text,
)

from app.db.base import Base


class Tenant(Base):
    __tablename__ = "tenants"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_code = Column(String(100), unique=True, nullable=False)
    tenant_name = Column(String(255), nullable=False)
    domain_name = Column(String(255), nullable=True)
    app_status = Column(
        Enum("ACTIVE", "INACTIVE", name="tenant_app_status"),
        nullable=False,
        default="ACTIVE",
    )
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class TenantAppConfig(Base):
    __tablename__ = "tenant_app_config"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False, unique=True)
    app_name = Column(String(255), nullable=False)
    app_tagline = Column(String(255), nullable=True)
    app_logo_url = Column(Text, nullable=True)
    splash_image_url = Column(Text, nullable=True)
    currency_code = Column(String(10), nullable=False, default="AUD")
    currency_symbol = Column(String(10), nullable=False, default="$")
    support_email = Column(String(255), nullable=True)
    support_phone = Column(String(50), nullable=True)
    primary_color = Column(String(20), nullable=True)
    secondary_color = Column(String(20), nullable=True)
    accent_color = Column(String(20), nullable=True)
    text_color = Column(String(20), nullable=True)
    background_color = Column(String(20), nullable=True)
    button_radius = Column(Integer, nullable=False, default=12)
    enable_sms = Column(Boolean, nullable=False, default=True)
    enable_email = Column(Boolean, nullable=False, default=True)
    enable_guest_checkout = Column(Boolean, nullable=False, default=False)
    enable_cod = Column(Boolean, nullable=False, default=False)
    enable_online_payment = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class TenantBanner(Base):
    __tablename__ = "tenant_banners"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    title = Column(String(255), nullable=True)
    subtitle = Column(String(255), nullable=True)
    image_url = Column(Text, nullable=False)
    action_type = Column(String(50), nullable=True)
    action_value = Column(String(255), nullable=True)
    sort_order = Column(Integer, nullable=False, default=0)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class User(Base):
    __tablename__ = "users"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    full_name = Column(String(255), nullable=True)
    role = Column(String(50), nullable=False, default="user")
    store_id = Column(BigInteger, nullable=True)
    delivery_partner_id = Column(BigInteger, nullable=True)
    mobile_number = Column(String(30), nullable=False)
    email = Column(String(255), nullable=True)
    country_code = Column(String(10), nullable=True)
    is_mobile_verified = Column(Boolean, nullable=False, default=False)
    status = Column(
        Enum("ACTIVE", "BLOCKED", "INACTIVE", name="user_status"),
        nullable=False,
        default="ACTIVE",
    )

    store_id = Column(BigInteger, nullable=True)
    delivery_partner_id = Column(BigInteger, nullable=True)

    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class Store(Base):
    __tablename__ = "stores"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    store_name = Column(String(255), nullable=False)
    store_email = Column(String(255), nullable=False)
    store_phone = Column(String(30), nullable=True)
    address = Column(Text, nullable=True)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, nullable=True, server_default=text("CURRENT_TIMESTAMP"))


class StoreProduct(Base):
    __tablename__ = "store_products"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    store_id = Column(BigInteger, ForeignKey("stores.id"), nullable=False)
    product_id = Column(BigInteger, ForeignKey("products.id"), nullable=False)
    stock_qty = Column(Integer, nullable=False, default=0)
    reserved_qty = Column(Integer, nullable=False, default=0)
    local_price = Column(Numeric(12, 2), nullable=True)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, nullable=True, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(
        TIMESTAMP,
        nullable=True,
        server_default=text("CURRENT_TIMESTAMP"),
        server_onupdate=text("CURRENT_TIMESTAMP"),
    )


class OtpRequest(Base):
    __tablename__ = "otp_requests"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    mobile_number = Column(String(30), nullable=False)
    otp_code = Column(String(10), nullable=False)
    purpose = Column(
        Enum("LOGIN", "SIGNUP", "RESET", name="otp_purpose"),
        nullable=False,
        default="LOGIN",
    )
    is_used = Column(Boolean, nullable=False, default=False)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))


class Category(Base):
    __tablename__ = "categories"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    category_name = Column(String(255), nullable=False)
    category_slug = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(Text, nullable=True)
    sort_order = Column(Integer, nullable=False, default=0)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class Product(Base):
    __tablename__ = "products"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    category_id = Column(BigInteger, ForeignKey("categories.id"), nullable=True)
    sort_order = Column(Integer, nullable=False, default=0)
    product_name = Column(String(255), nullable=False)
    brand_name = Column(String(255), nullable=True)
    product_slug = Column(String(255), nullable=False)
    short_description = Column(String(255), nullable=True)
    long_description = Column(Text, nullable=True)
    sku = Column(String(100), nullable=True)
    barcode = Column(String(100), nullable=True)
    image_url = Column(Text, nullable=True)
    gallery_json = Column(JSON, nullable=True)
    base_price = Column(Numeric(12, 2), nullable=False, default=0)
    sale_price = Column(Numeric(12, 2), nullable=True)
    currency_code = Column(String(10), nullable=False, default="AUD")
    stock_qty = Column(Integer, nullable=False, default=0)
    is_featured = Column(Boolean, nullable=False, default=False)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class ProductPrice(Base):
    __tablename__ = "product_prices"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    product_id = Column(BigInteger, ForeignKey("products.id"), nullable=False)
    price = Column(Numeric(12, 2), nullable=False)
    sale_price = Column(Numeric(12, 2), nullable=True)
    start_at = Column(DateTime, nullable=True)
    end_at = Column(DateTime, nullable=True)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class Cart(Base):
    __tablename__ = "carts"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False)
    status = Column(
        Enum("ACTIVE", "CHECKED_OUT", "ABANDONED", name="cart_status"),
        nullable=False,
        default="ACTIVE",
    )
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class CartItem(Base):
    __tablename__ = "cart_items"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    cart_id = Column(BigInteger, ForeignKey("carts.id"), nullable=False)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False)
    product_id = Column(BigInteger, ForeignKey("products.id"), nullable=False)
    product_name_snapshot = Column(String(255), nullable=False)
    product_image_snapshot = Column(Text, nullable=True)
    unit_price_snapshot = Column(Numeric(12, 2), nullable=False)
    quantity = Column(Integer, nullable=False, default=1)
    line_total = Column(Numeric(12, 2), nullable=False)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

class Order(Base):
    __tablename__ = "orders"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False)
    cart_id = Column(BigInteger, ForeignKey("carts.id"), nullable=True)
    order_number = Column(String(100), nullable=False)
    order_status = Column(
        Enum(
            "PENDING",
            "PAID",
            "CONFIRMED",
            "PROCESSING",
            "SHIPPED",
            "OUT_FOR_DELIVERY",
            "DELIVERED",
            "CANCELLED",
            "FAILED",
            name="order_status_enum",
        ),
        nullable=False,
        default="PENDING",
    )
    payment_status = Column(
        Enum("PENDING", "SUCCESS", "FAILED", "REFUNDED", name="payment_status_enum"),
        nullable=False,
        default="PENDING",
    )
    subtotal_amount = Column(Numeric(12, 2), nullable=False, default=0)
    tax_amount = Column(Numeric(12, 2), nullable=False, default=0)
    delivery_amount = Column(Numeric(12, 2), nullable=False, default=0)
    discount_amount = Column(Numeric(12, 2), nullable=False, default=0)
    total_amount = Column(Numeric(12, 2), nullable=False, default=0)
    currency_code = Column(String(10), nullable=False, default="AUD")
    delivery_address_text = Column(Text, nullable=True)
    customer_mobile = Column(String(30), nullable=True)
    customer_email = Column(String(255), nullable=True)
    notes = Column(Text, nullable=True)
    placed_at = Column(DateTime, nullable=True)

    store_id = Column(BigInteger, nullable=True)
    delivery_pincode = Column(String(20), nullable=True)
    delivery_partner_id = Column(BigInteger, nullable=True)

    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    order_id = Column(BigInteger, ForeignKey("orders.id"), nullable=False)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False)
    product_id = Column(BigInteger, ForeignKey("products.id"), nullable=True)
    product_name_snapshot = Column(String(255), nullable=False)
    product_image_snapshot = Column(Text, nullable=True)
    sku_snapshot = Column(String(100), nullable=True)
    unit_price_snapshot = Column(Numeric(12, 2), nullable=False)
    quantity = Column(Integer, nullable=False)
    line_total = Column(Numeric(12, 2), nullable=False)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))


class Payment(Base):
    __tablename__ = "payments"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False)
    order_id = Column(BigInteger, ForeignKey("orders.id"), nullable=False)
    payment_provider = Column(String(100), nullable=False, default="stripe")
    payment_reference = Column(String(255), nullable=True)
    payment_intent_id = Column(String(255), nullable=True, unique=True)
    amount = Column(Numeric(12, 2), nullable=False)
    currency_code = Column(String(10), nullable=False, default="AUD")
    payment_status = Column(
        Enum(
            "CREATED",
            "PENDING",
            "SUCCESS",
            "FAILED",
            "REFUNDED",
            name="payments_status_enum",
        ),
        nullable=False,
        default="CREATED",
    )
    raw_response_json = Column(JSON, nullable=True)
    paid_at = Column(DateTime, nullable=True)
    failure_reason = Column(Text, nullable=True)
    refunded_at = Column(DateTime, nullable=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class NotificationTemplate(Base):
    __tablename__ = "notification_templates"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    template_type = Column(
        Enum(
            "EMAIL_ORDER_CONFIRMATION",
            "SMS_ORDER_CONFIRMATION",
            "OTP_SMS",
            "OTP_EMAIL",
            name="notification_template_type",
        ),
        nullable=False,
    )
    subject = Column(String(255), nullable=True)
    body = Column(Text, nullable=False)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class NotificationLog(Base):
    __tablename__ = "notification_logs"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, ForeignKey("tenants.id"), nullable=False)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=True)
    order_id = Column(BigInteger, ForeignKey("orders.id"), nullable=True)
    channel = Column(Enum("EMAIL", "SMS", name="notification_channel"), nullable=False)
    recipient = Column(String(255), nullable=False)
    subject = Column(String(255), nullable=True)
    message_body = Column(Text, nullable=False)
    delivery_status = Column(
        Enum("PENDING", "SENT", "FAILED", name="notification_delivery_status"),
        nullable=False,
        default="PENDING",
    )
    provider_message_id = Column(String(255), nullable=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)