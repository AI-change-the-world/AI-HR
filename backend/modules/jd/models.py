from pydantic import BaseModel
from typing import Optional

class JDBase(BaseModel):
    title: str
    department: str
    location: str
    description: Optional[str] = None
    status: str = "草稿"

class JDCreate(JDBase):
    pass

class JDUpdate(JDBase):
    title: Optional[str] = None
    department: Optional[str] = None
    location: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None

class JDInDB(JDBase):
    id: int

    class Config:
        orm_mode = True