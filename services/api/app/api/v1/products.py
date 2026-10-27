from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, desc, asc
from app.db.session import get_db
from app.models.models import Product, Category, Shop, Brand
from app.schemas.schemas import ProductResponse

router = APIRouter(prefix="/products", tags=["Products"])

@router.get("", response_model=List[ProductResponse])
async def list_products(
    category_id: Optional[str] = Query(None),
    brand_id: Optional[str] = Query(None),
    shop_id: Optional[str] = Query(None),
    q: Optional[str] = Query(None, description="Search term for title or description"),
    min_price: Optional[float] = Query(None),
    max_price: Optional[float] = Query(None),
    sort_by: Optional[str] = Query("popular", description="popular, price_low, price_high, rating"),
    limit: int = Query(50, ge=1, le=250),
    page: int = Query(1, ge=1),
    db: AsyncSession = Depends(get_db)
):
    query = select(Product).where(Product.is_active == True)

    if category_id:
        query = query.where(Product.category_id == category_id)
    if brand_id:
        query = query.where(Product.brand_id == brand_id)
    if shop_id:
        query = query.where(Product.shop_id == shop_id)
    if q and q.strip():
        search_pattern = f"%{q.strip()}%"
        query = query.where(
            or_(
                Product.title.ilike(search_pattern),
                Product.description.ilike(search_pattern)
            )
        )
    if min_price is not None:
        query = query.where(Product.price >= min_price)
    if max_price is not None:
        query = query.where(Product.price <= max_price)

    # Sorting
    if sort_by == "price_low":
        query = query.order_by(asc(Product.price))
    elif sort_by == "price_high":
        query = query.order_by(desc(Product.price))
    elif sort_by == "rating":
        query = query.order_by(desc(Product.rating))
    else:
        query = query.order_by(desc(Product.total_reviews), desc(Product.rating))

    # Pagination
    offset = (page - 1) * limit
    query = query.offset(offset).limit(limit)

    result = await db.execute(query)
    products = result.scalars().all()
    return products

@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(product_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product
