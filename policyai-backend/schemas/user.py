from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class UserBase(BaseModel):
    phone: str = Field(..., min_length=10, max_length=10)

class UserCreate(UserBase):
    name: Optional[str] = None
    email: Optional[str] = None

class UserResponse(BaseModel):
    id: int
    phone: str
    name: Optional[str] = None
    email: Optional[str] = None
    is_verified: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class OTPRequest(BaseModel):
    phone: str = Field(..., min_length=10, max_length=10)

class OTPVerify(BaseModel):
    phone: str = Field(..., min_length=10, max_length=10)
    otp: str = Field(..., min_length=6, max_length=6)
