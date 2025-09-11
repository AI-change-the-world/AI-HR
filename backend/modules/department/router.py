from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from config.database import get_db
from modules import BaseResponse, PageResponse

from .models import DepartmentCreate, DepartmentInDB, DepartmentUpdate
from .service import (
    create_department,
    delete_department,
    get_department,
    get_departments,
    update_department,
)

router = APIRouter(prefix="/api/departments", tags=["部门管理"])


@router.post("/", response_model=BaseResponse[DepartmentInDB])
async def create_department_info(
    department: DepartmentCreate, db: Session = Depends(get_db)
):
    """创建部门"""
    try:
        result = create_department(department, db)
        return BaseResponse(data=result)
    except Exception as e:
        return BaseResponse(code=500, message=f"创建部门失败: {str(e)}", data=None)


@router.get("/{department_id}", response_model=BaseResponse[DepartmentInDB])
async def read_department(department_id: int, db: Session = Depends(get_db)):
    """获取部门详情"""
    try:
        department = get_department(department_id, db)
        if department is None:
            return BaseResponse(code=404, message="部门未找到", data=None)
        return BaseResponse(data=department)
    except Exception as e:
        return BaseResponse(code=500, message=f"获取部门失败: {str(e)}", data=None)


@router.get("/", response_model=BaseResponse[list[DepartmentInDB]])
async def read_departments(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
):
    """获取部门列表"""
    try:
        departments = get_departments(skip=skip, limit=limit, db=db)
        return BaseResponse(data=departments)
    except Exception as e:
        return BaseResponse(code=500, message=f"获取部门列表失败: {str(e)}", data=None)


@router.put("/{department_id}", response_model=DepartmentInDB)
async def update_department_info(
    department_id: int,
    department_update: DepartmentUpdate,
    db: Session = Depends(get_db),
):
    """更新部门信息"""
    department = update_department(department_id, department_update, db)
    if department is None:
        raise HTTPException(status_code=404, detail="部门未找到")
    return department


@router.delete("/{department_id}")
async def delete_department_info(department_id: int, db: Session = Depends(get_db)):
    """删除部门"""
    success = delete_department(department_id, db)
    if not success:
        raise HTTPException(status_code=404, detail="部门未找到")
    return {"message": "部门删除成功"}
