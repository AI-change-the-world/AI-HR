import json
import os
from typing import List, Optional

from sqlalchemy.orm import Session

from .models import JDCreate, JDInDB, JDUpdate


def create_jd(jd_create: JDCreate, db: Session) -> JDInDB:
    """创建新JD"""
    # 创建JD记录
    jd_dict = jd_create.dict()

    # 保存到数据库
    # 这里应该使用SQLAlchemy模型来创建和保存JD
    # 暂时返回模拟数据
    jd_dict["id"] = 1
    jd_dict["is_open"] = True
    return JDInDB(**jd_dict)


def get_jd(jd_id: int, db: Session) -> Optional[JDInDB]:
    """获取指定ID的JD"""
    # 这里应该从数据库查询JD
    # 暂时返回模拟数据
    jd_data = {
        "id": jd_id,
        "title": "软件工程师",
        "description": "负责软件开发工作",
        "requirements": "计算机相关专业，3年以上开发经验",
        "department": "技术部",
        "is_open": True,
    }
    return JDInDB(**jd_data)


def get_jds(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> List[JDInDB]:
    """获取JD列表"""
    # 这里应该从数据库查询JD列表
    # 暂时返回模拟数据
    jd_data = {
        "id": 1,
        "title": "软件工程师",
        "description": "负责软件开发工作",
        "requirements": "计算机相关专业，3年以上开发经验",
        "department": "技术部",
        "is_open": True,
    }
    return [JDInDB(**jd_data)]


def update_jd(jd_id: int, jd_update: JDUpdate, db: Session) -> Optional[JDInDB]:
    """更新JD"""
    # 这里应该更新数据库中的JD信息
    # 暂时返回模拟数据
    update_data = jd_update.dict(exclude_unset=True)
    jd_data = {
        "id": jd_id,
        "title": update_data.get("title", "软件工程师"),
        "description": update_data.get("description", "负责软件开发工作"),
        "requirements": update_data.get(
            "requirements", "计算机相关专业，3年以上开发经验"
        ),
        "department": update_data.get("department", "技术部"),
        "is_open": update_data.get("is_open", True),
    }
    return JDInDB(**jd_data)


def delete_jd(jd_id: int, db: Session) -> bool:
    """删除JD"""
    # 这里应该从数据库删除JD
    # 暂时返回模拟结果
    return True
