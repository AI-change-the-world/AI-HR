from datetime import datetime

from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.sql import func

from config.database import Base
from models._mixin import ToDictMixin


class OKR(Base, ToDictMixin):
    __tablename__ = "okrs"

    id = Column(Integer, primary_key=True, index=True, comment="OKR ID")
    employee_id = Column(Integer, ForeignKey("employees.id"), nullable=False, comment="员工ID")
    objective = Column(Text, nullable=False, comment="目标")
    key_results = Column(Text, nullable=True, comment="关键结果")
    quarter = Column(String(10), nullable=False, comment="季度")  # 如 "Q1-2025"
    start_date = Column(Date, nullable=False, comment="开始日期")
    end_date = Column(Date, nullable=False, comment="结束日期")
    progress = Column(Integer, default=0, comment="进度百分比")  # 0-100
    created_at = Column(DateTime, default=func.now(), comment="创建时间")
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), comment="更新时间")
