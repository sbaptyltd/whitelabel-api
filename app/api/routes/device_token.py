from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.commerce import UserDeviceToken

router = APIRouter(prefix="/api/device-token", tags=["device-token"])


class RegisterDeviceTokenRequest(BaseModel):
    device_token: str
    platform: str | None = "unknown"


@router.post("/register")
def register_device_token(
    payload: RegisterDeviceTokenRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    token = payload.device_token.strip()

    if not token:
        raise HTTPException(status_code=400, detail="device_token is required")

    existing = (
        db.query(UserDeviceToken)
        .filter(
            UserDeviceToken.tenant_id == current_user.tenant_id,
            UserDeviceToken.user_id == current_user.id,
            UserDeviceToken.device_token == token,
        )
        .first()
    )

    if existing:
        existing.platform = payload.platform
        existing.is_active = True
        db.commit()
        return {"message": "Device token already registered"}

    row = UserDeviceToken(
        tenant_id=current_user.tenant_id,
        user_id=current_user.id,
        device_token=token,
        platform=payload.platform,
        is_active=True,
    )

    db.add(row)
    db.commit()

    return {"message": "Device token registered"}