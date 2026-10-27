import time
from typing import List
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload
from app.db.session import get_db
from app.models.models import Order, OrderItem, CartItem, Product, User
from app.schemas.schemas import OrderCreate, OrderResponse
from app.core.security import get_current_user

router = APIRouter(prefix="/orders", tags=["Orders"])

def generate_order_number() -> str:
    timestamp = int(time.time())
    return f"BM-{timestamp}"

@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    payload: OrderCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    # Fetch user's cart items if explicit items not provided
    cart_res = await db.execute(
        select(CartItem, Product)
        .join(Product, CartItem.product_id == Product.id)
        .where(CartItem.user_id == current_user.id)
    )
    cart_rows = cart_res.all()

    if not cart_rows and not payload.items:
        raise HTTPException(status_code=400, detail="Cannot place order with empty cart")

    subtotal = 0.0
    order_items_to_create = []

    if cart_rows:
        for cart_item, product in cart_rows:
            item_total = product.price * cart_item.quantity
            subtotal += item_total
            order_items_to_create.append(
                OrderItem(
                    product_id=product.id,
                    title=product.title,
                    price=product.price,
                    quantity=cart_item.quantity,
                    unit=product.unit,
                    image_url=product.image_urls[0] if product.image_urls else ""
                )
            )
    elif payload.items:
        for item in payload.items:
            prod_id = item.get("productId") or item.get("product_id")
            prod_res = await db.execute(select(Product).where(Product.id == prod_id))
            product = prod_res.scalars().first()
            if not product:
                continue
            qty = item.get("quantity", 1)
            item_total = product.price * qty
            subtotal += item_total
            order_items_to_create.append(
                OrderItem(
                    product_id=product.id,
                    title=product.title,
                    price=product.price,
                    quantity=qty,
                    unit=product.unit,
                    image_url=product.image_urls[0] if product.image_urls else ""
                )
            )

    tax = round(subtotal * 0.18, 2)
    delivery_fee = 0.0 if subtotal >= 5000 else 250.0
    total_amount = round(subtotal + tax + delivery_fee, 2)
    estimated_delivery = (datetime.now(timezone.utc) + timedelta(days=2)).strftime("%d %b %Y")

    order = Order(
        order_number=generate_order_number(),
        user_id=current_user.id,
        subtotal=subtotal,
        tax=tax,
        delivery_fee=delivery_fee,
        total_amount=total_amount,
        status="confirmed",
        payment_method=payload.payment_method,
        payment_status="paid" if payload.payment_method != "cod" else "pending",
        delivery_address=payload.delivery_address,
        estimated_delivery=estimated_delivery
    )
    db.add(order)
    await db.flush()

    for item in order_items_to_create:
        item.order_id = order.id
        db.add(item)

    # Clear user's cart
    await db.execute(delete(CartItem).where(CartItem.user_id == current_user.id))

    await db.commit()

    # Re-query with eager selectinload
    res = await db.execute(
        select(Order).options(selectinload(Order.items)).where(Order.id == order.id)
    )
    final_order = res.scalars().first()
    return final_order

@router.get("", response_model=List[OrderResponse])
async def list_orders(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
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
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items))
        .where(
            (Order.id == order_id) | (Order.order_number == order_id),
            Order.user_id == current_user.id
        )
    )
    order = result.scalars().first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@router.post("/{order_id}/cancel", response_model=OrderResponse)
async def cancel_order(
    order_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(Order)
        .options(selectinload(Order.items))
        .where(Order.id == order_id, Order.user_id == current_user.id)
    )
    order = result.scalars().first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if order.status in ["dispatched", "delivered"]:
        raise HTTPException(status_code=400, detail="Cannot cancel order once dispatched or delivered")

    order.status = "cancelled"
    await db.commit()
    await db.refresh(order)
    return order
