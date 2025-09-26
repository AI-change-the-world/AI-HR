from datetime import datetime
from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func

from models.capability import Skill, EmployeeSkill, SkillAssessmentHistory, SkillLevel, SkillCategory
from models.employee import Employee
from models.department import Department
from .models import (
    SkillCreate, SkillUpdate, SkillInDB, EmployeeSkillCreate, EmployeeSkillUpdate,
    EmployeeSkillInDB, EmployeeSkillMatrix, SkillQuery, SkillStatistics,
    SkillAssessmentRequest, TeamSkillAnalysis, SkillDevelopmentPlan
)


# 技能管理
def create_skill(skill_create: SkillCreate, db: Session) -> SkillInDB:
    """创建新技能"""
    db_skill = Skill(**skill_create.dict())
    db.add(db_skill)
    db.commit()
    db.refresh(db_skill)
    
    return SkillInDB.from_orm(db_skill)


def get_skill(skill_id: int, db: Session) -> Optional[SkillInDB]:
    """获取指定ID的技能"""
    db_skill = db.query(Skill).filter(Skill.id == skill_id).first()
    if db_skill is None:
        return None
    
    return SkillInDB.from_orm(db_skill)


def update_skill(skill_id: int, skill_update: SkillUpdate, db: Session) -> Optional[SkillInDB]:
    """更新技能"""
    db_skill = db.query(Skill).filter(Skill.id == skill_id).first()
    if db_skill is None:
        return None
    
    update_data = skill_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_skill, field, value)
    
    db.commit()
    db.refresh(db_skill)
    
    return SkillInDB.from_orm(db_skill)


def delete_skill(skill_id: int, db: Session) -> bool:
    """删除技能（软删除）"""
    db_skill = db.query(Skill).filter(Skill.id == skill_id).first()
    if db_skill is None:
        return False
    
    db_skill.is_active = 0
    db.commit()
    return True


def get_skills(category: Optional[SkillCategory] = None, 
               keyword: Optional[str] = None,
               page: int = 1, page_size: int = 20,
               db: Session = None) -> Dict[str, Any]:
    """获取技能列表"""
    query = db.query(Skill).filter(Skill.is_active == 1)
    
    if category:
        query = query.filter(Skill.category == category)
    
    if keyword:
        query = query.filter(
            or_(
                Skill.name.contains(keyword),
                Skill.description.contains(keyword)
            )
        )
    
    total = query.count()
    offset = (page - 1) * page_size
    skills = query.order_by(Skill.name).offset(offset).limit(page_size).all()
    
    return {
        "skills": [SkillInDB.from_orm(skill) for skill in skills],
        "total": total,
        "page": page,
        "page_size": page_size
    }


# 员工技能管理
def create_employee_skill(emp_skill_create: EmployeeSkillCreate, db: Session) -> EmployeeSkillInDB:
    """创建员工技能记录"""
    # 检查是否已存在
    existing = db.query(EmployeeSkill).filter(
        and_(
            EmployeeSkill.employee_id == emp_skill_create.employee_id,
            EmployeeSkill.skill_id == emp_skill_create.skill_id
        )
    ).first()
    
    if existing:
        raise ValueError("该员工已有此技能记录，请使用更新接口")
    
    # 创建记录
    emp_skill_dict = emp_skill_create.dict()
    emp_skill_dict["assessment_date"] = datetime.now()
    
    db_emp_skill = EmployeeSkill(**emp_skill_dict)
    db.add(db_emp_skill)
    db.commit()
    db.refresh(db_emp_skill)
    
    # 记录评估历史
    _record_assessment_history(db_emp_skill.id, None, emp_skill_create.level, 
                              emp_skill_create.assessed_by, "初始评估", db)
    
    return _build_employee_skill_in_db(db_emp_skill, db)


def update_employee_skill(emp_skill_id: int, emp_skill_update: EmployeeSkillUpdate, 
                         db: Session) -> Optional[EmployeeSkillInDB]:
    """更新员工技能"""
    db_emp_skill = db.query(EmployeeSkill).filter(EmployeeSkill.id == emp_skill_id).first()
    if db_emp_skill is None:
        return None
    
    update_data = emp_skill_update.dict(exclude_unset=True)
    
    # 记录等级变更历史
    old_level = db_emp_skill.level
    new_level = update_data.get("level")
    
    if new_level and new_level != old_level:
        update_data["assessment_date"] = datetime.now()
    
    # 更新字段
    for field, value in update_data.items():
        setattr(db_emp_skill, field, value)
    
    db.commit()
    db.refresh(db_emp_skill)
    
    # 记录评估历史
    if new_level and new_level != old_level:
        _record_assessment_history(
            db_emp_skill.id, old_level, new_level,
            emp_skill_update.assessed_by, "技能评估更新", db
        )
    
    return _build_employee_skill_in_db(db_emp_skill, db)


def get_employee_skills(employee_id: int, db: Session) -> List[EmployeeSkillInDB]:
    """获取员工的所有技能"""
    emp_skills = db.query(EmployeeSkill).filter(
        EmployeeSkill.employee_id == employee_id
    ).all()
    
    return [_build_employee_skill_in_db(emp_skill, db) for emp_skill in emp_skills]


def get_employee_skill_matrix(employee_id: int, db: Session) -> EmployeeSkillMatrix:
    """获取员工技能矩阵"""
    # 获取员工信息
    employee = db.query(Employee).filter(Employee.id == employee_id).first()
    if not employee:
        raise ValueError("员工不存在")
    
    # 获取部门信息
    department_name = None
    if employee.department_id:
        department = db.query(Department).filter(Department.id == employee.department_id).first()
        if department:
            department_name = department.name
    
    # 获取技能列表
    skills = get_employee_skills(employee_id, db)
    
    # 按分类汇总技能
    skill_summary = {}
    for skill in skills:
        category = skill.skill_category or "其他"
        if category not in skill_summary:
            skill_summary[category] = {
                "total": 0,
                "levels": {"S": 0, "A": 0, "B": 0, "C": 0, "D": 0}
            }
        skill_summary[category]["total"] += 1
        skill_summary[category]["levels"][skill.level.value] += 1
    
    return EmployeeSkillMatrix(
        employee_id=employee_id,
        employee_name=employee.name,
        department_name=department_name,
        skills=skills,
        skill_summary=skill_summary
    )


def assess_employee_skill(assessment: SkillAssessmentRequest, db: Session) -> EmployeeSkillInDB:
    """评估员工技能"""
    # 查找员工技能记录
    emp_skill = db.query(EmployeeSkill).filter(
        and_(
            EmployeeSkill.employee_id == assessment.employee_id,
            EmployeeSkill.skill_id == assessment.skill_id
        )
    ).first()
    
    if not emp_skill:
        raise ValueError("未找到该员工的技能记录")
    
    # 记录旧等级
    old_level = emp_skill.level
    
    # 更新技能等级
    emp_skill.level = assessment.new_level
    emp_skill.assessment_date = datetime.now()
    emp_skill.assessed_by = assessment.assessed_by
    if assessment.assessment_notes:
        emp_skill.assessment_notes = assessment.assessment_notes
    
    db.commit()
    db.refresh(emp_skill)
    
    # 记录评估历史
    _record_assessment_history(
        emp_skill.id, old_level, assessment.new_level,
        assessment.assessed_by, assessment.assessment_method or "技能评估",
        db, assessment.assessment_notes
    )
    
    return _build_employee_skill_in_db(emp_skill, db)


def get_team_skill_analysis(department_id: Optional[int], db: Session) -> TeamSkillAnalysis:
    """获取团队技能分析"""
    # 构建员工查询
    employee_query = db.query(Employee).filter(Employee.status == 0)  # 在职员工
    if department_id:
        employee_query = employee_query.filter(Employee.department_id == department_id)
    
    employees = employee_query.all()
    total_employees = len(employees)
    
    if total_employees == 0:
        return TeamSkillAnalysis(
            department_id=department_id,
            total_employees=0,
            skill_coverage=[],
            skill_gaps=[],
            recommendations=[]
        )
    
    # 获取部门名称
    department_name = None
    if department_id:
        department = db.query(Department).filter(Department.id == department_id).first()
        if department:
            department_name = department.name
    
    # 分析技能覆盖情况
    skill_coverage = _analyze_skill_coverage(employees, db)
    
    # 分析技能差距
    skill_gaps = _analyze_skill_gaps(employees, db)
    
    # 生成改进建议
    recommendations = _generate_skill_recommendations(skill_coverage, skill_gaps)
    
    return TeamSkillAnalysis(
        department_id=department_id,
        department_name=department_name,
        total_employees=total_employees,
        skill_coverage=skill_coverage,
        skill_gaps=skill_gaps,
        recommendations=recommendations
    )


def get_skill_statistics(db: Session) -> SkillStatistics:
    """获取技能统计信息"""
    # 总技能数
    total_skills = db.query(Skill).filter(Skill.is_active == 1).count()
    
    # 总员工技能记录数
    total_employee_skills = db.query(EmployeeSkill).count()
    
    # 按分类的技能分布
    skill_distribution = {}
    categories = db.query(Skill.category, func.count(Skill.id)).filter(
        Skill.is_active == 1
    ).group_by(Skill.category).all()
    
    for category, count in categories:
        skill_distribution[category.value] = count
    
    # 按等级的分布
    level_distribution = {}
    levels = db.query(EmployeeSkill.level, func.count(EmployeeSkill.id)).group_by(
        EmployeeSkill.level
    ).all()
    
    for level, count in levels:
        level_distribution[level.value] = count
    
    # 最受欢迎的技能
    top_skills = db.query(
        Skill.name, func.count(EmployeeSkill.id).label('count')
    ).join(EmployeeSkill).filter(
        Skill.is_active == 1
    ).group_by(Skill.id, Skill.name).order_by(
        func.count(EmployeeSkill.id).desc()
    ).limit(10).all()
    
    top_skills_list = [{"name": name, "count": count} for name, count in top_skills]
    
    return SkillStatistics(
        total_skills=total_skills,
        total_employee_skills=total_employee_skills,
        skill_distribution=skill_distribution,
        level_distribution=level_distribution,
        top_skills=top_skills_list,
        skill_trends=[]  # 可以后续实现趋势分析
    )


# 辅助函数
def _build_employee_skill_in_db(db_emp_skill: EmployeeSkill, db: Session) -> EmployeeSkillInDB:
    """构建EmployeeSkillInDB对象，包含关联信息"""
    # 获取技能信息
    skill = db.query(Skill).filter(Skill.id == db_emp_skill.skill_id).first()
    skill_name = skill.name if skill else None
    skill_category = skill.category.value if skill else None
    
    # 获取员工信息
    employee = db.query(Employee).filter(Employee.id == db_emp_skill.employee_id).first()
    employee_name = employee.name if employee else None
    
    # 获取评估人信息
    assessor_name = None
    if db_emp_skill.assessed_by:
        assessor = db.query(Employee).filter(Employee.id == db_emp_skill.assessed_by).first()
        if assessor:
            assessor_name = assessor.name
    
    return EmployeeSkillInDB(
        **db_emp_skill.__dict__,
        skill_name=skill_name,
        skill_category=skill_category,
        employee_name=employee_name,
        assessor_name=assessor_name
    )


def _record_assessment_history(emp_skill_id: int, previous_level: Optional[SkillLevel],
                              new_level: SkillLevel, assessed_by: Optional[int],
                              assessment_method: str, db: Session,
                              assessment_notes: Optional[str] = None):
    """记录技能评估历史"""
    if not assessed_by:
        return
    
    history = SkillAssessmentHistory(
        employee_skill_id=emp_skill_id,
        previous_level=previous_level,
        new_level=new_level,
        assessed_by=assessed_by,
        assessment_method=assessment_method,
        assessment_notes=assessment_notes
    )
    
    db.add(history)
    db.commit()


def _analyze_skill_coverage(employees: List[Employee], db: Session) -> List[dict]:
    """分析技能覆盖情况"""
    # 获取所有技能
    all_skills = db.query(Skill).filter(Skill.is_active == 1).all()
    
    coverage = []
    for skill in all_skills:
        # 统计有此技能的员工数
        skilled_employees = db.query(EmployeeSkill).filter(
            and_(
                EmployeeSkill.skill_id == skill.id,
                EmployeeSkill.employee_id.in_([emp.id for emp in employees])
            )
        ).count()
        
        coverage_rate = (skilled_employees / len(employees)) * 100 if employees else 0
        
        coverage.append({
            "skill_id": skill.id,
            "skill_name": skill.name,
            "category": skill.category.value,
            "skilled_employees": skilled_employees,
            "total_employees": len(employees),
            "coverage_rate": coverage_rate
        })
    
    return sorted(coverage, key=lambda x: x["coverage_rate"], reverse=True)


def _analyze_skill_gaps(employees: List[Employee], db: Session) -> List[dict]:
    """分析技能差距"""
    # 这里可以根据职位要求分析技能差距
    # 简化实现：找出覆盖率低的技能
    coverage = _analyze_skill_coverage(employees, db)
    
    gaps = []
    for skill_info in coverage:
        if skill_info["coverage_rate"] < 50:  # 覆盖率低于50%认为有差距
            gaps.append({
                "skill_name": skill_info["skill_name"],
                "current_coverage": skill_info["coverage_rate"],
                "gap_severity": "高" if skill_info["coverage_rate"] < 20 else "中",
                "recommended_action": "需要培训或招聘"
            })
    
    return gaps


def _generate_skill_recommendations(skill_coverage: List[dict], skill_gaps: List[dict]) -> List[str]:
    """生成技能改进建议"""
    recommendations = []
    
    # 基于技能差距生成建议
    high_gap_skills = [gap for gap in skill_gaps if gap.get("gap_severity") == "高"]
    if high_gap_skills:
        recommendations.append(f"紧急需要加强以下技能培训：{', '.join([skill['skill_name'] for skill in high_gap_skills[:3]])}")
    
    # 基于覆盖率生成建议
    low_coverage_skills = [skill for skill in skill_coverage if skill["coverage_rate"] < 30]
    if low_coverage_skills:
        recommendations.append("建议组织技能培训或考虑外部招聘来提升团队整体技能水平")
    
    # 通用建议
    if not recommendations:
        recommendations.append("团队技能覆盖情况良好，建议继续保持并关注新技术发展")
    
    return recommendations