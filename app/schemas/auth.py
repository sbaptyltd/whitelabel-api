from typing import Optional
from pydantic import BaseModel


class RequestOtpRequest(BaseModel):
    tenant_code: str
    mobile_number: str
    purpose: str = "LOGIN"


class RequestOtpResponse(BaseModel):
    message: str
    otp_sent: bool


class VerifyOtpRequest(BaseModel):
    tenant_code: str
    mobile_number: str
    otp_code: str
    full_name: Optional[str] = None
    email: Optional[str] = None


class VerifyOtpResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    tenant_id: int

    role: str = "user"
    store_id: Optional[int] = None
    delivery_partner_id: Optional[int] = None

    mobile_number: Optional[str] = None
    email: Optional[str] = None
    full_name: Optional[str] = None