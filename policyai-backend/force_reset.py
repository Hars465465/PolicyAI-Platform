from sqlalchemy import text
from database import engine

print("🗑️  DROPPING RAILWAY POSTGRESQL TABLES...")
print("=" * 60)

with engine.connect() as conn:
    try:
        conn.execute(text("DROP TABLE IF EXISTS votes CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS users CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS policies CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS comments CASCADE"))
        conn.commit()
        print("✅ All tables dropped from Railway!")
    except Exception as e:
        print(f"⚠️  Error dropping: {e}")

print("\n🔨 CREATING FRESH TABLES ON RAILWAY...")
print("=" * 60)

from database import Base
from models.policy import Policy
from models.user import User
from models.vote import Vote

try:
    Base.metadata.create_all(bind=engine)
    print("✅ All tables created on Railway!")
    
    # Verify
    from sqlalchemy import inspect
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    
    print(f"\n📋 Tables in Railway PostgreSQL:")
    for table in tables:
        cols = inspector.get_columns(table)
        print(f"\n✅ {table} ({len(cols)} columns):")
        for col in cols:
            print(f"   - {col['name']}: {col['type']}")
    
    print("\n" + "=" * 60)
    print("🎉 RAILWAY DATABASE RESET COMPLETE!")
    print("=" * 60)
    print("\n🚀 Next: Run 'python seed_postgres.py'")
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
