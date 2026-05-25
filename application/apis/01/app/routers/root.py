from fastapi import APIRouter
from app.schemas.common import RootResponse
from app.core.config import settings

router = APIRouter(tags=["root"])


@router.get("/", response_model=RootResponse)
def root() -> RootResponse:
    return RootResponse(message="Welcome to the API", version=settings.APP_VERSION)
