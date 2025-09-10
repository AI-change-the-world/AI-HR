from sqlalchemy import Column, DateTime, Integer, String
from sqlalchemy.sql import func

from config.database import Base
from models._mixin import ToDictMixin


class Employee(Base, ToDictMixin):
    __tablename__ = "employees"

    id = Column(Integer, primary_key=True, index=True, comment="员工ID")
    name = Column(String(100), nullable=False, comment="员工姓名")
    department_id = Column(Integer, default=0, nullable=True, comment="所属部门")
    position = Column(String(100), nullable=False, comment="职位")
    status = Column(
        Integer,
        default=0,
        nullable=False,
        comment="员工状态,0 在职，1离职，2待入职，3待离职，4待转正，5被辞退",
    )
    comment = Column(String(1024), nullable=True, comment="员工备注")

    created_at = Column(DateTime, default=func.now(), comment="创建时间")
    updated_at = Column(
        DateTime, default=func.now(), onupdate=func.now(), comment="更新时间"
    )
