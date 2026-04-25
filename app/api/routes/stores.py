from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db.session import get_db

from app.models.store import Store, StorePincode
from app.models.commerce import Tenant


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


@router.get("/nearby")
def nearby_stores(
    tenant_code: str = Query(...),
    pincode: str = Query(...),
    db: Session = Depends(get_db),
):
    """
    Example:
    /api/stores/nearby?tenant_code=desi-tales&pincode=3023

    Used for Click & Collect.
    Returns stores serving or linked to the entered pincode.
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
            "stores": [],
            "message": "Invalid tenant."
        }

    mappings = (
        db.query(StorePincode)
        .join(Store, Store.id == StorePincode.store_id)
        .filter(
            Store.tenant_id == tenant.id,
            Store.is_active == True,
            StorePincode.is_active == True,
            StorePincode.pincode == clean_pincode,
        )
        .all()
    )

    stores = []
    for mapping in mappings:
        store = mapping.store

        stores.append({
            "id": store.id,
            "store_name": store.store_name,
            "store_email": store.store_email,
            "store_phone": store.store_phone,
            "address": store.address,
            "pincode": clean_pincode,
        })

    return {
        "stores": stores,
        "message": "Stores fetched successfully." if stores else "No stores found for this pincode."
    }