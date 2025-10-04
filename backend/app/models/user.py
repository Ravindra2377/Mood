from sqlalchemy import Column, Integer, String, Boolean, DateTime
from datetime import datetime, timezone
from app.models import Base

class User(Base):
	__tablename__ = 'users'
	id = Column(Integer, primary_key=True, index=True)
	email = Column(String, unique=True, index=True, nullable=False)
	hashed_password = Column(String, nullable=False)
	is_active = Column(Boolean, default=True)
	is_verified = Column(Boolean, default=False)
	role = Column(String, default='user', nullable=False)
	last_login = Column(DateTime(timezone=True), nullable=True)
	password_reset_token = Column(String, nullable=True)
	password_reset_expires = Column(DateTime(timezone=True), nullable=True)
	created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
