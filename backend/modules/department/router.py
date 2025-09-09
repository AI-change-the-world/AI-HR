from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from .models import DepartmentCreate, DepartmentInDB, DepartmentUpdate
from .service import (create_department, delete_department, get_db,
                      get_department, get_departments, update_department)

router = APIRouter(prefix="/api/departments", tags=["部门管理"])


@router.post("/", response_model=DepartmentInDB)
async def create_department_info(
    department: DepartmentCreate, db: Session = Depends(get_db)
):
    """创建部门"""
    return create_department(department, db)


@router.get("/{department_id}", response_model=DepartmentInDB)
async def read_department(department_id: int, db: Session = Depends(get_db)):
    """获取部门详情"""
    department = get_department(department_id, db)
    if department is None:
        raise HTTPException(status_code=404, detail="部门未找到")
    return department


@router.get("/", response_model=list[DepartmentInDB])
async def read_departments(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
):
    """获取部门列表"""
    return get_departments(skip=skip, limit=limit, db=db)


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
