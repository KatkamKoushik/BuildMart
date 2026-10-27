import uuid
from typing import Dict, Any
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.models.models import User
from app.schemas.schemas import UserResponse, AddressSchema
from app.core.security import get_current_user

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/address", response_model=UserResponse)
async def add_saved_address(
    address: AddressSchema,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    addr_dict = address.dict()
    if not addr_dict.get("id"):
        addr_dict["id"] = f"addr_{uuid.uuid4().hex[:8]}"

    addresses = list(current_user.saved_addresses or [])
    if addr_dict.get("isDefault"):
        for a in addresses:
            a["isDefault"] = False

    addresses.append(addr_dict)
    current_user.saved_addresses = addresses
    await db.commit()
    await db.refresh(current_user)
    return current_user
