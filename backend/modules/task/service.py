import json
from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func

from models.task import Task, TaskStatus, TaskDifficulty
from models.employee import Employee
from models.department import Department
from models.capability import EmployeeSkill, Skill, SkillLevel
from .models import (
    TaskCreate, TaskUpdate, TaskInDB, TaskQuery, TaskStatistics,
    TaskAssign, SmartAssignmentRequest, AssignmentCandidate, SmartAssignmentResponse
)


def create_task(task_create: TaskCreate, db: Session) -> TaskInDB:
    """创建新任务"""
    # 创建任务对象
    task_dict = task_create.dict()
    
    # 如果指定了分配人员，自动设置分配时间和状态
    if task_dict.get("assignee_id"):
        task_dict["assigned_at"] = datetime.now()
        task_dict["status"] = TaskStatus.ASSIGNED
    
    db_task = Task(**task_dict)
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    
    return _build_task_in_db(db_task, db)


def get_task(task_id: int, db: Session) -> Optional[TaskInDB]:
    """获取指定ID的任务"""
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if db_task is None:
        return None
    
    return _build_task_in_db(db_task, db)


def update_task(task_id: int, task_update: TaskUpdate, db: Session) -> Optional[TaskInDB]:
    """更新任务"""
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if db_task is None:
        return None
    
    update_data = task_update.dict(exclude_unset=True)
    
    # 特殊处理状态变更
    if "status" in update_data:
        new_status = update_data["status"]
        if new_status == TaskStatus.COMPLETED and db_task.status != TaskStatus.COMPLETED:
            update_data["completed_at"] = datetime.now()
            if not update_data.get("progress"):
                update_data["progress"] = 100
        elif new_status == TaskStatus.IN_PROGRESS and db_task.status == TaskStatus.ASSIGNED:
            update_data["start_date"] = datetime.now()
    
    # 更新字段
    for field, value in update_data.items():
        setattr(db_task, field, value)
    
    db.commit()
    db.refresh(db_task)
    
    return _build_task_in_db(db_task, db)


def delete_task(task_id: int, db: Session) -> bool:
    """删除任务"""
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if db_task is None:
        return False
    
    db.delete(db_task)
    db.commit()
    return True


def assign_task(task_id: int, assignment: TaskAssign, db: Session) -> Optional[TaskInDB]:
    """分配任务"""
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if db_task is None:
        return None
    
    # 检查被分配人是否存在
    assignee = db.query(Employee).filter(Employee.id == assignment.assignee_id).first()
    if assignee is None:
        raise ValueError("指定的员工不存在")
    
    # 更新任务分配信息
    db_task.assignee_id = assignment.assignee_id
    db_task.assigner_id = assignment.assigner_id
    db_task.assigned_at = datetime.now()
    db_task.status = TaskStatus.ASSIGNED
    
    if assignment.start_date:
        db_task.start_date = assignment.start_date
    if assignment.due_date:
        db_task.due_date = assignment.due_date
    if assignment.notes:
        db_task.notes = assignment.notes
    
    db.commit()
    db.refresh(db_task)
    
    return _build_task_in_db(db_task, db)


def get_tasks(query: TaskQuery, db: Session) -> Dict[str, Any]:
    """获取任务列表"""
    # 构建查询
    db_query = db.query(Task)
    
    # 添加过滤条件
    if query.assignee_id:
        db_query = db_query.filter(Task.assignee_id == query.assignee_id)
    if query.assigner_id:
        db_query = db_query.filter(Task.assigner_id == query.assigner_id)
    if query.status:
        db_query = db_query.filter(Task.status == query.status)
    if query.priority:
        db_query = db_query.filter(Task.priority == query.priority)
    if query.difficulty:
        db_query = db_query.filter(Task.difficulty == query.difficulty)
    if query.department_id:
        db_query = db_query.filter(Task.department_id == query.department_id)
    if query.due_date_from:
        db_query = db_query.filter(Task.due_date >= query.due_date_from)
    if query.due_date_to:
        db_query = db_query.filter(Task.due_date <= query.due_date_to)
    if query.keyword:
        keyword_filter = or_(
            Task.name.contains(query.keyword),
            Task.description.contains(query.keyword),
            Task.notes.contains(query.keyword)
        )
        db_query = db_query.filter(keyword_filter)
    
    # 获取总数
    total = db_query.count()
    
    # 分页
    offset = (query.page - 1) * query.page_size
    db_tasks = db_query.order_by(Task.created_at.desc()).offset(offset).limit(query.page_size).all()
    
    # 构建返回数据
    tasks = [_build_task_in_db(task, db) for task in db_tasks]
    
    return {
        "tasks": tasks,
        "total": total,
        "page": query.page,
        "page_size": query.page_size
    }


def get_task_statistics(db: Session, employee_id: Optional[int] = None, 
                       department_id: Optional[int] = None) -> TaskStatistics:
    """获取任务统计信息"""
    # 构建基础查询
    base_query = db.query(Task)
    
    if employee_id:
        base_query = base_query.filter(Task.assignee_id == employee_id)
    if department_id:
        base_query = base_query.filter(Task.department_id == department_id)
    
    # 统计各状态任务数量
    total_tasks = base_query.count()
    pending_tasks = base_query.filter(Task.status == TaskStatus.PENDING).count()
    in_progress_tasks = base_query.filter(Task.status == TaskStatus.IN_PROGRESS).count()
    completed_tasks = base_query.filter(Task.status == TaskStatus.COMPLETED).count()
    
    # 统计逾期任务
    now = datetime.now()
    overdue_tasks = base_query.filter(
        and_(
            Task.due_date < now,
            Task.status.notin_([TaskStatus.COMPLETED, TaskStatus.CANCELLED])
        )
    ).count()
    
    # 计算平均完成时间
    completed_with_duration = base_query.filter(
        and_(
            Task.status == TaskStatus.COMPLETED,
            Task.start_date.isnot(None),
            Task.completed_at.isnot(None)
        )
    ).all()
    
    avg_completion_time = None
    if completed_with_duration:
        total_duration = sum([
            (task.completed_at - task.start_date).days 
            for task in completed_with_duration
        ])
        avg_completion_time = total_duration / len(completed_with_duration)
    
    # 计算完成率
    completion_rate = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0
    
    return TaskStatistics(
        total_tasks=total_tasks,
        pending_tasks=pending_tasks,
        in_progress_tasks=in_progress_tasks,
        completed_tasks=completed_tasks,
        overdue_tasks=overdue_tasks,
        avg_completion_time=avg_completion_time,
        completion_rate=completion_rate
    )


def smart_assign_task(request: SmartAssignmentRequest, db: Session) -> SmartAssignmentResponse:
    """智能任务分配"""
    # 获取任务信息
    task = db.query(Task).filter(Task.id == request.task_id).first()
    if not task:
        raise ValueError("任务不存在")
    
    # 获取所有可分配的员工
    employees = db.query(Employee).filter(Employee.status == 0).all()  # 在职员工
    
    candidates = []
    
    for employee in employees:
        # 计算技能匹配分数
        skill_score = _calculate_skill_match_score(task, employee, db) if request.consider_skills else 0.5
        
        # 计算工作负载分数
        workload_score = _calculate_workload_score(employee, db) if request.consider_workload else 0.5
        
        # 计算综合分数
        overall_score = (skill_score * 0.6 + workload_score * 0.4)
        
        # 获取当前任务数量
        current_tasks = db.query(Task).filter(
            and_(
                Task.assignee_id == employee.id,
                Task.status.in_([TaskStatus.ASSIGNED, TaskStatus.IN_PROGRESS])
            )
        ).count()
        
        # 生成推荐理由
        reason = _generate_assignment_reason(skill_score, workload_score, current_tasks)
        
        candidate = AssignmentCandidate(
            employee_id=employee.id,
            employee_name=employee.name,
            department_name=_get_department_name(employee.department_id, db),
            skill_match_score=skill_score,
            workload_score=workload_score,
            overall_score=overall_score,
            current_tasks=current_tasks,
            reason=reason
        )
        candidates.append(candidate)
    
    # 按综合分数排序
    candidates.sort(key=lambda x: x.overall_score, reverse=True)
    
    # 取前N个候选人
    top_candidates = candidates[:request.max_candidates]
    
    # 最佳推荐
    recommendation = top_candidates[0] if top_candidates else None
    
    return SmartAssignmentResponse(
        task_id=task.id,
        task_name=task.name,
        candidates=top_candidates,
        recommendation=recommendation
    )


def _build_task_in_db(db_task: Task, db: Session) -> TaskInDB:
    """构建TaskInDB对象，包含关联信息"""
    # 获取分配人员信息
    assignee_name = None
    if db_task.assignee_id:
        assignee = db.query(Employee).filter(Employee.id == db_task.assignee_id).first()
        if assignee:
            assignee_name = assignee.name
    
    # 获取分配者信息
    assigner_name = None
    if db_task.assigner_id:
        assigner = db.query(Employee).filter(Employee.id == db_task.assigner_id).first()
        if assigner:
            assigner_name = assigner.name
    
    # 获取部门信息
    department_name = _get_department_name(db_task.department_id, db)
    
    return TaskInDB(
        **db_task.__dict__,
        assignee_name=assignee_name,
        assigner_name=assigner_name,
        department_name=department_name
    )


def _get_department_name(department_id: Optional[int], db: Session) -> Optional[str]:
    """获取部门名称"""
    if not department_id:
        return None
    
    department = db.query(Department).filter(Department.id == department_id).first()
    return department.name if department else None


def _calculate_skill_match_score(task: Task, employee: Employee, db: Session) -> float:
    """计算技能匹配分数"""
    if not task.required_skills:
        return 0.5  # 没有技能要求时返回中等分数
    
    try:
        required_skills = json.loads(task.required_skills)
    except:
        return 0.5
    
    if not required_skills:
        return 0.5
    
    # 获取员工技能
    employee_skills = db.query(EmployeeSkill).filter(
        EmployeeSkill.employee_id == employee.id
    ).all()
    
    if not employee_skills:
        return 0.1  # 没有技能记录
    
    # 计算匹配分数
    total_score = 0
    matched_skills = 0
    
    for required_skill in required_skills:
        skill_name = required_skill.get("name", "")
        required_level = required_skill.get("level", "C")
        
        # 查找对应的技能
        skill = db.query(Skill).filter(Skill.name == skill_name).first()
        if not skill:
            continue
        
        # 查找员工是否有这个技能
        emp_skill = next((es for es in employee_skills if es.skill_id == skill.id), None)
        if emp_skill:
            # 计算等级匹配分数
            required_score = EmployeeSkill.get_level_score_static(SkillLevel(required_level))
            actual_score = emp_skill.get_level_score()
            
            if actual_score >= required_score:
                total_score += 1.0  # 完全匹配
            else:
                total_score += actual_score / required_score  # 部分匹配
            
            matched_skills += 1
    
    if matched_skills == 0:
        return 0.1
    
    return min(total_score / len(required_skills), 1.0)


def _calculate_workload_score(employee: Employee, db: Session) -> float:
    """计算工作负载分数（分数越高表示负载越轻）"""
    # 获取当前进行中的任务数量
    current_tasks = db.query(Task).filter(
        and_(
            Task.assignee_id == employee.id,
            Task.status.in_([TaskStatus.ASSIGNED, TaskStatus.IN_PROGRESS])
        )
    ).count()
    
    # 根据任务数量计算负载分数
    if current_tasks == 0:
        return 1.0
    elif current_tasks <= 2:
        return 0.8
    elif current_tasks <= 4:
        return 0.6
    elif current_tasks <= 6:
        return 0.4
    else:
        return 0.2


def _generate_assignment_reason(skill_score: float, workload_score: float, current_tasks: int) -> str:
    """生成分配推荐理由"""
    reasons = []
    
    if skill_score >= 0.8:
        reasons.append("技能高度匹配")
    elif skill_score >= 0.6:
        reasons.append("技能较好匹配")
    elif skill_score >= 0.4:
        reasons.append("技能基本匹配")
    else:
        reasons.append("技能匹配度较低")
    
    if workload_score >= 0.8:
        reasons.append("工作负载较轻")
    elif workload_score >= 0.6:
        reasons.append("工作负载适中")
    else:
        reasons.append("工作负载较重")
    
    reasons.append(f"当前有{current_tasks}个进行中任务")
    
    return "；".join(reasons)