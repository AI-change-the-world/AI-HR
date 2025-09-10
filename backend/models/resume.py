from datetime import datetime
from typing import Optional

from sqlalchemy import Boolean, Column, DateTime, Float, Integer, String, Text
from sqlalchemy.sql import func

from config.database import Base
from models._mixin import ToDictMixin


class Resume(Base, ToDictMixin):
    __tablename__ = "resumes"

    id = Column(Integer, primary_key=True, index=True, comment="简历ID")
    filename = Column(String(255), nullable=False, comment="文件名")
    content = Column(Text, nullable=True, comment="简历内容")
    name = Column(String(100), nullable=True, comment="姓名")
    email = Column(String(100), nullable=True, comment="邮箱")
    phone = Column(String(20), nullable=True, comment="电话")
    education = Column(String(255), nullable=True, comment="教育背景")
    experience = Column(Text, nullable=True, comment="工作经验")
    skills = Column(Text, nullable=True, comment="技能")
    position = Column(String(100), nullable=True, comment="应聘职位")
    status = Column(String(50), default="待筛选", comment="简历状态")
    score = Column(Float, default=0.0, comment="简历评分")
    matched_jd_id = Column(Integer, nullable=True, comment="匹配的职位描述ID")
    match_score = Column(Float, default=0.0, comment="匹配度评分")
    path = Column(String(255), nullable=True, comment="文件存储的s3路径")
    created_at = Column(DateTime, default=func.now(), comment="创建时间")
    updated_at = Column(
        DateTime, default=func.now(), onupdate=func.now(), comment="更新时间"
    )
