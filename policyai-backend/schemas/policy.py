from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional


class PolicyBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str = Field(..., min_length=1)
    category: str = Field(..., max_length=100)
    ai_summary: Optional[str] = None

class PolicyCreate(PolicyBase):
    """Schema for creating a new policy"""
    pass

class PolicyUpdate(PolicyBase):
    """Schema for updating a policy"""
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    is_active: Optional[bool] = None

class PolicyBase(BaseModel):
    title: str
    description: str
    category: str

class PolicyResponse(BaseModel):
    id: int
    title: str
    description: str
    category: str
    support_percentage: int
    oppose_percentage: int
    total_votes: int
    time_left: str
    created_at: datetime
    
    model_config = {
        "from_attributes": True  # Replaces orm_mode in Pydantic v2
    }

class VoteCreate(BaseModel):
    policy_id: int
    stance: str  # "support" or "oppose"

class VoteResponse(BaseModel):
    id: int
    policy_id: int
    stance: str
    created_at: datetime
    
    class Config:
        from_attributes = True
