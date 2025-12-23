from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import auth, policies

app = FastAPI(
    title="PolicyAI API",
    description="National Policy Opinion Platform Backend",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(policies.router, prefix="/api/policies", tags=["Policies"])

@app.get("/")
def root():
    return {
        "message": "PolicyAI Backend is Running! 🚀",
        "version": "1.0.0",
        "status": "healthy",
        "docs": "/docs"
    }

@app.get("/health")
def health_check():
    return {"status": "ok"}
