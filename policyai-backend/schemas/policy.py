from pydantic import BaseModel
from datetime import datetime
from typing import Optional

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
    
    class Config:
        from_attributes = True

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
