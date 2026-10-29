import uuid
from datetime import UTC, datetime

from sqlalchemy import (
    JSON,
    Boolean,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
)
from sqlalchemy.orm import relationship

from app.db.session import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())

def utc_now():
    return datetime.now(UTC)

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    firebase_uid = Column(String(128), unique=True, index=True, nullable=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    phone = Column(String(20), nullable=True)
    role = Column(String(20), default="buyer", nullable=False) # buyer, vendor, admin
    profile_image_url = Column(Text, nullable=True)
    saved_addresses = Column(JSON, default=list)
    created_at = Column(DateTime, default=utc_now)
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now)

    orders = relationship("Order", back_populates="user", cascade="all, delete-orphan")
    cart_items = relationship("CartItem", back_populates="user", cascade="all, delete-orphan")

class Shop(Base):
    __tablename__ = "shops"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    name = Column(String(255), nullable=False, index=True)
    logo_url = Column(Text, nullable=True)
    cover_image_url = Column(Text, nullable=True)
    rating = Column(Float, default=4.5)
    review_count = Column(Integer, default=0)
    address = Column(Text, nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    distance_km = Column(Float, default=1.5)
    is_open = Column(Boolean, default=True)
    categories = Column(JSON, default=list)
    phone = Column(String(30), nullable=True)
    created_at = Column(DateTime, default=utc_now)

    products = relationship("Product", back_populates="shop")

class Category(Base):
    __tablename__ = "categories"

    id = Column(String(100), primary_key=True) # cement, steel, etc.
    name = Column(String(255), nullable=False, index=True)
    image_url = Column(Text, nullable=False)
    sort_order = Column(Integer, default=0)

    products = relationship("Product", back_populates="category")
    brands = relationship("Brand", back_populates="category")

class Brand(Base):
    __tablename__ = "brands"

    id = Column(String(100), primary_key=True)
    name = Column(String(255), nullable=False, index=True)
    image_url = Column(Text, nullable=False)
    category_id = Column(String(100), ForeignKey("categories.id", ondelete="SET NULL"), nullable=True)

    category = relationship("Category", back_populates="brands")
    products = relationship("Product", back_populates="brand")

class Product(Base):
    __tablename__ = "products"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    title = Column(String(255), nullable=False, index=True)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False, index=True)
    original_price = Column(Float, nullable=True)
    category_id = Column(String(100), ForeignKey("categories.id", ondelete="CASCADE"), nullable=False, index=True)
    shop_id = Column(String(36), ForeignKey("shops.id", ondelete="SET NULL"), nullable=True, index=True)
    brand_id = Column(String(100), ForeignKey("brands.id", ondelete="SET NULL"), nullable=True, index=True)
    image_urls = Column(JSON, default=list)
    specifications = Column(JSON, default=dict)
    rating = Column(Float, default=4.5)
    total_reviews = Column(Integer, default=0)
    stock_quantity = Column(Integer, default=100)
    unit = Column(String(50), default="unit")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=utc_now)

    category = relationship("Category", back_populates="products")
    shop = relationship("Shop", back_populates="products")
    brand = relationship("Brand", back_populates="products")

class CartItem(Base):
    __tablename__ = "cart_items"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    product_id = Column(String(36), ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    quantity = Column(Integer, default=1, nullable=False)
    created_at = Column(DateTime, default=utc_now)

    user = relationship("User", back_populates="cart_items")
    product = relationship("Product")

class Order(Base):
    __tablename__ = "orders"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    order_number = Column(String(50), unique=True, index=True, nullable=False)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    subtotal = Column(Float, nullable=False)
    tax = Column(Float, default=0.0)
    delivery_fee = Column(Float, default=0.0)
    total_amount = Column(Float, nullable=False)
    status = Column(String(50), default="pending", index=True) # pending, confirmed, processing, dispatched, delivered, cancelled
    payment_method = Column(String(50), default="razorpay") # razorpay, cod, upi, netbanking, card
    payment_status = Column(String(50), default="pending") # pending, paid, failed, refunded
    razorpay_order_id = Column(String(100), nullable=True, index=True)
    razorpay_payment_id = Column(String(100), nullable=True)
    razorpay_signature = Column(String(255), nullable=True)
    idempotency_key = Column(String(100), nullable=True, index=True)
    delivery_address = Column(JSON, nullable=False)
    estimated_delivery = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=utc_now)
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now)

    user = relationship("User", back_populates="orders")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")

class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    order_id = Column(String(36), ForeignKey("orders.id", ondelete="CASCADE"), nullable=False, index=True)
    product_id = Column(String(36), ForeignKey("products.id", ondelete="SET NULL"), nullable=True)
    title = Column(String(255), nullable=False)
    price = Column(Float, nullable=False)
    quantity = Column(Integer, default=1, nullable=False)
    unit = Column(String(50), default="unit")
    image_url = Column(Text, nullable=True)

    order = relationship("Order", back_populates="items")

class Banner(Base):
    __tablename__ = "banners"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    title = Column(String(255), nullable=False)
    subtitle = Column(String(255), nullable=True)
    image_url = Column(Text, nullable=False)
    target_category = Column(String(100), nullable=True)
    discount_text = Column(String(100), nullable=True)
    is_featured = Column(Boolean, default=True)

class QuoteRequest(Base):
    __tablename__ = "quote_requests"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    quote_number = Column(String(50), unique=True, index=True, nullable=False)
    customer_name = Column(String(255), nullable=False)
    email = Column(String(255), nullable=False)
    phone = Column(String(30), nullable=False)
    project_name = Column(String(255), nullable=True)
    delivery_pincode = Column(String(20), nullable=False)
    items = Column(JSON, default=list)
    estimated_total = Column(Float, default=0.0)
    status = Column(String(50), default="submitted") # draft, submitted, approved, rejected
    created_at = Column(DateTime, default=utc_now)

class WebhookEvent(Base):
    __tablename__ = "webhook_events"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    event_id = Column(String(128), unique=True, index=True, nullable=False)
    event_type = Column(String(100), nullable=False)
    payload = Column(JSON, default=dict)
    status = Column(String(50), default="processed") # processed, ignored, failed
    processed_at = Column(DateTime, default=utc_now)

