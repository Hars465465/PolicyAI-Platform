from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base
import enum

class PolicyCategory(str, enum.Enum):
    EDUCATION = "Education"
    HEALTHCARE = "Healthcare"
    INFRASTRUCTURE = "Infrastructure"
    TECHNOLOGY = "Technology"
    AGRICULTURE = "Agriculture"
    HOUSING = "Housing"

class VoteStance(str, enum.Enum):
    SUPPORT = "support"
    OPPOSE = "oppose"
    NEUTRAL = "neutral"

class Policy(Base):
    __tablename__ = "policies"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String(50), nullable=False)
    
    # AI Summary (JSON stored as text for now)
    ai_summary = Column(Text, nullable=True)
    
    # Metadata
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    ends_at = Column(DateTime, nullable=True)
    
    # Relationships
    votes = relationship("Vote", back_populates="policy")

class Vote(Base):
    __tablename__ = "votes"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    policy_id = Column(Integer, ForeignKey("policies.id"), nullable=False)
    stance = Column(String(20), nullable=False)  # support, oppose, neutral
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="votes")
    policy = relationship("Policy", back_populates="votes")
