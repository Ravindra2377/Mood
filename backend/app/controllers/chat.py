from fastapi import APIRouter, HTTPException, Depends
from app.schemas.chat import MessageIn, MessageOut
from app.services import nlp_engine, crisis

router = APIRouter()

@router.post('/chat/message', response_model=MessageOut)
def post_message(payload: MessageIn):
    text = payload.text
    if crisis.contains_crisis_language(text):
        # return a safe response and flag for further handling
        return {"id": 0, "sender": "bot", "text": "I detect you may be in crisis. If you're in immediate danger, please contact emergency services.", "created_at": None}
    resp = nlp_engine.respond_to_user(text)
    return {"id": 0, "sender": "bot", "text": resp, "created_at": None}
