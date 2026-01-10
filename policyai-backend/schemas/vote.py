from pydantic import BaseModel, Field
from datetime import datetime
from typing import Literal


class VoteCreate(BaseModel):
    device_id: str = Field(..., min_length=10)
    stance: Literal['support', 'oppose', 'neutral']


class VoteResponse(BaseModel):
    id: int
    user_id: int
    policy_id: int
    stance: str
    created_at: datetime
    
    class Config:
        from_attributes = True


class VoteResults(BaseModel):
    policy_id: int
    total_votes: int
    support_count: int
    oppose_count: int
    neutral_count: int
    support_percentage: int
    oppose_percentage: int
    neutral_percentage: int
