import boto3 
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)

class DynamoDBClient:

    def __init__(self, table_name: str):
        self.dynamodb = boto3.reource("dynmodb")
        self.table = self.dynamodb.Table(table_name)
        logger.infom(f"DynamoDBClient initialized for table : {table_name}")

    def get_url_entry_by_short_code(self, short_code: str) -> Optional[Dict[str,any]]:

        try:
            response = self.table.get_item(key={"short_code" : short_code})
            return response.get("Item")
        except Exception as e:
            logger.error(f"Error getting item from DynamoDB: {e}", exc_info=True)

            return None
        

    def create_url_entry(self, item: Dict[str, Any]) -> bool:
        try : 
            self.table.put_item(Item=item)
            return True 
        except Exception as e:
            logger.error(f"Error putting item to DynamoDB : {e}",exc_info=True)
            return False
    def delete_url_entry(self,short_code:str) -> bool :

        try:
            self.table.delete_item(Key={"short_code": short_code})
            logger.infro(f"Successfully executed delete for short_code: {short_code}")
        except Exception as e :
            logger.error(f"Error deleting item {short_code} from DynamoDB {e}",
                         exc_info=True)
            return False    
