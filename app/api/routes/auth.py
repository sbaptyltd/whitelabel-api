
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.config import settings
from app.db.session import get_db
from app.models.commerce import OtpRequest, Tenant, User
from app.schemas.auth import RequestOtpRequest, RequestOtpResponse, VerifyOtpRequest, VerifyOtpResponse
from app.services.security import create_access_token

router = APIRouter(prefix="/api/auth", tags=["auth"])

@router.post("/request-otp", response_model=RequestOtpResponse)
def request_otp(payload: RequestOtpRequest, db: Session = Depends(get_db)):
    tenant = db.query(Tenant).filter(Tenant.tenant_code == payload.tenant_code, Tenant.app_status == "ACTIVE").first()
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")

    otp = OtpRequest(
        tenant_id=tenant.id,
        mobile_number=payload.mobile_number,
        otp_code=settings.OTP_BYPASS_CODE,
        purpose=payload.purpose,
        is_used=False,
        expires_at=datetime.utcnow() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES),
    )
    db.add(otp)
    db.commit()
    return RequestOtpResponse(message="OTP sent", otp_sent=True)

@router.post("/verify-otp", response_model=VerifyOtpResponse)
def verify_otp(payload: VerifyOtpRequest, db: Session = Depends(get_db)):
    tenant = db.query(Tenant).filter(Tenant.tenant_code == payload.tenant_code, Tenant.app_status == "ACTIVE").first()
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")

    if payload.otp_code != settings.OTP_BYPASS_CODE:
        otp_row = db.query(OtpRequest).filter(
            OtpRequest.tenant_id == tenant.id,
            OtpRequest.mobile_number == payload.mobile_number,
            OtpRequest.otp_code == payload.otp_code,
            OtpRequest.is_used == False
        ).order_by(OtpRequest.id.desc()).first()
        if not otp_row:
            raise HTTPException(status_code=400, detail="Invalid OTP")
        if otp_row.expires_at < datetime.utcnow():
            raise HTTPException(status_code=400, detail="OTP expired")
        otp_row.is_used = True

    user = db.query(User).filter(User.tenant_id == tenant.id, User.mobile_number == payload.mobile_number).first()
    if not user:
        user = User(
            tenant_id=tenant.id,
            full_name=payload.full_name,
            mobile_number=payload.mobile_number,
            email=payload.email,
            is_mobile_verified=True,
            status="ACTIVE",
        )
        db.add(user)
        db.flush()
    else:
        user.is_mobile_verified = True
        if payload.full_name:
            user.full_name = payload.full_name
        if payload.email:
            user.email = payload.email

    db.commit()
    token = create_access_token(str(user.id))
    return VerifyOtpResponse(access_token=token, user_id=int(user.id), tenant_id=int(tenant.id))
