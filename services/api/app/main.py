from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exception_handlers import http_exception_handler

from app.core.config import settings
from app.db.session import engine, Base
from app.api.v1 import (
    health,
    categories,
    brands,
    banners,
    shops,
    products,
    cart,
    checkout,
    orders,
    quotes,
    auth,
    admin
)
from app.seed import seed_database

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: ensure tables exist and run seeder if initial setup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    try:
        await seed_database()
    except Exception as e:
        print(f"[Lifespan] Seeding notice: {e}")
    yield
    # Shutdown
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
origins = settings.cors_origins if settings.ENVIRONMENT.lower() == "production" else ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
