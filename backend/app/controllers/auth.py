from fastapi import APIRouter, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.user import UserCreate, UserRead, Token
from app.models.user import User
from app.services import security

router = APIRouter()

@router.post('/signup', response_model=UserRead)
def signup(user_in: UserCreate):
    from app.main import SessionLocal
    db: Session = SessionLocal()
    try:
        existing = db.query(User).filter(User.email == user_in.email).first()
        if existing:
            raise HTTPException(status_code=400, detail='Email already registered')
        user = User(email=user_in.email, hashed_password=security.hash_password(user_in.password))
        db.add(user)
        db.commit()
        db.refresh(user)
        return user
    finally:
        db.close()

@router.post('/login', response_model=Token)
def login(user_in: UserCreate):
    from app.main import SessionLocal
    db: Session = SessionLocal()
    try:
        user = db.query(User).filter(User.email == user_in.email).first()
        if not user or not security.verify_password(user_in.password, user.hashed_password):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid credentials')
        token = security.create_access_token({"sub": str(user.id)})
        return {"access_token": token, "token_type": "bearer"}
    finally:
        db.close()
