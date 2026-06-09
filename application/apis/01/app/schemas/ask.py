from pydantic import BaseModel


class AskRequest(BaseModel):
    question: str
    language: str = "fr"


class AskResponse(BaseModel):
    answer: str
    language: str
