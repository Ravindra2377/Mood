from fastapi import APIRouter, HTTPException, Depends
from app.schemas.profile import ProfileRead, ProfileUpdate
from app.models.profile import Profile
from app.models.user import User

router = APIRouter()

def get_current_user():
    # placeholder: in real code reuse the authentication dependency
    raise HTTPException(status_code=401, detail='Not implemented')

@router.get('/profile', response_model=ProfileRead)
def read_profile():
    raise HTTPException(status_code=501, detail='Profiles not implemented yet')

@router.patch('/profile', response_model=ProfileRead)
def update_profile():
    raise HTTPException(status_code=501, detail='Profiles not implemented yet')