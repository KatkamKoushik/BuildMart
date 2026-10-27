from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.models import Shop, Product
from app.schemas.schemas import ShopResponse, ProductResponse

router = APIRouter(prefix="/shops", tags=["Shops"])

@router.get("", response_model=List[ShopResponse])
async def list_shops(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Shop).order_by(Shop.distance_km))
    return result.scalars().all()

@router.get("/{shop_id}", response_model=ShopResponse)
async def get_shop(shop_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Shop).where(Shop.id == shop_id))
    shop = result.scalars().first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found")
    return shop

@router.get("/{shop_id}/products", response_model=List[ProductResponse])
async def get_shop_products(shop_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product).where(Product.shop_id == shop_id, Product.is_active == True))
    return result.scalars().all()
