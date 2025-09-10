from typing import Optional

from pydantic import BaseModel


class EmployeeBase(BaseModel):
    name: str
    department_id: Optional[int] = None
    position: str
    status: Optional[int] = 0
    comment: Optional[str] = None

    model_config = {"from_attributes": True}


class EmployeeCreate(EmployeeBase):
    model_config = {"from_attributes": True}


class EmployeeUpdate(EmployeeBase):
    name: Optional[str] = None
    department_id: Optional[int] = None
    position: Optional[str] = None
    status: Optional[int] = None
    comment: Optional[str] = None


class EmployeeInDB(EmployeeBase):
    id: int

    model_config = {"from_attributes": True}
