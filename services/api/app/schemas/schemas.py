from typing import List, Optional, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field, EmailStr, ConfigDict

# Common Address Schema
class AddressSchema(BaseModel):
    id: Optional[str] = None
    fullName: str
    addressLine1: str
    addressLine2: Optional[str] = None
    city: str
    state: str
    postalCode: str
    phone: str
    isDefault: Optional[bool] = False

# User Schemas
class UserBase(BaseModel):
    name: str
    email: EmailStr
    phone: Optional[str] = None
    role: str = "buyer"
    profile_image_url: Optional[str] = None

class UserCreate(UserBase):
    firebase_uid: Optional[str] = None

class UserResponse(UserBase):
    id: str
    firebase_uid: Optional[str] = None
    saved_addresses: List[Dict[str, Any]] = []
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# Category Schemas
class CategoryResponse(BaseModel):
    id: str
    name: str
    image_url: str
    sort_order: int = 0
    product_count: Optional[int] = 0

    model_config = ConfigDict(from_attributes=True)

# Brand Schemas
class BrandResponse(BaseModel):
    id: str
    name: str
    image_url: str
    category_id: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

# Shop Schemas
class ShopResponse(BaseModel):
    id: str
    name: str
    logo_url: Optional[str] = None
    cover_image_url: Optional[str] = None
    rating: float = 4.5
    review_count: int = 0
    address: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    distance_km: Optional[float] = 1.5
    is_open: bool = True
    categories: List[str] = []
    phone: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

# Product Schemas
class ProductResponse(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    price: float
    original_price: Optional[float] = None
    category_id: str
    category_name: Optional[str] = None
    shop_id: Optional[str] = None
    shop_name: Optional[str] = None
    brand_id: Optional[str] = None
    brand_name: Optional[str] = None
    image_urls: List[str] = []
    specifications: Dict[str, Any] = {}
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
    subtitle: Optional[str] = None
    image_url: str
    target_category: Optional[str] = None
    discount_text: Optional[str] = None
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
    shop_id: Optional[str] = None
    subtotal: float

class CartResponse(BaseModel):
    items: List[CartItemDetail]
    subtotal: float
    tax: float
    delivery_fee: float
    discount: float
    total: float
    total_count: int

# Order Schemas
class OrderItemResponse(BaseModel):
    id: str
    product_id: Optional[str] = None
    title: str
    price: float
    quantity: int
    unit: str
    image_url: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

class OrderCreate(BaseModel):
    delivery_address: Dict[str, Any]
    payment_method: str = "razorpay"
    items: Optional[List[Dict[str, Any]]] = None

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
    razorpay_order_id: Optional[str] = None
    delivery_address: Dict[str, Any]
    estimated_delivery: Optional[str] = None
    items: List[OrderItemResponse] = []
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

# Payment Verification
class RazorpayOrderCreate(BaseModel):
    amount: float
    currency: str = "INR"
    receipt: Optional[str] = None

class RazorpayVerifyRequest(BaseModel):
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str
    order_id: Optional[str] = None

# Quote Schemas
class QuoteItemSchema(BaseModel):
    product_id: Optional[str] = None
    title: str
    quantity: float
    unit: str = "units"
    category: Optional[str] = None
    notes: Optional[str] = None

class QuoteRequestCreate(BaseModel):
    customer_name: str
    email: EmailStr
    phone: str
    project_name: Optional[str] = None
    delivery_pincode: str
    items: List[QuoteItemSchema]

class QuoteRequestResponse(BaseModel):
    id: str
    quote_number: str
    customer_name: str
    email: str
    phone: str
    project_name: Optional[str] = None
    delivery_pincode: str
    items: List[Dict[str, Any]]
    estimated_total: float
    status: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# Admin & Product Management Schemas
class ProductCreate(BaseModel):
    title: str = Field(..., min_length=2)
    description: Optional[str] = None
    price: float = Field(..., gt=0)
    original_price: Optional[float] = None
    category_id: str
    shop_id: Optional[str] = None
    brand_id: Optional[str] = None
    image_urls: List[str] = []
    specifications: Dict[str, Any] = {}
    stock_quantity: int = Field(default=100, ge=0)
    unit: str = "unit"
    is_active: bool = True

class ProductUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = Field(None, gt=0)
    original_price: Optional[float] = None
    category_id: Optional[str] = None
    shop_id: Optional[str] = None
    brand_id: Optional[str] = None
    image_urls: Optional[List[str]] = None
    specifications: Optional[Dict[str, Any]] = None
    stock_quantity: Optional[int] = Field(None, ge=0)
    unit: Optional[str] = None
    is_active: Optional[bool] = None

class OrderStatusUpdate(BaseModel):
    status: str = Field(..., description="pending, confirmed, processing, dispatched, delivered, cancelled")

# Token & Auth Schemas
class TokenRequest(BaseModel):
    email: EmailStr
    role: Optional[str] = "buyer"

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

class WebhookResponse(BaseModel):
    status: str
    event_id: str
    message: str

