import json
from typing import Dict, Any
from sqlalchemy.orm import Session

from config.openai_client import openai_client
from config.settings import settings
from models.employee import Employee as EmployeeModel
from models.department import Department as DepartmentModel
from .models import ChartData
from common.logger import logger
from utils.logger_format_utils import log_safe_json


def identify_intent(user_message: str) -> Dict[str, Any]:
    """
    使用大模型识别用户意图
    
    Args:
        user_message: 用户输入的消息
        
    Returns:
        包含意图、参数和置信度的字典
    """
    # 定义系统提示词，告诉模型如何识别意图
    system_prompt = """
    你是一个人力资源系统的AI助手，能够识别用户查询的意图。请根据用户的问题识别其意图和相关参数。
    
    可能的意图包括：
    1. employee_count - 查询员工数量统计
    2. department_stats - 查询部门统计信息
    3. employee_search - 搜索特定员工
    4. general_question - 一般性问题
    
    请以以下JSON格式返回结果：
    {
        "intent": "意图标识",
        "parameters": {
            "参数名": "参数值"
        },
        "confidence": 置信度(0-1之间的浮点数)
    }
    
    示例：
    用户问："公司现在有多少员工？"
    返回：{"intent": "employee_count", "parameters": {}, "confidence": 0.95}
    
    用户问："技术部有多少人？"
    返回：{"intent": "department_stats", "parameters": {"department": "技术部"}, "confidence": 0.9}
    """
    
    try:
        response = openai_client.chat.completions.create(
            model=settings.OPENAI_MODEL,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message}
            ],
            temperature=0.1,
            max_tokens=200
        )
        
        # 解析模型响应
        content = response.choices[0].message.content.strip()
        # 移除可能的markdown代码块标记
        if content.startswith("```json"):
            content = content[7:]
        if content.endswith("```"):
            content = content[:-3]
            
        return json.loads(content)
    except Exception as e:
        # 如果意图识别失败，返回默认的一般性问题意图
        return {
            "intent": "general_question",
            "parameters": {},
            "confidence": 0.5
        }


def get_employee_stats(db: Session) -> Dict[str, Any]:
    """
    获取员工统计信息
    
    Args:
        db: 数据库会话
        
    Returns:
        员工统计信息字典
    """
    # 查询所有员工
    employees = db.query(EmployeeModel).all()
    
    # 统计各类状态的员工数量
    total = len(employees)
    active = 0  # 在职 (status = 0)
    inactive = 0  # 离职 (status = 1)
    pending = 0  # 其他状态 (status = 2, 3, 4, 5)
    
    # 按部门统计
    department_stats = {}
    
    for emp in employees:
        # 统计员工状态
        if emp.status == 0:
            active += 1
        elif emp.status == 1:
            inactive += 1
        else:
            pending += 1
            
        # 统计部门人数
        if emp.department_id:
            department = db.query(DepartmentModel).filter(
                DepartmentModel.id == emp.department_id
            ).first()
            if department:
                dept_name = department.name
                department_stats[dept_name] = department_stats.get(dept_name, 0) + 1
    
    return {
        "total": total,
        "active": active,
        "inactive": inactive,
        "pending": pending,
        "department_stats": department_stats
    }


def generate_chart_data(stats: Dict[str, Any]) -> Dict[str, Any]:
    """
    根据员工统计数据生成图表数据
    
    Args:
        stats: 员工统计数据
        
    Returns:
        图表数据字典
    """
    # 生成部门人数柱状图数据
    dept_names = list(stats["department_stats"].keys())
    dept_counts = list(stats["department_stats"].values())
    
    bar_chart = {
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
    
    # 生成员工状态饼图数据
    status_data = [
        {"name": "在职", "value": stats["active"]},
        {"name": "离职", "value": stats["inactive"]},
        {"name": "其他", "value": stats["pending"]}
    ]
    
    pie_chart = {
        "type": "pie",
        "title": "员工状态分布",
        "data": {
            "series": [{
                "type": "pie",
                "data": status_data
            }]
        }
    }
    
    return {
        "bar_chart": bar_chart,
        "pie_chart": pie_chart
    }


def process_employee_query(user_message: str, db: Session) -> Dict[str, Any]:
    """
    处理员工相关的查询
    
    Args:
        user_message: 用户查询
        db: 数据库会话
        
    Returns:
        处理结果，包含回答文本和图表数据
    """
    # 识别用户意图
    intent_result = identify_intent(user_message)
    # print("意图识别结果: "+ json.dumps(intent_result))
    log_safe_json(logger, "意图识别结果", intent_result)
    
    # 根据意图处理查询
    if intent_result["intent"] == "employee_count":
        # 获取员工统计数据
        stats = get_employee_stats(db)
        chart_data_dict = generate_chart_data(stats)
        
        # 选择一个图表作为主要图表数据（这里选择柱状图）
        bar_chart_dict = chart_data_dict["bar_chart"]
        
        # 创建符合模型的ChartData对象
        main_chart_data = ChartData(
            type=bar_chart_dict["type"],
            title=bar_chart_dict["title"],
            data=bar_chart_dict["data"]
        )
        
        # 生成回答文本
        response_text = f"公司目前共有 {stats['total']} 名员工，其中在职 {stats['active']} 人，离职 {stats['inactive']} 人，其他状态 {stats['pending']} 人。"
        
        return {
            "message": response_text,
            "chart_data": main_chart_data,  # 返回符合ChartData模型的对象
            "raw_data": stats
        }
        
    elif intent_result["intent"] == "department_stats":
        # 获取员工统计数据
        stats = get_employee_stats(db)
        
        # 获取特定部门信息
        department_name = intent_result["parameters"].get("department", "")
        if department_name and department_name in stats["department_stats"]:
            dept_count = stats["department_stats"][department_name]
            response_text = f"{department_name}目前有 {dept_count} 名员工。"
        else:
            response_text = "我没有找到您询问的部门信息。"
            
        return {
            "message": response_text,
            "chart_data": None,  # 不返回图表数据
            "raw_data": stats
        }
        
    else:
        # 一般性问题，使用大模型回答
        system_prompt = """
        你是一个专业的人力资源管理系统AI助手。请用专业、友好的语气回答用户的问题。
        如果问题涉及员工统计信息，请参考以下格式回答：
        "公司目前共有 X 名员工，其中在职 Y 人，离职 Z 人。"
        """
        
        try:
            response = openai_client.chat.completions.create(
                model=settings.OPENAI_MODEL,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_message}
                ],
                temperature=0.7,
                max_tokens=300
            )
            
            response_text = response.choices[0].message.content.strip()
            return {
                "message": response_text,
                "chart_data": None,
                "raw_data": None
            }
        except Exception as e:
            return {
                "message": "抱歉，我暂时无法回答您的问题。请稍后再试。",
                "chart_data": None,
                "raw_data": None
            }