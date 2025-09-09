from fastapi import APIRouter, HTTPException
from .models import EmployeeCreate, EmployeeUpdate, EmployeeInDB
from .service import create_employee, get_employee, get_employees, update_employee, delete_employee

router = APIRouter(
    prefix="/api/employees",
    tags=["员工管理"]
)

@router.post("/", response_model=EmployeeInDB)
async def create_employee_info(employee: EmployeeCreate):
    """创建员工"""
    return create_employee(employee)

@router.get("/{employee_id}", response_model=EmployeeInDB)
async def read_employee(employee_id: int):
    """获取员工详情"""
    employee = get_employee(employee_id)
    if employee is None:
        raise HTTPException(status_code=404, detail="员工未找到")
    return employee

@router.get("/", response_model=list[EmployeeInDB])
async def read_employees(skip: int = 0, limit: int = 100):
    """获取员工列表"""
    return get_employees(skip=skip, limit=limit)

@router.put("/{employee_id}", response_model=EmployeeInDB)
async def update_employee_info(employee_id: int, employee_update: EmployeeUpdate):
    """更新员工信息"""
    employee = update_employee(employee_id, employee_update)
    if employee is None:
        raise HTTPException(status_code=404, detail="员工未找到")
    return employee

@router.delete("/{employee_id}")
async def delete_employee_info(employee_id: int):
    """删除员工"""
    success = delete_employee(employee_id)
    if not success:
        raise HTTPException(status_code=404, detail="员工未找到")
    return {"message": "员工删除成功"}