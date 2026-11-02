import uuid
import hmac
import hashlib
import bcrypt
import jwt
from datetime import datetime, timedelta, timezone
from typing import Optional, List, Dict, Any, Set
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.models import User
from app.core.config import settings

security_scheme = HTTPBearer(auto_error=False)

JWT_ALGORITHM = "HS256"
JWT_ISSUER = "buildmart-api"
JWT_AUDIENCE = "buildmart-client"
JWT_EXPIRATION_HOURS = 24

# In-memory revocation registry (production setups back this with Redis)
REVOKED_TOKEN_IDS: Set[str] = set()

def hash_password(password: str) -> str:
    """
    Hashes plain password using bcrypt with salt rounds.
    """
    salt = bcrypt.gensalt(rounds=12)
    return bcrypt.hashpw(password.encode("utf-8"), salt).decode("utf-8")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Constant-time password verification against stored bcrypt hash.
    """
    if not plain_password or not hashed_password:
        return False
    try:
        return bcrypt.checkpw(plain_password.encode("utf-8"), hashed_password.encode("utf-8"))
    except Exception:
        return False

def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    """
    Creates a cryptographically signed JWT access token with standard claims
    (issuer, audience, issued-at, expiry, unique JWT ID).
    """
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(hours=JWT_EXPIRATION_HOURS)
        
    token_id = str(uuid.uuid4())
    to_encode.update({
        "exp": expire,
        "iat": now,
        "iss": JWT_ISSUER,
        "aud": JWT_AUDIENCE,
        "jti": token_id
    })
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=JWT_ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> Dict[str, Any]:
    """
    Decodes and validates a JWT access token.
    Enforces signature, expiration, issuer, audience, and revocation checks.
    Supports graceful secret rotation via PREVIOUS_SECRET_KEY.
    """
    # Key rotation handling: try primary SECRET_KEY, fallback to PREVIOUS_SECRET_KEY
    signing_keys = [settings.SECRET_KEY]
    if settings.PREVIOUS_SECRET_KEY:
        signing_keys.append(settings.PREVIOUS_SECRET_KEY)

    payload = None
    last_error = None

    for key in signing_keys:
        try:
            payload = jwt.decode(
                token,
                key,
                algorithms=[JWT_ALGORITHM],
                issuer=JWT_ISSUER,
                audience=JWT_AUDIENCE
            )
            break
        except jwt.ExpiredSignatureError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authentication token has expired",
                headers={"WWW-Authenticate": "Bearer"},
            )
        except jwt.InvalidIssuerError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token issuer",
                headers={"WWW-Authenticate": "Bearer"},
            )
        except jwt.InvalidAudienceError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token audience",
                headers={"WWW-Authenticate": "Bearer"},
            )
        except jwt.PyJWTError as e:
            last_error = e

    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token signature or payload",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Check revocation blacklist
    jti = payload.get("jti")
    if jti and jti in REVOKED_TOKEN_IDS:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token has been revoked",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return payload

def revoke_token(token: str) -> None:
    """
    Blacklists a JWT token by its unique JWT ID (jti).
    """
    try:
        payload = decode_access_token(token)
        jti = payload.get("jti")
        if jti:
            REVOKED_TOKEN_IDS.add(jti)
    except HTTPException:
        # If already invalid or expired, record raw token hash
        REVOKED_TOKEN_IDS.add(hashlib.sha256(token.encode("utf-8")).hexdigest())

async def get_current_user_from_token(token: str, db: AsyncSession) -> User:
    """
    Resolves an active User from a verified JWT token.
    Rejects any unverified format or nonexistent subject.
    """
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
) -> Optional[User]:
    """
    Optional authentication dependency.
    Returns authenticated user if valid token present, otherwise None for guest routes.
    Never auto-impersonates demo users.
    """
    if credentials and credentials.credentials:
        return await get_current_user_from_token(credentials.credentials, db)
    return None

async def require_authenticated_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    """
    Strict authentication dependency. Fails closed with 401 if unauthenticated.
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
    Role-based authorization guard.
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

require_admin = require_role(["admin"])
require_seller = require_role(["admin", "vendor", "seller"])
