from datetime import datetime
from typing import Any, Optional

from pydantic import BaseModel, Field


class ProductAdminBase(BaseModel):
    category_id: Optional[int] = None
    sort_order: int = 0
    product_name: str = Field(..., min_length=1, max_length=255)
    brand_name: Optional[str] = Field(None, max_length=255)
    product_slug: str = Field(..., min_length=1, max_length=255)
    short_description: Optional[str] = Field(None, max_length=255)
    long_description: Optional[str] = None
    sku: Optional[str] = Field(None, max_length=100)
    barcode: Optional[str] = Field(None, max_length=100)
    image_url: Optional[str] = None
    gallery_json: Optional[Any] = None
    base_price: float = 0.0
    sale_price: Optional[float] = None
    currency_code: str = Field(default="AUD", max_length=10)
    stock_qty: int = 0
    is_featured: bool = False
    is_active: bool = True


class ProductAdminCreate(ProductAdminBase):
    pass


class ProductAdminUpdate(BaseModel):
    category_id: Optional[int] = None
    sort_order: Optional[int] = None
    product_name: Optional[str] = Field(None, min_length=1, max_length=255)
    brand_name: Optional[str] = Field(None, max_length=255)
    product_slug: Optional[str] = Field(None, min_length=1, max_length=255)
    short_description: Optional[str] = Field(None, max_length=255)
    long_description: Optional[str] = None
    sku: Optional[str] = Field(None, max_length=100)
    barcode: Optional[str] = Field(None, max_length=100)
    image_url: Optional[str] = None
    gallery_json: Optional[Any] = None
    base_price: Optional[float] = None
    sale_price: Optional[float] = None
    currency_code: Optional[str] = Field(None, max_length=10)
    stock_qty: Optional[int] = None
    is_featured: Optional[bool] = None
    is_active: Optional[bool] = None


class ProductAdminResponse(BaseModel):
    id: int
    tenant_id: int
    category_id: Optional[int] = None
    sort_order: int
    product_name: str
    brand_name: Optional[str] = None
    product_slug: str
    short_description: Optional[str] = None
    long_description: Optional[str] = None
    sku: Optional[str] = None
    barcode: Optional[str] = None
    image_url: Optional[str] = None
    gallery_json: Optional[Any] = None
    base_price: float
    sale_price: Optional[float] = None
    currency_code: str
    stock_qty: int
    is_featured: bool
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True