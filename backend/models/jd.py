from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, Integer, String, Text
from sqlalchemy.sql import func

from config.database import Base
from models._mixin import ToDictMixin


class JobDescription(Base, ToDictMixin):
    __tablename__ = "job_descriptions"

    id = Column(Integer, primary_key=True, index=True, comment="职位描述ID")
    title = Column(String(255), nullable=False, comment="职位标题")
    description = Column(Text, nullable=False, comment="职位描述")
    requirements = Column(Text, nullable=True, comment="职位要求")
    department = Column(String(100), nullable=False, comment="所属部门")
    location = Column(String(100), nullable=True, comment="工作地点")
    salary_range = Column(String(50), nullable=True, comment="薪资范围")
    is_open = Column(Boolean, default=True, comment="是否开放")
    created_at = Column(DateTime, default=func.now(), comment="创建时间")
    updated_at = Column(
        DateTime, default=func.now(), onupdate=func.now(), comment="更新时间"
    )
