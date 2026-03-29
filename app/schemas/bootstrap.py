
from typing import Optional
from pydantic import BaseModel

class BootstrapResponse(BaseModel):
    tenant_code: str
    app_name: str
    currency_code: str
    currency_symbol: str
    theme: dict
    branding: dict
    features: dict
