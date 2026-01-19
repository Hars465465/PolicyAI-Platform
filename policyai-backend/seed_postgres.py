from sqlalchemy.orm import Session
from database import engine, SessionLocal
from models.user import User
from models.policy import Policy
from datetime import datetime, timedelta

def seed_database():
    """Seed database with sample policies"""
    
    db = SessionLocal()
    
    try:
        # ✅ STEP 1: Create a default user (author) first!
        existing_user = db.query(User).filter(User.device_id == "seed_user_001").first()
        
        if not existing_user:
            default_user = User(
                device_id="seed_user_001",
                username="admin",
                name="Admin User",
                full_name="System Administrator",
                email="admin@policyai.com",
                profile_picture="",
                auth_provider="device",
                is_verified=True,
                is_email_verified=True
            )
            db.add(default_user)
            db.commit()
            db.refresh(default_user)
            print(f"✅ Created default user: {default_user.id}")
            author_id = default_user.id
        else:
            author_id = existing_user.id
            print(f"✅ Using existing user: {author_id}")
        
        # ✅ STEP 2: Check if policies already exist
        existing_policies = db.query(Policy).count()
        if existing_policies > 0:
            print(f"⚠️ Database already has {existing_policies} policies. Skipping seed.")
            return
        
        # ✅ STEP 3: Create sample policies
        sample_policies = [
            {
                "title": "National Digital Education Initiative 2026",
                "description": "A comprehensive program to provide free tablets and internet access to all students in government schools, along with digital literacy training for teachers.",
                "category": "Education",
                "author_id": author_id,
                "ai_summary": "Aims to bridge the digital divide in education by providing technology access to underprivileged students.",
                "is_active": True,
                "ends_at": datetime.utcnow() + timedelta(days=30)
            },
            {
                "title": "Universal Healthcare Coverage Expansion",
                "description": "Expansion of free healthcare services to include dental care, mental health services, and preventive care for all citizens.",
                "category": "Healthcare",
                "author_id": author_id,
                "ai_summary": "Comprehensive healthcare reform to ensure every citizen has access to quality medical care.",
                "is_active": True,
                "ends_at": datetime.utcnow() + timedelta(days=45)
            },
            {
                "title": "Green Energy Infrastructure Program",
                "description": "Investment of ₹5 lakh crore in renewable energy infrastructure including solar parks, wind farms, and EV charging stations across the country.",
                "category": "Infrastructure",
                "author_id": author_id,
                "ai_summary": "Large-scale investment in clean energy to achieve carbon neutrality by 2050.",
                "is_active": True,
                "ends_at": datetime.utcnow() + timedelta(days=60)
            },
            {
                "title": "AI and Robotics Research Fund",
                "description": "Establishment of a ₹10,000 crore fund to support AI and robotics research in universities and startups.",
                "category": "Technology",
                "author_id": author_id,
                "ai_summary": "Boost India's position in AI and automation through targeted research funding.",
                "is_active": True,
                "ends_at": datetime.utcnow() + timedelta(days=90)
            },
            {
                "title": "Farmer Income Support Scheme",
                "description": "Direct income support of ₹12,000 per year to farmers with landholding less than 5 acres, along with crop insurance coverage.",
                "category": "Agriculture",
                "author_id": author_id,
                "ai_summary": "Financial assistance to small and marginal farmers to improve their livelihood.",
                "is_active": True,
                "ends_at": datetime.utcnow() + timedelta(days=120)
            },
            {
                "title": "Affordable Housing for All by 2030",
                "description": "Construction of 2 crore affordable homes in urban and rural areas with subsidized interest rates.",
                "category": "Housing",
                "author_id": author_id,
                "ai_summary": "Massive housing program to ensure every family has access to affordable shelter.",
                "is_active": True,
                "ends_at": datetime.utcnow() + timedelta(days=150)
            },
            {
                "title": "Women Safety and Empowerment Act",
                "description": "Comprehensive legislation for women's safety including mandatory self-defense training, fast-track courts, and skill development programs.",
                "category": "Social Welfare",
                "author_id": author_id,
                "ai_summary": "Multi-faceted approach to women's safety and economic empowerment.",
                "is_active": True
            },
            {
                "title": "Public Transport Electrification",
                "description": "Replace all diesel buses with electric buses in 100 cities by 2028, along with metro expansion.",
                "category": "Infrastructure",
                "author_id": author_id,
                "ai_summary": "Clean and efficient public transport to reduce pollution and improve urban mobility.",
                "is_active": True
            },
            {
                "title": "Startup India 2.0",
                "description": "Simplified regulations, tax holidays for 5 years, and ₹50,000 crore venture capital fund for startups.",
                "category": "Technology",
                "author_id": author_id,
                "ai_summary": "Create a thriving startup ecosystem to boost innovation and job creation.",
                "is_active": True
            },
            {
                "title": "Water Conservation and Management",
                "description": "Nationwide program for rainwater harvesting, river rejuvenation, and wastewater treatment in all cities.",
                "category": "Environment",
                "author_id": author_id,
                "ai_summary": "Address water scarcity through conservation and efficient management.",
                "is_active": True
            }
        ]
        
        # ✅ STEP 4: Add all policies
        for policy_data in sample_policies:
            policy = Policy(**policy_data)
            db.add(policy)
        
        db.commit()
        print(f"✅ Successfully seeded {len(sample_policies)} policies!")
        
    except Exception as e:
        print(f"❌ Error seeding database: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("🌱 Starting database seeding...")
    seed_database()
    print("✅ Database seeding complete!")
