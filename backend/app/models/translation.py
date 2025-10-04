from sqlalchemy import Column, Integer, String, Text, DateTime
from datetime import datetime, timezone
from app.models import Base


class Translation(Base):
    __tablename__ = 'translations'
    id = Column(Integer, primary_key=True, index=True)
    locale = Column(String, nullable=False, index=True)
    key = Column(String, nullable=False, index=True)
    value = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
