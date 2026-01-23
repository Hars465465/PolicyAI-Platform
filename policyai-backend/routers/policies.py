from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone  
from models.policy import Policy
from models.vote import Vote
from schemas.policy import PolicyResponse, PolicyCreate
from database import get_db
from services.fcm_service import send_new_policy_notification

router = APIRouter()


@router.get("/", response_model=List[PolicyResponse])
def get_policies(db: Session = Depends(get_db)):
    """Get all active policies"""
    
    policies = db.query(Policy).filter(Policy.is_active == True).all()
    
    result = []
    for policy in policies:
        votes = db.query(Vote).filter(Vote.policy_id == policy.id).all()
        total_votes = len(votes)
        support_votes = len([v for v in votes if v.stance == "support"])
        oppose_votes = len([v for v in votes if v.stance == "oppose"])
        
        support_percentage = int((support_votes / total_votes * 100)) if total_votes > 0 else 0
        oppose_percentage = int((oppose_votes / total_votes * 100)) if total_votes > 0 else 0
        
        # ✅ Fix: Use timezone-aware datetime
        if policy.ends_at:
            now = datetime.now(timezone.utc)  # ✅ Changed
            days_left = (policy.ends_at - now).days
            time_left = f"{days_left} days left" if days_left > 0 else "Ended"
        else:
            time_left = "No deadline"
        
        result.append({
            "id": policy.id,
            "title": policy.title,
            "description": policy.description,
            "category": policy.category,
            "support_percentage": support_percentage,
            "oppose_percentage": oppose_percentage,
            "total_votes": total_votes,
            "time_left": time_left,
            "created_at": policy.created_at
        })
    
    return result


@router.get("/{policy_id}", response_model=PolicyResponse)
def get_policy(policy_id: int, db: Session = Depends(get_db)):
    """Get single policy by ID"""
    
    policy = db.query(Policy).filter(Policy.id == policy_id).first()
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    votes = db.query(Vote).filter(Vote.policy_id == policy.id).all()
    total_votes = len(votes)
    support_votes = len([v for v in votes if v.stance == "support"])
    oppose_votes = len([v for v in votes if v.stance == "oppose"])
    
    support_percentage = int((support_votes / total_votes * 100)) if total_votes > 0 else 0
    oppose_percentage = int((oppose_votes / total_votes * 100)) if total_votes > 0 else 0
    
    # ✅ Fix: Use timezone-aware datetime
    if policy.ends_at:
        now = datetime.now(timezone.utc)  # ✅ Changed
        days_left = (policy.ends_at - now).days
        time_left = f"{days_left} days left" if days_left > 0 else "Ended"
    else:
        time_left = "No deadline"
    
    return {
        "id": policy.id,
        "title": policy.title,
        "description": policy.description,
        "category": policy.category,
        "support_percentage": support_percentage,
        "oppose_percentage": oppose_percentage,
        "total_votes": total_votes,
        "time_left": time_left,
        "created_at": policy.created_at
    }

from services.fcm_service import send_new_policy_notification

@router.post("/policies")
def create_policy(policy: PolicyCreate, db: Session = Depends(get_db)):
    """Create new policy and notify all users"""
    from models.user import User
    
    # Get or create admin user
    admin_user = db.query(User).first()
    if not admin_user:
        admin_user = User(
            device_id="SYSTEM_ADMIN",
            name="System Admin",
            fcm_token=None
        )
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)
    
    # Generate ai_summary if not provided
    ai_summary = getattr(policy, 'ai_summary', None)
    if not ai_summary:
        ai_summary = policy.description[:100] + "..." if len(policy.description) > 100 else policy.description
    
    # Create policy with ALL required fields
    new_policy = Policy(
        title=policy.title,
        description=policy.description,
        category=policy.category,
        author_id=admin_user.id,      # ✅ REQUIRED by model
        ai_summary=ai_summary,         # ✅ OPTIONAL but good to have
        is_active=True
    )
    
    db.add(new_policy)
    db.commit()
    db.refresh(new_policy)
    
    # Send push notification to all users
    send_new_policy_notification(new_policy.title)
    
    return {"message": "Policy created", "policy": new_policy}
