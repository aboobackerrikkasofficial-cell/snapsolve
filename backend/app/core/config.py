from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    # App Settings
    PROJECT_NAME: String = "SnapSolve Enterprise API Gateway"
    VERSION: String = "1.0.0"
    API_V1_STR: String = "/api/v1"
    
    # Security Settings (Must be set via environment variables)
    SECRET_KEY: String = os.getenv("SECRET_KEY", "DEVELOPMENT_SECRET_KEY_CHANGE_IN_PRODUCTION")
    ALGORITHM: String = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # AI Provider Keys (STRICTLY HIDDEN FROM FRONTEND)
    GEMINI_API_KEY: String = os.getenv("GEMINI_API_KEY", "")
    GROQ_API_KEY: String = os.getenv("GROQ_API_KEY", "")
    OPENROUTER_API_KEY: String = os.getenv("OPENROUTER_API_KEY", "")
    
    # Infrastructure
    ALLOWED_HOSTS: List[String] = ["*"] # Configure strictly in production
    DATABASE_URL: String = "sqlite+aiosqlite:///./snapsolve_prod.db"
    
    # Rate Limiting
    MAX_AI_REQUESTS_PER_USER_DAY: int = 100
    RATE_LIMIT_STORAGE_URL: String = "memory://" # Use Redis in production

    class Config:
        case_sensitive = True

settings = Settings()
