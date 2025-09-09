from typing import Optional

from pydantic import BaseModel


class DepartmentBase(BaseModel):
    name: str
    manager: str
    description: Optional[str] = None


class DepartmentCreate(DepartmentBase):
    pass


class DepartmentUpdate(DepartmentBase):
    name: Optional[str] = None
    manager: Optional[str] = None
    description: Optional[str] = None


class DepartmentInDB(DepartmentBase):
    id: int
    employee_count: int = 0

    class Config:
        orm_mode = True
