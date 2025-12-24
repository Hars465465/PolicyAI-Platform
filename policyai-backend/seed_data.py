from database import SessionLocal
from models.user import User
from models.policy import Policy
from datetime import datetime, timedelta

def seed_data():
    """Add sample policies to database"""
    db = SessionLocal()
    
    # Create a test user
    test_user = User(
        email="test@policyai.com",
        name="Test User",
        auth_provider="email",
        is_verified=True
    )
    db.add(test_user)
    db.commit()
    print("✅ Test user created")
    
    # Sample policies
    policies = [
        {
            "title": "National Education Reform Act 2025",
            "description": "Comprehensive reform focusing on digital literacy, teacher training, and infrastructure development in rural schools.",
            "category": "Education",
            "ends_at": datetime.utcnow() + timedelta(days=15)
        },
        {
            "title": "Universal Healthcare Expansion",
            "description": "Expansion of government healthcare coverage to include mental health services and preventive care for all citizens.",
            "category": "Healthcare",
            "ends_at": datetime.utcnow() + timedelta(days=20)
        },
        {
            "title": "Smart City Infrastructure Development",
            "description": "₹50,000 crore investment in upgrading urban infrastructure with focus on sustainable transportation and waste management.",
            "category": "Infrastructure",
            "ends_at": datetime.utcnow() + timedelta(days=10)
        },
        {
            "title": "Digital India 2.0 Initiative",
            "description": "Accelerating digital transformation with focus on AI, blockchain adoption in government services, and cybersecurity.",
            "category": "Technology",
            "ends_at": datetime.utcnow() + timedelta(days=25)
        },
        {
            "title": "Farmers Income Support Scheme",
            "description": "Direct income support of ₹12,000 per year to small and marginal farmers with crop insurance coverage.",
            "category": "Agriculture",
            "ends_at": datetime.utcnow() + timedelta(days=18)
        },
        {
            "title": "Affordable Housing Mission 2025",
            "description": "Construction of 2 million affordable housing units in urban areas with focus on sustainable building practices.",
            "category": "Housing",
            "ends_at": datetime.utcnow() + timedelta(days=30)
        }
    ]
    
    for policy_data in policies:
        policy = Policy(**policy_data)
        db.add(policy)
    
    db.commit()
    print(f"✅ Added {len(policies)} sample policies")
    
    db.close()
    print("🎉 Database seeded successfully!")

if __name__ == "__main__":
    seed_data()
