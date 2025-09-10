import json
import os
from typing import List, Optional

from sqlalchemy.orm import Session

from backend.models.department import Department as DepartmentModel  # 导入数据库模型
from .models import DepartmentCreate, DepartmentInDB, DepartmentUpdate


def get_department_by_name(name: str, db: Session) -> Optional[DepartmentInDB]:
    """根据名称获取部门"""
    db_department = db.query(DepartmentModel).filter(DepartmentModel.name == name).first()
    if db_department:
        return DepartmentInDB(
            id=db_department.id,
            name=db_department.name,
            manager=db_department.manager,
            description=db_department.description,
            employee_count=db_department.employee_count
        )
    return None


def create_department(
    department_create: DepartmentCreate, db: Session
) -> DepartmentInDB:
    """创建新部门"""
    # 创建部门记录
    db_department = DepartmentModel(**department_create.dict())
    
    # 保存到数据库
    db.add(db_department)
    db.commit()
    db.refresh(db_department)
    
    return DepartmentInDB(
        id=db_department.id,
        name=db_department.name,
        manager=db_department.manager,
        description=db_department.description,
        employee_count=db_department.employee_count
    )


def get_department(department_id: int, db: Session) -> Optional[DepartmentInDB]:
    """获取指定ID的部门"""
    # 这里应该从数据库查询部门
    # 暂时返回模拟数据
    department_data = {
        "id": department_id,
        "name": "技术部",
        "manager": "李四",
        "description": "负责软件开发和技术支持",
        "employee_count": 10,
    }
    return DepartmentInDB(**department_data)


def get_departments(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> List[DepartmentInDB]:
    """获取部门列表"""
    # 这里应该从数据库查询部门列表
    # 暂时返回模拟数据
    department_data = {
        "id": 1,
        "name": "技术部",
        "manager": "李四",
        "description": "负责软件开发和技术支持",
        "employee_count": 10,
    }
    return [DepartmentInDB(**department_data)]


def update_department(
    department_id: int, department_update: DepartmentUpdate, db: Session
) -> Optional[DepartmentInDB]:
    """更新部门"""
    # 这里应该更新数据库中的部门信息
    # 暂时返回模拟数据
    update_data = department_update.dict(exclude_unset=True)
    department_data = {
        "id": department_id,
        "name": update_data.get("name", "技术部"),
        "manager": update_data.get("manager", "李四"),
        "description": update_data.get("description", "负责软件开发和技术支持"),
        "employee_count": 10,
    }
    return DepartmentInDB(**department_data)


def delete_department(department_id: int, db: Session) -> bool:
    """删除部门"""
    # 这里应该从数据库删除部门
    # 暂时返回模拟结果
    return True
