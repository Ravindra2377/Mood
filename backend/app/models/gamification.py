from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from datetime import datetime
from app.models import Base

class Achievement(Base):
    __tablename__ = 'achievements'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    key = Column(String, nullable=False)
    points = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
