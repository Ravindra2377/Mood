from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

class MessageIn(BaseModel):
    text: str

class MessageOut(BaseModel):
    id: int
    sender: str
    text: str
    created_at: datetime

    model_config = {"from_attributes": True}

class ConversationRead(BaseModel):
    id: int
    user_id: int
    messages: List[MessageOut]

    model_config = {"from_attributes": True}
