import os
from pydantic_settings import BaseSettings


try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception as e:
    print(f"Warning: Could not load .env file: {e}")


class Settings(BaseSettings):
    # Database - Remove default, make it required
    DATABASE_URL: str
    firebase_credentials_path: str = "firebase-credentials.json"
    
    # JWT
    SECRET_KEY: str = os.getenv("SECRET_KEY", "re_PVZrzWum_Bdp2tXjy468zmmUfX14A3NYw")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 days
    
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
        extra = "forbid"


settings = Settings()
