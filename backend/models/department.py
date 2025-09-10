from sqlalchemy import Column, DateTime, Integer, String, Text
from sqlalchemy.sql import func

from config.database import Base
from models._mixin import ToDictMixin


class Department(Base, ToDictMixin):
    __tablename__ = "departments"

    id = Column(Integer, primary_key=True, index=True, comment="部门ID")
    name = Column(String(100), nullable=False, unique=True, comment="部门名称")
    description = Column(Text, nullable=True, comment="部门描述")

    created_at = Column(DateTime, default=func.now(), comment="创建时间")
    updated_at = Column(
        DateTime, default=func.now(), onupdate=func.now(), comment="更新时间"
    )
