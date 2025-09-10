from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from config.database import get_db

from .models import EmployeeCreate, EmployeeInDB, EmployeeUpdate
from modules import BaseResponse
from .service import (
    create_employee,
    delete_employee,
    get_employee,
    get_employees,
    update_employee,
)

router = APIRouter(prefix="/api/employees", tags=["员工管理"])


@router.post("/upload", response_class=BaseResponse)
async def upload_resume(file: UploadFile = File(...)):
    """上传处理员工列表
        必须包括以下几个字段 1. 姓名 2. 职位 3. 部门 
        几个要点：
        1. 文件必须为xls或者xlsx格式
        2. 员工可以同名
        3. 如果部门不存在，则需要先创建部门
    """
    if not file.filename.endswith(('.xls', '.xlsx')):
        raise BaseResponse(code=400, message="只支持xls和xlsx格式的文件")
    
    return await process_file(file)


@router.post("/", response_model=EmployeeInDB)
async def create_employee_info(employee: EmployeeCreate, db: Session = Depends(get_db)):
    """创建员工"""
    return create_employee(employee, db)


@router.get("/{employee_id}", response_model=EmployeeInDB)
async def read_employee(employee_id: int, db: Session = Depends(get_db)):
    """获取员工详情"""
    employee = get_employee(employee_id, db)
    if employee is None:
        raise HTTPException(status_code=404, detail="员工未找到")
    return employee


@router.get("/", response_model=list[EmployeeInDB])
async def read_employees(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
):
    """获取员工列表"""
    return get_employees(skip=skip, limit=limit, db=db)


@router.put("/{employee_id}", response_model=EmployeeInDB)
async def update_employee_info(
    employee_id: int, employee_update: EmployeeUpdate, db: Session = Depends(get_db)
):
    """更新员工信息"""
    employee = update_employee(employee_id, employee_update, db)
    if employee is None:
        raise HTTPException(status_code=404, detail="员工未找到")
    return employee


@router.delete("/{employee_id}")
async def delete_employee_info(employee_id: int, db: Session = Depends(get_db)):
    """删除员工"""
    success = delete_employee(employee_id, db)
    if not success:
        raise HTTPException(status_code=404, detail="员工未找到")
    return {"message": "员工删除成功"}
