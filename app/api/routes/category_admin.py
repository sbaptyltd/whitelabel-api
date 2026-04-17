from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class CategoryAdminBase(BaseModel):
    category_name: str = Field(..., min_length=1, max_length=255)
    category_slug: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    image_url: Optional[str] = None
    sort_order: int = 0
    is_active: bool = True


class CategoryAdminCreate(CategoryAdminBase):
    pass


class CategoryAdminUpdate(BaseModel):
    category_name: Optional[str] = Field(None, min_length=1, max_length=255)
    category_slug: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    image_url: Optional[str] = None
    sort_order: Optional[int] = None
    is_active: Optional[bool] = None


class CategoryAdminResponse(BaseModel):
    id: int
    tenant_id: int
    category_name: str
    category_slug: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    sort_order: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True