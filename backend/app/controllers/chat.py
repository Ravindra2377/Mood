from fastapi import APIRouter, HTTPException, Depends
from app.schemas.chat import MessageIn, MessageOut
from app.services import nlp_engine, crisis
from app.dependencies import get_current_user

router = APIRouter()

@router.post('/chat/message', response_model=MessageOut)
def post_message(payload: MessageIn, user_id: int = Depends(get_current_user)):
    text = payload.text
    if crisis.contains_crisis_language(text):
        # create conversation + message record and return crisis response
        from app.main import SessionLocal
        from app.models.conversation import Conversation, Message
        db = SessionLocal()
        try:
            conv = Conversation(user_id=user_id)
            db.add(conv)
            db.commit()
            db.refresh(conv)
            msg = Message(conversation_id=conv.id, sender='user', text=text)
            db.add(msg)
            db.commit()
            bot_text = "I detect you may be in crisis. If you're in immediate danger, please contact emergency services."
            bot_msg = Message(conversation_id=conv.id, sender='bot', text=bot_text)
            db.add(bot_msg)
            db.commit()
            db.refresh(bot_msg)
            return bot_msg
        finally:
            db.close()
    # normal flow
    resp = nlp_engine.respond_to_user(text)
    from app.main import SessionLocal
    from app.models.conversation import Conversation, Message
    db = SessionLocal()
    try:
        conv = Conversation(user_id=user_id)
        db.add(conv)
        db.commit()
        db.refresh(conv)
        umsg = Message(conversation_id=conv.id, sender='user', text=text)
        db.add(umsg)
        db.commit()
        bmsg = Message(conversation_id=conv.id, sender='bot', text=resp)
        db.add(bmsg)
        db.commit()
        db.refresh(bmsg)
        return bmsg
    finally:
        db.close()
