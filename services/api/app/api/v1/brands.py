from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.models import Brand
from app.schemas.schemas import BrandResponse

router = APIRouter(prefix="/brands", tags=["Brands"])

@router.get("", response_model=List[BrandResponse])
async def list_brands(
    category_id: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    query = select(Brand)
    if category_id:
        query = query.where(Brand.category_id == category_id)
    query = query.order_by(Brand.name)
    result = await db.execute(query)
    return result.scalars().all()
