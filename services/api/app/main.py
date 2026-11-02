import uuid
from contextlib import asynccontextmanager

from app.api.v1 import (
    admin,
    auth,
    banners,
    brands,
    cart,
    categories,
    checkout,
    health,
    orders,
    products,
    quotes,
    shops,
)
from app.core.config import settings
from app.db.mongodb import close_mongo_connection
from app.db.session import Base, engine
from app.seed import seed_database
from fastapi import FastAPI, HTTPException, Request, status
from fastapi.exception_handlers import http_exception_handler
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse

MAX_REQUEST_BODY_SIZE = 10 * 1024 * 1024  # 10 MB

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: ensure tables exist and run seeder if initial setup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    if settings.ENVIRONMENT.lower() != "production":
        try:
            await seed_database()
        except Exception as e:
            print(f"[Lifespan] Seeding notice: {e}")
    else:
        print("[Lifespan] Production mode: Automatic database seeding is disabled.")
    yield
    # Shutdown
    close_mongo_connection()
    await engine.dispose()

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="BuildMart Production B2B/B2C Construction Materials Marketplace API",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/api/v1/openapi.json"
)

# CORS configuration
origins = settings.cors_origins
if not origins or (settings.ENVIRONMENT.lower() != "production" and "*" in origins):
    origins = ["http://localhost:3000", "http://127.0.0.1:3000", "http://localhost:8000"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Security Headers & Request Limit Middleware
@app.middleware("http")
async def security_and_limits_middleware(request: Request, call_next):
    # Correlation ID propagation (Section 28-B011)
    request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
    # 1. Reject payloads exceeding maximum allowable request size
    content_length = request.headers.get("content-length")
    if content_length:
        try:
            if int(content_length) > MAX_REQUEST_BODY_SIZE:
                return JSONResponse(
                    status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                    content={
                        "success": False,
                        "error": "PayloadTooLarge",
                        "message": "Request payload exceeds maximum allowable limit (10MB)."
                    }
                )
        except ValueError:
            pass

    response = await call_next(request)

    # 2. Strict Security Headers
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Content-Security-Policy"] = "default-src 'none'; frame-ancestors 'none'"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["X-Request-ID"] = request_id
    
    if settings.ENVIRONMENT.lower() == "production":
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"

    return response

# Mount API v1 Routers
api_v1_routers = [
    health.router,
    categories.router,
    brands.router,
    banners.router,
    shops.router,
    products.router,
    cart.router,
    checkout.router,
    orders.router,
    quotes.router,
    auth.router,
    admin.router,
]

for router in api_v1_routers:
    app.include_router(router, prefix=settings.API_V1_PREFIX)

@app.exception_handler(HTTPException)
async def custom_http_exception_handler(request: Request, exc: HTTPException):
    return await http_exception_handler(request, exc)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error": "InternalServerError",
            "message": str(exc) if settings.DEBUG else "An unexpected error occurred."
        }
    )

@app.get("/")
async def root():
    return {
        "message": "Welcome to BuildMart API",
        "docs": "/docs",
        "health": f"{settings.API_V1_PREFIX}/health"
    }
