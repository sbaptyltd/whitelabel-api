from typing import Optional
from pydantic import BaseModel, Field


class AddCartItemRequest(BaseModel):
    product_id: int
    quantity: int = Field(default=1, ge=1)


class UpdateCartItemRequest(BaseModel):
    product_id: int
    quantity: int = Field(ge=0)


class RemoveCartItemRequest(BaseModel):
    product_id: int


class CreateOrderRequest(BaseModel):
    store_id: int
    delivery_pincode: Optional[str] = None
    delivery_address_text: Optional[str] = None
    customer_email: Optional[str] = None
    notes: Optional[str] = None
    payment_provider: str = "stripe"


class ConfirmPaymentRequest(BaseModel):
    order_id: int
    payment_reference: Optional[str] = None
    payment_intent_id: Optional[str] = None
    raw_response_json: Optional[dict] = None