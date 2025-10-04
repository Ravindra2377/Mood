from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
	email: EmailStr
	password: str

class UserRead(BaseModel):
	id: int
	email: EmailStr
	is_active: bool
	is_verified: bool
	role: str
	created_at: datetime

	model_config = {"from_attributes": True}

class Token(BaseModel):
	access_token: str
	token_type: str = 'bearer'
	refresh_token: str | None = None


class PasswordResetRequest(BaseModel):
	email: EmailStr


class PasswordResetConfirm(BaseModel):
	token: str
	new_password: str


class UserUpdate(BaseModel):
	is_active: Optional[bool] = None
	role: Optional[str] = None
	is_verified: Optional[bool] = None
