from sqlalchemy import text
from database import engine

def add_missing_columns():
    """Add missing authentication columns to users table"""
    
    sql_commands = [
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS name VARCHAR(255);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS bio VARCHAR(500);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(500);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(255);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE;",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;",
        "CREATE UNIQUE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;"
    ]
    
    with engine.connect() as connection:
        for sql in sql_commands:
            try:
                connection.execute(text(sql))
                connection.commit()
                print(f"✅ Executed: {sql[:50]}...")
            except Exception as e:
                print(f"❌ Error: {e}")
    
    print("✅ All columns added successfully!")

if __name__ == "__main__":
    add_missing_columns()
