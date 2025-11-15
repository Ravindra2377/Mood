"""
Database configuration and utilities.
Re-exports database components from main for use in controllers.
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

from app.config import settings
from app.models import Base

# Create engine and session factory
DATABASE_URL = settings.DATABASE_URL
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Session:
    """Dependency for getting database session in FastAPI endpoints."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Initialize database tables
def init_db():
    """Create all database tables."""
    Base.metadata.create_all(bind=engine)


__all__ = ["engine", "SessionLocal", "get_db", "init_db", "Base"]
