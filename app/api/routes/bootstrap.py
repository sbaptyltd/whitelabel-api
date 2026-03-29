
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.bootstrap import BootstrapResponse
from app.services.tenants import get_tenant_by_code, get_tenant_config, get_active_banners

router = APIRouter(prefix="/api", tags=["bootstrap"])

@router.get("/bootstrap", response_model=BootstrapResponse)
def bootstrap(tenant_code: str, db: Session = Depends(get_db)):
    tenant = get_tenant_by_code(db, tenant_code)
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")

    cfg = get_tenant_config(db, tenant.id)
    if not cfg:
        raise HTTPException(status_code=404, detail="Tenant config not found")

    _ = get_active_banners(db, tenant.id)

    return BootstrapResponse(
        tenant_code=tenant.tenant_code,
        app_name=cfg.app_name,
        currency_code=cfg.currency_code,
        currency_symbol=cfg.currency_symbol,
        theme={
            "primary_color": cfg.primary_color,
            "secondary_color": cfg.secondary_color,
            "accent_color": cfg.accent_color,
            "text_color": cfg.text_color,
            "background_color": cfg.background_color,
            "button_radius": cfg.button_radius,
        },
        branding={
            "logo_url": cfg.app_logo_url,
            "splash_image_url": cfg.splash_image_url,
            "tagline": cfg.app_tagline,
        },
        features={
            "enable_sms": bool(cfg.enable_sms),
            "enable_email": bool(cfg.enable_email),
            "enable_guest_checkout": bool(cfg.enable_guest_checkout),
            "enable_cod": bool(cfg.enable_cod),
            "enable_online_payment": bool(cfg.enable_online_payment),
        },
    )
