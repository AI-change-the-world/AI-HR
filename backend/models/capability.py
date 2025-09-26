from datetime import datetime
from sqlalchemy import Column, DateTime, Integer, String, Text, ForeignKey, Enum as SQLEnum, UniqueConstraint
from sqlalchemy.sql import func
import enum

from config.database import Base
from models._mixin import ToDictMixin


class SkillLevel(enum.Enum):
    """技能等级枚举"""
    D = "D"  # 初学者 - 了解基础概念，需要指导
    C = "C"  # 入门级 - 能完成简单任务，偶尔需要帮助
    B = "B"  # 熟练级 - 能独立完成大部分工作
    A = "A"  # 高级 - 能处理复杂问题，指导他人
    S = "S"  # 专家级 - 领域专家，能创新和优化


class SkillCategory(enum.Enum):
    """技能分类枚举"""
    TECHNICAL = "technical"        # 技术技能
    MANAGEMENT = "management"      # 管理技能
    COMMUNICATION = "communication"  # 沟通技能
    DESIGN = "design"             # 设计技能
    BUSINESS = "business"         # 业务技能
    LANGUAGE = "language"         # 语言技能
    OTHER = "other"               # 其他技能


class Skill(Base, ToDictMixin):
    """技能定义模型"""
    __tablename__ = "skills"

    id = Column(Integer, primary_key=True, index=True, comment="技能ID")
    name = Column(String(100), nullable=False, unique=True, comment="技能名称")
    category = Column(
        SQLEnum(SkillCategory), 
        nullable=False, 
        default=SkillCategory.TECHNICAL,
        comment="技能分类"
    )
    description = Column(Text, nullable=True, comment="技能描述")
    
    # 等级标准定义
    level_d_criteria = Column(Text, nullable=True, comment="D级标准")
    level_c_criteria = Column(Text, nullable=True, comment="C级标准")
    level_b_criteria = Column(Text, nullable=True, comment="B级标准")
    level_a_criteria = Column(Text, nullable=True, comment="A级标准")
    level_s_criteria = Column(Text, nullable=True, comment="S级标准")
    
    # 系统字段
    is_active = Column(Integer, default=1, comment="是否启用")
    created_at = Column(DateTime, default=func.now(), comment="创建时间")
    updated_at = Column(
        DateTime, default=func.now(), onupdate=func.now(), comment="更新时间"
    )

    def get_level_criteria(self, level: SkillLevel) -> str:
        """获取指定等级的标准描述"""
        criteria_map = {
            SkillLevel.D: self.level_d_criteria,
            SkillLevel.C: self.level_c_criteria,
            SkillLevel.B: self.level_b_criteria,
            SkillLevel.A: self.level_a_criteria,
            SkillLevel.S: self.level_s_criteria,
        }
        return criteria_map.get(level, "")


class EmployeeSkill(Base, ToDictMixin):
    """员工技能关联模型"""
    __tablename__ = "employee_skills"

    id = Column(Integer, primary_key=True, index=True, comment="记录ID")
    employee_id = Column(
        Integer, 
        ForeignKey("employees.id"), 
        nullable=False, 
        comment="员工ID"
    )
    skill_id = Column(
        Integer, 
        ForeignKey("skills.id"), 
        nullable=False, 
        comment="技能ID"
    )
    level = Column(
        SQLEnum(SkillLevel), 
        nullable=False, 
        comment="技能等级"
    )
    
    # 评估信息
    assessed_by = Column(
        Integer, 
        ForeignKey("employees.id"), 
        nullable=True, 
        comment="评估人ID"
    )
    assessment_date = Column(DateTime, nullable=True, comment="评估日期")
    assessment_notes = Column(Text, nullable=True, comment="评估备注")
    
    # 证明材料
    evidence = Column(Text, nullable=True, comment="证明材料（项目经验、证书等）")
    years_experience = Column(Integer, nullable=True, comment="相关经验年数")
    
    # 学习计划
    target_level = Column(
        SQLEnum(SkillLevel), 
        nullable=True, 
        comment="目标等级"
    )
    learning_plan = Column(Text, nullable=True, comment="学习计划")
    next_review_date = Column(DateTime, nullable=True, comment="下次评估日期")
    
    # 系统字段
    created_at = Column(DateTime, default=func.now(), comment="创建时间")
    updated_at = Column(
        DateTime, default=func.now(), onupdate=func.now(), comment="更新时间"
    )

    # 唯一约束：一个员工的同一技能只能有一条记录
    __table_args__ = (
        UniqueConstraint('employee_id', 'skill_id', name='uk_employee_skill'),
    )

    def get_level_description(self) -> str:
        """获取等级描述"""
        level_map = {
            SkillLevel.D: "D级 - 初学者（了解基础概念，需要指导）",
            SkillLevel.C: "C级 - 入门级（能完成简单任务，偶尔需要帮助）",
            SkillLevel.B: "B级 - 熟练级（能独立完成大部分工作）",
            SkillLevel.A: "A级 - 高级（能处理复杂问题，指导他人）",
            SkillLevel.S: "S级 - 专家级（领域专家，能创新和优化）"
        }
        return level_map.get(self.level, "未知等级")

    def get_level_score(self) -> int:
        """获取等级对应的数值分数（用于计算）"""
        score_map = {
            SkillLevel.D: 1,
            SkillLevel.C: 2,
            SkillLevel.B: 3,
            SkillLevel.A: 4,
            SkillLevel.S: 5
        }
        return score_map.get(self.level, 0)

    def can_upgrade_to(self, target_level: SkillLevel) -> bool:
        """检查是否可以升级到目标等级"""
        current_score = self.get_level_score()
        target_score = EmployeeSkill.get_level_score_static(target_level)
        return target_score > current_score

    @staticmethod
    def get_level_score_static(level: SkillLevel) -> int:
        """静态方法：获取等级对应的数值分数"""
        score_map = {
            SkillLevel.D: 1,
            SkillLevel.C: 2,
            SkillLevel.B: 3,
            SkillLevel.A: 4,
            SkillLevel.S: 5
        }
        return score_map.get(level, 0)


class SkillAssessmentHistory(Base, ToDictMixin):
    """技能评估历史记录"""
    __tablename__ = "skill_assessment_history"

    id = Column(Integer, primary_key=True, index=True, comment="记录ID")
    employee_skill_id = Column(
        Integer, 
        ForeignKey("employee_skills.id"), 
        nullable=False, 
        comment="员工技能ID"
    )
    previous_level = Column(SQLEnum(SkillLevel), nullable=True, comment="之前等级")
    new_level = Column(SQLEnum(SkillLevel), nullable=False, comment="新等级")
    
    assessed_by = Column(
        Integer, 
        ForeignKey("employees.id"), 
        nullable=False, 
        comment="评估人ID"
    )
    assessment_method = Column(String(50), nullable=True, comment="评估方式")
    assessment_notes = Column(Text, nullable=True, comment="评估说明")
    
    created_at = Column(DateTime, default=func.now(), comment="评估时间")