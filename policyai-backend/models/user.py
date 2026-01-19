from sqlalchemy import Column, Integer, String, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from database import Base


class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    
    # Authentication fields
    email = Column(String(255), unique=True, index=True, nullable=True)
    username = Column(String(100), unique=True, index=True, nullable=True)
    name = Column(String(255), nullable=True)  # ← ADDED for auth.py
    full_name = Column(String(255), nullable=True)
    bio = Column(String(500), nullable=True)  # ← ADDED for profile updates
    
    # Profile pictures
    profile_picture = Column(String(500), nullable=True, default="")

    avatar_url = Column(String(500), nullable=True, default="")  # ← ADDED for auth.py
    
    # Auth providers
    auth_provider = Column(String(20), default="email")
    firebase_uid = Column(String(255), unique=True, nullable=True)
    google_id = Column(String(255), unique=True, nullable=True)  # ← ADDED for Google Sign-in
    
    # Verification status
    is_verified = Column(Boolean, default=False)  # ← ADDED for auth.py
    is_email_verified = Column(Boolean, default=False)
    
    # Push notifications
    fcm_token = Column(String(500), nullable=True)
    
    # Device tracking (legacy)
    device_id = Column(String(255), nullable=True)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    last_login = Column(DateTime(timezone=True), nullable=True)  # ← ADDED for auth.py
    
    # Relationships
    policies = relationship("Policy", back_populates="author")
    votes = relationship("Vote", back_populates="user")
    comments = relationship("Comment", back_populates="user")
