from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import get_db
from models.user import User
from models.vote import Vote
from models.policy import Policy
from schemas.vote import VoteCreate, VoteResponse, VoteResults

router = APIRouter()


@router.post("/{policy_id}/vote", response_model=VoteResponse)
def cast_vote(policy_id: int, vote_data: VoteCreate, db: Session = Depends(get_db)):
    policy = db.query(Policy).filter(Policy.id == policy_id).first()
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    user = db.query(User).filter(User.device_id == vote_data.device_id).first()
    if not user:
        user = User(device_id=vote_data.device_id, name="Anonymous")
        db.add(user)
        db.commit()
        db.refresh(user)
    
    existing_vote = db.query(Vote).filter(
        Vote.user_id == user.id, Vote.policy_id == policy_id
    ).first()
    
    if existing_vote:
        existing_vote.stance = vote_data.stance
        db.commit()
        db.refresh(existing_vote)
        return existing_vote
    
    new_vote = Vote(user_id=user.id, policy_id=policy_id, stance=vote_data.stance)
    db.add(new_vote)
    db.commit()
    db.refresh(new_vote)
    return new_vote


@router.get("/{policy_id}/results", response_model=VoteResults)
def get_results(policy_id: int, db: Session = Depends(get_db)):
    policy = db.query(Policy).filter(Policy.id == policy_id).first()
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    vote_counts = db.query(Vote.stance, func.count(Vote.id).label('count')
    ).filter(Vote.policy_id == policy_id).group_by(Vote.stance).all()
    
    counts = {stance: count for stance, count in vote_counts}
    support = counts.get('support', 0)
    oppose = counts.get('oppose', 0)
    neutral = counts.get('neutral', 0)
    total = support + oppose + neutral
    
    support_pct = round((support / total) * 100) if total > 0 else 0
    oppose_pct = round((oppose / total) * 100) if total > 0 else 0
    neutral_pct = round((neutral / total) * 100) if total > 0 else 0
    
    return VoteResults(
        policy_id=policy_id, total_votes=total,
        support_count=support, oppose_count=oppose, neutral_count=neutral,
        support_percentage=support_pct, oppose_percentage=oppose_pct, 
        neutral_percentage=neutral_pct
    )

@router.delete("/{policy_id}/vote")
def delete_vote(policy_id: int, device_id: str = Query(...), db: Session = Depends(get_db)):
    """Withdraw vote"""
    
    policy = db.query(Policy).filter(Policy.id == policy_id).first()
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    user = db.query(User).filter(User.device_id == device_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    existing_vote = db.query(Vote).filter(
        Vote.user_id == user.id,
        Vote.policy_id == policy_id
    ).first()
    
    if not existing_vote:
        raise HTTPException(status_code=404, detail="No vote found")
    
    db.delete(existing_vote)
    db.commit()
    
    return {"message": "Vote withdrawn successfully"}