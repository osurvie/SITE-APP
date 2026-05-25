from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True)
    APP_NAME: str = "osurvie-app-api"
    APP_VERSION: str = "0.1.0"
    DEV: bool = False


settings = Settings()
