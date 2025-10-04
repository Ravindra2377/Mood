from fastapi import APIRouter, HTTPException, Depends, Request
from typing import List
from app.schemas.chat import MessageIn, MessageOut, ConversationRead
from app.services import nlp_engine, crisis
from app.dependencies import get_current_user

router = APIRouter()


@router.post('/chat/message', response_model=MessageOut)
def post_message(payload: MessageIn, request: Request, user = Depends(get_current_user)):
    """Post a user message. Creates (or reuses) a conversation, persists the user message,
    generates a bot response using the NLP engine with context and modality, and persists the bot reply.
    """
    text = payload.text
    # safety: crisis detection
    if crisis.contains_crisis_language(text):
        from app.main import SessionLocal
        from app.models.conversation import Conversation, Message
        db = SessionLocal()
        try:
            conv = Conversation(user_id=user.id)
            db.add(conv)
            db.commit()
            db.refresh(conv)
            umsg = Message(conversation_id=conv.id, sender='user', text=text)
            db.add(umsg)
            db.commit()
            bot_text = "I detect you may be in crisis. If you're in immediate danger, please contact emergency services."
            bmsg = Message(conversation_id=conv.id, sender='bot', text=bot_text)
            db.add(bmsg)
            db.commit()
            db.refresh(bmsg)
            return bmsg
        finally:
            db.close()

    # normal flow: gather context messages if conversation specified
    from app.main import SessionLocal
    from app.models.conversation import Conversation, Message
    db = SessionLocal()
    try:
        conv = None
        if payload.conversation_id:
            conv = db.query(Conversation).filter(Conversation.id == int(payload.conversation_id), Conversation.user_id == user.id).first()
        if not conv:
            conv = Conversation(user_id=user.id)
            db.add(conv)
            db.commit()
            db.refresh(conv)

        # persist user message
        umsg = Message(conversation_id=conv.id, sender='user', text=text)
        db.add(umsg)
        db.commit()

        # fetch recent context
        max_msgs = payload.max_context_messages or 10
        msgs = db.query(Message).filter(Message.conversation_id == conv.id).order_by(Message.id.desc()).limit(max_msgs).all()
        # reverse to chronological
        msgs = list(reversed(msgs))
        context = [{'sender': m.sender, 'text': m.text} for m in msgs]

        modality = (payload.modality or 'general').lower()
        bot_resp = nlp_engine.respond_to_user(text, context={'messages': context, 'modality': modality})

        bmsg = Message(conversation_id=conv.id, sender='bot', text=bot_resp)
        db.add(bmsg)
        db.commit()
        db.refresh(bmsg)
        return bmsg
    finally:
        db.close()


@router.get('/chat/conversations', response_model=List[ConversationRead])
def list_conversations(user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.conversation import Conversation, Message
    db = SessionLocal()
    try:
        convs = db.query(Conversation).filter(Conversation.user_id == user.id).order_by(Conversation.id.desc()).all()
        # attach messages
        for c in convs:
            c.messages = db.query(Message).filter(Message.conversation_id == c.id).order_by(Message.id.asc()).all()
        return convs
    finally:
        db.close()


@router.get('/chat/conversations/{conversation_id}', response_model=ConversationRead)
def get_conversation(conversation_id: int, user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.conversation import Conversation, Message
    db = SessionLocal()
    try:
        conv = db.query(Conversation).filter(Conversation.id == conversation_id, Conversation.user_id == user.id).first()
        if not conv:
            raise HTTPException(status_code=404, detail='Conversation not found')
        conv.messages = db.query(Message).filter(Message.conversation_id == conv.id).order_by(Message.id.asc()).all()
        return conv
    finally:
        db.close()
