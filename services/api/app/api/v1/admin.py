from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc, delete
from sqlalchemy.orm import selectinload
from app.db.session import get_db
from app.models.models import User, Product, Order, Category, Brand, Shop
from app.schemas.schemas import (
    ProductResponse,
    ProductCreate,
    ProductUpdate,
    OrderResponse,
    OrderStatusUpdate,
    UserResponse
)
from app.core.security import require_admin

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.get("/metrics")
async def get_admin_metrics(
    admin_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    F-02: Admin-only platform metrics and KPI summary.
    """
    products_count = await db.scalar(select(func.count(Product.id)))
    orders_count = await db.scalar(select(func.count(Order.id)))
    users_count = await db.scalar(select(func.count(User.id)))
    total_gmv = await db.scalar(select(func.sum(Order.total_amount)).where(Order.payment_status == "paid")) or 0.0

    return {
        "total_products": products_count or 0,
        "total_orders": orders_count or 0,
        "total_users": users_count or 0,
        "total_gmv_inr": round(float(total_gmv), 2),
        "admin_caller": admin_user.email
    }

@router.get("/orders", response_model=List[OrderResponse])
async def list_all_orders_admin(
    status_filter: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    page: int = Query(1, ge=1),
    admin_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    F-02: Admin-only access to view all system orders.
    """
    query = select(Order).options(selectinload(Order.items)).order_by(Order.created_at.desc())
    if status_filter:
        query = query.where(Order.status == status_filter.lower())

    offset = (page - 1) * limit
    query = query.offset(offset).limit(limit)

    result = await db.execute(query)
    return result.scalars().all()

@router.post("/products", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product_admin(
    payload: ProductCreate,
    admin_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    F-02: Admin-only product creation.
    """
    # Verify category exists
    cat_res = await db.execute(select(Category).where(Category.id == payload.category_id))
    if not cat_res.scalars().first():
        raise HTTPException(status_code=400, detail=f"Category '{payload.category_id}' does not exist")

    # If brand provided, verify brand exists
    if payload.brand_id:
        brand_res = await db.execute(select(Brand).where(Brand.id == payload.brand_id))
        if not brand_res.scalars().first():
            raise HTTPException(status_code=400, detail=f"Brand '{payload.brand_id}' does not exist")

    product = Product(
        title=payload.title,
        description=payload.description,
        price=payload.price,
        original_price=payload.original_price or payload.price,
        category_id=payload.category_id,
        shop_id=payload.shop_id,
        brand_id=payload.brand_id,
        image_urls=payload.image_urls,
        specifications=payload.specifications,
        stock_quantity=payload.stock_quantity,
        unit=payload.unit,
        is_active=payload.is_active
    )
    db.add(product)
    await db.commit()
    await db.refresh(product)
    return product

@router.put("/products/{product_id}", response_model=ProductResponse)
async def update_product_admin(
    product_id: str,
    payload: ProductUpdate,
    admin_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    F-02: Admin-only product modification.
    """
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    update_data = payload.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(product, key, value)

    await db.commit()
    await db.refresh(product)
    return product

@router.delete("/products/{product_id}", status_code=status.HTTP_200_OK)
async def delete_product_admin(
    product_id: str,
    admin_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    F-02: Admin-only product deletion.
    """
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    await db.delete(product)
    await db.commit()
    return {"message": f"Product '{product_id}' deleted successfully", "deleted": True}
