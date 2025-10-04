from passlib.context import CryptContext
from datetime import datetime, timedelta
from jose import jwt, JWTError
from app.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
	return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
	return pwd_context.verify(plain, hashed)

def create_access_token(data: dict, expires_delta: int = None) -> str:
	to_encode = data.copy()
	expire_minutes = settings.ACCESS_TOKEN_EXPIRE_MINUTES if expires_delta is None else expires_delta
	expire = datetime.utcnow() + timedelta(minutes=int(expire_minutes))
	to_encode.update({"exp": expire})
	encoded = jwt.encode(to_encode, settings.SECRET_KEY, algorithm="HS256")
	return encoded

def decode_access_token(token: str) -> dict:
	try:
		payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
		return payload
	except JWTError:
		return {}
