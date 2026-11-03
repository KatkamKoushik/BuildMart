from app.core.logging import logger
import uuid
import hmac
import hashlib
import jwt
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, Header, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.models import User
from app.schemas.schemas import (
    UserResponse,
    AddressSchema,
    RegisterRequest,
    LoginRequest,
    TokenRequest,
    TokenResponse,
    AdminBootstrapRequest,
    PasswordResetRequest,
    PasswordResetConfirm,
)
from app.core.security import (
    get_current_user,
    require_authenticated_user,
    create_access_token,
    decode_access_token,
    revoke_token,
    hash_password,
    verify_password,
    JWT_ALGORITHM,
    JWT_ISSUER,
    JWT_AUDIENCE,
)
from app.core.config import settings

router = APIRouter(prefix="/auth", tags=["Auth"])

RESET_TOKEN_PURPOSE = "password_reset"
RESET_EXPIRATION_MINUTES = 15

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register_account(
    payload: RegisterRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Public registration endpoint.
    - Strictly enforces password complexity.
    - Prevents privilege escalation: Role is unconditionally assigned as 'buyer'.
    - Existing email collision raises 409 Conflict.
    """
    existing_res = await db.execute(select(User).where(User.email == payload.email))
    if existing_res.scalars().first():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email address already exists"
        )

    hashed_pw = hash_password(payload.password)
    user_id = f"usr_{uuid.uuid4().hex[:12]}"
    
    user = User(
        id=user_id,
        name=payload.name,
        email=payload.email,
        phone=payload.phone or "0000000000",
        hashed_password=hashed_pw,
        role="buyer",  # Enforce least privilege server-side
        saved_addresses=[]
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    token = create_access_token({
        "sub": user.id,
        "email": user.email,
        "role": user.role,
        "name": user.name
    })

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=user
    )


@router.post("/login", response_model=TokenResponse)
@router.post("/token", response_model=TokenResponse)
async def login_user(
    payload: TokenRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Authenticates a user and issues a signed JWT access token.
    An email address alone is NOT proof of identity. A valid matching password is required.
    """
    if not payload.password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Password is required to obtain an authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    result = await db.execute(select(User).where(User.email == payload.email))
    user = result.scalars().first()

    if not user or not user.hashed_password or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = create_access_token({
        "sub": user.id,
        "email": user.email,
        "role": user.role,
        "name": user.name
    })

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=user
    )


@router.post("/logout")
async def logout_user(
    authorization: str = Header(...),
    current_user: User = Depends(require_authenticated_user)
):
    """
    Revokes the current authentication token.
    """
    token = authorization.replace("Bearer ", "").strip()
    revoke_token(token)
    return {"message": "Token revoked successfully. Logged out."}


@router.post("/bootstrap-admin", response_model=UserResponse)
async def bootstrap_admin_account(
    payload: AdminBootstrapRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Protected bootstrap protocol to promote an existing account to 'admin'.
    Requires knowledge of the pre-shared ADMIN_BOOTSTRAP_SECRET.
    Fails closed in production if secret is insecure or unconfigured.
    """
    configured_secret = settings.ADMIN_BOOTSTRAP_SECRET
    if not configured_secret or (settings.ENVIRONMENT.lower() == "production" and "dev" in configured_secret.lower()):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Admin bootstrap protocol is unavailable or unconfigured"
        )

    if not hmac.compare_digest(payload.admin_secret.encode("utf-8"), configured_secret.encode("utf-8")):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid administrative bootstrap credentials"
        )

    result = await db.execute(select(User).where(User.email == payload.target_email))
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Target user for administrative promotion not found"
        )

    old_role = user.role
    user.role = "admin"
    await db.commit()
    await db.refresh(user)

    logger.warning(f"[SECURITY AUDIT] User '{user.email}' (ID: {user.id}) promoted from '{old_role}' to 'admin' via bootstrap protocol at {datetime.now(timezone.utc).isoformat()}")
    return user


@router.post("/password-reset-request")
async def request_password_reset(
    payload: PasswordResetRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Initiates a secure password reset flow.
    Issues a short-lived token with strict purpose and expiration claims.
    """
    result = await db.execute(select(User).where(User.email == payload.email))
    user = result.scalars().first()
    
    # Generic response to prevent user enumeration
    resp = {"message": "If this email is registered, a password reset instruction has been generated"}
    if not user:
        return resp

    # Generate cryptographic reset token (15 minute validity)
    expire = datetime.now(timezone.utc) + timedelta(minutes=RESET_EXPIRATION_MINUTES)
    reset_data = {
        "sub": user.id,
        "email": user.email,
        "purpose": RESET_TOKEN_PURPOSE,
        "exp": expire,
        "iss": JWT_ISSUER,
        "aud": JWT_AUDIENCE,
        "jti": str(uuid.uuid4())
    }
    reset_token = jwt.encode(reset_data, settings.SECRET_KEY, algorithm=JWT_ALGORITHM)
    
    # In production, this token is sent via verified email.
    # In non-production, return it for testing validation.
    if settings.ENVIRONMENT.lower() != "production":
        resp["reset_token"] = reset_token
    return resp


@router.post("/password-reset")
async def confirm_password_reset(
    payload: PasswordResetConfirm,
    db: AsyncSession = Depends(get_db)
):
    """
    Completes password reset using a valid, unexpired reset token.
    """
    try:
        data = jwt.decode(
            payload.token,
            settings.SECRET_KEY,
            algorithms=[JWT_ALGORITHM],
            issuer=JWT_ISSUER,
            audience=JWT_AUDIENCE
        )
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=400, detail="Password reset token has expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=400, detail="Invalid password reset token")

    if data.get("purpose") != RESET_TOKEN_PURPOSE:
        raise HTTPException(status_code=400, detail="Invalid token purpose")

    user_id = data.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User account not found")

    user.hashed_password = hash_password(payload.new_password)
    await db.commit()
    return {"message": "Password updated successfully. You may now log in with your new password."}


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(current_user: User = Depends(require_authenticated_user)):
    return current_user


@router.post("/address", response_model=UserResponse)
async def add_saved_address(
    address: AddressSchema,
    current_user: User = Depends(require_authenticated_user),
    db: AsyncSession = Depends(get_db)
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
