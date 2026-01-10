from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from database import get_db
from models.comment import Comment
from models.user import User
from models.policy import Policy
from schemas.comment import CommentCreate, CommentResponse, CommentStats

router = APIRouter()

# ========== ADD COMMENT ==========
@router.post("/policies/{policy_id}/comments", response_model=CommentResponse)
def add_comment(
    policy_id: int,
    comment_data: CommentCreate,
    db: Session = Depends(get_db)
):
    """Add a comment to a policy"""
    
    # Check if policy exists
    policy = db.query(Policy).filter(Policy.id == policy_id).first()
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    # Get or create user
    user = db.query(User).filter(User.device_id == comment_data.device_id).first()
    if not user:
        user = User(device_id=comment_data.device_id, name=f"User_{comment_data.device_id[:8]}")
        db.add(user)
        db.commit()
        db.refresh(user)
    
    # Create comment
    new_comment = Comment(
        policy_id=policy_id,
        user_id=user.id,
        text=comment_data.text
    )
    
    db.add(new_comment)
    db.commit()
    db.refresh(new_comment)
    
    return CommentResponse(
        id=new_comment.id,
        policy_id=new_comment.policy_id,
        user_id=new_comment.user_id,
        user_name=user.name or f"User_{user.device_id[:8]}",
        text=new_comment.text,
        created_at=new_comment.created_at,
        is_own=True
    )


# ========== GET COMMENTS ==========
@router.get("/policies/{policy_id}/comments")
def get_comments(
    policy_id: int,
    device_id: str = Query(...),
    sort: str = Query("newest", regex="^(newest|oldest)$"),
    db: Session = Depends(get_db)
):
    """Get all comments for a policy"""
    
    # Check if policy exists
    policy = db.query(Policy).filter(Policy.id == policy_id).first()
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    # Get current user
    current_user = db.query(User).filter(User.device_id == device_id).first()
    
    # Query comments with user data
    query = db.query(Comment, User).join(
        User, Comment.user_id == User.id
    ).filter(
        Comment.policy_id == policy_id
    )
    
    # Sort
    if sort == "newest":
        query = query.order_by(desc(Comment.created_at))
    else:
        query = query.order_by(Comment.created_at)
    
    comments = query.all()
    
    # Format response
    result = []
    for comment, user in comments:
        result.append({
            "id": comment.id,
            "policy_id": comment.policy_id,
            "user_id": comment.user_id,
            "user_name": user.name or f"User_{user.device_id[:8]}",
            "text": comment.text,
            "created_at": comment.created_at.isoformat(),
            "is_own": current_user and comment.user_id == current_user.id
        })
    
    return {
        "comments": result,
        "total": len(result)
    }


# ========== DELETE COMMENT ==========
@router.delete("/comments/{comment_id}")
def delete_comment(
    comment_id: int,
    device_id: str = Query(...),
    db: Session = Depends(get_db)
):
    """Delete a comment (only own comments)"""
    
    # Get user
    user = db.query(User).filter(User.device_id == device_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Get comment
    comment = db.query(Comment).filter(Comment.id == comment_id).first()
    if not comment:
        raise HTTPException(status_code=404, detail="Comment not found")
    
    # Check ownership
    if comment.user_id != user.id:
        raise HTTPException(status_code=403, detail="You can only delete your own comments")
    
    db.delete(comment)
    db.commit()
    
    return {"success": True, "message": "Comment deleted"}


# ========== GET COMMENT COUNT ==========
@router.get("/policies/{policy_id}/comments/count", response_model=CommentStats)
def get_comment_count(policy_id: int, db: Session = Depends(get_db)):
    """Get comment count for a policy"""
    
    count = db.query(func.count(Comment.id)).filter(
        Comment.policy_id == policy_id
    ).scalar()
    
    return CommentStats(
        policy_id=policy_id,
        total_comments=count or 0
    )
