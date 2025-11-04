from fastapi import APIRouter, Depends
from fastapi.concurrency import run_in_threadpool

from app.ai_chat_service import generate_response
from app.dependencies import get_current_user
from app.schemas.chat_companion import ChatRequest, ChatResponse

router = APIRouter()


@router.post("/chat", response_model=ChatResponse)
async def send_chat_message(
    payload: ChatRequest,
    current_user = Depends(get_current_user),
) -> ChatResponse:
    """Handle chat messages destined for the Soul AI companion."""

    reply = await run_in_threadpool(generate_response, payload.message)
    return ChatResponse(reply=reply)
