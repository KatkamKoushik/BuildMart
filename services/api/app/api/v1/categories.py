from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.db.session import get_db
from app.models.models import Category, Product
from app.schemas.schemas import CategoryResponse

router = APIRouter(prefix="/categories", tags=["Categories"])

@router.get("", response_model=List[CategoryResponse])
async def list_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Category).order_by(Category.sort_order, Category.name))
    categories = result.scalars().all()
    
    # Get product counts
    counts_res = await db.execute(
        select(Product.category_id, func.count(Product.id)).group_by(Product.category_id)
    )
    counts = dict(counts_res.all())
    
    response = []
    for cat in categories:
        cat_dict = {
            "id": cat.id,
            "name": cat.name,
            "image_url": cat.image_url,
            "sort_order": cat.sort_order,
            "product_count": counts.get(cat.id, 0)
        }
        response.append(cat_dict)
    return response

@router.get("/{category_id}", response_model=CategoryResponse)
async def get_category(category_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Category).where(Category.id == category_id))
    cat = result.scalars().first()
    if not cat:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Category not found")
    
    count_res = await db.execute(
        select(func.count(Product.id)).where(Product.category_id == category_id)
    )
    count = count_res.scalar() or 0
    return {
        "id": cat.id,
        "name": cat.name,
        "image_url": cat.image_url,
        "sort_order": cat.sort_order,
        "product_count": count
    }
