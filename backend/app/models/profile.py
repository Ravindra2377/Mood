from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from datetime import datetime
from app.models import Base

class Profile(Base):
    __tablename__ = 'profiles'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=False)
    display_name = Column(String, nullable=True)
    language = Column(String, default='en')
    timezone = Column(String, nullable=True)
    consent_privacy = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
