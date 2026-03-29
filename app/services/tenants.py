
from sqlalchemy.orm import Session
from app.models.commerce import Tenant, TenantAppConfig, TenantBanner

def get_tenant_by_code(db: Session, tenant_code: str):
    return db.query(Tenant).filter(Tenant.tenant_code == tenant_code, Tenant.app_status == "ACTIVE").first()

def get_tenant_config(db: Session, tenant_id: int):
    return db.query(TenantAppConfig).filter(TenantAppConfig.tenant_id == tenant_id).first()

def get_active_banners(db: Session, tenant_id: int):
    return db.query(TenantBanner).filter(TenantBanner.tenant_id == tenant_id, TenantBanner.is_active == True).order_by(TenantBanner.sort_order.asc()).all()
