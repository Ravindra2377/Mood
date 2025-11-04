from pydantic import BaseModel, Field


class ChatRequest(BaseModel):
    """Incoming payload for the AI companion."""

    message: str = Field(..., min_length=1, max_length=2000)


class ChatResponse(BaseModel):
    """Response payload returned to the client."""

    reply: str
