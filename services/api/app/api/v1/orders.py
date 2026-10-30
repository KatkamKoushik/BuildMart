import time
from typing import List, Tuple
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload
from app.db.session import get_db
from app.models.models import Order, OrderItem, CartItem, Product, User
from app.schemas.schemas import OrderCreate, OrderResponse, OrderStatusUpdate
from app.core.security import require_authenticated_user, require_admin

router = APIRouter(prefix="/orders", tags=["Orders"])

def generate_order_number() -> str:
    timestamp = int(time.time() * 1000)
    return f"BM-{timestamp}"

# Allowed order lifecycle transitions
VALID_TRANSITIONS = {
    "pending": ["confirmed", "cancelled"],
    "confirmed": ["processing", "cancelled"],
    "processing": ["dispatched", "cancelled"],
    "dispatched": ["delivered"],
    "delivered": [], # Terminal state
    "cancelled": []  # Terminal state
}

def calculate_order_financials(subtotal: float) -> Tuple[float, float, float, float]:
    """
    Authoritative order calculation enforcing:
    - 18% GST (standard Indian construction materials tax rate)
    - Free delivery for orders >= Rs. 5000, otherwise Rs. 250
    Returns (subtotal, tax, delivery_fee, total_amount).
    """
    subtotal = round(subtotal, 2)
    tax = round(subtotal * 0.18, 2)
    delivery_fee = 0.0 if subtotal >= 5000 else 250.0
    total_amount = round(subtotal + tax + delivery_fee, 2)
    return subtotal, tax, delivery_fee, total_amount


def build_items_from_cart(cart_rows) -> Tuple[float, List[OrderItem]]:
    """
    Validates cart items and builds OrderItem instances using current product prices.
    """
    subtotal = 0.0
    order_items: List[OrderItem] = []
    for cart_item, product in cart_rows:
        if cart_item.quantity <= 0:
            raise HTTPException(status_code=422, detail="Item quantity must be greater than zero")
        if not product.is_active:
            raise HTTPException(status_code=400, detail=f"Product '{product.title}' is currently unavailable")

        item_total = round(product.price * cart_item.quantity, 2)
        subtotal += item_total
        order_items.append(
            OrderItem(
                product_id=product.id,
                title=product.title,
                price=product.price,
                quantity=cart_item.quantity,
                unit=product.unit,
                image_url=product.image_urls[0] if product.image_urls else ""
            )
        )
    return subtotal, order_items


async def build_items_from_payload(
    items: List[dict], db: AsyncSession
) -> Tuple[float, List[OrderItem]]:
    """
    Batch-fetches products and builds OrderItem instances from direct order items.
    Prevents N+1 queries by batching product IDs.
    """
    product_ids = [
        item.get("productId") or item.get("product_id")
        for item in items
        if item.get("productId") or item.get("product_id")
    ]
    products_by_id = {}
    if product_ids:
        prod_res = await db.execute(select(Product).where(Product.id.in_(product_ids)))
        products_by_id = {prod.id: prod for prod in prod_res.scalars().all()}

    subtotal = 0.0
    order_items: List[OrderItem] = []
    for item in items:
        prod_id = item.get("productId") or item.get("product_id")
        qty = item.get("quantity", 1)
        if not isinstance(qty, int) or qty <= 0:
            raise HTTPException(status_code=422, detail="Item quantity must be a positive integer")

        product = products_by_id.get(prod_id)
        if not product:
            raise HTTPException(status_code=404, detail=f"Product with ID '{prod_id}' not found")
        if not product.is_active:
            raise HTTPException(status_code=400, detail=f"Product '{product.title}' is currently inactive")

        item_total = round(product.price * qty, 2)
        subtotal += item_total
        order_items.append(
            OrderItem(
                product_id=product.id,
                title=product.title,
                price=product.price,
                quantity=qty,
                unit=product.unit,
                image_url=product.image_urls[0] if product.image_urls else ""
            )
        )
    return subtotal, order_items


@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    payload: OrderCreate,
    current_user: User = Depends(require_authenticated_user),
    db: AsyncSession = Depends(get_db)
):
    """
    F-01, F-11 & F-13: Server-authoritative order creation.
    - Validates quantity > 0 and stock availability.
    - Re-fetches prices from DB (ignoring any client-submitted prices).
    - Enforces 18% GST and standard delivery fee rules.
    - Never marks online orders as 'paid' at creation time.
    """
    cart_res = await db.execute(
        select(CartItem, Product)
        .join(Product, CartItem.product_id == Product.id)
        .where(CartItem.user_id == current_user.id)
    )
    cart_rows = cart_res.all()

    if not cart_rows and not payload.items:
        raise HTTPException(status_code=400, detail="Cannot place order with empty cart")

    if payload.items:
        subtotal, order_items = await build_items_from_payload(payload.items, db)
    else:
        subtotal, order_items = build_items_from_cart(cart_rows)

    if not order_items:
        raise HTTPException(status_code=400, detail="Order must contain at least one valid product")

    subtotal, tax, delivery_fee, total_amount = calculate_order_financials(subtotal)
    estimated_delivery = (datetime.now(timezone.utc) + timedelta(days=2)).strftime("%d %b %Y")

    payment_method = payload.payment_method.lower()
    initial_status = "confirmed" if payment_method == "cod" else "pending"

    order = Order(
        order_number=generate_order_number(),
        user_id=current_user.id,
        subtotal=subtotal,
        tax=tax,
        delivery_fee=delivery_fee,
        total_amount=total_amount,
        status=initial_status,
        payment_method=payment_method,
        payment_status="pending",
        delivery_address=payload.delivery_address,
        estimated_delivery=estimated_delivery
    )
    db.add(order)
    await db.flush()

    for item in order_items:
        item.order_id = order.id
        db.add(item)

    # Clear user's cart
    await db.execute(delete(CartItem).where(CartItem.user_id == current_user.id))
    await db.commit()

    # Re-query with eager selectinload
    res = await db.execute(
        select(Order).options(selectinload(Order.items)).where(Order.id == order.id)
    )
    return res.scalars().first()

@router.get("", response_model=List[OrderResponse])
async def list_orders(
    current_user: User = Depends(require_authenticated_user),
    db: AsyncSession = Depends(get_db)
):
    """
    List orders for the authenticated user only.
    """
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items))
        .where(Order.user_id == current_user.id)
        .order_by(Order.created_at.desc())
    )
    return result.scalars().all()

@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: str,
    current_user: User = Depends(require_authenticated_user),
    db: AsyncSession = Depends(get_db)
):
    """
    F-02 & F-10: Resource ownership enforcement.
    Users cannot access other users' orders. Administrators may access any order.
    """
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items))
        .where((Order.id == order_id) | (Order.order_number == order_id))
    )
    order = result.scalars().first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if order.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access forbidden: You do not have permission to view this order"
        )

    return order

@router.post("/{order_id}/cancel", response_model=OrderResponse)
async def cancel_order(
    order_id: str,
    current_user: User = Depends(require_authenticated_user),
    db: AsyncSession = Depends(get_db)
):
    """
    F-11: Authoritative Order Lifecycle - Cancellation.
    - Owner or admin only.
    - Cannot cancel once dispatched or delivered.
    """
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items))
        .where((Order.id == order_id) | (Order.order_number == order_id))
    )
    order = result.scalars().first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if order.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access forbidden: You do not have permission to cancel this order"
        )

    if order.status in ["dispatched", "delivered"]:
        raise HTTPException(status_code=400, detail="Cannot cancel order once dispatched or delivered")

    if order.status == "cancelled":
        return order

    order.status = "cancelled"
    if order.payment_status == "paid":
        order.payment_status = "refunded"

    await db.commit()
    await db.refresh(order)
    return order

@router.put("/{order_id}/status", response_model=OrderResponse)
async def update_order_status(
    order_id: str,
    payload: OrderStatusUpdate,
    admin_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    F-02 & F-11: Admin-only order status transition with state machine validation.
    """
    new_status = payload.status.lower()
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items))
        .where((Order.id == order_id) | (Order.order_number == order_id))
    )
    order = result.scalars().first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    current_status = order.status
    allowed_next_states = VALID_TRANSITIONS.get(current_status, [])

    if new_status != current_status and new_status not in allowed_next_states:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid state transition: Cannot move order from '{current_status}' to '{new_status}'. Allowed: {allowed_next_states}"
        )

    order.status = new_status
    await db.commit()
    await db.refresh(order)
    return order
