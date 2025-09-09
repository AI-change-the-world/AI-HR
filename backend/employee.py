from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import json
import os

router = APIRouter(prefix="/api/employees", tags=["员工管理"])

# 员工数据模型
class Employee(BaseModel):
    id: int
    name: str
    department: str
    position: str
    email: str
    phone: Optional[str] = None

class EmployeeCreate(BaseModel):
    name: str
    department: str
    position: str
    email: str
    phone: Optional[str] = None

class EmployeeUpdate(BaseModel):
    name: Optional[str] = None
    department: Optional[str] = None
    position: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None

# 模拟数据库存储
EMPLOYEE_DB_FILE = "employees.json"

def load_employees():
    """加载员工数据"""
    if os.path.exists(EMPLOYEE_DB_FILE):
        with open(EMPLOYEE_DB_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def save_employees(employees):
    """保存员工数据"""
    with open(EMPLOYEE_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(employees, f, ensure_ascii=False, indent=2)

@router.get("/", response_model=List[Employee])
async def list_employees():
    """获取员工列表"""
    employees = load_employees()
    return [Employee(**emp) for emp in employees]

@router.post("/", response_model=Employee)
async def create_employee(employee: EmployeeCreate):
    """创建员工"""
    employees = load_employees()
    new_id = max([emp.get("id", 0) for emp in employees], default=0) + 1
    
    new_employee = {
        "id": new_id,
        **employee.dict()
    }
    
    employees.append(new_employee)
    save_employees(employees)
    
    return Employee(**new_employee)

@router.get("/{employee_id}", response_model=Employee)
async def get_employee(employee_id: int):
    """获取员工详情"""
    employees = load_employees()
    for emp in employees:
        if emp["id"] == employee_id:
            return Employee(**emp)
    raise HTTPException(status_code=404, detail="员工未找到")

@router.put("/{employee_id}", response_model=Employee)
async def update_employee(employee_id: int, employee_update: EmployeeUpdate):
    """更新员工信息"""
    employees = load_employees()
    for i, emp in enumerate(employees):
        if emp["id"] == employee_id:
            # 更新信息
            update_data = employee_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                if value is not None:
                    emp[key] = value
            
            employees[i] = emp
            save_employees(employees)
            return Employee(**emp)
    raise HTTPException(status_code=404, detail="员工未找到")

@router.delete("/{employee_id}")
async def delete_employee(employee_id: int):
    """删除员工"""
    employees = load_employees()
    for i, emp in enumerate(employees):
        if emp["id"] == employee_id:
            employees.pop(i)
            save_employees(employees)
            return {"message": "员工删除成功"}
    raise HTTPException(status_code=404, detail="员工未找到")