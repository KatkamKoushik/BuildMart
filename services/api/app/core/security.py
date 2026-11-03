import uuid
import hmac
import hashlib
import bcrypt
import jwt
from datetime import datetime, timedelta, timezone
from typing import Optional, List, Dict, Any, Set
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.models import User
from app.core.config import settings

import redis
from app.core.logging import logger

security_scheme = HTTPBearer(auto_error=False)

JWT_ALGORITHM = "HS256"
JWT_ISSUER = "buildmart-api"
JWT_AUDIENCE = "buildmart-client"
JWT_EXPIRATION_HOURS = 24

# Redis-backed revocation registry with fail-safe distributed enforcement
REVOKED_TOKEN_IDS: Set[str] = set()
_redis_client: Optional[redis.Redis] = None
_last_redis_check: float = 0.0

def get_redis_client() -> Optional[redis.Redis]:
    global _redis_client, _last_redis_check
    import time
    if _redis_client is not None:
        return _redis_client
    now = time.time()
    if now - _last_redis_check < 30.0:
        return None
    _last_redis_check = now
    if settings.REDIS_URL:
        try:
            client = redis.from_url(
                settings.REDIS_URL,
                decode_responses=True,
                socket_connect_timeout=0.1,
                socket_timeout=0.2
            )
            client.ping()
            _redis_client = client
            return _redis_client
        except Exception:
            return None
    return None

def is_token_revoked(token_id: str) -> bool:
    if token_id in REVOKED_TOKEN_IDS:
        return True
    if settings.REDIS_URL:
        r = get_redis_client()
        if r is not None:
            try:
                return bool(r.get(f"revoked_token:{token_id}"))
            except Exception as e:
                if settings.ENVIRONMENT.lower() == "production":
                    logger.error(f"[Security] Redis query error checking token revocation: {e}")
                    raise HTTPException(
                        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                        detail="Distributed session verification temporarily unavailable"
                    )
    return False

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
    if jti and is_token_revoked(jti):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token has been revoked",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return payload

def revoke_token_id(token_id: str) -> None:
    """
    Blacklists a specific token ID (jti) with 24-hour TTL in local and distributed registries.
    Fails closed in production if Redis is configured but unreachable.
    """
    if not token_id:
        return
    REVOKED_TOKEN_IDS.add(token_id)
    if settings.REDIS_URL and settings.ENVIRONMENT.lower() == "production":
        r = get_redis_client()
        if r is None:
            logger.error("[Security] Distributed token revocation failure: Redis unavailable in production")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Distributed revocation service is temporarily unavailable"
            )
        try:
            r.setex(f"revoked_token:{token_id}", JWT_EXPIRATION_HOURS * 3600, "revoked")
        except Exception as e:
            logger.error(f"[Security] Failed to write token revocation to Redis: {e}")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Failed to persist token revocation to distributed storage"
            )
    else:
        r = get_redis_client()
        if r is not None:
            try:
                r.setex(f"revoked_token:{token_id}", JWT_EXPIRATION_HOURS * 3600, "revoked")
            except Exception as e:
                logger.warning(f"[Security] Failed to write token revocation to Redis: {e}")

def revoke_token(token: str) -> None:
    """
    Blacklists a JWT token by its unique JWT ID (jti) or hash with 24-hour TTL.
    """
    token_id = None
    try:
        payload = decode_access_token(token)
        token_id = payload.get("jti")
    except HTTPException:
        token_id = hashlib.sha256(token.encode("utf-8")).hexdigest()

    if token_id:
        revoke_token_id(token_id)

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
    request: Request,
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_scheme),
    db: AsyncSession = Depends(get_db)
) -> Optional[User]:
    """
    Optional authentication dependency.
    Resolves Bearer header or HttpOnly access_token cookie.
    Never auto-impersonates demo users.
    """
    token = None
    if credentials and credentials.credentials:
        token = credentials.credentials
    elif request.cookies.get("access_token"):
        token = request.cookies.get("access_token")

    if token:
        try:
            return await get_current_user_from_token(token, db)
        except HTTPException:
            return None
    return None

async def require_authenticated_user(
    request: Request,
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    """
    Strict authentication dependency. Fails closed with 401 if unauthenticated.
    Supports both Authorization Bearer header and HttpOnly access_token cookie.
    """
    token = None
    if credentials and credentials.credentials:
        token = credentials.credentials
    elif request.cookies.get("access_token"):
        token = request.cookies.get("access_token")

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token required",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return await get_current_user_from_token(token, db)

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
