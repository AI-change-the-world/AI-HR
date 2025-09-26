from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field
from models.capability import SkillLevel, SkillCategory


class SkillBase(BaseModel):
    """技能基础模型"""
    name: str = Field(..., description="技能名称")
    category: SkillCategory = Field(SkillCategory.TECHNICAL, description="技能分类")
    description: Optional[str] = Field(None, description="技能描述")
    level_d_criteria: Optional[str] = Field(None, description="D级标准")
    level_c_criteria: Optional[str] = Field(None, description="C级标准")
    level_b_criteria: Optional[str] = Field(None, description="B级标准")
    level_a_criteria: Optional[str] = Field(None, description="A级标准")
    level_s_criteria: Optional[str] = Field(None, description="S级标准")


class SkillCreate(SkillBase):
    """创建技能模型"""
    pass


class SkillUpdate(BaseModel):
    """更新技能模型"""
    name: Optional[str] = Field(None, description="技能名称")
    category: Optional[SkillCategory] = Field(None, description="技能分类")
    description: Optional[str] = Field(None, description="技能描述")
    level_d_criteria: Optional[str] = Field(None, description="D级标准")
    level_c_criteria: Optional[str] = Field(None, description="C级标准")
    level_b_criteria: Optional[str] = Field(None, description="B级标准")
    level_a_criteria: Optional[str] = Field(None, description="A级标准")
    level_s_criteria: Optional[str] = Field(None, description="S级标准")
    is_active: Optional[int] = Field(None, description="是否启用")


class SkillInDB(SkillBase):
    """数据库中的技能模型"""
    id: int
    is_active: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class EmployeeSkillBase(BaseModel):
    """员工技能基础模型"""
    employee_id: int = Field(..., description="员工ID")
    skill_id: int = Field(..., description="技能ID")
    level: SkillLevel = Field(..., description="技能等级")
    assessment_notes: Optional[str] = Field(None, description="评估备注")
    evidence: Optional[str] = Field(None, description="证明材料")
    years_experience: Optional[int] = Field(None, description="相关经验年数")
    target_level: Optional[SkillLevel] = Field(None, description="目标等级")
    learning_plan: Optional[str] = Field(None, description="学习计划")
    next_review_date: Optional[datetime] = Field(None, description="下次评估日期")


class EmployeeSkillCreate(EmployeeSkillBase):
    """创建员工技能模型"""
    assessed_by: Optional[int] = Field(None, description="评估人ID")


class EmployeeSkillUpdate(BaseModel):
    """更新员工技能模型"""
    level: Optional[SkillLevel] = Field(None, description="技能等级")
    assessment_notes: Optional[str] = Field(None, description="评估备注")
    evidence: Optional[str] = Field(None, description="证明材料")
    years_experience: Optional[int] = Field(None, description="相关经验年数")
    target_level: Optional[SkillLevel] = Field(None, description="目标等级")
    learning_plan: Optional[str] = Field(None, description="学习计划")
    next_review_date: Optional[datetime] = Field(None, description="下次评估日期")
    assessed_by: Optional[int] = Field(None, description="评估人ID")


class EmployeeSkillInDB(EmployeeSkillBase):
    """数据库中的员工技能模型"""
    id: int
    assessed_by: Optional[int] = None
    assessment_date: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    
    # 关联信息
    skill_name: Optional[str] = None
    skill_category: Optional[str] = None
    employee_name: Optional[str] = None
    assessor_name: Optional[str] = None

    class Config:
        from_attributes = True


class EmployeeSkillMatrix(BaseModel):
    """员工技能矩阵"""
    employee_id: int
    employee_name: str
    department_name: Optional[str] = None
    skills: List[EmployeeSkillInDB]
    skill_summary: dict  # 按分类汇总的技能统计


class SkillGapAnalysis(BaseModel):
    """技能差距分析"""
    skill_id: int
    skill_name: str
    required_level: SkillLevel
    current_level: Optional[SkillLevel] = None
    gap_level: int  # 差距等级数
    improvement_needed: bool


class TeamSkillAnalysis(BaseModel):
    """团队技能分析"""
    department_id: Optional[int] = None
    department_name: Optional[str] = None
    total_employees: int
    skill_coverage: List[dict]  # 技能覆盖情况
    skill_gaps: List[SkillGapAnalysis]  # 技能差距
    recommendations: List[str]  # 改进建议


class SkillAssessmentRequest(BaseModel):
    """技能评估请求"""
    employee_id: int = Field(..., description="员工ID")
    skill_id: int = Field(..., description="技能ID")
    new_level: SkillLevel = Field(..., description="新等级")
    assessment_notes: Optional[str] = Field(None, description="评估说明")
    assessment_method: Optional[str] = Field(None, description="评估方式")
    assessed_by: int = Field(..., description="评估人ID")


class SkillDevelopmentPlan(BaseModel):
    """技能发展计划"""
    employee_id: int
    employee_name: str
    current_skills: List[EmployeeSkillInDB]
    development_goals: List[dict]  # 发展目标
    learning_resources: List[dict]  # 学习资源
    timeline: dict  # 时间规划
    milestones: List[dict]  # 里程碑


class SkillQuery(BaseModel):
    """技能查询参数"""
    employee_id: Optional[int] = Field(None, description="员工ID")
    skill_id: Optional[int] = Field(None, description="技能ID")
    category: Optional[SkillCategory] = Field(None, description="技能分类")
    level: Optional[SkillLevel] = Field(None, description="技能等级")
    department_id: Optional[int] = Field(None, description="部门ID")
    keyword: Optional[str] = Field(None, description="关键词搜索")
    page: int = Field(1, ge=1, description="页码")
    page_size: int = Field(20, ge=1, le=100, description="每页数量")


class SkillStatistics(BaseModel):
    """技能统计"""
    total_skills: int
    total_employee_skills: int
    skill_distribution: dict  # 按分类的技能分布
    level_distribution: dict  # 按等级的分布
    top_skills: List[dict]  # 最受欢迎的技能
    skill_trends: List[dict]  # 技能趋势