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
from services.otp_service import generate_otp, store_otp, verify_otp, send_otp_email


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
    bio: Optional[str] = None
    avatar_url: Optional[str]
    auth_provider: str
    created_at: datetime
    
    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    name: Optional[str] = None
    bio: Optional[str] = None
    avatar_url: Optional[str] = None


# ============ EMAIL OTP ============


@router.post("/email/send-otp")
async def send_email_otp(request: EmailOTPRequest, db: Session = Depends(get_db)):
    """Send OTP to email"""
    
    try:
        # Generate 6-digit OTP
        otp = generate_otp()
        
        # Store OTP with 5-minute expiry
        store_otp(request.email, otp)
        
        # Send email via Resend
        email_sent = await send_otp_email(request.email, otp)
        
        if email_sent:
            return {
                "success": True,
                "message": f"OTP sent to {request.email}",
                "email": request.email,
                "expires_in": "5 minutes",
                # Remove in production for security!
                "mock_otp": otp  # Only for testing
            }
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to send OTP email"
            )
    
    except Exception as e:
        print(f"❌ Error in send_email_otp: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error sending OTP: {str(e)}"
        )


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
        # Generate unique device_id for email auth
        import uuid
        device_id = f"email_{uuid.uuid4().hex[:16]}"
        
        # Create new user
        user = User(
            email=request.email,
            username=request.email.split('@')[0],  # Use email username as name
            device_id=device_id,  # ✅ ADD THIS LINE!
            is_email_verified=True,
            auth_provider="email",
            last_login=datetime.utcnow()
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        print(f"✅ New user created: {user.email} with device_id: {device_id}")
    else:
        # Update existing user
        user.last_login = datetime.utcnow()
        user.is_verified = True
        db.commit()
        print(f"✅ User logged in: {user.email}")
    
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
            "bio": user.bio if hasattr(user, 'bio') else None,
            "avatar_url": user.avatar_url,
            "auth_provider": user.auth_provider
        }
    }

# ============ GOOGLE SIGN IN ============


@router.post("/google/signin", response_model=Token)
async def google_sign_in(request: GoogleSignIn, db: Session = Depends(get_db)):
    """
    Sign in with Google
    Phase 1: Mock implementation
    Phase 2: Real Google token verification
    """
    
    # TODO Phase 2.5: Verify Google token
    # from google.oauth2 import id_token
    # from google.auth.transport import requests
    # try:
    #     idinfo = id_token.verify_oauth2_token(
    #         request.google_token, 
    #         requests.Request(), 
    #         settings.GOOGLE_CLIENT_ID
    #     )
    #     google_id = idinfo['sub']
    #     email = idinfo['email']
    #     name = idinfo.get('name')
    #     avatar_url = idinfo.get('picture')
    # except ValueError:
    #     raise HTTPException(status_code=400, detail="Invalid Google token")
    
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
            name=request.name or request.email.split('@')[0],
            avatar_url=request.avatar_url,
            google_id=request.google_token[:20],  # Mock for now
            is_verified=True,
            auth_provider="google",
            last_login=datetime.utcnow()
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        print(f"✅ New Google user created: {user.email}")
    else:
        # Update existing user
        user.last_login = datetime.utcnow()
        user.name = request.name or user.name
        user.avatar_url = request.avatar_url or user.avatar_url
        user.auth_provider = "google"
        db.commit()
        print(f"✅ Google user logged in: {user.email}")
    
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
            "bio": user.bio if hasattr(user, 'bio') else None,
            "avatar_url": user.avatar_url,
            "auth_provider": user.auth_provider
        }
    }


# ============ GET CURRENT USER ============


@router.get("/me", response_model=UserResponse)
async def get_current_user(
    db: Session = Depends(get_db),
    # TODO: Add JWT token dependency for authentication
    # current_user: User = Depends(get_current_user_from_token)
):
    """Get current user info"""
    
    # Mock: Return first user (replace with real auth later)
    user = db.query(User).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No users found"
        )
    
    return user


# ============ GET USER PROFILE ============


@router.get("/me/profile")
async def get_user_profile(db: Session = Depends(get_db)):
    """Get current user's complete profile"""
    
    # TODO: Get user from JWT token
    user = db.query(User).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return {
        "success": True,
        "user": {
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "bio": user.bio if hasattr(user, 'bio') else None,
            "avatar_url": user.avatar_url,
            "auth_provider": user.auth_provider,
            "is_verified": user.is_verified,
            "created_at": user.created_at.isoformat() if user.created_at else None,
            "last_login": user.last_login.isoformat() if user.last_login else None,
            "updated_at": user.updated_at.isoformat() if hasattr(user, 'updated_at') and user.updated_at else None
        }
    }


# ============ UPDATE USER PROFILE ============


@router.put("/me/update")
async def update_user_profile(
    user_update: UserUpdate,
    db: Session = Depends(get_db)
):
    """Update current user's profile (name, bio, avatar)"""
    
    # TODO: Get user from JWT token
    # For now, get first user (mock)
    user = db.query(User).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Update fields if provided
    if user_update.name is not None and user_update.name.strip():
        user.name = user_update.name.strip()
    
    if user_update.bio is not None:
        user.bio = user_update.bio.strip() if user_update.bio else None
    
    if user_update.avatar_url is not None:
        user.avatar_url = user_update.avatar_url
    
    # Update timestamp
    if hasattr(user, 'updated_at'):
        user.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(user)
    
    print(f"✅ Profile updated for user: {user.email}")
    
    return {
        "success": True,
        "message": "Profile updated successfully! ✅",
        "user": {
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "bio": user.bio if hasattr(user, 'bio') else None,
            "avatar_url": user.avatar_url,
            "auth_provider": user.auth_provider,
            "updated_at": user.updated_at.isoformat() if hasattr(user, 'updated_at') and user.updated_at else None
        }
    }


# ============ LOGOUT ============


@router.post("/logout")
async def logout():
    """
    Logout user
    Since we're using JWT, logout is handled client-side by deleting token
    """
    return {
        "success": True,
        "message": "Logged out successfully. Please delete token on client side."
    }


# ============ HELPER FUNCTIONS ============


def create_access_token(data: dict, expires_delta: timedelta = None):
    """Create JWT access token"""
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        # Default: 7 days expiry
        expire = datetime.utcnow() + timedelta(days=7)
    
    to_encode.update({"exp": expire})
    
    encoded_jwt = jwt.encode(
        to_encode, 
        settings.SECRET_KEY, 
        algorithm="HS256"
    )
    
    return encoded_jwt


def verify_access_token(token: str):
    """Verify JWT token and return user data"""
    try:
        payload = jwt.decode(
            token, 
            settings.SECRET_KEY, 
            algorithms=["HS256"]
        )
        user_id: str = payload.get("sub")
        email: str = payload.get("email")
        
        if user_id is None or email is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )
        
        return {"user_id": user_id, "email": email}
    
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )
