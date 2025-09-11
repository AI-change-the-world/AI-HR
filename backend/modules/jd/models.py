from typing import Optional
from datetime import datetime

from pydantic import BaseModel


class JDBase(BaseModel):
    title: str
    department: str
    location: str
    description: Optional[str] = None
    requirements: Optional[str] = None
    status: str = "草稿"


class JDCreate(JDBase):
    pass


class JDUpdate(JDBase):
    title: Optional[str] = None
    department: Optional[str] = None
    location: Optional[str] = None
    description: Optional[str] = None
    requirements: Optional[str] = None
    status: Optional[str] = None


class JDInDB(JDBase):
    id: int
    is_open: bool = True
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = {"from_attributes": True}