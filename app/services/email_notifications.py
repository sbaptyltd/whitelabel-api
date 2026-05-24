import os
import smtplib
from decimal import Decimal
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from sqlalchemy.orm import Session

from app.models.commerce import NotificationLog, Order, OrderItem, Product, Store, User, CartItem


# ============================================================
# TEMP TEST CONFIG - hardcoded for testing only
# Later move these back to Cloud Run env vars / Secret Manager.
# ============================================================

SMTP_HOST = "smtp.hostinger.com"

# Hostinger options:
# - Port 587 with STARTTLS
# - Port 465 with SSL
SMTP_PORT = 587

SMTP_USER = "contact@synergybits.com.au"

# IMPORTANT:
# This must be the Hostinger MAILBOX password for contact@synergybits.com.au,
# not the Hostinger account login password.
SMTP_PASSWORD = "Vandu@8789"

SMTP_FROM_EMAIL = "contact@synergybits.com.au"
SMTP_FROM_NAME = "DesiDash"

SMTP_USE_TLS = True
SMTP_USE_SSL = False


class EmailNotificationError(Exception):
    pass


def _money(value) -> str:
    try:
        amount = Decimal(value or 0)
    except Exception:
        amount = Decimal("0.00")
    return f"${amount:.2f}"


def _html_escape(value) -> str:
    if value is None:
        return ""
    return (
        str(value)
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&#x27;")
    )


def _strip_html(html: str) -> str:
    return (
        html.replace("<br>", "\n")
        .replace("<br/>", "\n")
        .replace("<br />", "\n")
        .replace("</p>", "\n")
        .replace("</tr>", "\n")
        .replace("</h1>", "\n")
        .replace("</h2>", "\n")
        .replace("</h3>", "\n")
    )


def _send_email(
    to_email: str,
    subject: str,
    html_body: str,
    text_body: str | None = None,
) -> None:
    if not to_email:
        raise EmailNotificationError("Missing recipient email")

    if not SMTP_HOST or not SMTP_USER or not SMTP_PASSWORD or not SMTP_FROM_EMAIL:
        raise EmailNotificationError(
            "SMTP is not configured. Required values: "
            "SMTP_HOST, SMTP_USER, SMTP_PASSWORD, SMTP_FROM_EMAIL"
        )

    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = f"{SMTP_FROM_NAME} <{SMTP_FROM_EMAIL}>"
    msg["To"] = to_email

    plain = text_body or _strip_html(html_body)
    msg.attach(MIMEText(plain, "plain", "utf-8"))
    msg.attach(MIMEText(html_body, "html", "utf-8"))

    server = None

    try:
        print(
            f"[EMAIL_CONNECT] host={SMTP_HOST} port={SMTP_PORT} "
            f"use_tls={SMTP_USE_TLS} use_ssl={SMTP_USE_SSL} user={SMTP_USER}"
        )

        if SMTP_USE_SSL:
            server = smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT, timeout=30)
        else:
            server = smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=30)

        server.ehlo()

        if SMTP_USE_TLS:
            server.starttls()
            server.ehlo()

        print(f"[EMAIL_LOGIN] user={SMTP_USER}")
        server.login(SMTP_USER, SMTP_PASSWORD)

        server.sendmail(
            SMTP_FROM_EMAIL,
            [to_email],
            msg.as_string(),
        )

        print(f"[EMAIL_SENT] to={to_email} subject={subject}")

    except Exception as e:
        print(f"[EMAIL_SEND_FAILED] to={to_email} subject={subject} error={e}")
        raise

    finally:
        if server:
            try:
                server.quit()
            except Exception:
                pass


def _log_email(
    db: Session,
    tenant_id: int,
    user_id: int | None,
    order_id: int | None,
    recipient: str,
    subject: str,
    body: str,
    status: str,
    error: str | None = None,
) -> None:
    message_body = body if not error else f"{body}\n\nERROR: {error}"

    db.add(
        NotificationLog(
            tenant_id=tenant_id,
            user_id=user_id,
            order_id=order_id,
            channel="EMAIL",
            recipient=recipient or "unknown@example.com",
            subject=subject,
            message_body=message_body,
            delivery_status=status,
        )
    )


def _send_and_log(
    db: Session,
    tenant_id: int,
    user_id: int | None,
    order_id: int | None,
    recipient: str,
    subject: str,
    html_body: str,
) -> bool:
    try:
        _send_email(recipient, subject, html_body)
        _log_email(
            db=db,
            tenant_id=tenant_id,
            user_id=user_id,
            order_id=order_id,
            recipient=recipient,
            subject=subject,
            body=html_body,
            status="SENT",
        )
        return True

    except Exception as e:
        print(f"[EMAIL_NOTIFICATION_FAILED] recipient={recipient} error={e}")
        _log_email(
            db=db,
            tenant_id=tenant_id,
            user_id=user_id,
            order_id=order_id,
            recipient=recipient,
            subject=subject,
            body=html_body,
            status="FAILED",
            error=str(e),
        )
        return False


def _get_order_items(db: Session, order: Order) -> list[OrderItem]:
    # Force SQLAlchemy to write pending OrderItem rows before this email queries them.
    # This fixes empty store email tables when email is sent before the outer transaction commits.
    try:
        db.flush()
    except Exception as e:
        print(f"[EMAIL_ORDER_ITEMS_FLUSH_WARNING] order_id={getattr(order, 'id', None)} error={e}")

    return (
        db.query(OrderItem)
        .filter(
            OrderItem.order_id == order.id,
            OrderItem.tenant_id == order.tenant_id,
        )
        .order_by(OrderItem.id.asc())
        .all()
    )


def _get_product_base_price(
    db: Session,
    tenant_id: int,
    product_id: int | None,
) -> Decimal:
    if not product_id:
        return Decimal("0.00")

    product = (
        db.query(Product)
        .filter(
            Product.id == product_id,
            Product.tenant_id == tenant_id,
        )
        .first()
    )

    if not product:
        return Decimal("0.00")

    return Decimal(product.base_price or 0)


def _items_table_for_store(
    db: Session,
    order: Order,
    items: list[OrderItem],
) -> tuple[str, Decimal]:
    """
    Store table uses Product.base_price only.

    Robust behaviour:
    1. Prefer order_items, because they are the official order snapshot.
    2. If order_items are not visible yet, fallback to cart_items using order.cart_id.
       This prevents an empty email table / $0.00 total when the email is generated
       inside the same transaction before commit.
    """
    rows = []
    total = Decimal("0.00")

    def add_row(product_name, product_id, quantity):
        nonlocal total

        base_price = _get_product_base_price(
            db=db,
            tenant_id=order.tenant_id,
            product_id=product_id,
        )

        qty = int(quantity or 0)
        line_total = base_price * qty
        total += line_total

        rows.append(
            f"""
            <tr>
              <td style="padding:8px; border:1px solid #ddd;">{_html_escape(product_name)}</td>
              <td style="text-align:center; padding:8px; border:1px solid #ddd;">{qty}</td>
              <td style="text-align:right; padding:8px; border:1px solid #ddd;">{_money(base_price)}</td>
              <td style="text-align:right; padding:8px; border:1px solid #ddd;">{_money(line_total)}</td>
            </tr>
            """
        )

    # Main path: order_items
    for item in items:
        add_row(
            product_name=item.product_name_snapshot,
            product_id=item.product_id,
            quantity=item.quantity,
        )

    # Fallback path: cart_items, used only if order_items were empty.
    if not rows and getattr(order, "cart_id", None):
        print(f"[STORE_EMAIL_ORDER_ITEMS_EMPTY_FALLBACK_TO_CART] order_id={order.id} cart_id={order.cart_id}")
        cart_items = (
            db.query(CartItem)
            .filter(
                CartItem.cart_id == order.cart_id,
                CartItem.tenant_id == order.tenant_id,
            )
            .order_by(CartItem.id.asc())
            .all()
        )

        for cart_item in cart_items:
            add_row(
                product_name=getattr(cart_item, "product_name_snapshot", None) or f"Product {cart_item.product_id}",
                product_id=cart_item.product_id,
                quantity=cart_item.quantity,
            )

    if not rows:
        rows.append(
            """
            <tr>
              <td colspan="4" style="padding:8px; border:1px solid #ddd; text-align:center; color:#777;">
                No order items found for this order. Please check order_items/cart_items data.
              </td>
            </tr>
            """
        )

    return "".join(rows), total

def _items_table_for_customer(items: list[OrderItem]) -> tuple[str, Decimal]:
    rows = []
    total = Decimal("0.00")

    for item in items:
        unit_price = Decimal(item.unit_price_snapshot or 0)
        qty = int(item.quantity or 0)
        line_total = Decimal(item.line_total or 0)
        total += line_total

        rows.append(
            f"""
            <tr>
              <td style="padding:8px; border:1px solid #ddd;">{_html_escape(item.product_name_snapshot)}</td>
              <td style="text-align:center; padding:8px; border:1px solid #ddd;">{qty}</td>
              <td style="text-align:right; padding:8px; border:1px solid #ddd;">{_money(unit_price)}</td>
              <td style="text-align:right; padding:8px; border:1px solid #ddd;">{_money(line_total)}</td>
            </tr>
            """
        )

    return "".join(rows), total


def _base_layout(title: str, body_html: str) -> str:
    return f"""
    <!doctype html>
    <html>
      <body style="font-family: Arial, sans-serif; color: #222; line-height: 1.5;">
        <div style="max-width: 720px; margin: 0 auto; padding: 20px;">
          <h2 style="margin: 0 0 16px; color: #b45309;">{_html_escape(title)}</h2>
          {body_html}
          <p style="margin-top: 28px; font-size: 12px; color: #777;">
            This is an automated notification from DesiDash.
          </p>
        </div>
      </body>
    </html>
    """


def _order_summary_block(order: Order) -> str:
    return f"""
    <p><strong>Order:</strong> {_html_escape(order.order_number)}</p>
    <p><strong>Delivery pincode:</strong> {_html_escape(order.delivery_pincode)}</p>
    <p><strong>Delivery address:</strong><br>{_html_escape(order.delivery_address_text)}</p>
    <p><strong>Customer mobile:</strong> {_html_escape(order.customer_mobile)}</p>
    <p><strong>Customer email:</strong> {_html_escape(order.customer_email)}</p>
    """


def _items_table_html(
    rows_html: str,
    total_label: str,
    total_amount: Decimal,
    unit_header: str = "Unit",
    total_header: str = "Total",
) -> str:
    return f"""
    <table style="width:100%; border-collapse: collapse; margin-top: 16px; table-layout: fixed;">
      <thead>
        <tr style="background:#f7f7f7;">
          <th style="width:38%; text-align:left; padding:8px; border:1px solid #ddd;">Item</th>
          <th style="width:12%; text-align:center; padding:8px; border:1px solid #ddd;">Qty</th>
          <th style="width:25%; text-align:right; padding:8px; border:1px solid #ddd;">{_html_escape(unit_header)}</th>
          <th style="width:25%; text-align:right; padding:8px; border:1px solid #ddd;">{_html_escape(total_header)}</th>
        </tr>
      </thead>
      <tbody>{rows_html}</tbody>
      <tfoot>
        <tr>
          <td colspan="3" style="text-align:right; padding:8px; border:1px solid #ddd;">
            <strong>{_html_escape(total_label)}</strong>
          </td>
          <td style="text-align:right; padding:8px; border:1px solid #ddd;">
            <strong>{_money(total_amount)}</strong>
          </td>
        </tr>
      </tfoot>
    </table>
    """


def send_store_new_order_email(db: Session, order: Order) -> None:
    """
    Sent after payment success / order confirmed.
    Store email uses Product.base_price, not customer sale price.
    """
    if not order.store_id:
        print(f"[STORE_EMAIL_SKIPPED] order_id={order.id} reason=no_store_id")
        return

    items = _get_order_items(db, order)
    rows_html, store_total = _items_table_for_store(db, order, items)

    body = _base_layout(
        "New paid order received",
        f"""
        <p>A customer payment has succeeded and a new order is ready for store processing.</p>
        {_order_summary_block(order)}
        {_items_table_html(
            rows_html,
            "Store total based on base price",
            store_total,
            unit_header="Unit base price",
            total_header="Total base price",
        )}
        <p><strong>Note:</strong> This store view uses base price, not customer sale price.</p>
        """,
    )

    subject = f"New paid order {order.order_number}"

    store_users = (
        db.query(User)
        .filter(
            User.tenant_id == order.tenant_id,
            User.role.in_(["store", "store_admin", "store_user", "store_owner"]),
            User.store_id == order.store_id,
            User.status == "ACTIVE",
        )
        .all()
    )

    sent_to = set()

    for user in store_users:
        if user.email and user.email not in sent_to:
            print(f"[STORE_EMAIL_TO_USER] order_id={order.id} user_id={user.id} email={user.email}")
            _send_and_log(
                db=db,
                tenant_id=order.tenant_id,
                user_id=user.id,
                order_id=order.id,
                recipient=user.email,
                subject=subject,
                html_body=body,
            )
            sent_to.add(user.email)

    store = (
        db.query(Store)
        .filter(
            Store.id == order.store_id,
            Store.tenant_id == order.tenant_id,
        )
        .first()
    )

    if store and store.store_email and store.store_email not in sent_to:
        print(f"[STORE_EMAIL_TO_STORE] order_id={order.id} store_id={store.id} email={store.store_email}")
        _send_and_log(
            db=db,
            tenant_id=order.tenant_id,
            user_id=None,
            order_id=order.id,
            recipient=store.store_email,
            subject=subject,
            html_body=body,
        )
        sent_to.add(store.store_email)

    if not sent_to:
        print(f"[STORE_EMAIL_NO_RECIPIENT] order_id={order.id} store_id={order.store_id}")


def send_delivery_ready_email(db: Session, order: Order) -> None:
    """
    Sent when store marks order READY.
    Delivery role receives pickup/delivery details.
    """
    body = _base_layout(
        "Order ready for delivery pickup",
        f"""
        <p>An order has been marked READY and is waiting for delivery pickup.</p>
        {_order_summary_block(order)}
        <p><strong>Store ID:</strong> {_html_escape(order.store_id)}</p>
        """,
    )

    subject = f"Order ready for pickup {order.order_number}"

    delivery_users = (
        db.query(User)
        .filter(
            User.tenant_id == order.tenant_id,
            User.role.in_(["delivery", "delivery_partner", "driver"]),
            User.status == "ACTIVE",
        )
        .all()
    )

    sent_to = set()

    for user in delivery_users:
        if user.email and user.email not in sent_to:
            _send_and_log(
                db=db,
                tenant_id=order.tenant_id,
                user_id=user.id,
                order_id=order.id,
                recipient=user.email,
                subject=subject,
                html_body=body,
            )
            sent_to.add(user.email)


def send_customer_invoice_email(db: Session, order: Order) -> None:
    """
    Sent when order is marked DELIVERED.
    Customer invoice uses OrderItem.unit_price_snapshot / line_total,
    which is customer sale price snapshot.
    """
    if not order.customer_email:
        print(f"[CUSTOMER_EMAIL_SKIPPED] order_id={order.id} reason=no_customer_email")
        return

    items = _get_order_items(db, order)
    rows_html, customer_total = _items_table_for_customer(items)

    body = _base_layout(
        "Your DesiDash invoice",
        f"""
        <p>Thank you for shopping with DesiDash. Your order has been delivered.</p>
        {_order_summary_block(order)}
        {_items_table_html(
            rows_html,
            "Invoice total",
            customer_total,
            unit_header="Sale price",
            total_header="Line total",
        )}
        <p><strong>Payment status:</strong> {_html_escape(order.payment_status)}</p>
        """,
    )

    subject = f"Invoice for order {order.order_number}"

    _send_and_log(
        db=db,
        tenant_id=order.tenant_id,
        user_id=order.user_id,
        order_id=order.id,
        recipient=order.customer_email,
        subject=subject,
        html_body=body,
    )
