import os

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str
    api_key: str = "dev-key-123"
    env: str = "dev"

    class Config:
        env_prefix = ""
        env_file = ".env"


settings = Settings(
    database_url=os.getenv("DATABASE_URL", ""),
    api_key=os.getenv("API_KEY", "dev-key-123"),
    env=os.getenv("ENV", "dev"),
)
