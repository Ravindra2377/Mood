from fastapi import HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from app.services import security

oauth2_scheme = OAuth2PasswordBearer(tokenUrl='/api/auth/token')

def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = security.decode_access_token(token)
    if not payload or 'sub' not in payload:
        raise HTTPException(status_code=401, detail='Invalid token')
    return int(payload['sub'])
