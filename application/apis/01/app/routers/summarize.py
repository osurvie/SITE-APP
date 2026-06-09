from fastapi import APIRouter, HTTPException
import httpx
from app.schemas.summarize import SummarizeRequest, SummarizeResponse

router = APIRouter(tags=["summarize"])

OLLAMA_URL = "http://localhost:11434/api/chat"
SYSTEM_PROMPT = (
    "Tu es un assistant qui aide des personnes qui ne savent pas bien lire. "
    "Résume le document suivant en 3 phrases maximum, en langage très simple et courant, "
    "sans jargon. Réponds uniquement dans la langue indiquée par le paramètre language "
    "(fr=français, en=anglais, ar=arabe)."
)


@router.post("/api/summarize", response_model=SummarizeResponse)
async def summarize(request: SummarizeRequest) -> SummarizeResponse:
    async with httpx.AsyncClient(timeout=120.0) as client:
        try:
            res = await client.post(OLLAMA_URL, json={
                "model": "llava:13b",
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": f"language: {request.language}\n\n{request.text}"},
                ],
                "stream": False,
            })
            res.raise_for_status()
            data = res.json()
            return SummarizeResponse(
                summary=data["message"]["content"],
                language=request.language,
            )
        except httpx.RequestError as e:
            raise HTTPException(status_code=503, detail=f"Ollama unreachable: {e}")
