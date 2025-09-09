from typing import Optional

from pydantic import BaseModel


class EmployeeBase(BaseModel):
    name: str
    department: str
    position: str
    email: str
    phone: Optional[str] = None


class EmployeeCreate(EmployeeBase):
    pass


class EmployeeUpdate(EmployeeBase):
    name: Optional[str] = None
    department: Optional[str] = None
    position: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None


class EmployeeInDB(EmployeeBase):
    id: int

    class Config:
        orm_mode = True
