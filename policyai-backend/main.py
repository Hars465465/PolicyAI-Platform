# Force rebuild 2026-01-27 13:29


from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from database import Base, engine, get_db, SessionLocal
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
# Check if this code exists in main.py:

@app.on_event("startup")
async def startup_event():
    """Run on application startup"""
    # Create tables
    Base.metadata.create_all(bind=engine)
    
    # ✅ ADD THIS: Auto-seed if database is empty
    try:
        db = SessionLocal()
        policy_count = db.query(Policy).count()
        if policy_count == 0:
            print("📦 Database is empty, running seed script...")
            from seed_postgres import seed_database
            seed_database()
        else:
            print(f"✅ Database already has {policy_count} policies")
        db.close()
    except Exception as e:
        print(f"⚠️ Seed check failed: {e}")


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

print("🚀 Routes registered!")
print("📋 API Docs: http://localhost:8000/docs")
