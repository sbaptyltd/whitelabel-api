from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.commerce import Tenant, Store
from app.models.store import StorePincode

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
        .filter(
            Tenant.tenant_code == clean_tenant,
            Tenant.app_status == "ACTIVE",
        )
        .first()
    )

    if not tenant:
        return {
            "serviceable": False,
            "store_id": None,
            "message": "Invalid tenant.",
        }

    row = (
        db.query(StorePincode, Store)
        .join(Store, Store.id == StorePincode.store_id)
        .filter(
            Store.tenant_id == tenant.id,
            Store.is_active == True,
            StorePincode.tenant_id == tenant.id,
            StorePincode.is_active == True,
            StorePincode.pincode == clean_pincode,
        )
        .first()
    )

    if not row:
        return {
            "serviceable": False,
            "store_id": None,
            "message": "Sorry, delivery is not available for this pincode yet.",
        }

    mapping, store = row

    return {
        "serviceable": True,
        "store_id": int(store.id),
        "store_name": store.store_name,
        "message": "Delivery available for this pincode.",
    }


@router.get("/nearby")
def nearby_stores(
    tenant_code: str = Query(...),
    pincode: str = Query(...),
    db: Session = Depends(get_db),
):
    clean_tenant = tenant_code.strip()
    clean_pincode = pincode.strip()

    tenant = (
        db.query(Tenant)
        .filter(
            Tenant.tenant_code == clean_tenant,
            Tenant.app_status == "ACTIVE",
        )
        .first()
    )

    if not tenant:
        return {
            "stores": [],
            "message": "Invalid tenant.",
        }

    rows = (
        db.query(StorePincode, Store)
        .join(Store, Store.id == StorePincode.store_id)
        .filter(
            Store.tenant_id == tenant.id,
            Store.is_active == True,
            StorePincode.tenant_id == tenant.id,
            StorePincode.is_active == True,
            StorePincode.pincode == clean_pincode,
        )
        .all()
    )

    stores = []

    for mapping, store in rows:
        stores.append(
            {
                "id": int(store.id),
                "store_id": int(store.id),
                "store_name": store.store_name,
                "store_email": store.store_email,
                "store_phone": store.store_phone,
                "address": store.address,
                "pincode": clean_pincode,
            }
        )

    return {
        "stores": stores,
        "message": "Stores fetched successfully."
        if stores
        else "No stores found for this pincode.",
    }