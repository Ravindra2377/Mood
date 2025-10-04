from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from datetime import datetime, timezone
from sqlalchemy.orm import relationship
from app.models import Base


class CommunityGroup(Base):
    __tablename__ = 'community_groups'
    id = Column(Integer, primary_key=True, index=True)
    key = Column(String, nullable=False, unique=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    guidelines = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class GroupMembership(Base):
    __tablename__ = 'group_memberships'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    group_id = Column(Integer, ForeignKey('community_groups.id'), nullable=False, index=True)
    role = Column(String, default='member')  # member | moderator
    joined_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship('User', lazy='joined')
    group = relationship('CommunityGroup', lazy='joined')


class Post(Base):
    __tablename__ = 'community_posts'
    id = Column(Integer, primary_key=True, index=True)
    group_id = Column(Integer, ForeignKey('community_groups.id'), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True, index=True)
    anon = Column(Integer, default=0)
    title = Column(String, nullable=True)
    body = Column(Text, nullable=False)
    removed = Column(Integer, default=0)
    flagged = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship('User', lazy='joined')
    group = relationship('CommunityGroup', lazy='joined')


class Comment(Base):
    __tablename__ = 'community_comments'
    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey('community_posts.id'), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True, index=True)
    anon = Column(Integer, default=0)
    body = Column(Text, nullable=False)
    removed = Column(Integer, default=0)
    flagged = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    post = relationship('Post', lazy='joined')
    user = relationship('User', lazy='joined')
