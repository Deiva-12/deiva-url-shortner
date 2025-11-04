import logging.config
from pythonjsonlogger import jsonlogger
from src.utils.settings import settings

def setup_logging() -> None:
    """Configures structured logging for the application."""
    LOGGING_CONFIG = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "json": {
                "()": "pythonjsonlogger.jsonlogger.JsonFormatter",
                "format": "%(asctime)s %(levelname)s %(name)s %(message)s",
            },
        },
        "handlers": {
            "console": {
                "class": "logging.StreamHandler",
                "formatter": "standard",
                "level": settings.LOG_LEVEL.upper(),
            },
        },
        "root": {
            "handlers": ["console"],
            "level": settings.LOG_LEVEL.upper(),
        },
    }
    logging.config.dictConfig(LOGGING_CONFIG)
