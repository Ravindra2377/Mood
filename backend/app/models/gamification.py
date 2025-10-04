from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.models import Base


class Achievement(Base):
    __tablename__ = 'achievements'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    key = Column(String, nullable=False, index=True)
    points = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    # relationship to User (backref so User.achievements is available without editing user.py)
    user = relationship("User", backref="achievements", lazy="joined")


class Streak(Base):
    __tablename__ = 'streaks'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    current_streak = Column(Integer, default=0)
    best_streak = Column(Integer, default=0)
    last_active_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship("User", backref="streak", lazy="joined")


class Reward(Base):
    __tablename__ = 'rewards'
    id = Column(Integer, primary_key=True, index=True)
    key = Column(String, nullable=False, unique=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    cost_points = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class ClaimedReward(Base):
    __tablename__ = 'claimed_rewards'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    reward_id = Column(Integer, ForeignKey('rewards.id'), nullable=False)
    meta = Column('metadata', Text, nullable=True)
    refunded = Column(Integer, default=0)  # 0/1 to avoid Boolean migration quirks across DBs
    refunded_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship("User", backref="claimed_rewards", lazy="joined")
    reward = relationship("Reward", lazy="joined")


class PointsLedger(Base):
    __tablename__ = 'points_ledger'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    change = Column(Integer, nullable=False)
    reason = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship("User", backref="points_ledger", lazy="joined")
