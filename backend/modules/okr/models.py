from pydantic import BaseModel
from typing import List, Optional

class KeyResult(BaseModel):
    id: int
    description: str
    target: float
    current: float

class OKRBase(BaseModel):
    objective: str
    quarter: str
    owner: str
    progress: float = 0.0

class OKRCreate(OKRBase):
    pass

class OKRUpdate(OKRBase):
    objective: Optional[str] = None
    quarter: Optional[str] = None
    owner: Optional[str] = None
    progress: Optional[float] = None

class OKRInDB(OKRBase):
    id: int
    key_results: List[KeyResult] = []

    class Config:
        orm_mode = True