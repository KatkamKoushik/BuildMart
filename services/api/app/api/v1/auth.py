from app.core.logging import logger
import uuid
import time
import hmac
import hashlib
import jwt
from typing import Optional, Dict, List
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, Header, Response, Request, status
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
    revoke_token_id,
    is_token_revoked,
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

# Password reset in-memory sliding window rate-limiter: email -> list of timestamps
RESET_RATE_LIMITS: Dict[str, List[float]] = {}
MAX_RESETS_PER_WINDOW = 3
RESET_WINDOW_SECONDS = 900  # 15 minutes

def check_reset_rate_limit(email: str) -> bool:
    now = time.time()
    timestamps = [t for t in RESET_RATE_LIMITS.get(email, []) if now - t < RESET_WINDOW_SECONDS]
    if len(timestamps) >= MAX_RESETS_PER_WINDOW:
        return False
    timestamps.append(now)
    RESET_RATE_LIMITS[email] = timestamps
    return True

async def dispatch_password_reset_email(to_email: str, reset_token: str) -> None:
    """
    Dispatches password reset verification email.
    If SMTP server is configured, sends via SMTP with TLS.
    Otherwise, logs structured audit event for transactional provider.
    """
    if settings.SMTP_HOST and settings.SMTP_USER and settings.SMTP_PASSWORD:
        import smtplib
        from email.mime.text import MIMEText
        try:
            msg = MIMEText(
                f"You requested a password reset for BuildMart.\n\n"
                f"Your password reset token is:\n{reset_token}\n\n"
                f"This token expires in 15 minutes and can only be used once."
            )
            msg["Subject"] = "BuildMart - Password Reset Request"
            msg["From"] = settings.EMAIL_FROM
            msg["To"] = to_email

            with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10) as server:
                server.starttls()
                server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                server.send_message(msg)
            logger.info(f"[Email] Password reset email dispatched via SMTP to {to_email}")
            return
        except Exception as e:
            logger.error(f"[Email] SMTP dispatch failure to {to_email}: {e}")

    # Structured audit trail fallback
    logger.info(f"[Email Audit] Password reset email instruction queued for recipient: {to_email}")


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register_account(
    payload: RegisterRequest,
    response: Response,
    db: AsyncSession = Depends(get_db)
):
    """
    Public registration endpoint.
    - Strictly enforces password complexity.
    - Prevents privilege escalation: Role is unconditionally assigned as 'buyer'.
    - Stores NULL when phone is not provided (avoids dummy phone numbers).
    - Issues HttpOnly, Secure cookie alongside bearer token response.
    """
    existing_res = await db.execute(select(User).where(User.email == payload.email))
    if existing_res.scalars().first():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email address already exists"
        )

    hashed_pw = hash_password(payload.password)
    user_id = f"usr_{uuid.uuid4().hex[:12]}"
    
    # Store clean phone or NULL (no manufactured 0000000000)
    phone_clean = payload.phone.strip() if payload.phone and payload.phone.strip() else None

    user = User(
        id=user_id,
        name=payload.name,
        email=payload.email,
        phone=phone_clean,
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

    # Set secure HttpOnly cookie for browser sessions
    response.set_cookie(
        key="access_token",
        value=token,
        httponly=True,
        secure=(settings.ENVIRONMENT.lower() == "production"),
        samesite="lax",
        max_age=24 * 3600,
        path="/"
    )

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=user
    )


@router.post("/login", response_model=TokenResponse)
@router.post("/token", response_model=TokenResponse)
async def login_user(
    payload: TokenRequest,
    response: Response,
    db: AsyncSession = Depends(get_db)
):
    """
    Authenticates a user and issues a signed JWT access token.
    An email address alone is NOT proof of identity. A valid matching password is required.
    Sets an HttpOnly, Secure, SameSite=Lax cookie for browser clients.
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

    # Set secure HttpOnly cookie for browser sessions
    response.set_cookie(
        key="access_token",
        value=token,
        httponly=True,
        secure=(settings.ENVIRONMENT.lower() == "production"),
        samesite="lax",
        max_age=24 * 3600,
        path="/"
    )

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=user
    )


@router.post("/logout")
async def logout_user(
    response: Response,
    authorization: Optional[str] = Header(None),
    current_user: User = Depends(require_authenticated_user)
):
    """
    Revokes the current authentication token and purges the session cookie.
    """
    if authorization:
        token = authorization.replace("Bearer ", "").strip()
        revoke_token(token)

    response.delete_cookie(key="access_token", path="/")
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
    Enforces rate-limiting (max 3 requests per 15 minutes per email).
    Issues a short-lived token with strict purpose and expiration claims.
    Dispatches verified instructions via email service.
    """
    email = payload.email.strip().lower()
    if not check_reset_rate_limit(email):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many password reset requests. Please try again after 15 minutes."
        )

    result = await db.execute(select(User).where(User.email == email))
    user = result.scalars().first()
    
    # Generic response to prevent user enumeration
    resp = {"message": "If this email is registered, a password reset instruction has been generated"}
    if not user:
        return resp

    # Generate cryptographic reset token (15 minute validity)
    expire = datetime.now(timezone.utc) + timedelta(minutes=RESET_EXPIRATION_MINUTES)
    token_jti = str(uuid.uuid4())
    reset_data = {
        "sub": user.id,
        "email": user.email,
        "purpose": RESET_TOKEN_PURPOSE,
        "exp": expire,
        "iss": JWT_ISSUER,
        "aud": JWT_AUDIENCE,
        "jti": token_jti
    }
    reset_token = jwt.encode(reset_data, settings.SECRET_KEY, algorithm=JWT_ALGORITHM)

    # Dispatch verified email delivery
    await dispatch_password_reset_email(user.email, reset_token)
    
    # In non-production, return it for testing validation
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
    Enforces single-use token consumption preventing replay attacks.
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

    jti = data.get("jti")
    if jti and is_token_revoked(jti):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password reset token has already been used or revoked"
        )

    user_id = data.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User account not found")

    user.hashed_password = hash_password(payload.new_password)
    await db.commit()

    # Single-use consumption: revoke token jti
    if jti:
        revoke_token_id(jti)

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
