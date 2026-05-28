from datetime import datetime, timedelta
import hashlib
import secrets

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.services.twilio_sms import generate_otp, send_sms_otp, normalize_phone_number

router = APIRouter(prefix="/api/auth/signup", tags=["signup-auth"])


class SignupRequestOtpRequest(BaseModel):
    tenant_code: str
    full_name: str
    mobile_number: str
    email: str
    purpose: str = "SIGNUP"


class SignupVerifyOtpRequest(BaseModel):
    tenant_code: str
    full_name: str
    mobile_number: str
    email: str
    otp_code: str


def normalize_mobile(mobile: str) -> str:
    mobile = mobile.strip().replace(" ", "")

    if mobile.startswith("+"):
        return mobile

    if mobile.startswith("0"):
        return "+61" + mobile[1:]

    return mobile


@router.post("/request-otp")
def signup_request_otp(
    payload: SignupRequestOtpRequest,
    db: Session = Depends(get_db),
):
   
    mobile = normalize_phone_number(payload.mobile_number)
    email = payload.email.strip().lower()

    tenant = db.execute(
        text(
            """
            SELECT id
            FROM tenants
            WHERE tenant_code = :tenant_code
            LIMIT 1
            """
        ),
        {"tenant_code": payload.tenant_code},
    ).mappings().first()

    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")

    tenant_id = tenant["id"]

    existing_user = db.execute(
        text(
            """
            SELECT id
            FROM users
            WHERE tenant_id = :tenant_id
              AND mobile_number = :mobile_number
              AND status = 'ACTIVE'
            LIMIT 1
            """
        ),
        {
            "tenant_id": tenant_id,
            "mobile_number": mobile,
        },
    ).mappings().first()

    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="User already exists. Please login.",
        )

    otp_code = generate_otp()

    otp_hash = hashlib.sha256(otp_code.encode()).hexdigest()

    expires_at = datetime.utcnow() + timedelta(minutes=5)

    db.execute(
        text(
            """
            INSERT INTO otp_requests
                (
                    tenant_id,
                    mobile_number,
                    otp_hash,
                    purpose,
                    expires_at,
                    is_used,
                    created_at
                )
            VALUES
                (
                    :tenant_id,
                    :mobile_number,
                    :otp_hash,
                    'SIGNUP',
                    :expires_at,
                    0,
                    NOW()
                )
            """
        ),
        {
            "tenant_id": tenant_id,
            "mobile_number": mobile,
            "otp_hash": otp_hash,
            "expires_at": expires_at,
        },
    )

    db.commit()

    send_sms_otp(mobile, otp_code)

    return {
        "success": True,
        "message": "OTP sent successfully.",
    }


@router.post("/verify-otp")
def signup_verify_otp(
    payload: SignupVerifyOtpRequest,
    db: Session = Depends(get_db),
):
    mobile = normalize_mobile(payload.mobile_number)
    email = payload.email.strip().lower()

    tenant = db.execute(
        text(
            """
            SELECT id
            FROM tenants
            WHERE tenant_code = :tenant_code
            LIMIT 1
            """
        ),
        {"tenant_code": payload.tenant_code},
    ).mappings().first()

    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")

    tenant_id = tenant["id"]

    existing_user = db.execute(
        text(
            """
            SELECT id
            FROM users
            WHERE tenant_id = :tenant_id
              AND mobile_number = :mobile_number
              AND status = 'ACTIVE'
            LIMIT 1
            """
        ),
        {
            "tenant_id": tenant_id,
            "mobile_number": mobile,
        },
    ).mappings().first()

    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="User already exists. Please login.",
        )

    otp_hash = hashlib.sha256(payload.otp_code.encode()).hexdigest()

    otp_row = db.execute(
        text(
            """
            SELECT id
            FROM otp_requests
            WHERE tenant_id = :tenant_id
              AND mobile_number = :mobile_number
              AND otp_hash = :otp_hash
              AND purpose = 'SIGNUP'
              AND is_used = 0
              AND expires_at > NOW()
            ORDER BY id DESC
            LIMIT 1
            """
        ),
        {
            "tenant_id": tenant_id,
            "mobile_number": mobile,
            "otp_hash": otp_hash,
        },
    ).mappings().first()

    if not otp_row:
        raise HTTPException(
            status_code=400,
            detail="Invalid or expired OTP.",
        )

    db.execute(
        text(
            """
            UPDATE otp_requests
            SET is_used = 1
            WHERE id = :id
            """
        ),
        {
            "id": otp_row["id"],
        },
    )

    db.execute(
        text(
            """
            INSERT INTO users
                (
                    tenant_id,
                    full_name,
                    mobile_number,
                    email,
                    is_mobile_verified,
                    status,
                    role,
                    created_at,
                    updated_at
                )
            VALUES
                (
                    :tenant_id,
                    :full_name,
                    :mobile_number,
                    :email,
                    1,
                    'ACTIVE',
                    'user',
                    NOW(),
                    NOW()
                )
            """
        ),
        {
            "tenant_id": tenant_id,
            "full_name": payload.full_name.strip(),
            "mobile_number": mobile,
            "email": email,
        },
    )

    db.commit()

    return {
        "success": True,
        "message": "Signup completed successfully. Please login.",
    }