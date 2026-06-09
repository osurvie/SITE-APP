from fastapi import APIRouter, HTTPException
import httpx
from app.schemas.ask import AskRequest, AskResponse

router = APIRouter(tags=["ask"])

OLLAMA_URL = "http://localhost:11434/api/chat"
SYSTEM_PROMPT = (
    "Tu es un assistant bienveillant qui aide des personnes vulnérables "
    "(seniors, personnes illettrées, non francophones). "
    "Réponds en 2-3 phrases maximum, en langage très simple et rassurant, sans jargon. "
    "Ne donne jamais de conseils médicaux précis — oriente toujours vers un médecin "
    "ou professionnel de santé pour les questions médicales. "
    "Réponds uniquement dans la langue indiquée."
)


@router.post("/api/ask", response_model=AskResponse)
async def ask(request: AskRequest) -> AskResponse:
    async with httpx.AsyncClient(timeout=120.0) as client:
        try:
            res = await client.post(OLLAMA_URL, json={
                "model": "llava:13b",
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": f"language: {request.language}\n\n{request.question}"},
                ],
                "stream": False,
            })
            res.raise_for_status()
            data = res.json()
            return AskResponse(
                answer=data["message"]["content"],
                language=request.language,
            )
        except httpx.RequestError as e:
            raise HTTPException(status_code=503, detail=f"Ollama unreachable: {e}")
