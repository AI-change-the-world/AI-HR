from typing import Optional, Dict, Any
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
    full_text: Optional[str] = None
    evaluation_criteria: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}


class JDFullInfoUpdate(BaseModel):
    """更新JD完整信息和评估标准"""
    full_text: Optional[str] = None
    evaluation_criteria: Optional[Dict[str, Any]] = None


class EvaluationCriteriaUpdate(BaseModel):
    """更新JD评估标准"""
    criteria: Dict[str, Any]