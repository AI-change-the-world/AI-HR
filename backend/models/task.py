from datetime import datetime
from sqlalchemy import Column, DateTime, Integer, String, Text, ForeignKey, Enum as SQLEnum
from sqlalchemy.sql import func
import enum

from config.database import Base
from models._mixin import ToDictMixin


class TaskDifficulty(enum.Enum):
    """任务难度枚举"""
    VERY_EASY = "very_easy"      # 非常简单 - 1-2小时完成，无需特殊技能
    EASY = "easy"                # 简单 - 半天完成，基础技能即可
    MEDIUM = "medium"            # 中等 - 1-2天完成，需要一定经验
    HARD = "hard"                # 困难 - 3-5天完成，需要高级技能
    VERY_HARD = "very_hard"      # 非常困难 - 1周以上，需要专家级技能


class TaskStatus(enum.Enum):
    """任务状态枚举"""
    PENDING = "pending"          # 待分配
    ASSIGNED = "assigned"        # 已分配
    IN_PROGRESS = "in_progress"  # 进行中
    COMPLETED = "completed"      # 已完成
    CANCELLED = "cancelled"      # 已取消
    OVERDUE = "overdue"         # 已逾期


class TaskPriority(enum.Enum):
    """任务优先级枚举"""
    LOW = "low"                  # 低优先级
    MEDIUM = "medium"            # 中等优先级
    HIGH = "high"                # 高优先级
    URGENT = "urgent"            # 紧急


class Task(Base, ToDictMixin):
    """工作任务模型"""
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True, comment="任务ID")
    name = Column(String(255), nullable=False, comment="任务名称")
    description = Column(Text, nullable=True, comment="任务详情描述")
    
    # 难度相关
    difficulty = Column(
        SQLEnum(TaskDifficulty), 
        nullable=False, 
        default=TaskDifficulty.MEDIUM,
        comment="任务难度"
    )
    estimated_hours = Column(Integer, nullable=True, comment="预估工时（小时）")
    
    # 分配相关
    assignee_id = Column(
        Integer, 
        ForeignKey("employees.id"), 
        nullable=True, 
        comment="指派人员ID"
    )
    assigner_id = Column(
        Integer, 
        ForeignKey("employees.id"), 
        nullable=True, 
        comment="分配者ID"
    )
    
    # 状态和优先级
    status = Column(
        SQLEnum(TaskStatus), 
        nullable=False, 
        default=TaskStatus.PENDING,
        comment="任务状态"
    )
    priority = Column(
        SQLEnum(TaskPriority), 
        nullable=False, 
        default=TaskPriority.MEDIUM,
        comment="任务优先级"
    )
    
    # 时间相关
    assigned_at = Column(DateTime, nullable=True, comment="分配时间")
    start_date = Column(DateTime, nullable=True, comment="开始时间")
    due_date = Column(DateTime, nullable=True, comment="截止时间")
    completed_at = Column(DateTime, nullable=True, comment="完成时间")
    
    # 技能要求
    required_skills = Column(Text, nullable=True, comment="所需技能（JSON格式）")
    
    # 关联信息
    department_id = Column(Integer, nullable=True, comment="所属部门ID")
    project_id = Column(Integer, nullable=True, comment="所属项目ID（预留）")
    
    # 进度和评价
    progress = Column(Integer, default=0, comment="完成进度（0-100）")
    actual_hours = Column(Integer, nullable=True, comment="实际工时（小时）")
    quality_score = Column(Integer, nullable=True, comment="质量评分（1-10）")
    
    # 备注
    notes = Column(Text, nullable=True, comment="备注信息")
    
    # 系统字段
    created_at = Column(DateTime, default=func.now(), comment="创建时间")
    updated_at = Column(
        DateTime, default=func.now(), onupdate=func.now(), comment="更新时间"
    )

    def get_difficulty_description(self) -> str:
        """获取难度描述"""
        difficulty_map = {
            TaskDifficulty.VERY_EASY: "非常简单（1-2小时，无需特殊技能）",
            TaskDifficulty.EASY: "简单（半天，基础技能）",
            TaskDifficulty.MEDIUM: "中等（1-2天，一定经验）",
            TaskDifficulty.HARD: "困难（3-5天，高级技能）",
            TaskDifficulty.VERY_HARD: "非常困难（1周以上，专家级技能）"
        }
        return difficulty_map.get(self.difficulty, "未知难度")

    def is_overdue(self) -> bool:
        """检查任务是否逾期"""
        if not self.due_date:
            return False
        return (
            self.status not in [TaskStatus.COMPLETED, TaskStatus.CANCELLED] 
            and datetime.now() > self.due_date
        )

    def get_duration_days(self) -> int:
        """获取任务持续天数"""
        if not self.start_date or not self.completed_at:
            return 0
        return (self.completed_at - self.start_date).days