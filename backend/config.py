from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    REDIS_HOST: str
    REDIS_PORT: int
    REDIS_USERNAME: str
    REDIS_PASSWORD: str
    MONGO_URI: str

    
    class Config:
        env_file = ".env"
        
settings = Settings()