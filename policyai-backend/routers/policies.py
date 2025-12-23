from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta
from models.policy import Policy, Vote
from schemas.policy import PolicyResponse, VoteCreate, VoteResponse
from database import get_db

router = APIRouter()

@router.get("/", response_model=List[PolicyResponse])
def get_policies(db: Session = Depends(get_db)):
    """Get all active policies"""
    
    policies = db.query(Policy).filter(Policy.is_active == True).all()
    
    # Calculate stats for each policy
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
            days_left = (policy.ends_at - datetime.utcnow()).days
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
    
    # Calculate stats
    votes = db.query(Vote).filter(Vote.policy_id == policy.id).all()
    total_votes = len(votes)
    support_votes = len([v for v in votes if v.stance == "support"])
    oppose_votes = len([v for v in votes if v.stance == "oppose"])
    
    support_percentage = int((support_votes / total_votes * 100)) if total_votes > 0 else 0
    oppose_percentage = int((oppose_votes / total_votes * 100)) if total_votes > 0 else 0
    
    if policy.ends_at:
        days_left = (policy.ends_at - datetime.utcnow()).days
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

@router.post("/vote", response_model=VoteResponse)
def vote_on_policy(vote: VoteCreate, db: Session = Depends(get_db)):
    """Vote on a policy (Mock user for Phase 1)"""
    
    # Phase 1: Use mock user ID = 1
    # Phase 2: Get from JWT token
    user_id = 1
    
    # Check if policy exists
    policy = db.query(Policy).filter(Policy.id == vote.policy_id).first()
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    # Check if user already voted
    existing_vote = db.query(Vote).filter(
        Vote.user_id == user_id,
        Vote.policy_id == vote.policy_id
    ).first()
    
    if existing_vote:
        # Update existing vote
        existing_vote.stance = vote.stance
        db.commit()
        db.refresh(existing_vote)
        return existing_vote
    else:
        # Create new vote
        new_vote = Vote(
            user_id=user_id,
            policy_id=vote.policy_id,
            stance=vote.stance
        )
        db.add(new_vote)
        db.commit()
        db.refresh(new_vote)
        return new_vote
