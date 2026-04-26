from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.config import settings
from app.db.session import get_db
from app.models.commerce import OtpRequest, Tenant, User
from app.schemas.auth import (
    RequestOtpRequest,
    RequestOtpResponse,
    VerifyOtpRequest,
    VerifyOtpResponse,
)
from app.services.security import create_access_token
from app.services.twilio_sms import generate_otp, send_sms_otp, normalize_phone_number

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.get("/me")
def me(current_user=Depends(get_current_user)):
    return {
        "id": int(current_user.id),
        "tenant_id": int(current_user.tenant_id),
        "mobile_number": current_user.mobile_number,
        "email": current_user.email,
        "full_name": current_user.full_name,
        "role": current_user.role or "user",
        "store_id": int(current_user.store_id) if current_user.store_id else None,
        "delivery_partner_id": int(current_user.delivery_partner_id)
        if current_user.delivery_partner_id
        else None,
    }


@router.post("/request-otp", response_model=RequestOtpResponse)
def request_otp(payload: RequestOtpRequest, db: Session = Depends(get_db)):
    tenant = db.query(Tenant).filter(
        Tenant.tenant_code == payload.tenant_code,
        Tenant.app_status == "ACTIVE",
    ).first()

    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")

    normalized_mobile = normalize_phone_number(payload.mobile_number)
    otp_code = generate_otp()

    try:
        sms_result = send_sms_otp(
            phone_number=normalized_mobile,
            otp_code=otp_code,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send OTP: {str(e)}")

    otp = OtpRequest(
        tenant_id=tenant.id,
        mobile_number=normalized_mobile,
        otp_code=otp_code,
        purpose=payload.purpose,
        is_used=False,
        expires_at=datetime.utcnow() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES),
    )

    db.add(otp)
    db.commit()

    return RequestOtpResponse(
        message=f"OTP sent successfully. Status: {sms_result['status']}",
        otp_sent=True,
    )


@router.post("/verify-otp", response_model=VerifyOtpResponse)
def verify_otp(payload: VerifyOtpRequest, db: Session = Depends(get_db)):
    tenant = db.query(Tenant).filter(
        Tenant.tenant_code == payload.tenant_code,
        Tenant.app_status == "ACTIVE",
    ).first()

    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")

    normalized_mobile = normalize_phone_number(payload.mobile_number)

    otp_row = db.query(OtpRequest).filter(
        OtpRequest.tenant_id == tenant.id,
        OtpRequest.mobile_number == normalized_mobile,
        OtpRequest.otp_code == payload.otp_code.strip(),
        OtpRequest.is_used == False,
    ).order_by(OtpRequest.id.desc()).first()

    if not otp_row:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    if otp_row.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="OTP expired")

    otp_row.is_used = True

    user = db.query(User).filter(
        User.tenant_id == tenant.id,
        User.mobile_number == normalized_mobile,
    ).first()

    now = datetime.utcnow()

    if not user:
        user = User(
            tenant_id=tenant.id,
            full_name=payload.full_name,
            mobile_number=normalized_mobile,
            email=payload.email,
            role="user",
            is_mobile_verified=True,
            status="ACTIVE",
            created_at=now,
            updated_at=now,
        )
        db.add(user)
        db.flush()
    else:
        user.is_mobile_verified = True
        user.updated_at = now

        if payload.full_name:
            user.full_name = payload.full_name

        if payload.email:
            user.email = payload.email

    db.commit()

    token = create_access_token(str(user.id))

    return {
        "access_token": token,
        "token_type": "bearer",
        "user_id": int(user.id),
        "tenant_id": int(tenant.id),
        "role": user.role or "user",
        "store_id": int(user.store_id) if user.store_id else None,
        "delivery_partner_id": int(user.delivery_partner_id)
        if user.delivery_partner_id
        else None,
        "mobile_number": user.mobile_number,
        "email": user.email,
        "full_name": user.full_name,
    }