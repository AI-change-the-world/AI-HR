from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import json
import os

router = APIRouter(prefix="/api/departments", tags=["部门管理"])

# 部门数据模型
class Department(BaseModel):
    id: int
    name: str
    manager: str
    description: Optional[str] = None
    employee_count: int = 0

class DepartmentCreate(BaseModel):
    name: str
    manager: str
    description: Optional[str] = None

class DepartmentUpdate(BaseModel):
    name: Optional[str] = None
    manager: Optional[str] = None
    description: Optional[str] = None
    employee_count: Optional[int] = None

# 模拟数据库存储
DEPARTMENT_DB_FILE = "departments.json"

def load_departments():
    """加载部门数据"""
    if os.path.exists(DEPARTMENT_DB_FILE):
        with open(DEPARTMENT_DB_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def save_departments(departments):
    """保存部门数据"""
    with open(DEPARTMENT_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(departments, f, ensure_ascii=False, indent=2)

@router.get("/", response_model=List[Department])
async def list_departments():
    """获取部门列表"""
    departments = load_departments()
    return [Department(**dept) for dept in departments]

@router.post("/", response_model=Department)
async def create_department(department: DepartmentCreate):
    """创建部门"""
    departments = load_departments()
    new_id = max([dept.get("id", 0) for dept in departments], default=0) + 1
    
    new_department = {
        "id": new_id,
        "employee_count": 0,
        **department.dict()
    }
    
    departments.append(new_department)
    save_departments(departments)
    
    return Department(**new_department)

@router.get("/{department_id}", response_model=Department)
async def get_department(department_id: int):
    """获取部门详情"""
    departments = load_departments()
    for dept in departments:
        if dept["id"] == department_id:
            return Department(**dept)
    raise HTTPException(status_code=404, detail="部门未找到")

@router.put("/{department_id}", response_model=Department)
async def update_department(department_id: int, department_update: DepartmentUpdate):
    """更新部门信息"""
    departments = load_departments()
    for i, dept in enumerate(departments):
        if dept["id"] == department_id:
            # 更新信息
            update_data = department_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                if value is not None:
                    dept[key] = value
            
            departments[i] = dept
            save_departments(departments)
            return Department(**dept)
    raise HTTPException(status_code=404, detail="部门未找到")

@router.delete("/{department_id}")
async def delete_department(department_id: int):
    """删除部门"""
    departments = load_departments()
    for i, dept in enumerate(departments):
        if dept["id"] == department_id:
            departments.pop(i)
            save_departments(departments)
            return {"message": "部门删除成功"}
    raise HTTPException(status_code=404, detail="部门未找到")