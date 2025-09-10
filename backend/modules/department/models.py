from typing import Optional

from pydantic import BaseModel


class DepartmentBase(BaseModel):
    name: str
    description: Optional[str] = None

    model_config = {"from_attributes": True}


class DepartmentCreate(DepartmentBase):
    pass


class DepartmentUpdate(DepartmentBase):
    name: Optional[str] = None
    manager: Optional[str] = None
    description: Optional[str] = None


class DepartmentInDB(DepartmentBase):
    id: int
    employee_count: int = 0

    model_config = {"from_attributes": True}
