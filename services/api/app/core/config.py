from typing import List, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field, model_validator

class Settings(BaseSettings):
    PROJECT_NAME: str = "BuildMart API"
    VERSION: str = "2.0.0"
    API_V1_PREFIX: str = "/api/v1"
    ENVIRONMENT: str = Field(default="development")
    DEBUG: bool = Field(default=True)
    SECRET_KEY: str = Field(default="buildmart-dev-secret-key-at-least-32-chars-long")
    PREVIOUS_SECRET_KEY: Optional[str] = Field(default=None)
    ADMIN_BOOTSTRAP_SECRET: str = Field(default="dev-admin-bootstrap-secret-min-32-chars")
    
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

    # MongoDB / Firestore with MongoDB Compatibility
    MONGODB_URI: Optional[str] = Field(default=None)
    MONGODB_DB_NAME: str = Field(default="buildmart")

    # Email / Password Recovery Delivery
    SMTP_HOST: Optional[str] = Field(default=None)
    SMTP_PORT: int = Field(default=587)
    SMTP_USER: Optional[str] = Field(default=None)
    SMTP_PASSWORD: Optional[str] = Field(default=None)
    EMAIL_FROM: str = Field(default="noreply@buildmart.dev")

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

            # 3. Reject empty, mock, test, or placeholder Razorpay credentials in production
            if not self.RAZORPAY_KEY_ID or not self.RAZORPAY_KEY_ID.strip():
                raise ValueError("FATAL CONFIG ERROR: RAZORPAY_KEY_ID cannot be empty in production.")
            if not self.RAZORPAY_KEY_SECRET or not self.RAZORPAY_KEY_SECRET.strip():
                raise ValueError("FATAL CONFIG ERROR: RAZORPAY_KEY_SECRET cannot be empty in production.")
            if not self.RAZORPAY_WEBHOOK_SECRET or not self.RAZORPAY_WEBHOOK_SECRET.strip():
                raise ValueError("FATAL CONFIG ERROR: RAZORPAY_WEBHOOK_SECRET cannot be empty in production.")

            if (
                not self.RAZORPAY_KEY_ID.startswith("rzp_live_")
                or len(self.RAZORPAY_KEY_ID.strip()) < 14
                or "test" in self.RAZORPAY_KEY_ID.lower()
                or "mock" in self.RAZORPAY_KEY_ID.lower()
            ):
                raise ValueError(
                    "FATAL CONFIG ERROR: Production mode requires a valid live RAZORPAY_KEY_ID starting with 'rzp_live_'."
                )

            if (
                len(self.RAZORPAY_KEY_SECRET.strip()) < 16
                or self.RAZORPAY_KEY_SECRET.startswith("mock_")
                or self.RAZORPAY_KEY_SECRET.startswith("your_")
                or "mock" in self.RAZORPAY_KEY_SECRET.lower()
                or "test" in self.RAZORPAY_KEY_SECRET.lower()
            ):
                raise ValueError(
                    "FATAL CONFIG ERROR: Production mode requires a valid live RAZORPAY_KEY_SECRET of at least 16 characters."
                )

            if (
                len(self.RAZORPAY_WEBHOOK_SECRET.strip()) < 16
                or self.RAZORPAY_WEBHOOK_SECRET.startswith("mock_")
                or self.RAZORPAY_WEBHOOK_SECRET.startswith("your_")
                or "mock" in self.RAZORPAY_WEBHOOK_SECRET.lower()
                or "test" in self.RAZORPAY_WEBHOOK_SECRET.lower()
            ):
                raise ValueError(
                    "FATAL CONFIG ERROR: Production mode requires a valid live RAZORPAY_WEBHOOK_SECRET of at least 16 characters."
                )

            # 4. Reject default bootstrap secret
            if "dev" in self.ADMIN_BOOTSTRAP_SECRET.lower() or len(self.ADMIN_BOOTSTRAP_SECRET) < 32:
                raise ValueError(
                    "FATAL CONFIG ERROR: Production mode requires a secure ADMIN_BOOTSTRAP_SECRET with at least 32 characters."
                )
        return self

settings = Settings()
