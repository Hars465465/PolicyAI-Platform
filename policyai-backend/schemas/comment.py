from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

# Request Schema
class CommentCreate(BaseModel):
    device_id: str = Field(..., min_length=10)
    text: str = Field(..., min_length=1, max_length=1000)

# Response Schema
class CommentResponse(BaseModel):
    id: int
    policy_id: int
    user_id: int
    user_name: str
    text: str
    created_at: datetime
    is_own: bool = False  # To check if comment is from current user
    
    class Config:
        from_attributes = True

# Comment Stats
class CommentStats(BaseModel):
    policy_id: int
    total_comments: int
