from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.session import get_db
from app.db.mongodb import check_mongo_health
from app.core.config import settings

router = APIRouter(prefix="/health", tags=["Health"])

@router.get("", status_code=status.HTTP_200_OK)
async def health_liveness():
    """
    Liveness probe: verifies process responsiveness.
    """
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT
    }

@router.get("/ready", status_code=status.HTTP_200_OK)
async def health_readiness(db: AsyncSession = Depends(get_db)):
    """
    Readiness probe: validates real database connectivity.
    Fails closed with 503 Service Unavailable if downstream dependencies cannot be reached.
    """
    db_healthy = False
    try:
        res = await db.execute(text("SELECT 1"))
        if res.scalar() == 1:
            db_healthy = True
    except Exception as e:
        print(f"[Health] Database readiness check failed: {e}")
        db_healthy = False

    if not db_healthy:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "status": "unhealthy",
                "database": "disconnected",
                "service": settings.PROJECT_NAME
            }
        )

    res = {
        "status": "ready",
        "database": "connected",
        "service": settings.PROJECT_NAME,
        "environment": settings.ENVIRONMENT
    }

    if settings.MONGODB_URI:
        mongo_healthy = check_mongo_health()
        res["mongodb"] = "connected" if mongo_healthy else "degraded"

    return res
