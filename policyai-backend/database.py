from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import settings

# PostgreSQL engine with connection pooling
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,          # Check connections before using
    pool_recycle=3600,            # Recycle connections every hour
    pool_size=5,                  # Number of connections to maintain
    max_overflow=10,              # Max extra connections
    echo=False                    # Set True for SQL debugging
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
