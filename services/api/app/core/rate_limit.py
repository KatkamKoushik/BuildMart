import os
from slowapi import Limiter
from slowapi.util import get_remote_address
from app.core.config import settings

is_testing = os.getenv("TESTING", "").lower() in ("1", "true") or settings.ENVIRONMENT.lower() == "test"

# SlowAPI Rate Limiter configured for distributed Redis or in-memory fallback
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["120/minute"],
    storage_uri=settings.REDIS_URL if (settings.REDIS_URL and settings.ENVIRONMENT.lower() == "production") else "memory://",
    enabled=not is_testing
)
