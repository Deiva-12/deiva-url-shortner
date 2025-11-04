from fastapi import APIRouter, status ,FastAPI
from src.models.url_models import CreateUrlRequest, CreateUrlResponse
from src.services.url_service import Urlservice
from src.database.dynamodb_client import DynamoDBClient
from src.utils.settings import settings
import logging

logger = logging.getLogger(__name__)
router = APIRouter()
@router.get("/",status_code=status.HTTP_200_OK)
@router.get("/healthz", status_code=status.HTTP_200_OK)
def health_check():
    logger.info("Health check endpoint called")
    return {"status": "ok"} 



