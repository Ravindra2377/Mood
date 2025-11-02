from fastapi import APIRouter, HTTPException, Depends, Request, status
from fastapi.responses import StreamingResponse
from typing import List, Optional
from datetime import datetime
import asyncio
import json
import logging
import time

from app.schemas.chat import (
    MessageIn,
    MessageOut,
    ConversationRead,
    ChatRequest,
    ChatResponse,
    ChatSessionRead,
    ChatMessageRead,
    CrisisResponseSchema,
    StreamToken,
    SessionHistoryRead,
)
from app.services import nlp_engine, crisis
from app.services.crisis_detection import crisis_detector
from app.services.ai_service import get_ai_service
from app.dependencies import get_current_user
from app.main import SessionLocal
from app.models.conversation import Conversation, Message
from app.models.chat_session import ChatSession, ChatMessage, ModerationLog, UserContextCache
from app.models.profile import Profile
from app.models.mood_entry import MoodEntry
from app.models.exercise import Exercise, ExerciseSession
from app.models.personalization import UserPathway
from app.limits import limiter

logger = logging.getLogger(__name__)
router = APIRouter()


# ============================================================================
# Legacy conversation endpoints (kept for backward compatibility)
# ============================================================================


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


# ============================================================================
# New AI Chat System endpoints
# ============================================================================


async def _get_user_context(db, user_id: int) -> dict:
    """Fetch user's recent context from database for AI personalization."""
    context = {
        'user_id': user_id,
        'latest_mood': None,
        'mood_intensity': None,
        'recent_triggers': [],
        'completed_activities': [],
        'active_pathways': [],
        'assessment_scores': {},
    }

    try:
        # Get latest mood entry
        latest_mood = db.query(MoodEntry).filter(
            MoodEntry.user_id == user_id
        ).order_by(MoodEntry.created_at.desc()).first()

        if latest_mood:
            context['latest_mood'] = latest_mood.mood
            context['mood_intensity'] = latest_mood.intensity
            if latest_mood.triggers:
                context['recent_triggers'] = latest_mood.triggers if isinstance(latest_mood.triggers, list) else []

        # Get recent completed exercises (last 7 days)
        from datetime import timedelta
        week_ago = datetime.utcnow() - timedelta(days=7)
        recent_exercises = db.query(ExerciseSession).filter(
            ExerciseSession.user_id == user_id,
            ExerciseSession.completed_at >= week_ago
        ).all()
        context['completed_activities'] = [e.exercise_id for e in recent_exercises]

        # Get active pathways
        active_pathways = db.query(UserPathway).filter(
            UserPathway.user_id == user_id,
            UserPathway.is_active == True
        ).all()
        context['active_pathways'] = [p.pathway_name for p in active_pathways]

    except Exception as e:
        logger.warning(f"Error fetching user context: {str(e)}")

    return context


@router.post("/chat/interactive")
@limiter.limit("10/minute")
async def chat_interactive(
    request: Request,
    chat_request: ChatRequest,
    current_user = Depends(get_current_user),
):
    """
    Main AI chat endpoint with streaming response.
    Accepts user message, performs crisis detection, and streams back AI response.
    """
    db = SessionLocal()

    try:
        start_time = time.time()

        # Crisis detection FIRST (before AI processing)
        severity, keywords, is_crisis = crisis_detector.detect(chat_request.message)

        if is_crisis:
            logger.critical(
                f"Crisis detected for user {current_user.id}: {keywords} (severity: {severity})"
            )

            # Store crisis event in moderation log
            try:
                mod_log = ModerationLog(
                    user_id=current_user.id,
                    flagged_content=chat_request.message,
                    moderation_reason=f"Crisis keywords: {', '.join(keywords)}",
                    severity_level=severity,
                    human_reviewed=False,
                )
                db.add(mod_log)
                db.commit()
            except Exception as e:
                logger.error(f"Error logging crisis event: {str(e)}")

            # Return crisis resources immediately
            crisis_response = crisis_detector.get_crisis_response()
            return crisis_response

        # Get or create session
        if chat_request.session_id:
            session = db.query(ChatSession).filter(
                ChatSession.id == chat_request.session_id,
                ChatSession.user_id == current_user.id,
            ).first()
            if not session:
                raise HTTPException(status_code=404, detail="Session not found")
        else:
            # Create new session
            session = ChatSession(user_id=current_user.id)
            db.add(session)
            db.commit()
            db.refresh(session)

        # Get user context if requested
        context = None
        if chat_request.include_context:
            context = await _get_user_context(db, current_user.id)

        # Get conversation history
        history = db.query(ChatMessage).filter(
            ChatMessage.session_id == session.id
        ).order_by(ChatMessage.created_at).all()

        history_dicts = [
            {'role': m.role, 'content': m.content}
            for m in history
        ]

        # Save user message
        from uuid import uuid4
        user_msg = ChatMessage(
            id=str(uuid4()),
            session_id=session.id,
            role='user',
            content=chat_request.message,
        )
        db.add(user_msg)
        db.commit()

        # Prepare streaming response
        assistant_msg_id = str(uuid4())

        async def generate_stream():
            """Generator for SSE streaming."""
            full_response = ""
            start_stream = time.time()

            try:
                # Get AI service
                ai_service = get_ai_service()

                # Stream tokens from AI
                async for token in ai_service.chat(
                    chat_request.message,
                    history_dicts,
                    context,
                ):
                    full_response += token
                    yield f"data: {json.dumps({'token': token, 'done': False})}\n\n"
                    await asyncio.sleep(0.01)  # Small delay for smooth streaming

                # Calculate response time
                response_time = int((time.time() - start_stream) * 1000)

                # Save assistant message
                assistant_msg = ChatMessage(
                    id=assistant_msg_id,
                    session_id=session.id,
                    role='assistant',
                    content=full_response,
                    streaming_completed=True,
                    response_time_ms=response_time,
                )
                db.add(assistant_msg)

                # Update session
                session.total_messages = (session.total_messages or 0) + 2  # user + assistant
                session.updated_at = datetime.utcnow()
                db.commit()

                # Send final event with session metadata so the client can persist the session id
                yield f"data: {json.dumps({'token': '', 'done': True, 'message_id': assistant_msg_id, 'session_id': session.id})}\n\n"

            except Exception as e:
                logger.error(f"Stream generation error: {str(e)}")
                yield f"data: {json.dumps({'error': 'Stream interrupted', 'done': True})}\n\n"
            finally:
                db.close()

        return StreamingResponse(
            generate_stream(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "X-Accel-Buffering": "no",
                "Connection": "keep-alive",
            },
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Chat endpoint error: {str(e)}")
        db.close()
        raise HTTPException(status_code=500, detail="Internal server error")


@router.get("/chat/sessions", response_model=List[SessionHistoryRead])
@limiter.limit("20/minute")
async def get_sessions(
    request: Request,
    current_user = Depends(get_current_user),
    limit: int = 10,
):
    """Get user's recent chat sessions."""
    db = SessionLocal()

    try:
        sessions = db.query(ChatSession).filter(
            ChatSession.user_id == current_user.id
        ).order_by(ChatSession.started_at.desc()).limit(limit).all()

        return sessions
    finally:
        db.close()


@router.get("/chat/sessions/{session_id}/messages", response_model=List[ChatMessageRead])
@limiter.limit("20/minute")
async def get_session_messages(
    request: Request,
    session_id: str,
    current_user = Depends(get_current_user),
):
    """Get all messages in a session."""
    db = SessionLocal()

    try:
        session = db.query(ChatSession).filter(
            ChatSession.id == session_id,
            ChatSession.user_id == current_user.id,
        ).first()

        if not session:
            raise HTTPException(status_code=404, detail="Session not found")

        messages = db.query(ChatMessage).filter(
            ChatMessage.session_id == session_id
        ).order_by(ChatMessage.created_at).all()

        return messages
    finally:
        db.close()


@router.delete("/chat/sessions/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
@limiter.limit("20/minute")
async def delete_session(
    request: Request,
    session_id: str,
    current_user = Depends(get_current_user),
):
    """Delete a chat session and all its messages."""
    db = SessionLocal()

    try:
        session = db.query(ChatSession).filter(
            ChatSession.id == session_id,
            ChatSession.user_id == current_user.id,
        ).first()

        if not session:
            raise HTTPException(status_code=404, detail="Session not found")

        db.delete(session)  # Cascade will delete messages
        db.commit()

    finally:
        db.close()
