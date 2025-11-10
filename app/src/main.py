from src.utils.app_logging import setup_logging
from fastapi import FastAPI
from src.controllers.url_controller import router 
import logging


setup_logging()

app = FastAPI(title="TinyURL Service")

app.include_router(router)