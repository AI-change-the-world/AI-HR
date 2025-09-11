import json
from typing import Any, Dict, Generator, List, Optional

from sqlalchemy.orm import Session

from models.jd import JobDescription
from models.department import Department

from .evaluation_agent import evaluate_resume_stepwise
from .models import JDCreate, JDFullInfoUpdate, JDInDB, JDUpdate
from .text_polisher import jd_polisher


def _build_jd_in_db(db_jd: JobDescription, db: Session) -> JDInDB:
    """构建 JDInDB 对象，包含部门信息（使用简单JOIN查询）"""
    # 获取部门信息 - 使用简单的JOIN查询
    department_name = None
    if db_jd.department_id:
        department = db.query(Department).filter(Department.id == db_jd.department_id).first()
        if department:
            department_name = department.name

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
        department_id=db_jd.department_id,
        department=department_name,
        location=db_jd.location,
        description=db_jd.description,
        requirements=db_jd.requirements,
        status="开放" if db_jd.is_open else "关闭",
        created_at=db_jd.created_at,
        updated_at=db_jd.updated_at,
        full_text=db_jd.full_text,
        evaluation_criteria=evaluation_criteria,
    )


def polish_jd_text(original_text: str) -> str:
    """
    AI润色JD文本
    """
    return jd_polisher.polish_text(original_text)


def create_jd_from_text(text: str, db: Session) -> JDInDB:
    """
    从文本创建JD
    """
    # 使用AI提取结构化信息
    extracted_fields = jd_polisher.extract_jd_fields(text)

    # 生成评估标准 （没必要在这个接口中都一起完成，很容易超时）
    # evaluation_criteria = jd_polisher.generate_evaluation_criteria(text)

    # 创建JD记录
    db_jd = JobDescription(
        title=extracted_fields.get("title", "未命名职位"),
        department_id=None,  # 初始创建时不指定部门，后续可编辑
        location=extracted_fields.get("location", "未指定"),
        description=extracted_fields.get("description", ""),
        requirements=extracted_fields.get("requirements", ""),
        full_text=text,
        evaluation_criteria="",
        is_open=True,  # 默认开放状态
    )

    db.add(db_jd)
    db.commit()
    db.refresh(db_jd)

    return _build_jd_in_db(db_jd, db)


def create_jd(jd_create: JDCreate, db: Session) -> JDInDB:
    """创建新JD"""
    # 创建JD记录
    db_jd = JobDescription(
        title=jd_create.title,
        department_id=jd_create.department_id,
        location=jd_create.location,
        description=jd_create.description or "",
        requirements=jd_create.requirements or "",
        is_open=jd_create.status == "开放",
    )

    db.add(db_jd)
    db.commit()
    db.refresh(db_jd)

    return _build_jd_in_db(db_jd, db)


def get_jd(jd_id: int, db: Session) -> Optional[JDInDB]:
    """获取指定ID的JD"""
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return None

    return _build_jd_in_db(db_jd, db)


def get_jds(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> List[JDInDB]:
    """获取JD列表（优化版，使用一次JOIN查询）"""
    # 使用JOIN查询一次性获取JD和部门信息
    query = db.query(JobDescription, Department.name.label('department_name')).outerjoin(
        Department, JobDescription.department_id == Department.id
    ).offset(skip).limit(limit)
    
    results = query.all()
    jd_list = []
    
    for db_jd, dept_name in results:
        # 解析evaluation_criteria
        evaluation_criteria = None
        if db_jd.evaluation_criteria:
            try:
                evaluation_criteria = json.loads(db_jd.evaluation_criteria)
            except json.JSONDecodeError:
                evaluation_criteria = None

        jd_list.append(
            JDInDB(
                id=db_jd.id,
                title=db_jd.title,
                department_id=db_jd.department_id,
                department=dept_name,  # 从 JOIN 查询结果获取
                location=db_jd.location,
                description=db_jd.description,
                requirements=db_jd.requirements,
                status="开放" if db_jd.is_open else "关闭",
                created_at=db_jd.created_at,
                updated_at=db_jd.updated_at,
                full_text=db_jd.full_text,
                evaluation_criteria=evaluation_criteria,
            )
        )
    
    return jd_list


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

    return _build_jd_in_db(db_jd, db)


def delete_jd(jd_id: int, db: Session) -> bool:
    """删除JD"""
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return False

    db.delete(db_jd)
    db.commit()
    return True


def evaluate_resume(
    jd_id: int, resume_text: str, db: Session
) -> Generator[Dict[str, Any], None, None]:
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


def update_jd_evaluation_criteria(
    jd_id: int, criteria: Dict[str, Any], db: Session
) -> bool:
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
        "学历": {"本科": 5, "研究生": 10, "博士及以上": 20},
        "技能": {"Python": 10, "SQL": 5, "Java": 8, "JavaScript": 8},
        "年限": {">=3年": 10, "<3年": 5, "<1年": 0},
        "真实性": {"AI生成嫌疑": -10, "具体案例丰富": 10},
    }


def update_jd_full_info(
    jd_id: int, full_info: JDFullInfoUpdate, db: Session
) -> Optional[JDInDB]:
    """
    更新JD的完整信息和评估标准
    """
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        return None

    if full_info.full_text is not None:
        db_jd.full_text = full_info.full_text

    if full_info.evaluation_criteria is not None:
        db_jd.evaluation_criteria = json.dumps(
            full_info.evaluation_criteria, ensure_ascii=False
        )

    db.commit()
    db.refresh(db_jd)

    return _build_jd_in_db(db_jd, db)
