import os
from pydantic_settings import BaseSettings

try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception as e:
    print(f"Warning: Could not load .env file: {e}")

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://postgres:mhfskelSXEFRyINpHjCVOMtxUbRmwekO@switchyard.proxy.rlwy.net:10418/railway")
    
    # JWT
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-change-in-production-min-32-chars")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200
    
    # Google OAuth
    GOOGLE_CLIENT_ID: str = os.getenv("GOOGLE_CLIENT_ID", "")
    GOOGLE_CLIENT_SECRET: str = os.getenv("GOOGLE_CLIENT_SECRET", "")
    
    # Email
    EMAIL_FROM: str = "noreply@policyai.com"
    RESEND_API_KEY: str = os.getenv("RESEND_API_KEY", "")
    
    # App
    PROJECT_NAME: str = "PolicyAI"
    VERSION: str = "1.0.0"
    
    class Config:
        env_file = ".env"

settings = Settings()
