from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional

from config.database import get_db
from .models import (
    TaskCreate, TaskUpdate, TaskInDB, TaskQuery, TaskStatistics,
    TaskAssign, SmartAssignmentRequest, SmartAssignmentResponse, TaskListResponse
)
from .service import (
    create_task, get_task, update_task, delete_task, assign_task,
    get_tasks, get_task_statistics, smart_assign_task
)

router = APIRouter(prefix="/api/tasks", tags=["任务管理"])


@router.post("/", response_model=TaskInDB, summary="创建任务")
async def create_task_endpoint(
    task: TaskCreate,
    db: Session = Depends(get_db)
):
    """创建新任务"""
    try:
        return create_task(task, db)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{task_id}", response_model=TaskInDB, summary="获取任务详情")
async def get_task_endpoint(
    task_id: int,
    db: Session = Depends(get_db)
):
    """获取指定ID的任务详情"""
    task = get_task(task_id, db)
    if task is None:
        raise HTTPException(status_code=404, detail="任务不存在")
    return task


@router.put("/{task_id}", response_model=TaskInDB, summary="更新任务")
async def update_task_endpoint(
    task_id: int,
    task_update: TaskUpdate,
    db: Session = Depends(get_db)
):
    """更新任务信息"""
    task = update_task(task_id, task_update, db)
    if task is None:
        raise HTTPException(status_code=404, detail="任务不存在")
    return task


@router.delete("/{task_id}", summary="删除任务")
async def delete_task_endpoint(
    task_id: int,
    db: Session = Depends(get_db)
):
    """删除任务"""
    success = delete_task(task_id, db)
    if not success:
        raise HTTPException(status_code=404, detail="任务不存在")
    return {"message": "任务删除成功"}


@router.post("/{task_id}/assign", response_model=TaskInDB, summary="分配任务")
async def assign_task_endpoint(
    task_id: int,
    assignment: TaskAssign,
    db: Session = Depends(get_db)
):
    """分配任务给指定员工"""
    try:
        return assign_task(task_id, assignment, db)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/", response_model=TaskListResponse, summary="获取任务列表")
async def get_tasks_endpoint(
    assignee_id: Optional[int] = Query(None, description="指派人员ID"),
    assigner_id: Optional[int] = Query(None, description="分配者ID"),
    status: Optional[str] = Query(None, description="任务状态"),
    priority: Optional[str] = Query(None, description="任务优先级"),
    difficulty: Optional[str] = Query(None, description="任务难度"),
    department_id: Optional[int] = Query(None, description="所属部门ID"),
    keyword: Optional[str] = Query(None, description="关键词搜索"),
    page: int = Query(1, ge=1, description="页码"),
    page_size: int = Query(20, ge=1, le=100, description="每页数量"),
    db: Session = Depends(get_db)
):
    """获取任务列表，支持多种过滤条件"""
    query = TaskQuery(
        assignee_id=assignee_id,
        assigner_id=assigner_id,
        status=status,
        priority=priority,
        difficulty=difficulty,
        department_id=department_id,
        keyword=keyword,
        page=page,
        page_size=page_size
    )
    
    result = get_tasks(query, db)
    return TaskListResponse(**result)


@router.get("/statistics/overview", response_model=TaskStatistics, summary="获取任务统计")
async def get_task_statistics_endpoint(
    employee_id: Optional[int] = Query(None, description="员工ID"),
    department_id: Optional[int] = Query(None, description="部门ID"),
    db: Session = Depends(get_db)
):
    """获取任务统计信息"""
    return get_task_statistics(db, employee_id, department_id)


@router.post("/smart-assign", response_model=SmartAssignmentResponse, summary="智能任务分配")
async def smart_assign_task_endpoint(
    request: SmartAssignmentRequest,
    db: Session = Depends(get_db)
):
    """基于技能和工作负载的智能任务分配"""
    try:
        return smart_assign_task(request, db)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/employee/{employee_id}/workload", summary="获取员工工作负载")
async def get_employee_workload(
    employee_id: int,
    db: Session = Depends(get_db)
):
    """获取指定员工的工作负载信息"""
    from models.task import Task, TaskStatus
    from sqlalchemy import and_
    
    # 获取员工当前任务
    current_tasks = db.query(Task).filter(
        and_(
            Task.assignee_id == employee_id,
            Task.status.in_([TaskStatus.ASSIGNED, TaskStatus.IN_PROGRESS])
        )
    ).all()
    
    # 计算工作负载
    total_estimated_hours = sum([task.estimated_hours or 0 for task in current_tasks])
    task_count = len(current_tasks)
    
    # 按优先级分组
    priority_stats = {}
    for task in current_tasks:
        priority = task.priority.value
        if priority not in priority_stats:
            priority_stats[priority] = 0
        priority_stats[priority] += 1
    
    return {
        "employee_id": employee_id,
        "current_task_count": task_count,
        "total_estimated_hours": total_estimated_hours,
        "priority_distribution": priority_stats,
        "tasks": [
            {
                "id": task.id,
                "name": task.name,
                "priority": task.priority.value,
                "status": task.status.value,
                "estimated_hours": task.estimated_hours,
                "due_date": task.due_date
            }
            for task in current_tasks
        ]
    }