import json
import os
from typing import List, Optional, Dict, Any, Generator
from sqlalchemy.orm import Session

from models.jd import JobDescription
from .models import JDCreate, JDInDB, JDUpdate, JDFullInfoUpdate
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
        status="开放" if db_jd.is_open else "关闭",
        created_at=db_jd.created_at,
        updated_at=db_jd.updated_at
    )


def get_jd(jd_id: int, db: Session) -> Optional[JDInDB]:
    """获取指定ID的JD"""
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return None
    
    # 解析evaluation_criteria
    evaluation_criteria = None
    if db_jd.evaluation_criteria:
        try:
            evaluation_criteria = json.loads(db_jd.evaluation_criteria)
        except json.JSONDecodeError:
            evaluation_criteria = None
    
    return JDInDB(
        id=db_jd.id,
        title=db_jd.title,
        department=db_jd.department,
        location=db_jd.location,
        description=db_jd.description,
        requirements=db_jd.requirements,
        status="开放" if db_jd.is_open else "关闭",
        created_at=db_jd.created_at,
        updated_at=db_jd.updated_at,
        full_text=db_jd.full_text,
        evaluation_criteria=evaluation_criteria
    )


def get_jds(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> List[JDInDB]:
    """获取JD列表"""
    db_jds = db.query(JobDescription).offset(skip).limit(limit).all()
    result = []
    for db_jd in db_jds:
        # 解析evaluation_criteria
        evaluation_criteria = None
        if db_jd.evaluation_criteria:
            try:
                evaluation_criteria = json.loads(db_jd.evaluation_criteria)
            except json.JSONDecodeError:
                evaluation_criteria = None
        
        result.append(JDInDB(
            id=db_jd.id,
            title=db_jd.title,
            department=db_jd.department,
            location=db_jd.location,
            description=db_jd.description,
            requirements=db_jd.requirements,
            status="开放" if db_jd.is_open else "关闭",
            created_at=db_jd.created_at,
            updated_at=db_jd.updated_at,
            full_text=db_jd.full_text,
            evaluation_criteria=evaluation_criteria
        ))
    return result


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
    
    # 解析evaluation_criteria
    evaluation_criteria = None
    if db_jd.evaluation_criteria:
        try:
            evaluation_criteria = json.loads(db_jd.evaluation_criteria)
        except json.JSONDecodeError:
            evaluation_criteria = None
    
    return JDInDB(
        id=db_jd.id,
        title=db_jd.title,
        department=db_jd.department,
        location=db_jd.location,
        description=db_jd.description,
        requirements=db_jd.requirements,
        status="开放" if db_jd.is_open else "关闭",
        created_at=db_jd.created_at,
        updated_at=db_jd.updated_at,
        full_text=db_jd.full_text,
        evaluation_criteria=evaluation_criteria
    )


def delete_jd(jd_id: int, db: Session) -> bool:
    """删除JD"""
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return False
    
    db.delete(db_jd)
    db.commit()
    return True


def evaluate_resume(jd_id: int, resume_text: str, db: Session) -> Generator[Dict[str, Any], None, None]:
    """
    评估简历与指定JD的匹配度
    """
    # 获取JD信息
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if not db_jd:
        raise ValueError("JD未找到")
    
    # 优先使用full_text，如果没有则使用结构化信息
    if db_jd.full_text:
        jd_text = db_jd.full_text
    else:
        jd_text = f"职位名称: {db_jd.title}\n部门: {db_jd.department}\n工作地点: {db_jd.location}\n描述: {db_jd.description}\n要求: {db_jd.requirements}"
    
    # 获取评分规则
    scoring_rules = {}
    if db_jd.evaluation_criteria:
        try:
            scoring_rules = json.loads(db_jd.evaluation_criteria)
        except json.JSONDecodeError:
            scoring_rules = {}
    
    # 调用评估智能体
    return evaluate_resume_stepwise(jd_text, resume_text, scoring_rules)


def update_jd_evaluation_criteria(jd_id: int, criteria: Dict[str, Any], db: Session) -> bool:
    """
    更新JD的评估标准
    """
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return False
    
    db_jd.evaluation_criteria = json.dumps(criteria, ensure_ascii=False)
    db.commit()
    return True


def get_jd_evaluation_criteria(jd_id: int, db: Session) -> Optional[Dict[str, Any]]:
    """
    获取JD的评估标准
    """
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return None
    
    if db_jd.evaluation_criteria:
        try:
            return json.loads(db_jd.evaluation_criteria)
        except json.JSONDecodeError:
            return {}
    
    # 返回默认评估标准
    return {
        "学历": { "本科": 5, "研究生": 10, "博士及以上": 20 },
        "技能": { "Python": 10, "SQL": 5, "Java": 8, "JavaScript": 8 },
        "年限": { ">=3年": 10, "<3年": 5, "<1年": 0 },
        "真实性": { "AI生成嫌疑": -10, "具体案例丰富": 10 }
    }


def update_jd_full_info(jd_id: int, full_info: JDFullInfoUpdate, db: Session) -> Optional[JDInDB]:
    """
    更新JD的完整信息和评估标准
    """
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return None
    
    if full_info.full_text is not None:
        db_jd.full_text = full_info.full_text
    
    if full_info.evaluation_criteria is not None:
        db_jd.evaluation_criteria = json.dumps(full_info.evaluation_criteria, ensure_ascii=False)
    
    db.commit()
    db.refresh(db_jd)
    
    # 解析evaluation_criteria
    evaluation_criteria = None
    if db_jd.evaluation_criteria:
        try:
            evaluation_criteria = json.loads(db_jd.evaluation_criteria)
        except json.JSONDecodeError:
            evaluation_criteria = None
    
    return JDInDB(
        id=db_jd.id,
        title=db_jd.title,
        department=db_jd.department,
        location=db_jd.location,
        description=db_jd.description,
        requirements=db_jd.requirements,
        status="开放" if db_jd.is_open else "关闭",
        created_at=db_jd.created_at,
        updated_at=db_jd.updated_at,
        full_text=db_jd.full_text,
        evaluation_criteria=evaluation_criteria
    )