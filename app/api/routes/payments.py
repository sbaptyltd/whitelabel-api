import json
import os
from datetime import datetime
from decimal import Decimal

import stripe
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import Order, Payment

router = APIRouter(prefix="/api/payments", tags=["payments"])

stripe.api_key = (os.getenv("STRIPE_SECRET_KEY") or "").strip()
STRIPE_WEBHOOK_SECRET = (os.getenv("STRIPE_WEBHOOK_SECRET") or "").strip()
STRIPE_SKIP_WEBHOOK_SIGNATURE = (
    (os.getenv("STRIPE_SKIP_WEBHOOK_SIGNATURE") or "false").strip().lower() == "true"
)


class CreatePaymentIntentRequest(BaseModel):
    order_id: int


class CreatePaymentIntentResponse(BaseModel):
    success: bool
    client_secret: str
    payment_intent_id: str
    amount: float
    currency_code: str


@router.get("/health")
def payments_health():
    return {
        "ok": True,
        "stripe_key_loaded": bool(stripe.api_key),
        "webhook_secret_loaded": bool(STRIPE_WEBHOOK_SECRET),
        "skip_webhook_signature": STRIPE_SKIP_WEBHOOK_SIGNATURE,
    }


@router.post("/create-payment-intent", response_model=CreatePaymentIntentResponse)
def create_payment_intent(
    payload: CreatePaymentIntentRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if not stripe.api_key:
        raise HTTPException(status_code=500, detail="Missing STRIPE_SECRET_KEY")

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

    order_total = Decimal(str(order.total_amount or 0))
    if order_total <= 0:
        raise HTTPException(status_code=400, detail="Invalid order amount")

    existing_success = (
        db.query(Payment)
        .filter(
            Payment.order_id == order.id,
            Payment.tenant_id == current_user.tenant_id,
            Payment.user_id == current_user.id,
            Payment.payment_status == "SUCCESS",
        )
        .first()
    )
    if existing_success:
        raise HTTPException(status_code=400, detail="Order already paid")

    amount_in_cents = int(order_total * 100)
    currency = (order.currency_code or "AUD").lower()

    try:
        intent = stripe.PaymentIntent.create(
            amount=amount_in_cents,
            currency=currency,
            automatic_payment_methods={"enabled": True},
            metadata={
                "order_id": str(order.id),
                "tenant_id": str(current_user.tenant_id),
                "user_id": str(current_user.id),
            },
        )

        payment = Payment(
            tenant_id=current_user.tenant_id,
            user_id=current_user.id,
            order_id=order.id,
            payment_provider="stripe",
            payment_reference=None,
            payment_intent_id=intent.id,
            amount=order_total,
            currency_code=(order.currency_code or "AUD").upper(),
            payment_status="PENDING",
            raw_response_json=intent.to_dict(),
            failure_reason=None,
            paid_at=None,
            refunded_at=None,
        )

        db.add(payment)
        db.commit()
        db.refresh(payment)

        return CreatePaymentIntentResponse(
            success=True,
            client_secret=intent.client_secret,
            payment_intent_id=intent.id,
            amount=float(order_total),
            currency_code=(order.currency_code or "AUD").upper(),
        )

    except stripe.error.StripeError as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/webhook")
async def stripe_webhook(request: Request, db: Session = Depends(get_db)):
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")

    try:
        if STRIPE_SKIP_WEBHOOK_SIGNATURE:
            event = json.loads(payload.decode("utf-8"))
        else:
            if not STRIPE_WEBHOOK_SECRET:
                raise HTTPException(status_code=500, detail="Missing STRIPE_WEBHOOK_SECRET")

            event = stripe.Webhook.construct_event(
                payload=payload,
                sig_header=sig_header,
                secret=STRIPE_WEBHOOK_SECRET,
            )
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid payload")
    except stripe.error.SignatureVerificationError:
        raise HTTPException(status_code=400, detail="Invalid signature")

    event_type = event["type"]
    data = event["data"]["object"]

    try:
        if event_type == "payment_intent.succeeded":
            payment_intent_id = data["id"]

            payment = (
                db.query(Payment)
                .filter(Payment.payment_intent_id == payment_intent_id)
                .first()
            )

            if payment:
                payment.payment_status = "SUCCESS"
                payment.payment_reference = data.get("latest_charge")
                payment.raw_response_json = data
                payment.paid_at = datetime.utcnow()
                payment.failure_reason = None

                order = db.query(Order).filter(Order.id == payment.order_id).first()
                if order:
                    order.payment_status = "SUCCESS"
                    order.order_status = "CONFIRMED"
                    if not order.placed_at:
                        order.placed_at = datetime.utcnow()

                db.commit()

        elif event_type == "payment_intent.payment_failed":
            payment_intent_id = data["id"]

            payment = (
                db.query(Payment)
                .filter(Payment.payment_intent_id == payment_intent_id)
                .first()
            )

            if payment:
                payment.payment_status = "FAILED"
                payment.raw_response_json = data
                payment.failure_reason = (
                    (data.get("last_payment_error") or {}).get("message")
                )

                order = db.query(Order).filter(Order.id == payment.order_id).first()
                if order:
                    order.payment_status = "FAILED"
                    order.order_status = "FAILED"

                db.commit()

        elif event_type == "charge.refunded":
            payment_intent_id = data.get("payment_intent")

            if payment_intent_id:
                payment = (
                    db.query(Payment)
                    .filter(Payment.payment_intent_id == payment_intent_id)
                    .first()
                )

                if payment:
                    payment.payment_status = "REFUNDED"
                    payment.raw_response_json = data
                    payment.refunded_at = datetime.utcnow()

                    order = db.query(Order).filter(Order.id == payment.order_id).first()
                    if order:
                        order.payment_status = "REFUNDED"

                    db.commit()

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Webhook processing failed: {e}")

    return {"received": True}