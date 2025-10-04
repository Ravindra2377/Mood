from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class GroupRead(BaseModel):
    id: int
    key: str
    title: str
    description: Optional[str]
    guidelines: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}

class GroupCreate(BaseModel):
    key: str
    title: str
    description: Optional[str] = None
    guidelines: Optional[str] = None

    model_config = {"from_attributes": True}

class PostCreate(BaseModel):
    group_key: str
    title: Optional[str] = None
    body: str
    anon: Optional[bool] = False

class PostRead(BaseModel):
    id: int
    group_id: int
    user_id: Optional[int]
    anon: int
    title: Optional[str]
    body: str
    removed: int
    flagged: int
    created_at: datetime

    model_config = {"from_attributes": True}

class CommentCreate(BaseModel):
    post_id: int
    body: str
    anon: Optional[bool] = False

class CommentRead(BaseModel):
    id: int
    post_id: int
    user_id: Optional[int]
    anon: int
    body: str
    removed: int
    flagged: int
    created_at: datetime

    model_config = {"from_attributes": True}


class MemberRead(BaseModel):
    id: int
    user_id: int
    group_id: int
    role: str
    joined_at: datetime

    model_config = {"from_attributes": True}


class MemberInfo(BaseModel):
    user_id: int
    email: Optional[str]
    display_name: Optional[str]
    role: str
    joined_at: datetime

    model_config = {"from_attributes": True}
