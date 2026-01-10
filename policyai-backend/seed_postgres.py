from database import SessionLocal
from models.policy import Policy
from datetime import datetime, timedelta

print("🌱 SEEDING RAILWAY POSTGRESQL...")
print("=" * 60)

db = SessionLocal()

try:
    # Clear old policies
    deleted = db.query(Policy).delete()
    db.commit()
    print(f"🗑️  Deleted {deleted} old policies")
    
    print("\n📝 Adding fresh policies...")
    
    # Add policies
    policies = [
        Policy(
            title="Universal Basic Income for India",
            description="Provide ₹5,000 monthly basic income to all citizens above 18 years to reduce poverty.",
            category="Education",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=30)
        ),
        Policy(
            title="Free WiFi in All Villages",
            description="Free high-speed internet connectivity in all villages across India.",
            category="Technology",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=25)
        ),
        Policy(
            title="Electric Vehicle Subsidy Expansion",
            description="Increase subsidies on electric vehicles by 50% and expand charging infrastructure.",
            category="Infrastructure",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=20)
        ),
        Policy(
            title="National Healthcare Card for All",
            description="Issue free health cards providing ₹5 lakh annual coverage to all citizens.",
            category="Healthcare",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=28)
        ),
        Policy(
            title="Skill Development Program for Youth",
            description="Free vocational training and skill development courses for unemployed youth.",
            category="Education",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=22)
        ),
        Policy(
            title="Smart City Expansion Initiative",
            description="Expand smart city initiative to 200 more cities with sustainable infrastructure.",
            category="Infrastructure",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=18)
        ),
        Policy(
            title="Agricultural Loan Waiver Program",
            description="One-time waiver of agricultural loans up to ₹2 lakh for small farmers.",
            category="Agriculture",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=15)
        ),
        Policy(
            title="Women Safety & Security Initiative",
            description="Install CCTV cameras in public spaces and increase women police force by 50%.",
            category="Healthcare",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=27)
        ),
        Policy(
            title="Clean Ganga Mission Phase 2",
            description="Accelerate river cleaning with advanced sewage treatment plants.",
            category="Infrastructure",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=24)
        ),
        Policy(
            title="Startup India Funding Boost",
            description="Allocate ₹10,000 crore fund for Indian startups with simplified regulations.",
            category="Technology",
            is_active=True,
            ends_at=datetime.utcnow() + timedelta(days=21)
        ),
    ]
    
    for policy in policies:
        db.add(policy)
    
    db.commit()
    
    count = db.query(Policy).count()
    print(f"✅ Successfully added {count} policies!")
    
    # Show samples
    samples = db.query(Policy).limit(5).all()
    print("\n📋 Sample policies:")
    for p in samples:
        print(f"   {p.id}. {p.title} ({p.category})")
    
    print("\n" + "=" * 60)
    print("🎉 SEEDING COMPLETE!")
    print("=" * 60)
    print(f"\n✅ Total policies: {count}")
    print("\n🚀 Next: Run 'uvicorn main:app --reload'")
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
    db.rollback()
finally:
    db.close()
