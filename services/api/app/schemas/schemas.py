from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, EmailStr, Field


# Common Address Schema
class AddressSchema(BaseModel):
    id: str | None = None
    fullName: str
    addressLine1: str
    addressLine2: str | None = None
    city: str
    state: str
    postalCode: str
    phone: str
    isDefault: bool | None = False

# User Schemas
class UserBase(BaseModel):
    name: str
    email: EmailStr
    phone: str | None = None
    role: str = "buyer"
    profile_image_url: str | None = None

class UserCreate(UserBase):
    firebase_uid: str | None = None

class UserResponse(UserBase):
    id: str
    firebase_uid: str | None = None
    saved_addresses: list[dict[str, Any]] = []
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# Category Schemas
class CategoryResponse(BaseModel):
    id: str
    name: str
    image_url: str
    sort_order: int = 0
    product_count: int | None = 0

    model_config = ConfigDict(from_attributes=True)

# Brand Schemas
class BrandResponse(BaseModel):
    id: str
    name: str
    image_url: str
    category_id: str | None = None

    model_config = ConfigDict(from_attributes=True)

# Shop Schemas
class ShopResponse(BaseModel):
    id: str
    name: str
    logo_url: str | None = None
    cover_image_url: str | None = None
    rating: float = 4.5
    review_count: int = 0
    address: str
    latitude: float | None = None
    longitude: float | None = None
    distance_km: float | None = 1.5
    is_open: bool = True
    categories: list[str] = []
    phone: str | None = None

    model_config = ConfigDict(from_attributes=True)

# Product Schemas
class ProductResponse(BaseModel):
    id: str
    title: str
    description: str | None = None
    price: float
    original_price: float | None = None
    category_id: str
    category_name: str | None = None
    shop_id: str | None = None
    shop_name: str | None = None
    brand_id: str | None = None
    brand_name: str | None = None
    image_urls: list[str] = []
    specifications: dict[str, Any] = {}
    rating: float = 4.5
    total_reviews: int = 0
    stock_quantity: int = 100
    unit: str = "unit"
    is_active: bool = True
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# Banner Schemas
class BannerResponse(BaseModel):
    id: str
    title: str
    subtitle: str | None = None
    image_url: str
    target_category: str | None = None
    discount_text: str | None = None
    is_featured: bool = True

    model_config = ConfigDict(from_attributes=True)

# Cart Schemas
class CartItemAdd(BaseModel):
    product_id: str
    quantity: int = Field(default=1, ge=1)

class CartItemUpdate(BaseModel):
    quantity: int = Field(..., ge=0)

class CartItemDetail(BaseModel):
    id: str
    product_id: str
    title: str
    price: float
    quantity: int
    image_url: str
    unit: str
    shop_id: str | None = None
    subtotal: float

class CartResponse(BaseModel):
    items: list[CartItemDetail]
    subtotal: float
    tax: float
    delivery_fee: float
    discount: float
    total: float
    total_count: int

# Order Schemas
class OrderItemResponse(BaseModel):
    id: str
    product_id: str | None = None
    title: str
    price: float
    quantity: int
    unit: str
    image_url: str | None = None

    model_config = ConfigDict(from_attributes=True)

class OrderCreate(BaseModel):
    delivery_address: dict[str, Any]
    payment_method: str = "razorpay"
    items: list[dict[str, Any]] | None = None

class OrderResponse(BaseModel):
    id: str
    order_number: str
    user_id: str
    subtotal: float
    tax: float
    delivery_fee: float
    total_amount: float
    status: str
    payment_method: str
    payment_status: str
    razorpay_order_id: str | None = None
    delivery_address: dict[str, Any]
    estimated_delivery: str | None = None
    items: list[OrderItemResponse] = []
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

# Payment Verification
class RazorpayOrderCreate(BaseModel):
    order_id: str
    currency: str = "INR"
    receipt: str | None = None

class RazorpayVerifyRequest(BaseModel):
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str
    order_id: str | None = None

# Quote Schemas
class QuoteItemSchema(BaseModel):
    product_id: str | None = None
    title: str
    quantity: float
    unit: str = "units"
    category: str | None = None
    notes: str | None = None

class QuoteRequestCreate(BaseModel):
    customer_name: str
    email: EmailStr
    phone: str
    project_name: str | None = None
    delivery_pincode: str
    items: list[QuoteItemSchema]

class QuoteRequestResponse(BaseModel):
    id: str
    quote_number: str
    customer_name: str
    email: str
    phone: str
    project_name: str | None = None
    delivery_pincode: str
    items: list[dict[str, Any]]
    estimated_total: float
    status: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# Admin & Product Management Schemas
class ProductCreate(BaseModel):
    title: str = Field(..., min_length=2)
    description: str | None = None
    price: float = Field(..., gt=0)
    original_price: float | None = None
    category_id: str
    shop_id: str | None = None
    brand_id: str | None = None
    image_urls: list[str] = []
    specifications: dict[str, Any] = {}
    stock_quantity: int = Field(default=100, ge=0)
    unit: str = "unit"
    is_active: bool = True

class ProductUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    price: float | None = Field(None, gt=0)
    original_price: float | None = None
    category_id: str | None = None
    shop_id: str | None = None
    brand_id: str | None = None
    image_urls: list[str] | None = None
    specifications: dict[str, Any] | None = None
    stock_quantity: int | None = Field(None, ge=0)
    unit: str | None = None
    is_active: bool | None = None

class OrderStatusUpdate(BaseModel):
    status: str = Field(..., description="pending, confirmed, processing, dispatched, delivered, cancelled")

# Token & Auth Schemas
class TokenRequest(BaseModel):
    email: EmailStr
    role: str | None = "buyer"

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

class WebhookResponse(BaseModel):
    status: str
    event_id: str
    message: str

