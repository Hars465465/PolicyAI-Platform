from database import Base, engine
from sqlalchemy import inspect

# Import all models
from models.policy import Policy
from models.user import User
from models.vote import Vote

print("🔧 Creating PolicyAI PostgreSQL tables...")
print("=" * 60)
print(f"📍 Database: Railway PostgreSQL")
print("=" * 60)

try:
    # Create all tables
    Base.metadata.create_all(bind=engine)
    
    # Verify tables created
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    
    print("\n✅ Tables created successfully!")
    for table in tables:
        columns = inspector.get_columns(table)
        print(f"\n📋 Table: {table}")
        for col in columns:
            print(f"   - {col['name']}: {col['type']}")
    
    print("\n🎉 Database schema ready!")
    print("\n📋 Tables created:")
    print("  ✅ users")
    print("  ✅ policies")
    print("  ✅ votes")
    print("\n🚀 Ready to seed data!")
    
except Exception as e:
    print(f"\n❌ Error creating tables: {e}")
    import traceback
    traceback.print_exc()
