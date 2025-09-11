import json
import os
from typing import List, Optional

from sqlalchemy.orm import Session

from models.department import Department as DepartmentModel  # 导入数据库模型

from .models import DepartmentCreate, DepartmentInDB, DepartmentUpdate


def get_department_by_name(name: str, db: Session) -> Optional[DepartmentInDB]:
    """根据名称获取部门"""
    db_department = (
        db.query(DepartmentModel).filter(DepartmentModel.name == name).first()
    )
    if db_department:
        return DepartmentInDB(
            id=db_department.id,
            name=db_department.name,
            manager=db_department.manager,
            description=db_department.description,
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
    )


def get_department(department_id: int, db: Session) -> Optional[DepartmentInDB]:
    """获取指定ID的部门"""
    db_department = db.query(DepartmentModel).filter(DepartmentModel.id == department_id).first()
    if not db_department:
        return None
        
    return DepartmentInDB(
        id=db_department.id,
        name=db_department.name,
        manager=db_department.manager,
        description=db_department.description,
    )


def get_departments(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> List[DepartmentInDB]:
    """获取部门列表"""
    db_departments = db.query(DepartmentModel).offset(skip).limit(limit).all()
    result = []
    for db_department in db_departments:
        result.append(
            DepartmentInDB(
                id=db_department.id,
                name=db_department.name,
                description=db_department.description,
            )
        )
    return result


def update_department(
    department_id: int, department_update: DepartmentUpdate, db: Session
) -> Optional[DepartmentInDB]:
    """更新部门"""
    db_department = db.query(DepartmentModel).filter(DepartmentModel.id == department_id).first()
    if not db_department:
        return None

    update_data = department_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        if value is not None:
            setattr(db_department, key, value)

    db.commit()
    db.refresh(db_department)

    return DepartmentInDB(
        id=db_department.id,
        name=db_department.name,
        manager=db_department.manager,
        description=db_department.description,
    )


def delete_department(department_id: int, db: Session) -> bool:
    """删除部门"""
    db_department = db.query(DepartmentModel).filter(DepartmentModel.id == department_id).first()
    if not db_department:
        return False

    db.delete(db_department)
    db.commit()
    return True
