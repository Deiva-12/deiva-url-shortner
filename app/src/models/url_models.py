from pydantic import BaseModel, HttpUrl

class CreateUrlRequest(BaseModel):
    original_url: str # Pydantic validates this is a valid URL
    phone_number: str

class CreateUrlResponse(BaseModel):
    short_url: str

class FetchUrlResponse(BaseModel):
    original_url: HttpUrl