from fastapi import FastAPI, logger
from app.routers import health, root, chat, summarize, ask
from app.core.config import settings

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    docs_url="/docs" if settings.DEV else None,
    redoc_url="/redoc" if settings.DEV else None,
)

app.include_router(root.router)
app.include_router(health.router)
app.include_router(chat.router)
app.include_router(summarize.router)
app.include_router(ask.router)

