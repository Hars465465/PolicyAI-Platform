from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database import Base


class Vote(Base):
    __tablename__ = "votes"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    policy_id = Column(Integer, ForeignKey("policies.id", ondelete="CASCADE"), nullable=False)
    stance = Column(String(20), nullable=False)  # Changed from vote_type
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # CHANGE backref to back_populates!
    user = relationship("User", back_populates="votes")
    policy = relationship("Policy", back_populates="votes")
    
    __table_args__ = (
        UniqueConstraint('user_id', 'policy_id', name='uq_user_policy_vote'),
        {'extend_existing': True}
    )
