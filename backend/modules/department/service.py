import os
import json
from typing import List, Optional
from .models import DepartmentCreate, DepartmentUpdate, DepartmentInDB

# 部门数据文件路径
DEPARTMENT_DB_FILE = "data/departments.json"

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

def load_departments() -> List[dict]:
    """加载所有部门"""
    init_data_dir()
    with open(DEPARTMENT_DB_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_departments(departments: List[dict]):
    """保存部门列表"""
    init_data_dir()
    with open(DEPARTMENT_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(departments, f, ensure_ascii=False, indent=2)

def get_next_id() -> int:
    """获取下一个可用ID"""
    departments = load_departments()
    if not departments:
        return 1
    return max(department['id'] for department in departments) + 1

def create_department(department_create: DepartmentCreate) -> DepartmentInDB:
    """创建新部门"""
    # 创建部门记录
    department_dict = {
        "id": get_next_id(),
        "employee_count": 0,
        **department_create.dict()
    }
    
    # 保存到数据库
    departments = load_departments()
    departments.append(department_dict)
    save_departments(departments)
    
    return DepartmentInDB(**department_dict)

def get_department(department_id: int) -> Optional[DepartmentInDB]:
    """获取指定ID的部门"""
    departments = load_departments()
    for department in departments:
        if department["id"] == department_id:
            return DepartmentInDB(**department)
    return None

def get_departments(skip: int = 0, limit: int = 100) -> List[DepartmentInDB]:
    """获取部门列表"""
    departments = load_departments()
    # 分页处理
    paginated = departments[skip:skip + limit]
    return [DepartmentInDB(**department) for department in paginated]

def update_department(department_id: int, department_update: DepartmentUpdate) -> Optional[DepartmentInDB]:
    """更新部门"""
    departments = load_departments()
    for i, department in enumerate(departments):
        if department["id"] == department_id:
            # 更新字段
            update_data = department_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                if value is not None:
                    department[key] = value
            
            # 保存更新
            departments[i] = department
            save_departments(departments)
            
            return DepartmentInDB(**department)
    return None

def delete_department(department_id: int) -> bool:
    """删除部门"""
    departments = load_departments()
    for i, department in enumerate(departments):
        if department["id"] == department_id:
            departments.pop(i)
            save_departments(departments)
            return True
    return False