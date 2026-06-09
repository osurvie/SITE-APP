from pydantic import BaseModel

class ChatRequest(BaseModel):
    message: str
    model: str = "llava:13b"

class ChatResponse(BaseModel):
    response: str
    model: str
