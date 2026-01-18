from database import engine
from sqlalchemy import text

# Add fcm_token column to users table
with engine.connect() as conn:
    try:
        conn.execute(text("ALTER TABLE users ADD COLUMN fcm_token VARCHAR(255)"))
        conn.commit()
        print("✅ fcm_token column added successfully!")
    except Exception as e:
        if "already exists" in str(e).lower():
            print("✅ fcm_token column already exists")
        else:
            print(f"❌ Error: {e}")
