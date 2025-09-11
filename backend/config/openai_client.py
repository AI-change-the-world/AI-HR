from openai import OpenAI

from config.settings import settings

openai_client = OpenAI(
    api_key=settings.OPENAI_API_KEY, base_url=settings.OPENAI_BASE_URL
)
