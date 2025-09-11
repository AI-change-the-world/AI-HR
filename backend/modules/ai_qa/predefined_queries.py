#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
预定义查询函数
实现常用的HR数据查询功能
"""

from typing import Dict, Any, List
from sqlalchemy.orm import Session
from sqlalchemy import func, case
from models.employee import Employee as EmployeeModel
from models.department import Department as DepartmentModel
from models.jd import JobDescription as JDModel
from models.resume import Resume as ResumeModel
from models.okr import OKR as OKRModel
from .query_registry import register_query
from .models import ChartData


def employee_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """员工总数查询"""
    count = db.query(func.count(EmployeeModel.id)).scalar()
    return {
        "result": {"total": count},
        "message": f"公司目前共有 {count} 名员工"
    }


def active_employee_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """在职员工数查询"""
    count = db.query(func.count(EmployeeModel.id)).filter(EmployeeModel.status == 0).scalar()
    return {
        "result": {"active_count": count},
        "message": f"在职员工数：{count}人"
    }


def inactive_employee_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """离职员工数查询"""
    count = db.query(func.count(EmployeeModel.id)).filter(EmployeeModel.status == 1).scalar()
    return {
        "result": {"inactive_count": count},
        "message": f"离职员工数：{count}人"
    }


def department_stats_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """各部门人数统计查询"""
    # 使用LEFT JOIN获取所有部门及其员工数
    result = db.query(
        DepartmentModel.name,
        func.count(EmployeeModel.id).label('count')
    ).outerjoin(
        EmployeeModel, DepartmentModel.id == EmployeeModel.department_id
    ).group_by(
        DepartmentModel.id, DepartmentModel.name
    ).all()
    
    # 转换为字典列表
    department_stats = [
        {"department": row[0], "count": row[1]} 
        for row in result
    ]
    
    return {
        "result": department_stats,
        "message": "各部门员工数量统计已完成"
    }


def department_stats_chart_generator(query_result: Dict[str, Any]) -> Dict[str, Any]:
    """各部门人数统计图表生成器"""
    if not isinstance(query_result.get("result"), list):
        return {}
    
    department_stats = query_result["result"]
    dept_names = [item["department"] for item in department_stats]
    dept_counts = [item["count"] for item in department_stats]
    
    return {
        "type": "bar",
        "title": "各部门员工数量统计",
        "data": {
            "xAxis": {
                "type": "category",
                "data": dept_names
            },
            "yAxis": {
                "type": "value"
            },
            "series": [{
                "data": dept_counts,
                "type": "bar"
            }]
        }
    }


def employee_status_distribution_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """员工状态分布查询"""
    result = db.query(
        case(
            (EmployeeModel.status == 0, "在职"),
            (EmployeeModel.status == 1, "离职"),
            else_="其他"
        ).label('status'),
        func.count(EmployeeModel.id).label('count')
    ).group_by(
        case(
            (EmployeeModel.status == 0, "在职"),
            (EmployeeModel.status == 1, "离职"),
            else_="其他"
        )
    ).all()
    
    # 转换为字典列表
    status_distribution = [
        {"status": row[0], "count": row[1]} 
        for row in result
    ]
    
    return {
        "result": status_distribution,
        "message": "员工状态分布统计已完成"
    }


def employee_status_chart_generator(query_result: Dict[str, Any]) -> Dict[str, Any]:
    """员工状态分布图表生成器"""
    if not isinstance(query_result.get("result"), list):
        return {}
    
    status_data = query_result["result"]
    chart_data = [
        {"name": item["status"], "value": item["count"]}
        for item in status_data
    ]
    
    return {
        "type": "pie",
        "title": "员工状态分布",
        "data": {
            "series": [{
                "type": "pie",
                "data": chart_data
            }]
        }
    }


def department_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """部门总数查询"""
    count = db.query(func.count(DepartmentModel.id)).scalar()
    return {
        "result": {"total": count},
        "message": f"公司目前共有 {count} 个部门"
    }


def jd_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """职位描述总数查询"""
    count = db.query(func.count(JDModel.id)).scalar()
    return {
        "result": {"total": count},
        "message": f"职位描述总数：{count}个"
    }


def open_jd_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """开放职位数查询"""
    count = db.query(func.count(JDModel.id)).filter(JDModel.is_open == True).scalar()
    return {
        "result": {"open_count": count},
        "message": f"当前开放的职位数量：{count}个"
    }


def resume_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """简历总数查询"""
    count = db.query(func.count(ResumeModel.id)).scalar()
    return {
        "result": {"total": count},
        "message": f"简历总数：{count}份"
    }


def pending_resume_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """待筛选简历数查询"""
    count = db.query(func.count(ResumeModel.id)).filter(ResumeModel.status == "待筛选").scalar()
    return {
        "result": {"pending_count": count},
        "message": f"待筛选的简历数量：{count}份"
    }


def okr_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """OKR总数查询"""
    count = db.query(func.count(OKRModel.id)).scalar()
    return {
        "result": {"total": count},
        "message": f"OKR总数：{count}个"
    }


# 注册所有预定义查询
register_query("员工总数", "查询公司员工总数", employee_count_query)
register_query("在职员工数", "查询在职员工数量", active_employee_count_query)
register_query("离职员工数", "查询离职员工数量", inactive_employee_count_query)
register_query("部门总数", "查询公司部门总数", department_count_query)
register_query("职位总数", "查询职位描述总数", jd_count_query)
register_query("开放职位数", "查询当前开放的职位数量", open_jd_count_query)
register_query("简历总数", "查询简历总数", resume_count_query)
register_query("待筛选简历数", "查询待筛选的简历数量", pending_resume_count_query)
register_query("OKR总数", "查询OKR总数", okr_count_query)

# 注册带图表的查询
register_query(
    "各部门人数", 
    "按部门统计员工人数", 
    department_stats_query, 
    department_stats_chart_generator
)

register_query(
    "员工状态分布", 
    "统计员工状态分布情况", 
    employee_status_distribution_query, 
    employee_status_chart_generator
)