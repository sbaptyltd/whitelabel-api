from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

# USE THE SAME get_db IMPORT USED IN YOUR OTHER WORKING ROUTES
from app.db.session import get_db

from app.models.store import Store, StorePincode
from app.models.commerce import Tenant, TenantAppConfig, TenantBanner


router = APIRouter(
    prefix="/api/stores",
    tags=["Stores"],
)


@router.get("/check-pincode")
def check_pincode(
    tenant_code: str = Query(...),
    pincode: str = Query(...),
    db: Session = Depends(get_db),
):
    """
    Example:
    /api/stores/check-pincode?tenant_code=desi-tales&pincode=3023
    """

    clean_tenant = tenant_code.strip()
    clean_pincode = pincode.strip()

    tenant = (
        db.query(Tenant)
        .filter(Tenant.tenant_code == clean_tenant)
        .first()
    )

    if not tenant:
        return {
            "serviceable": False,
            "message": "Invalid tenant."
        }

    mapping = (
        db.query(StorePincode)
        .join(Store, Store.id == StorePincode.store_id)
        .filter(
            Store.tenant_id == tenant.id,
            Store.is_active == True,
            StorePincode.is_active == True,
            StorePincode.pincode == clean_pincode,
        )
        .first()
    )

    if not mapping:
        return {
            "serviceable": False,
            "message": "Sorry, delivery is not available for this pincode yet."
        }

    return {
        "serviceable": True,
        "message": "Delivery available for this pincode."
    }