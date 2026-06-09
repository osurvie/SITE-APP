from fastapi import APIRouter, HTTPException
import httpx
from app.schemas.chat import ChatRequest, ChatResponse
from app.core.config import settings

router = APIRouter(tags=["chat"])

OLLAMA_URL = "http://localhost:11434/api/chat"

@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    async with httpx.AsyncClient(timeout=120.0) as client:
        try:
            res = await client.post(OLLAMA_URL, json={
                "model": request.model,
                "messages": [{"role": "user", "content": request.message}],
                "stream": False
            })
            res.raise_for_status()
            data = res.json()
            return ChatResponse(
                response=data["message"]["content"],
                model=request.model
            )
        except httpx.RequestError as e:
            raise HTTPException(status_code=503, detail=f"Ollama unreachable: {e}")
