from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import Order
from app.services.email_notifications import (
    _send_and_log,
    _base_layout,
    _html_escape,
)

router = APIRouter(prefix="/api/incidents", tags=["incidents"])

SUPPORT_EMAIL = "contact@synergybits.com.au"


class CreateIncidentRequest(BaseModel):
    order_id: int | None = None
    subject: str
    message: str


@router.post("/create")
def create_incident(
    payload: CreateIncidentRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    now = datetime.utcnow()
    sla_due_at = now + timedelta(days=1)

    subject = payload.subject.strip()
    message = payload.message.strip()

    if not subject:
        raise HTTPException(status_code=400, detail="Subject is required")

    if not message:
        raise HTTPException(status_code=400, detail="Message is required")

    order = None
    if payload.order_id:
        order = (
            db.query(Order)
            .filter(
                Order.id == payload.order_id,
                Order.tenant_id == current_user.tenant_id,
                Order.user_id == current_user.id,
            )
            .first()
        )

        if not order:
            raise HTTPException(status_code=404, detail="Order not found")

    db.execute(
        text(
            """
            INSERT INTO customer_incidents
                (tenant_id, user_id, order_id, incident_number, subject, message,
                 status, priority, sla_due_at, created_at, updated_at)
            VALUES
                (:tenant_id, :user_id, :order_id, :incident_number, :subject, :message,
                 'OPEN', 'NORMAL', :sla_due_at, :created_at, :updated_at)
            """
        ),
        {
            "tenant_id": current_user.tenant_id,
            "user_id": current_user.id,
            "order_id": payload.order_id,
            "incident_number": "TEMP",
            "subject": subject,
            "message": message,
            "sla_due_at": sla_due_at,
            "created_at": now,
            "updated_at": now,
        },
    )

    incident_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()
    incident_number = f"INC-{now.strftime('%Y%m%d')}-{int(incident_id):06d}"

    db.execute(
        text(
            """
            UPDATE customer_incidents
            SET incident_number = :incident_number
            WHERE id = :id
            """
        ),
        {
            "incident_number": incident_number,
            "id": incident_id,
        },
    )

    order_info = ""
    if order:
        order_info = f"""
        <p><strong>Order Number:</strong> {_html_escape(order.order_number)}</p>
        <p><strong>Order Status:</strong> {_html_escape(order.order_status)}</p>
        <p><strong>Payment Status:</strong> {_html_escape(order.payment_status)}</p>
        <p><strong>Total:</strong> {_html_escape(order.total_amount)} {_html_escape(order.currency_code)}</p>
        """

    html_body = _base_layout(
        f"New Customer Incident {incident_number}",
        f"""
        <p>A customer has submitted a Contact Us request.</p>

        <p><strong>Incident:</strong> {_html_escape(incident_number)}</p>
        <p><strong>SLA Due:</strong> {_html_escape(sla_due_at)}</p>

        <h3>Customer</h3>
        <p><strong>User ID:</strong> {_html_escape(current_user.id)}</p>
        <p><strong>Name:</strong> {_html_escape(current_user.full_name)}</p>
        <p><strong>Email:</strong> {_html_escape(current_user.email)}</p>
        <p><strong>Mobile:</strong> {_html_escape(current_user.mobile_number)}</p>

        <h3>Order</h3>
        {order_info if order_info else "<p>No order selected.</p>"}

        <h3>Message</h3>
        <p><strong>Subject:</strong> {_html_escape(subject)}</p>
        <p>{_html_escape(message)}</p>
        """,
    )

    _send_and_log(
        db=db,
        tenant_id=current_user.tenant_id,
        user_id=current_user.id,
        order_id=payload.order_id,
        recipient=SUPPORT_EMAIL,
        subject=f"Customer Incident {incident_number}: {subject}",
        html_body=html_body,
    )

    db.commit()

    return {
        "success": True,
        "incident_id": int(incident_id),
        "incident_number": incident_number,
        "status": "OPEN",
        "sla_due_at": sla_due_at.isoformat(),
        "message": "Your request has been submitted. Our team will respond within 1 day.",
    }


@router.get("/my")
def my_incidents(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    rows = db.execute(
        text(
            """
            SELECT
                ci.id,
                ci.incident_number,
                ci.order_id,
                o.order_number,
                ci.subject,
                ci.message,
                ci.status,
                ci.priority,
                ci.sla_due_at,
                ci.created_at,
                ci.resolved_at
            FROM customer_incidents ci
            LEFT JOIN orders o ON o.id = ci.order_id
            WHERE ci.tenant_id = :tenant_id
              AND ci.user_id = :user_id
            ORDER BY ci.id DESC
            """
        ),
        {
            "tenant_id": current_user.tenant_id,
            "user_id": current_user.id,
        },
    ).mappings().all()

    return {"items": [dict(r) for r in rows]}