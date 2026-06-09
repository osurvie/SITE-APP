from pydantic import BaseModel


class SummarizeRequest(BaseModel):
    text: str
    language: str = "fr"


class SummarizeResponse(BaseModel):
    summary: str
    language: str
