
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.models import Brand
from app.schemas.schemas import BrandResponse

router = APIRouter(prefix="/brands", tags=["Brands"])

@router.get("", response_model=list[BrandResponse])
async def list_brands(
    category_id: str | None = Query(None),
    db: AsyncSession = Depends(get_db)  # noqa: B008
):
    query = select(Brand)
    if category_id:
        query = query.where(Brand.category_id == category_id)
    query = query.order_by(Brand.name)
    result = await db.execute(query)
    return result.scalars().all()
