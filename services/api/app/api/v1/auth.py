import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import (
    create_access_token,
    get_current_user,
    get_or_create_default_user,
    require_authenticated_user,
)
from app.db.session import get_db
from app.models.models import User
from app.schemas.schemas import AddressSchema, TokenRequest, TokenResponse, UserResponse

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/token", response_model=TokenResponse)
async def login_or_issue_token(
    payload: TokenRequest,
    db: AsyncSession = Depends(get_db)  # noqa: B008
):
    """
    Issues a signed JWT access token for authentication.
    If the user does not exist in dev/test, creates or retrieves user with specified role.
    """
    result = await db.execute(select(User).where(User.email == payload.email))
    user = result.scalars().first()

    if not user:
        role = payload.role if payload.role in ["buyer", "vendor", "seller", "admin"] else "buyer"
        user = await get_or_create_default_user(db, email=payload.email, role=role, name=payload.email.split("@")[0].title())

    token_data = {
        "sub": user.id,
        "email": user.email,
        "role": user.role,
        "name": user.name
    }
    access_token = create_access_token(token_data)

    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        user=user
    )

@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(current_user: User = Depends(get_current_user)):  # noqa: B008
    return current_user

@router.post("/address", response_model=UserResponse)
async def add_saved_address(
    address: AddressSchema,
    current_user: User = Depends(require_authenticated_user),  # noqa: B008
    db: AsyncSession = Depends(get_db)  # noqa: B008
):
    addr_dict = address.model_dump()
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
