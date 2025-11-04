from fastapi import FastAPI
from src.controllers import url_controller 
from src.utils.logging import setup_logging

setup_logging()

app = FastAPI(title="TinyURL Service")

app.include_router(url_controller.router)