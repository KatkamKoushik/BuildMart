
from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.models import Banner
from app.schemas.schemas import BannerResponse

router = APIRouter(prefix="/banners", tags=["Banners"])

@router.get("", response_model=list[BannerResponse])
async def list_banners(db: AsyncSession = Depends(get_db)):  # noqa: B008
    result = await db.execute(select(Banner).where(Banner.is_featured == True))
    return result.scalars().all()
