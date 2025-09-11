import json
import os
from typing import List, Optional, Dict, Any, Generator
from sqlalchemy.orm import Session

from models.jd import JobDescription
from .models import JDCreate, JDInDB, JDUpdate
from .evaluation_agent import evaluate_resume_stepwise

def create_jd(jd_create: JDCreate, db: Session) -> JDInDB:
    """创建新JD"""
    # 创建JD记录
    db_jd = JobDescription(
        title=jd_create.title,
        department=jd_create.department,
        location=jd_create.location,
        description=jd_create.description or "",
        requirements=jd_create.requirements or "",
        is_open=jd_create.status == "开放"
    )
    
    db.add(db_jd)
    db.commit()
    db.refresh(db_jd)
    
    return JDInDB(
        id=db_jd.id,
        title=db_jd.title,
        department=db_jd.department,
        location=db_jd.location,
        description=db_jd.description,
        requirements=db_jd.requirements,
        status="开放" if db_jd.is_open else "关闭"
    )


def get_jd(jd_id: int, db: Session) -> Optional[JDInDB]:
    """获取指定ID的JD"""
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return None
    
    return JDInDB(
        id=db_jd.id,
        title=db_jd.title,
        department=db_jd.department,
        location=db_jd.location,
        description=db_jd.description,
        requirements=db_jd.requirements,
        status="开放" if db_jd.is_open else "关闭"
    )


def get_jds(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> List[JDInDB]:
    """获取JD列表"""
    db_jds = db.query(JobDescription).offset(skip).limit(limit).all()
    return [
        JDInDB(
            id=db_jd.id,
            title=db_jd.title,
            department=db_jd.department,
            location=db_jd.location,
            description=db_jd.description,
            requirements=db_jd.requirements,
            status="开放" if db_jd.is_open else "关闭"
        )
        for db_jd in db_jds
    ]


def update_jd(jd_id: int, jd_update: JDUpdate, db: Session) -> Optional[JDInDB]:
    """更新JD"""
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return None
    
    update_data = jd_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        if key == "status":
            db_jd.is_open = value == "开放"
        elif value is not None:
            setattr(db_jd, key, value)
    
    db.commit()
    db.refresh(db_jd)
    
    return JDInDB(
        id=db_jd.id,
        title=db_jd.title,
        department=db_jd.department,
        location=db_jd.location,
        description=db_jd.description,
        requirements=db_jd.requirements,
        status="开放" if db_jd.is_open else "关闭"
    )


def delete_jd(jd_id: int, db: Session) -> bool:
    """删除JD"""
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return False
    
    db.delete(db_jd)
    db.commit()
    return True


def evaluate_resume(jd_id: int, resume_text: str, scoring_rules: Dict[str, Any], db: Session) -> Generator[Dict[str, Any], None, None]:
    """
    评估简历与指定JD的匹配度
    """
    # 获取JD信息
    jd = get_jd(jd_id, db)
    if not jd:
        raise ValueError("JD未找到")
    
    # 构造JD文本
    jd_text = f"职位名称: {jd.title}\n部门: {jd.department}\n工作地点: {jd.location}\n描述: {jd.description}\n要求: {jd.requirements}"
    
    # 调用评估智能体
    return evaluate_resume_stepwise(jd_text, resume_text, scoring_rules)