from sqlalchemy import Column, Integer, String, Text, DateTime, Float, Boolean
from sqlalchemy.sql import func
from config.database import Base
from typing import Optional
from datetime import datetime

class Resume(Base):
    __tablename__ = "resumes"
    
    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String(255), nullable=False)
    content = Column(Text, nullable=True)
    name = Column(String(100), nullable=True)
    email = Column(String(100), nullable=True)
    phone = Column(String(20), nullable=True)
    education = Column(String(255), nullable=True)
    experience = Column(Text, nullable=True)
    skills = Column(Text, nullable=True)
    position = Column(String(100), nullable=True)
    status = Column(String(50), default="待筛选")
    score = Column(Float, default=0.0)
    matched_jd_id = Column(Integer, nullable=True)
    match_score = Column(Float, default=0.0)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    def to_dict(self):
        """转换为字典"""
        return {
            "id": self.id,
            "filename": self.filename,
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "education": self.education,
            "experience": self.experience,
            "skills": self.skills,
            "position": self.position,
            "status": self.status,
            "score": self.score,
            "matched_jd_id": self.matched_jd_id,
            "match_score": self.match_score,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }