from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from database import Base, engine, get_db
from models.policy import Policy
from models.user import User
from models.vote import Vote
from models.comment import Comment

# Create app
app = FastAPI(
    title="PolicyAI API",
    description="National Policy Opinion Platform Backend",
    version="1.0.0",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create/Update tables on startup
from sqlalchemy import text

@app.on_event("startup")
async def startup():
    print("🔨 Adding missing columns to users table...")
    
    # Add missing columns
    with engine.connect() as connection:
        try:
            connection.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS name VARCHAR(255);"))
            connection.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS bio VARCHAR(500);"))
            connection.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(500);"))
            connection.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(255);"))
            connection.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE;"))
            connection.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;"))
            connection.commit()
            print("✅ All columns added!")
        except Exception as e:
            print(f"⚠️  Column add error (might already exist): {e}")
    
    # Create tables for other models
    Base.metadata.create_all(bind=engine)
    print("✅ Database ready!")

# Root endpoint
@app.get("/")
def root():
    return {
        "message": "PolicyAI Backend is Running! 🚀",
        "version": "1.0.0",
        "status": "healthy",
        "docs": "/docs",
    }

@app.get("/health")
def health_check():
    return {"status": "ok", "database": "Railway PostgreSQL"}

# Import routers
from routers import auth, comment, policies, users, votes  # noqa: E402

# Register routes
app.include_router(policies.router, prefix="/api/policies", tags=["Policies"])
app.include_router(votes.router, prefix="/api/policies", tags=["Votes"])
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(comment.router, prefix="/api/comments", tags=["Comments"])
app.include_router(users.router, prefix="/api", tags=["Users"]) 

# 🔁 Withdraw/delete vote endpoint
@app.delete("/api/policies/{policy_id}/vote")
async def delete_vote(
    policy_id: int,
    device_id: str = Query(...),
    db: Session = Depends(get_db),
):
    """Withdraw/delete a vote for this device on a policy."""
    
    # Find policy
    policy = db.query(Policy).filter(Policy.id == policy_id).first()
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    # Find user by device_id
    user = db.query(User).filter(User.device_id == device_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Find existing vote
    existing_vote = (
        db.query(Vote)
        .filter(Vote.user_id == user.id, Vote.policy_id == policy_id)
        .first()
    )
    if not existing_vote:
        raise HTTPException(status_code=404, detail="No vote found to delete")
    
    # Delete vote
    db.delete(existing_vote)
    db.commit()
    
    return {"message": "Vote withdrawn successfully", "policy_id": policy_id}

print("🚀 Routes registered!")
print("📋 API Docs: http://localhost:8000/docs")
