#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
查询注册表
使用简单的Dict[str, Any]结构，包含可执行函数，便于扩展
"""

from typing import Dict, Any, Callable, Optional
from sqlalchemy.orm import Session


# 查询注册表结构
# {
#     "查询名称": {
#         "description": "查询描述",
#         "executor": 可执行函数,
#         "chart_generator": 可选的图表生成函数
#     }
# }

QUERY_REGISTRY: Dict[str, Dict[str, Any]] = {}


def register_query(
    name: str,
    description: str,
    executor: Callable[[Dict[str, Any], Session], Dict[str, Any]],
    chart_generator: Optional[Callable[[Dict[str, Any]], Dict[str, Any]]] = None
):
    """
    注册一个新的查询
    
    Args:
        name: 查询名称
        description: 查询描述
        executor: 执行函数，接收参数字典和数据库会话，返回结果字典
        chart_generator: 可选的图表生成函数，接收查询结果，返回图表数据
    """
    QUERY_REGISTRY[name] = {
        "description": description,
        "executor": executor,
        "chart_generator": chart_generator
    }


def get_query(name: str) -> Optional[Dict[str, Any]]:
    """
    获取查询信息
    
    Args:
        name: 查询名称
        
    Returns:
        查询信息字典，如果未找到则返回None
    """
    return QUERY_REGISTRY.get(name)


def list_queries() -> Dict[str, str]:
    """
    列出所有已注册的查询
    
    Returns:
        查询名称到描述的映射字典
    """
    return {name: info["description"] for name, info in QUERY_REGISTRY.items()}


def execute_query(name: str, params: Dict[str, Any], db: Session) -> Optional[Dict[str, Any]]:
    """
    执行查询
    
    Args:
        name: 查询名称
        params: 查询参数
        db: 数据库会话
        
    Returns:
        查询结果字典，如果未找到查询则返回None
    """
    query_info = get_query(name)
    if not query_info:
        return None
    
    executor = query_info["executor"]
    return executor(params, db)


def generate_chart(name: str, query_result: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """
    生成查询结果的图表数据
    
    Args:
        name: 查询名称
        query_result: 查询结果
        
    Returns:
        图表数据字典，如果没有图表生成函数则返回None
    """
    query_info = get_query(name)
    if not query_info:
        return None
    
    chart_generator = query_info.get("chart_generator")
    if chart_generator:
        return chart_generator(query_result)
    return None