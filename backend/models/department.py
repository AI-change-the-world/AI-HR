from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.sql import func
from config.database import Base

class Department(Base):
    __tablename__ = "departments"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, unique=True)
    manager = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    employee_count = Column(Integer, default=0)
    
    def to_dict(self):
        """转换为字典"""
        return {
            "id": self.id,
            "name": self.name,
            "manager": self.manager,
            "description": self.description,
            "employee_count": self.employee_count,
        }