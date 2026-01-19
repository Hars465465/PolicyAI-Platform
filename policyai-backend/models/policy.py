from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database import Base


class Policy(Base):
    __tablename__ = "policies"
    __table_args__ = {'extend_existing': True}
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String(100), nullable=False)
    author_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # ← ADD THIS!
    ai_summary = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    ends_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships - ADD ALL THREE!
    author = relationship("User", back_populates="policies")  # ← ADD THIS!
    votes = relationship("Vote", back_populates="policy", cascade="all, delete-orphan")  # ← ADD THIS!
    comments = relationship("Comment", back_populates="policy", cascade="all, delete-orphan")
