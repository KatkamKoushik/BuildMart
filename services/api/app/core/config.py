import os
from typing import List
from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    PROJECT_NAME: str = "BuildMart API"
    VERSION: str = "1.0.0"
    API_V1_PREFIX: str = "/api/v1"
    ENVIRONMENT: str = Field(default="development")
    DEBUG: bool = Field(default=True)
    SECRET_KEY: str = Field(default="buildmart-dev-secret-key-at-least-32-chars-long")
    
    # Database
    DATABASE_URL: str = Field(default="sqlite+aiosqlite:///./buildmart.db")
    
    # Redis
    REDIS_URL: str = Field(default="redis://localhost:6379/0")
    
    # CORS
    ALLOWED_ORIGINS: str = Field(default="http://localhost:3000,http://127.0.0.1:3000,http://localhost:8000")
    
    # Razorpay
    RAZORPAY_KEY_ID: str = Field(default="rzp_test_TM6Z7BqbHQaK7R")
    RAZORPAY_KEY_SECRET: str = Field(default="mock_razorpay_secret")
    RAZORPAY_WEBHOOK_SECRET: str = Field(default="mock_webhook_secret")
    
    # Cloudinary
    CLOUDINARY_CLOUD_NAME: str = Field(default="snwiu5gv")
    CLOUDINARY_API_KEY: str = Field(default="")
    CLOUDINARY_API_SECRET: str = Field(default="")

    @property
    def cors_origins(self) -> List[str]:
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",") if origin.strip()]

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "ignore"

settings = Settings()
