from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from app.db.session import get_db
from app.models.models import CartItem, Product, User
from app.schemas.schemas import CartItemAdd, CartItemUpdate, CartResponse, CartItemDetail
from app.core.security import get_current_user

router = APIRouter(prefix="/cart", tags=["Cart"])

async def calculate_cart_summary(db: AsyncSession, user_id: str) -> CartResponse:
    result = await db.execute(
        select(CartItem, Product)
        .join(Product, CartItem.product_id == Product.id)
        .where(CartItem.user_id == user_id)
    )
    rows = result.all()

    items: List[CartItemDetail] = []
    subtotal = 0.0
    total_count = 0

    for cart_item, product in rows:
        item_subtotal = round(product.price * cart_item.quantity, 2)
        subtotal += item_subtotal
        total_count += cart_item.quantity
        img = product.image_urls[0] if (product.image_urls and len(product.image_urls) > 0) else ""

        items.append(
            CartItemDetail(
                id=cart_item.id,
                product_id=product.id,
                title=product.title,
                price=product.price,
                quantity=cart_item.quantity,
                image_url=img,
                unit=product.unit,
                shop_id=product.shop_id,
                subtotal=item_subtotal
            )
        )

    # Business rules: 18% GST (standard Indian construction material tax rate), free delivery over ₹5000 else ₹250
    subtotal = round(subtotal, 2)
    tax = round(subtotal * 0.18, 2) if subtotal > 0 else 0.0
    delivery_fee = 0.0 if (subtotal >= 5000 or subtotal == 0) else 250.0
    discount = 0.0
    total = round(subtotal + tax + delivery_fee - discount, 2)

    return CartResponse(
        items=items,
        subtotal=subtotal,
        tax=tax,
        delivery_fee=delivery_fee,
        discount=discount,
        total=total,
        total_count=total_count
    )

@router.get("", response_model=CartResponse)
async def get_cart(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    return await calculate_cart_summary(db, current_user.id)

@router.post("/items", response_model=CartResponse)
async def add_to_cart(
    payload: CartItemAdd,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    # Verify product exists
    prod_res = await db.execute(select(Product).where(Product.id == payload.product_id))
    product = prod_res.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Check if item already exists in user's cart
    item_res = await db.execute(
        select(CartItem).where(
            CartItem.user_id == current_user.id,
            CartItem.product_id == payload.product_id
        )
    )
    existing_item = item_res.scalars().first()

    if existing_item:
        existing_item.quantity += payload.quantity
    else:
        new_item = CartItem(
            user_id=current_user.id,
            product_id=payload.product_id,
            quantity=payload.quantity
        )
        db.add(new_item)

    await db.commit()
    return await calculate_cart_summary(db, current_user.id)

@router.put("/items/{item_id}", response_model=CartResponse)
async def update_cart_item(
    item_id: str,
    payload: CartItemUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    item_res = await db.execute(
        select(CartItem).where(CartItem.id == item_id, CartItem.user_id == current_user.id)
    )
    item = item_res.scalars().first()
    if not item:
        raise HTTPException(status_code=404, detail="Cart item not found")

    if payload.quantity <= 0:
        await db.delete(item)
    else:
        item.quantity = payload.quantity

    await db.commit()
    return await calculate_cart_summary(db, current_user.id)

@router.delete("/items/{item_id}", response_model=CartResponse)
async def remove_cart_item(
    item_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    item_res = await db.execute(
        select(CartItem).where(CartItem.id == item_id, CartItem.user_id == current_user.id)
    )
    item = item_res.scalars().first()
    if item:
        await db.delete(item)
        await db.commit()
    return await calculate_cart_summary(db, current_user.id)

@router.delete("", status_code=status.HTTP_204_NO_CONTENT)
async def clear_cart(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    await db.execute(delete(CartItem).where(CartItem.user_id == current_user.id))
    await db.commit()
    return None
