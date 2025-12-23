from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    
    # Authentication fields
    email = Column(String(100), unique=True, index=True, nullable=True)
    google_id = Column(String(100), unique=True, nullable=True)
    phone = Column(String(10), unique=True, nullable=True)  # Optional now
    
    # Profile
    name = Column(String(100), nullable=True)
    avatar_url = Column(String(500), nullable=True)  # Google profile picture
    
    # Status
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    auth_provider = Column(String(20), default="email")  # "email" or "google"
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    last_login = Column(DateTime, nullable=True)
    
    # Relationships
    votes = relationship("Vote", back_populates="user")
