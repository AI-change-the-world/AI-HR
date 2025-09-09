import os
import json
from typing import List, Optional
from .models import EmployeeCreate, EmployeeUpdate, EmployeeInDB

# 员工数据文件路径
EMPLOYEE_DB_FILE = "data/employees.json"

def init_data_dir():
    """初始化数据目录"""
    data_dir = "data"
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)
        # 初始化空的JSON文件
        init_files = [
            "data/resumes.json",
            "data/employees.json", 
            "data/departments.json",
            "data/job_descriptions.json",
            "data/okrs.json"
        ]
        
        for file_path in init_files:
            if not os.path.exists(file_path):
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump([], f)

def load_employees() -> List[dict]:
    """加载所有员工"""
    init_data_dir()
    with open(EMPLOYEE_DB_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_employees(employees: List[dict]):
    """保存员工列表"""
    init_data_dir()
    with open(EMPLOYEE_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(employees, f, ensure_ascii=False, indent=2)

def get_next_id() -> int:
    """获取下一个可用ID"""
    employees = load_employees()
    if not employees:
        return 1
    return max(employee['id'] for employee in employees) + 1

def create_employee(employee_create: EmployeeCreate) -> EmployeeInDB:
    """创建新员工"""
    # 创建员工记录
    employee_dict = {
        "id": get_next_id(),
        **employee_create.dict()
    }
    
    # 保存到数据库
    employees = load_employees()
    employees.append(employee_dict)
    save_employees(employees)
    
    return EmployeeInDB(**employee_dict)

def get_employee(employee_id: int) -> Optional[EmployeeInDB]:
    """获取指定ID的员工"""
    employees = load_employees()
    for employee in employees:
        if employee["id"] == employee_id:
            return EmployeeInDB(**employee)
    return None

def get_employees(skip: int = 0, limit: int = 100) -> List[EmployeeInDB]:
    """获取员工列表"""
    employees = load_employees()
    # 分页处理
    paginated = employees[skip:skip + limit]
    return [EmployeeInDB(**employee) for employee in paginated]

def update_employee(employee_id: int, employee_update: EmployeeUpdate) -> Optional[EmployeeInDB]:
    """更新员工"""
    employees = load_employees()
    for i, employee in enumerate(employees):
        if employee["id"] == employee_id:
            # 更新字段
            update_data = employee_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                if value is not None:
                    employee[key] = value
            
            # 保存更新
            employees[i] = employee
            save_employees(employees)
            
            return EmployeeInDB(**employee)
    return None

def delete_employee(employee_id: int) -> bool:
    """删除员工"""
    employees = load_employees()
    for i, employee in enumerate(employees):
        if employee["id"] == employee_id:
            employees.pop(i)
            save_employees(employees)
            return True
    return False