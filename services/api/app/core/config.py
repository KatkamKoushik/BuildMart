import os
from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field, model_validator

class Settings(BaseSettings):
    PROJECT_NAME: str = "BuildMart API"
    VERSION: str = "2.0.0"
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

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    @property
    def cors_origins(self) -> List[str]:
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",") if origin.strip()]

    @model_validator(mode="after")
    def validate_production_security(self) -> "Settings":
        """
        F-07 & F-08: Fail-fast security validation preventing production launch
        with insecure developer defaults or mock payment keys.
        """
        if self.ENVIRONMENT.lower() == "production":
            # 1. Reject insecure or default secret keys
            if "dev" in self.SECRET_KEY.lower() or "buildmart-dev" in self.SECRET_KEY or len(self.SECRET_KEY) < 32:
                raise ValueError(
                    "FATAL CONFIG ERROR: Production mode requires a secure SECRET_KEY with at least 32 characters, "
                    "not containing dev/placeholder strings."
                )
            # 2. Reject debug mode in production
            if self.DEBUG:
                raise ValueError("FATAL CONFIG ERROR: DEBUG must be set to False in production.")
            # 3. Reject mock Razorpay credentials in production
            if self.RAZORPAY_KEY_SECRET.startswith("mock_") or self.RAZORPAY_WEBHOOK_SECRET.startswith("mock_"):
                raise ValueError(
                    "FATAL CONFIG ERROR: Production mode cannot start with mock Razorpay secrets."
                )
        return self

settings = Settings()

