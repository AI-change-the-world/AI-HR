from datetime import datetime

from sqlalchemy import (Column, Date, DateTime, ForeignKey, Integer, String,
                        Text)
from sqlalchemy.sql import func

from config.database import Base


class OKR(Base):
    __tablename__ = "okrs"

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, ForeignKey("employees.id"), nullable=False)
    objective = Column(Text, nullable=False)
    key_results = Column(Text, nullable=True)
    quarter = Column(String(10), nullable=False)  # 如 "Q1-2025"
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    progress = Column(Integer, default=0)  # 0-100
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    def to_dict(self):
        """转换为字典"""
        return {
            "id": self.id,
            "employee_id": self.employee_id,
            "objective": self.objective,
            "key_results": self.key_results,
            "quarter": self.quarter,
            "start_date": self.start_date.isoformat() if self.start_date else None,
            "end_date": self.end_date.isoformat() if self.end_date else None,
            "progress": self.progress,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
