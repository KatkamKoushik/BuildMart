import jwt
from datetime import datetime, timedelta, timezone
from typing import Optional, List, Dict, Any
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.models import User
from app.core.config import settings

security_scheme = HTTPBearer(auto_error=False)

# Seed / Mock user constant for frictionless dev testing
DEFAULT_USER_EMAIL = "buyer@buildmart.dev"
DEFAULT_USER_NAME = "BuildMart Demo User"
ADMIN_USER_EMAIL = "admin@buildmart.dev"
SELLER_USER_EMAIL = "seller@buildmart.dev"

JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_HOURS = 24

def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    """
    Creates a signed JWT access token with standard claims.
    """
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(hours=JWT_EXPIRATION_HOURS)
    to_encode.update({"exp": expire, "iat": now})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=JWT_ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> Dict[str, Any]:
    """
    Decodes and validates a JWT access token.
    Raises HTTPException(401) on expired or invalid token.
    """
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token signature or payload",
            headers={"WWW-Authenticate": "Bearer"},
        )

async def get_or_create_default_user(db: AsyncSession, email: str = DEFAULT_USER_EMAIL, role: str = "buyer", name: str = DEFAULT_USER_NAME) -> User:
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalars().first()
    if not user:
        user = User(
            id=f"usr_{role}_{email.split('@')[0]}",
            name=name,
            email=email,
            phone="9876543210",
            role=role,
            saved_addresses=[
                {
                    "id": "addr_001",
                    "fullName": name,
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

async def get_current_user_from_token(token: str, db: AsyncSession) -> User:
    """
    Resolves a user from a JWT token or developer test token.
    """
    # 1. Dev token format: user:<email>
    if token.startswith("user:"):
        email = token.replace("user:", "").strip()
        result = await db.execute(select(User).where(User.email == email))
        user = result.scalars().first()
        if not user:
            # If in dev, auto-seed the requested test role
            role = "admin" if "admin" in email else ("seller" if "seller" in email else "buyer")
            user = await get_or_create_default_user(db, email=email, role=role, name=f"Test {role.title()}")
        return user

    # 2. Signed JWT Token
    payload = decode_access_token(token)
    user_id = payload.get("sub")
    email = payload.get("email")

    query = select(User)
    if user_id:
        query = query.where(User.id == user_id)
    elif email:
        query = query.where(User.email == email)
    else:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token missing subject or email claim",
            headers={"WWW-Authenticate": "Bearer"},
        )

    result = await db.execute(query)
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User associated with token not found",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user

async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    """
    Resolves the current user.
    If credentials provided, validates token.
    If no credentials provided and in development mode, provides default demo user
    for backward-compatible dev exploration.
    """
    if credentials and credentials.credentials:
        return await get_current_user_from_token(credentials.credentials, db)

    # In development mode, provide default demo user
    if settings.ENVIRONMENT.lower() != "production":
        return await get_or_create_default_user(db)

    # In production, require credentials
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Authentication credentials required",
        headers={"WWW-Authenticate": "Bearer"},
    )

async def require_authenticated_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    """
    Strict authentication dependency. Fails fast with 401 if unauthenticated,
    regardless of environment.
    """
    if not credentials or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token required",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return await get_current_user_from_token(credentials.credentials, db)

def require_role(allowed_roles: List[str]):
    """
    F-02: Role-based authorization guard.
    Rejects unauthorized roles with 403 Forbidden.
    """
    async def role_checker(current_user: User = Depends(require_authenticated_user)) -> User:
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access forbidden: Insufficient privileges. Required role in {allowed_roles}, but current user role is '{current_user.role}'."
            )
        return current_user
    return role_checker

# Convenience RBAC dependencies
require_admin = require_role(["admin"])
require_seller = require_role(["admin", "vendor", "seller"])
