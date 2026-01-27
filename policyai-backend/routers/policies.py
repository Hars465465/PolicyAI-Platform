# Force update 2026-01-27
from fastapi import APIRouter, Depends, HTTPException

from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone  
from models.policy import Policy
from models.vote import Vote
from models.user import User
from schemas.policy import PolicyResponse, PolicyCreate, PolicyWithStats
from database import get_db
from services.fcm_service import send_new_policy_notification
from services.ai_service import generate_policy_summary, analyze_policy_pros_cons


router = APIRouter()


@router.get("/", response_model=List[PolicyWithStats])
def get_policies(db: Session = Depends(get_db)):
    """Get all active policies with voting stats"""
    
    policies = db.query(Policy).filter(Policy.is_active == True).all()
    
    result = []
    for policy in policies:
        votes = db.query(Vote).filter(Vote.policy_id == policy.id).all()
        total_votes = len(votes)
        support_votes = len([v for v in votes if v.stance == "support"])
        oppose_votes = len([v for v in votes if v.stance == "oppose"])
        
        support_percentage = int((support_votes / total_votes * 100)) if total_votes > 0 else 0
        oppose_percentage = int((oppose_votes / total_votes * 100)) if total_votes > 0 else 0
        
        # Calculate time left
        if policy.ends_at:
            now = datetime.now(timezone.utc)
            days_left = (policy.ends_at - now).days
            time_left = f"{days_left} days left" if days_left > 0 else "Ended"
        else:
            time_left = "No deadline"
        
        # Build response with all fields including pros/cons
        policy_dict = {
            "id": policy.id,
            "title": policy.title,
            "description": policy.description,
            "category": policy.category,
            "author_id": policy.author_id,
            "ai_summary": policy.ai_summary,
            "pros": policy.pros if policy.pros else [],
            "cons": policy.cons if policy.cons else [],
            "is_active": policy.is_active,
            "created_at": policy.created_at,
            "ends_at": policy.ends_at,
            "updated_at": policy.updated_at if hasattr(policy, 'updated_at') else None,
            "support_percentage": support_percentage,
            "oppose_percentage": oppose_percentage,
            "total_votes": total_votes,
            "time_left": time_left
        }
        result.append(policy_dict)
    
    return result


@router.get("/{policy_id}", response_model=PolicyWithStats)
def get_policy(policy_id: int, db: Session = Depends(get_db)):
    """Get single policy by ID with voting stats"""
    
    policy = db.query(Policy).filter(Policy.id == policy_id).first()
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    votes = db.query(Vote).filter(Vote.policy_id == policy.id).all()
    total_votes = len(votes)
    support_votes = len([v for v in votes if v.stance == "support"])
    oppose_votes = len([v for v in votes if v.stance == "oppose"])
    
    support_percentage = int((support_votes / total_votes * 100)) if total_votes > 0 else 0
    oppose_percentage = int((oppose_votes / total_votes * 100)) if total_votes > 0 else 0
    
    # Calculate time left
    if policy.ends_at:
        now = datetime.now(timezone.utc)
        days_left = (policy.ends_at - now).days
        time_left = f"{days_left} days left" if days_left > 0 else "Ended"
    else:
        time_left = "No deadline"
    
    return {
        "id": policy.id,
        "title": policy.title,
        "description": policy.description,
        "category": policy.category,
        "author_id": policy.author_id,
        "ai_summary": policy.ai_summary,
        "pros": policy.pros if policy.pros else [],
        "cons": policy.cons if policy.cons else [],
        "is_active": policy.is_active,
        "created_at": policy.created_at,
        "ends_at": policy.ends_at,
        "updated_at": policy.updated_at if hasattr(policy, 'updated_at') else None,
        "support_percentage": support_percentage,
        "oppose_percentage": oppose_percentage,
        "total_votes": total_votes,
        "time_left": time_left
    }


@router.post("/policies", response_model=PolicyResponse)
def create_policy(policy: PolicyCreate, db: Session = Depends(get_db)):
    """Create new policy with AI-generated summary, pros, and cons"""
    
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
    
    # Generate AI summary if not provided
    ai_summary = policy.ai_summary
    if not ai_summary:
        print(f"🤖 Generating AI summary for: {policy.title}")
        ai_summary = generate_policy_summary(
            title=policy.title,
            description=policy.description,
            category=policy.category
        )
    
    # Generate AI pros & cons analysis
    print(f"🤖 Analyzing pros & cons for: {policy.title}")
    analysis = analyze_policy_pros_cons(
        title=policy.title,
        description=policy.description,
        category=policy.category
    )
    
    # Create new policy with AI-generated content
    new_policy = Policy(
        title=policy.title,
        description=policy.description,
        category=policy.category,
        author_id=admin_user.id,
        ai_summary=ai_summary,
        pros=analysis["pros"],
        cons=analysis["cons"],
        is_active=True
    )
    
    db.add(new_policy)
    db.commit()
    db.refresh(new_policy)
    
    # Send push notification to all users
    send_new_policy_notification(new_policy.title)
    
    # Return the policy object directly
    return new_policy
