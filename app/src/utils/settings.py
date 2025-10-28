from pydantic_settings import BaseSettings,SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env",env_file_encoding="utf-8")

    DYNAMODB_TABLE_NAME:str
    API_KEY:str
    LOG_LEVEL:str = "INFO"

settings = Settings ()