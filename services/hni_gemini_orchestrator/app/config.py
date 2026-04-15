from dataclasses import dataclass
import os


@dataclass(frozen=True)
class Settings:
    gemini_api_key: str
    gemini_model: str
    port: int


def load_settings() -> Settings:
    return Settings(
        gemini_api_key=os.getenv("GEMINI_API_KEY", "").strip(),
        gemini_model=os.getenv("HNI_GEMINI_MODEL", "gemini-2.5-flash-lite").strip(),
        port=int(os.getenv("HNI_GEMINI_PORT", "8091")),
    )
