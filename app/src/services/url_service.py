import time 
import pyshorteners
import logging
from typing import Optional
from src.database.dynamodb_client import DynamoDBClient


logger = logging.getLogger(__name__)

class Urlservice:

    def __init__(self,db_client: DynamoDBClient):
        self.db_client = db_client
    
    def create_short_url(self, original_url: str, phone_number: str)-> Optional[str]:

        try:
            s = pyshorteners.Shortener()

            short_url = s.tinyurl.short(original_url)

            short_code = short_url.split('/')[-1]
        
        except Exception as e:
            logger.error(f"Failed to generate short URL using pyshorteners: {e}", exc_info=True)

            return None
        
        item = { 
            "short_code" : short_code,
            "original_url" : original_url,
            "phone_number" : phone_number,
            "created_at" : int(time.time()),
        }

        success = self.db_client.create_url_entry(item)
        return short_code if success else None

    
    def get_original_url(self, short_code: str) -> Optional[str]:

        item = self.db_client.get_url_entry_by_short_code(short_code)

        if item:
            return item.get("original_url")
        return None
    
    def delete_short_url(self, short_code: str) -> bool :

        item = self.db_client.get_url_entry_by_short_code(short_code)

        if not item: 
            logger.warning(f"Delete failed: short code '{short_code}' not found.")
            return False
        return self.db_client.delete_url_entry(short_code)