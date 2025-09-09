from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from .models import EmployeeCreate, EmployeeUpdate, EmployeeInDB
from .service import create_employee, get_employee, get_employees, update_employee, delete_employee, get_db

router = APIRouter(
    prefix="/api/employees",
    tags=["员工管理"]
)

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
async def read_employees(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """获取员工列表"""
    return get_employees(skip=skip, limit=limit, db=db)

@router.put("/{employee_id}", response_model=EmployeeInDB)
async def update_employee_info(employee_id: int, employee_update: EmployeeUpdate, db: Session = Depends(get_db)):
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