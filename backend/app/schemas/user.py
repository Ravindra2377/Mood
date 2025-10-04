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
	created_at: datetime

	model_config = {"from_attributes": True}

class Token(BaseModel):
	access_token: str
	token_type: str = 'bearer'
