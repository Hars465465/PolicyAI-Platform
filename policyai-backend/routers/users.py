from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import get_db
from models.user import User
from models.vote import Vote
from models.policy import Policy
from pydantic import BaseModel

router = APIRouter()

# ========== SCHEMAS ==========

class UserProfileResponse(BaseModel):
    user: dict
    statistics: dict

class VotingHistoryItem(BaseModel):
    policy_id: int
    policy_title: str
    category: str
    stance: str
    voted_at: str

class UpdateProfileRequest(BaseModel):
    name: str

# ========== ENDPOINTS ==========

@router.get("/users/me", response_model=UserProfileResponse)
def get_user_profile(device_id: str = Query(...), db: Session = Depends(get_db)):
    """Get user profile with voting statistics"""
    
    # Get user by device_id
    user = db.query(User).filter(User.device_id == device_id).first()
    
    if not user:
        # Create user if not exists
        user = User(device_id=device_id, name=f"User_{device_id[:8]}")
        db.add(user)
        db.commit()
        db.refresh(user)
    
    # Get vote counts
    votes = db.query(Vote).filter(Vote.user_id == user.id).all()
    
    support_count = sum(1 for v in votes if v.stance == 'support')
    oppose_count = sum(1 for v in votes if v.stance == 'oppose')
    neutral_count = sum(1 for v in votes if v.stance == 'neutral')
    
    return {
        "user": {
            "id": user.id,
            "name": user.name or f"User_{device_id[:8]}",
            "device_id": user.device_id,
            "created_at": user.created_at.isoformat(),
        },
        "statistics": {
            "total_votes": len(votes),
            "support_count": support_count,
            "oppose_count": oppose_count,
            "neutral_count": neutral_count,
            "points": len(votes) * 10,  # 10 points per vote
        }
    }


@router.get("/users/me/voting-history")
def get_voting_history(device_id: str = Query(...), db: Session = Depends(get_db)):
    """Get complete voting history with policy details"""
    
    user = db.query(User).filter(User.device_id == device_id).first()
    
    if not user:
        return {"votes": [], "total": 0}
    
    # Join votes with policies
    votes = db.query(Vote, Policy).join(
        Policy, Vote.policy_id == Policy.id
    ).filter(
        Vote.user_id == user.id
    ).order_by(Vote.created_at.desc()).all()
    
    history = []
    for vote, policy in votes:
        history.append({
            "policy_id": policy.id,
            "policy_title": policy.title,
            "category": policy.category,
            "stance": vote.stance,
            "voted_at": vote.created_at.isoformat(),
            "is_active": policy.is_active,
        })
    
    return {"votes": history, "total": len(history)}


@router.put("/users/me/update")
def update_user_profile(
    device_id: str = Query(...),
    profile: UpdateProfileRequest = None,
    db: Session = Depends(get_db)
):
    """Update user profile (name only for now)"""
    
    user = db.query(User).filter(User.device_id == device_id).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if profile and profile.name:
        user.name = profile.name
        db.commit()
        db.refresh(user)
    
    return {
        "success": True,
        "user": {
            "id": user.id,
            "name": user.name,
            "device_id": user.device_id,
        }
    }
