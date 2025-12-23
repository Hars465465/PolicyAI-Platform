from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import jwt
from jwt import PyJWTError as JWTError
from pydantic import BaseModel, EmailStr
from typing import Optional
from models.user import User
from database import get_db
from config import settings
from services.email_service import generate_otp, store_otp, verify_otp, send_otp_email

router = APIRouter()

# ============ SCHEMAS ============

class EmailOTPRequest(BaseModel):
    email: EmailStr

class EmailOTPVerify(BaseModel):
    email: EmailStr
    otp: str

class GoogleSignIn(BaseModel):
    google_token: str  # ID token from Google
    name: Optional[str] = None
    email: Optional[str] = None
    avatar_url: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str
    user: dict

class UserResponse(BaseModel):
    id: int
    email: Optional[str]
    name: Optional[str]
    avatar_url: Optional[str]
    auth_provider: str
    created_at: datetime
    
    class Config:
        from_attributes = True

# ============ EMAIL OTP ============

@router.post("/email/send-otp")
async def send_email_otp(request: EmailOTPRequest, db: Session = Depends(get_db)):
    """Send OTP to email"""
    
    # Generate OTP
    otp = generate_otp()
    
    # Store OTP
    store_otp(request.email, otp)
    
    # Send email
    await send_otp_email(request.email, otp)
    
    return {
        "message": f"OTP sent to {request.email}",
        "mock_otp": otp,  # Remove in production!
        "expires_in": "5 minutes"
    }

@router.post("/email/verify-otp", response_model=Token)
async def verify_email_otp(request: EmailOTPVerify, db: Session = Depends(get_db)):
    """Verify email OTP and return JWT token"""
    
    # Verify OTP
    if not verify_otp(request.email, request.otp):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP"
        )
    
    # Find or create user
    user = db.query(User).filter(User.email == request.email).first()
    
    if not user:
        user = User(
            email=request.email,
            is_verified=True,
            auth_provider="email",
            last_login=datetime.utcnow()
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        user.last_login = datetime.utcnow()
        db.commit()
    
    # Create JWT token
    access_token = create_access_token(
        data={"sub": str(user.id), "email": user.email}
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "avatar_url": user.avatar_url,
            "auth_provider": user.auth_provider
        }
    }

# ============ GOOGLE SIGN IN ============

@router.post("/google/signin", response_model=Token)
async def google_sign_in(request: GoogleSignIn, db: Session = Depends(get_db)):
    """
    Sign in with Google
    Flutter will send Google ID token, we'll verify and create/login user
    """
    
    # TODO Phase 2: Verify Google token
    # from google.oauth2 import id_token
    # from google.auth.transport import requests
    # idinfo = id_token.verify_oauth2_token(
    #     request.google_token, 
    #     requests.Request(), 
    #     settings.GOOGLE_CLIENT_ID
    # )
    # google_id = idinfo['sub']
    # email = idinfo['email']
    # name = idinfo.get('name')
    # avatar_url = idinfo.get('picture')
    
    # Phase 1: Mock Google login (accept any token)
    if not request.email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email required"
        )
    
    # Find or create user
    user = db.query(User).filter(User.email == request.email).first()
    
    if not user:
        user = User(
            email=request.email,
            name=request.name,
            avatar_url=request.avatar_url,
            google_id=request.google_token[:20],  # Mock
            is_verified=True,
            auth_provider="google",
            last_login=datetime.utcnow()
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        user.last_login = datetime.utcnow()
        user.name = request.name or user.name
        user.avatar_url = request.avatar_url or user.avatar_url
        db.commit()
    
    # Create JWT token
    access_token = create_access_token(
        data={"sub": str(user.id), "email": user.email}
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "avatar_url": user.avatar_url,
            "auth_provider": user.auth_provider
        }
    }

# ============ GET CURRENT USER ============

@router.get("/me", response_model=UserResponse)
def get_current_user(db: Session = Depends(get_db)):
    """Get current user (mock for now)"""
    user = db.query(User).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# ============ HELPER FUNCTIONS ============

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

