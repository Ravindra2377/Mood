from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordRequestForm
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


@router.post('/token', response_model=Token)
def token(form_data: OAuth2PasswordRequestForm = Depends()):
    # OAuth2-compatible token endpoint
    from app.main import SessionLocal
    db: Session = SessionLocal()
    try:
        user = db.query(User).filter(User.email == form_data.username).first()
        if not user or not security.verify_password(form_data.password, user.hashed_password):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid credentials')
        token = security.create_access_token({"sub": str(user.id)})
        return {"access_token": token, "token_type": "bearer"}
    finally:
        db.close()


@router.post('/password-reset')
def password_reset(email: str):
    # stub: send a password reset email / token
    return {"status": "ok", "message": "Password reset flow not implemented in prototype"}
