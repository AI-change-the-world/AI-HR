from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field
from models.task import TaskDifficulty, TaskStatus, TaskPriority


class TaskBase(BaseModel):
    """任务基础模型"""
    name: str = Field(..., description="任务名称")
    description: Optional[str] = Field(None, description="任务详情描述")
    difficulty: TaskDifficulty = Field(TaskDifficulty.MEDIUM, description="任务难度")
    estimated_hours: Optional[int] = Field(None, description="预估工时（小时）")
    priority: TaskPriority = Field(TaskPriority.MEDIUM, description="任务优先级")
    due_date: Optional[datetime] = Field(None, description="截止时间")
    required_skills: Optional[str] = Field(None, description="所需技能（JSON格式）")
    department_id: Optional[int] = Field(None, description="所属部门ID")
    notes: Optional[str] = Field(None, description="备注信息")


class TaskCreate(TaskBase):
    """创建任务模型"""
    assignee_id: Optional[int] = Field(None, description="指派人员ID")
    assigner_id: Optional[int] = Field(None, description="分配者ID")


class TaskUpdate(BaseModel):
    """更新任务模型"""
    name: Optional[str] = Field(None, description="任务名称")
    description: Optional[str] = Field(None, description="任务详情描述")
    difficulty: Optional[TaskDifficulty] = Field(None, description="任务难度")
    estimated_hours: Optional[int] = Field(None, description="预估工时（小时）")
    assignee_id: Optional[int] = Field(None, description="指派人员ID")
    status: Optional[TaskStatus] = Field(None, description="任务状态")
    priority: Optional[TaskPriority] = Field(None, description="任务优先级")
    start_date: Optional[datetime] = Field(None, description="开始时间")
    due_date: Optional[datetime] = Field(None, description="截止时间")
    progress: Optional[int] = Field(None, ge=0, le=100, description="完成进度（0-100）")
    actual_hours: Optional[int] = Field(None, description="实际工时（小时）")
    quality_score: Optional[int] = Field(None, ge=1, le=10, description="质量评分（1-10）")
    required_skills: Optional[str] = Field(None, description="所需技能（JSON格式）")
    department_id: Optional[int] = Field(None, description="所属部门ID")
    notes: Optional[str] = Field(None, description="备注信息")


class TaskAssign(BaseModel):
    """任务分配模型"""
    assignee_id: int = Field(..., description="指派人员ID")
    assigner_id: Optional[int] = Field(None, description="分配者ID")
    start_date: Optional[datetime] = Field(None, description="开始时间")
    due_date: Optional[datetime] = Field(None, description="截止时间")
    notes: Optional[str] = Field(None, description="分配备注")


class TaskInDB(TaskBase):
    """数据库中的任务模型"""
    id: int
    assignee_id: Optional[int] = None
    assigner_id: Optional[int] = None
    status: TaskStatus
    assigned_at: Optional[datetime] = None
    start_date: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    progress: int = 0
    actual_hours: Optional[int] = None
    quality_score: Optional[int] = None
    project_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime

    # 关联信息（通过JOIN查询获得）
    assignee_name: Optional[str] = None
    assigner_name: Optional[str] = None
    department_name: Optional[str] = None

    class Config:
        from_attributes = True


class TaskListResponse(BaseModel):
    """任务列表响应模型"""
    tasks: List[TaskInDB]
    total: int
    page: int
    page_size: int


class TaskStatistics(BaseModel):
    """任务统计模型"""
    total_tasks: int
    pending_tasks: int
    in_progress_tasks: int
    completed_tasks: int
    overdue_tasks: int
    avg_completion_time: Optional[float] = None  # 平均完成时间（天）
    completion_rate: float  # 完成率


class TaskQuery(BaseModel):
    """任务查询参数"""
    assignee_id: Optional[int] = Field(None, description="指派人员ID")
    assigner_id: Optional[int] = Field(None, description="分配者ID")
    status: Optional[TaskStatus] = Field(None, description="任务状态")
    priority: Optional[TaskPriority] = Field(None, description="任务优先级")
    difficulty: Optional[TaskDifficulty] = Field(None, description="任务难度")
    department_id: Optional[int] = Field(None, description="所属部门ID")
    due_date_from: Optional[datetime] = Field(None, description="截止时间起始")
    due_date_to: Optional[datetime] = Field(None, description="截止时间结束")
    keyword: Optional[str] = Field(None, description="关键词搜索")
    page: int = Field(1, ge=1, description="页码")
    page_size: int = Field(20, ge=1, le=100, description="每页数量")


class SmartAssignmentRequest(BaseModel):
    """智能分配请求模型"""
    task_id: int = Field(..., description="任务ID")
    consider_workload: bool = Field(True, description="是否考虑工作负载")
    consider_skills: bool = Field(True, description="是否考虑技能匹配")
    max_candidates: int = Field(5, ge=1, le=10, description="最大候选人数量")


class AssignmentCandidate(BaseModel):
    """分配候选人模型"""
    employee_id: int
    employee_name: str
    department_name: Optional[str] = None
    skill_match_score: float  # 技能匹配分数 (0-1)
    workload_score: float     # 工作负载分数 (0-1)
    overall_score: float      # 综合分数 (0-1)
    current_tasks: int        # 当前任务数量
    reason: str              # 推荐理由


class SmartAssignmentResponse(BaseModel):
    """智能分配响应模型"""
    task_id: int
    task_name: str
    candidates: List[AssignmentCandidate]
    recommendation: Optional[AssignmentCandidate] = None  # 最佳推荐