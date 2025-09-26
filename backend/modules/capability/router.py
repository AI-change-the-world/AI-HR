from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional, List

from config.database import get_db
from models.capability import SkillCategory, SkillLevel
from .models import (
    SkillCreate, SkillUpdate, SkillInDB, EmployeeSkillCreate, EmployeeSkillUpdate,
    EmployeeSkillInDB, EmployeeSkillMatrix, SkillStatistics, SkillAssessmentRequest,
    TeamSkillAnalysis
)
from .service import (
    create_skill, get_skill, update_skill, delete_skill, get_skills,
    create_employee_skill, update_employee_skill, get_employee_skills,
    get_employee_skill_matrix, assess_employee_skill, get_team_skill_analysis,
    get_skill_statistics
)

router = APIRouter(prefix="/api/capabilities", tags=["能力管理"])


# 技能管理接口
@router.post("/skills", response_model=SkillInDB, summary="创建技能")
async def create_skill_endpoint(
    skill: SkillCreate,
    db: Session = Depends(get_db)
):
    """创建新技能定义"""
    try:
        return create_skill(skill, db)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/skills/{skill_id}", response_model=SkillInDB, summary="获取技能详情")
async def get_skill_endpoint(
    skill_id: int,
    db: Session = Depends(get_db)
):
    """获取指定ID的技能详情"""
    skill = get_skill(skill_id, db)
    if skill is None:
        raise HTTPException(status_code=404, detail="技能不存在")
    return skill


@router.put("/skills/{skill_id}", response_model=SkillInDB, summary="更新技能")
async def update_skill_endpoint(
    skill_id: int,
    skill_update: SkillUpdate,
    db: Session = Depends(get_db)
):
    """更新技能信息"""
    skill = update_skill(skill_id, skill_update, db)
    if skill is None:
        raise HTTPException(status_code=404, detail="技能不存在")
    return skill


@router.delete("/skills/{skill_id}", summary="删除技能")
async def delete_skill_endpoint(
    skill_id: int,
    db: Session = Depends(get_db)
):
    """删除技能（软删除）"""
    success = delete_skill(skill_id, db)
    if not success:
        raise HTTPException(status_code=404, detail="技能不存在")
    return {"message": "技能删除成功"}


@router.get("/skills", summary="获取技能列表")
async def get_skills_endpoint(
    category: Optional[SkillCategory] = Query(None, description="技能分类"),
    keyword: Optional[str] = Query(None, description="关键词搜索"),
    page: int = Query(1, ge=1, description="页码"),
    page_size: int = Query(20, ge=1, le=100, description="每页数量"),
    db: Session = Depends(get_db)
):
    """获取技能列表"""
    return get_skills(category, keyword, page, page_size, db)


# 员工技能管理接口
@router.post("/employee-skills", response_model=EmployeeSkillInDB, summary="创建员工技能记录")
async def create_employee_skill_endpoint(
    emp_skill: EmployeeSkillCreate,
    db: Session = Depends(get_db)
):
    """为员工添加技能记录"""
    try:
        return create_employee_skill(emp_skill, db)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/employee-skills/{emp_skill_id}", response_model=EmployeeSkillInDB, summary="更新员工技能")
async def update_employee_skill_endpoint(
    emp_skill_id: int,
    emp_skill_update: EmployeeSkillUpdate,
    db: Session = Depends(get_db)
):
    """更新员工技能信息"""
    emp_skill = update_employee_skill(emp_skill_id, emp_skill_update, db)
    if emp_skill is None:
        raise HTTPException(status_code=404, detail="员工技能记录不存在")
    return emp_skill


@router.get("/employees/{employee_id}/skills", response_model=List[EmployeeSkillInDB], summary="获取员工技能列表")
async def get_employee_skills_endpoint(
    employee_id: int,
    db: Session = Depends(get_db)
):
    """获取指定员工的所有技能"""
    return get_employee_skills(employee_id, db)


@router.get("/employees/{employee_id}/skill-matrix", response_model=EmployeeSkillMatrix, summary="获取员工技能矩阵")
async def get_employee_skill_matrix_endpoint(
    employee_id: int,
    db: Session = Depends(get_db)
):
    """获取员工技能矩阵"""
    try:
        return get_employee_skill_matrix(employee_id, db)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/assessments", response_model=EmployeeSkillInDB, summary="评估员工技能")
async def assess_employee_skill_endpoint(
    assessment: SkillAssessmentRequest,
    db: Session = Depends(get_db)
):
    """评估员工技能等级"""
    try:
        return assess_employee_skill(assessment, db)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# 分析和统计接口
@router.get("/statistics", response_model=SkillStatistics, summary="获取技能统计")
async def get_skill_statistics_endpoint(
    db: Session = Depends(get_db)
):
    """获取技能统计信息"""
    return get_skill_statistics(db)


@router.get("/team-analysis", response_model=TeamSkillAnalysis, summary="获取团队技能分析")
async def get_team_skill_analysis_endpoint(
    department_id: Optional[int] = Query(None, description="部门ID"),
    db: Session = Depends(get_db)
):
    """获取团队技能分析"""
    return get_team_skill_analysis(department_id, db)


@router.get("/skill-levels", summary="获取技能等级说明")
async def get_skill_levels():
    """获取技能等级定义和说明"""
    return {
        "levels": [
            {
                "level": "D",
                "name": "初学者",
                "description": "了解基础概念，需要指导",
                "score": 1
            },
            {
                "level": "C", 
                "name": "入门级",
                "description": "能完成简单任务，偶尔需要帮助",
                "score": 2
            },
            {
                "level": "B",
                "name": "熟练级", 
                "description": "能独立完成大部分工作",
                "score": 3
            },
            {
                "level": "A",
                "name": "高级",
                "description": "能处理复杂问题，指导他人",
                "score": 4
            },
            {
                "level": "S",
                "name": "专家级",
                "description": "领域专家，能创新和优化",
                "score": 5
            }
        ]
    }


@router.get("/skill-categories", summary="获取技能分类")
async def get_skill_categories():
    """获取技能分类列表"""
    return {
        "categories": [
            {
                "value": "technical",
                "label": "技术技能",
                "description": "编程、开发、技术工具等"
            },
            {
                "value": "management",
                "label": "管理技能", 
                "description": "项目管理、团队管理、领导力等"
            },
            {
                "value": "communication",
                "label": "沟通技能",
                "description": "演讲、写作、协调等"
            },
            {
                "value": "design",
                "label": "设计技能",
                "description": "UI/UX设计、平面设计等"
            },
            {
                "value": "business",
                "label": "业务技能",
                "description": "业务分析、市场营销、销售等"
            },
            {
                "value": "language",
                "label": "语言技能",
                "description": "外语能力、翻译等"
            },
            {
                "value": "other",
                "label": "其他技能",
                "description": "其他专业技能"
            }
        ]
    }


@router.get("/employees/{employee_id}/skill-gaps", summary="获取员工技能差距分析")
async def get_employee_skill_gaps(
    employee_id: int,
    target_position: Optional[str] = Query(None, description="目标职位"),
    db: Session = Depends(get_db)
):
    """分析员工技能差距"""
    # 这里可以根据目标职位的JD要求分析技能差距
    # 简化实现：返回基本的技能分析
    
    employee_skills = get_employee_skills(employee_id, db)
    
    # 按分类统计技能
    skill_by_category = {}
    for skill in employee_skills:
        category = skill.skill_category or "其他"
        if category not in skill_by_category:
            skill_by_category[category] = []
        skill_by_category[category].append({
            "skill_name": skill.skill_name,
            "current_level": skill.level.value,
            "target_level": skill.target_level.value if skill.target_level else None,
            "gap": skill.target_level.value if skill.target_level and skill.target_level != skill.level else None
        })
    
    return {
        "employee_id": employee_id,
        "target_position": target_position,
        "skill_analysis": skill_by_category,
        "recommendations": [
            "建议加强技术技能的学习和实践",
            "可以考虑参加相关培训课程",
            "寻找导师进行指导"
        ]
    }