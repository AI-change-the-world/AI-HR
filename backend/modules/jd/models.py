from datetime import datetime
from typing import Any, Dict, Optional

from pydantic import BaseModel


class JDBase(BaseModel):
    title: str
    department_id: Optional[int] = None
    location: Optional[str] = None
    description: Optional[str] = None
    requirements: Optional[str] = None
    status: str = "草稿"


class JDCreate(JDBase):
    pass


class JDUpdate(JDBase):
    title: Optional[str] = None
    department_id: Optional[int] = None
    location: Optional[str] = None
    description: Optional[str] = None
    requirements: Optional[str] = None
    status: Optional[str] = None


class JDInDB(JDBase):
    id: int
    department_id: Optional[int] = None
    department: Optional[str] = None  # 部门名称，用于显示
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
