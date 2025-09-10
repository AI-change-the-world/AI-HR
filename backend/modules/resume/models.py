from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class ResumeBase(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    education: Optional[str] = None
    experience: Optional[str] = None
    skills: Optional[str] = None
    position: Optional[str] = None


class ResumeCreate(ResumeBase):
    filename: str


class ResumeUpdate(ResumeBase):
    status: Optional[str] = None
    score: Optional[float] = None


class ResumeInDB(ResumeBase):
    id: int
    filename: str
    status: str = "待筛选"
    score: float = 0.0
    created_at: str
    updated_at: str

    model_config = {"from_attributes": True}
