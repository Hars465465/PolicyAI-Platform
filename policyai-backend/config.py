import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql://user:password@localhost/policyai_db"
    
    # JWT
    SECRET_KEY: str = "your-secret-key-change-in-production-min-32-chars-long"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200  # 30 days
    
    # Google OAuth
    GOOGLE_CLIENT_ID: str = ""  # Will add later
    GOOGLE_CLIENT_SECRET: str = ""  # Will add later
    
    # Email OTP (using Gmail SMTP or Resend)
    EMAIL_FROM: str = "noreply@policyai.com"
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""  # Your Gmail
    SMTP_PASSWORD: str = ""  # App password
    
    # Or use Resend (Recommended - FREE)
    RESEND_API_KEY: str = ""  # Will get from resend.com
    
    # App
    PROJECT_NAME: str = "PolicyAI"
    VERSION: str = "1.0.0"
    
    class Config:
        env_file = ".env"

settings = Settings()
