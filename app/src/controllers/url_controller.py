from fastapi import APIRouter, status ,FastAPI,Depends,HTTPException,Request
from src.models import url_models
from src.services.url_service import Urlservice
from src.database.dynamodb_client import DynamoDBClient
from src.utils.settings import settings
import logging



router = APIRouter()
logger = logging.getLogger(__name__)

def get_dynamodb_client() -> DynamoDBClient:
      return DynamoDBClient(settings.DYNAMODB_TABLE_NAME)
      

def get_url_instance(dynamodb_client: DynamoDBClient = Depends(get_dynamodb_client)) -> Urlservice:
        return Urlservice(dynamodb_client)

@router.get("/",status_code=status.HTTP_200_OK)
@router.get("/healthz", status_code=status.HTTP_200_OK)
def health_check():
    logger.info("Health check endpoint called")
    return {"status": "ok"} 

# @router.post("/create", response_model=CreateUrlResponse ,status_code=status.HTTP_200_OK)
# async def create_tiny_url(payload: CreateUrlRequest,
#     service : Urlservice = Depends(Urlservice)):
#     # logging.info("Health check endpoint called")
#     # return {"status": "ok"} 
#     try:
#         short_code = await service.create_short_url(payload.original_url, payload.phone_number)
#         short_url = f"{settings.DOMAIN_URL}/{short_code}"
#         return {"short_url": short_url}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

@router.post("/create", response_model=url_models.CreateUrlResponse)
def create_tiny_url(request: Request,payload: url_models.CreateUrlRequest, urlservice: Urlservice = Depends(get_url_instance)):
    
    logger.info(f"Received request to shorten URL: {payload.original_url}")

    short_code = urlservice.create_short_url(payload.original_url, payload.phone_number)
    if not short_code:
        #   return "falied to create short_url" #need to raise http exception with status code 500
        raise HTTPException(status_code=500, detail="Failed to create short URL") 

    base_url = str(request.base_url)
    short_url = f"{base_url}{short_code}"

    logger.info(f"Created new mapping: {short_url} for phone: {payload.phone_number}")   
     
    
    return url_models.CreateUrlResponse(short_url=short_url)






