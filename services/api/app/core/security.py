from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.models import User

security_scheme = HTTPBearer(auto_error=False)

# Seed / Mock user constant for frictionless dev testing
DEFAULT_USER_EMAIL = "buyer@buildmart.dev"
DEFAULT_USER_NAME = "BuildMart Demo User"

async def get_or_create_default_user(db: AsyncSession) -> User:
    result = await db.execute(select(User).where(User.email == DEFAULT_USER_EMAIL))
    user = result.scalars().first()
    if not user:
        user = User(
            id="usr_demo_buildmart_001",
            name=DEFAULT_USER_NAME,
            email=DEFAULT_USER_EMAIL,
            phone="9876543210",
            role="buyer",
            saved_addresses=[
                {
                    "id": "addr_001",
                    "fullName": "BuildMart Site Manager",
                    "addressLine1": "Plot 42, Hitec City Phase 2",
                    "addressLine2": "Near Cyber Towers",
                    "city": "Hyderabad",
                    "state": "Telangana",
                    "postalCode": "500081",
                    "phone": "9876543210",
                    "isDefault": True
                }
            ]
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
    return user

async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    """
    Retrieves current user. If no auth or dev token provided, falls back to default demo user
    to support seamless client browsing and testing without complex auth blockers.
    """
    if not credentials or not credentials.credentials:
        return await get_or_create_default_user(db)

    token = credentials.credentials
    # In dev, handle test token or email in token
    if token.startswith("user:"):
        email = token.replace("user:", "")
        result = await db.execute(select(User).where(User.email == email))
        user = result.scalars().first()
        if user:
            return user

    # Default fallback
    return await get_or_create_default_user(db)
