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
from .query_registry import get_query, list_queries, execute_query, generate_chart
from .predefined_queries import *  # 导入所有预定义查询


def identify_intent(user_message: str) -> Dict[str, Any]:
    """
    使用大模型识别用户意图
    
    Args:
        user_message: 用户输入的消息
        
    Returns:
        包含意图、参数和置信度的字典
    """
    # 首先尝试基于查询注册表进行精确匹配
    queries = list_queries()
    for query_name in queries:
        if query_name in user_message:
            return {
                "intent": "registered_query",
                "parameters": {
                    "query_name": query_name
                },
                "confidence": 0.95
            }
    
    # 定义系统提示词，告诉模型如何识别意图
    system_prompt =  f"""
你是一个精确的意图识别与参数抽取助手，专注于“人力资源管理系统（HRMS）”相关的自然语言查询。目标：把用户的自然语言问题映射为严格、可机器解析的 JSON（仅返回 JSON，不允许多余文本、注释或代码块），以便后端直接调用预定义的 SQL 查询或其他处理逻辑。

-- 当前系统支持的预定义查询（注册表）：
{chr(10).join([f"{i+1}. {name}: {desc}" for i, (name, desc) in enumerate(queries.items())])}

-- 输出 JSON 格式（**必须严格遵守**，否则判为错误）：
{{
  "intent": "<意图标识，见下文>",
  "parameters": {{
    // 任意可选的参数键值对（详见允许的参数列表）
  }},
  "confidence": <0-1 之间的浮点数>
}}

-- 允许的意图（intent）说明（优先级按顺序）：
- "registered_query"：明确匹配到上面某个已注册查询（**优先使用**）。当命中此意图时，parameters 必须包含 "query_name"（其值为上面列表中的中文名称），其余可带上抽取到的参数（如 department、need_chart 等）。
- "employee_search"：在寻找或查询特定员工的详细信息或列表（参数示例：employee_name、employee_id、fuzzy、department）。
- "department_stats"：以部门为单位的统计与查询（可为单个部门或请求“各部门”总体）；若可映射为已注册查询（如“各部门人数”），优先返回 registered_query。
- "general_question"：非结构化的一般问题或非 HR 数据查询（例如天气、闲聊等）。

-- 常用/推荐参数（字段名与约定格式）：
- query_name: 已注册查询的完整中文名（仅在 intent == "registered_query" 时使用）。
- department: 部门名称（字符串，例如 "技术部"、"人事部"；尽量保留用户原话，但建议归一化为常见后缀 "部"）。
- employee_name: 员工姓名（字符串）。
- employee_id: 员工唯一 ID（数字或字符串）。
- status: 员工状态，标准化为 "在职" / "离职" / "待筛选" / "其他"。
- date_from, date_to: 日期范围，使用 ISO 格式 "YYYY-MM-DD"。
- job_title: 职位/职称字符串。
- jd_is_open: 布尔（true/false），用于职位是否开放的过滤。
- resume_status: 简历状态（比如 "待筛选"）。
- need_chart: 布尔（true/false），当用户明确要求“画图/图表/饼图/柱状图”时置为 true。
- page, page_size: 分页（整数）。

-- 匹配与置信度策略：
1. 精确命中已注册查询名或其高频同义句 → confidence: 0.98 ~ 1.00，intent="registered_query"。
2. 语义对应但非精确字符串匹配 → confidence: 0.85 ~ 0.97，intent="registered_query"。
3. 需要参数抽取且匹配度较高 → confidence: 0.7 ~ 0.9。
4. 模糊或不完全信息 → confidence: 0.4 ~ 0.7。
5. 非 HR 查询或无法匹配 → confidence: 0.0 ~ 0.4，intent="general_question"。

-- 示例：
用户: "公司现在有多少员工？"
返回: {{"intent":"registered_query","parameters":{{"query_name":"员工总数"}},"confidence":0.99}}

用户: "技术部有多少人？"
返回: {{"intent":"registered_query","parameters":{{"query_name":"各部门人数","department":"技术部"}},"confidence":0.92}}

用户: "今天天气怎么样？"
返回: {{"intent":"general_question","parameters":{{}},"confidence":0.12}}

-- 结束语：
严格遵守以上格式与规则。仅返回 JSON，不允许输出任何额外说明。
"""

    log_safe_json(logger,"system prompt: ", system_prompt[:200] + "...")
    
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
        # 移除可能的代码块标记
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
    log_safe_json(logger, "意图识别结果", intent_result)
    
    # 根据意图处理查询
    if intent_result["intent"] == "registered_query":
        # 使用预定义查询注册表
        query_name = intent_result["parameters"].get("query_name")
        if query_name:
            query_info = get_query(query_name)
            if query_info:
                # 执行查询
                query_result = execute_query(query_name, {}, db)
                if query_result:
                    # 生成回答文本
                    response_text = query_result.get("message", f"查询 '{query_name}' 执行完成")
                    
                    # 生成图表数据
                    chart_data = None
                    chart_dict = generate_chart(query_name, query_result)
                    if chart_dict:
                        chart_data = ChartData(
                            type=chart_dict["type"],
                            title=chart_dict["title"],
                            data=chart_dict["data"]
                        )
                    
                    return {
                        "message": response_text,
                        "chart_data": chart_data,
                        "raw_data": query_result.get("result", {})
                    }
                else:
                    return {
                        "message": f"执行查询 '{query_name}' 时发生错误",
                        "chart_data": None,
                        "raw_data": None
                    }
            else:
                return {
                    "message": f"未找到查询 '{query_name}'",
                    "chart_data": None,
                    "raw_data": None
                }
        else:
            return {
                "message": "未指定查询名称",
                "chart_data": None,
                "raw_data": None
            }
        
    elif intent_result["intent"] == "employee_count":
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
你是一个专业的人力资源管理系统AI助手，请用专业、友好的语气回答用户的问题。

回答要求：
1. 保持专业和礼貌的语调
2. 回答要准确、简洁明了
3. 如果问题涉及员工统计信息，请参考以下格式回答：
   "公司目前共有 X 名员工，其中在职 Y 人，离职 Z 人。"
4. 如果无法回答问题，请诚恳说明原因

请直接回答用户问题，不要包含任何额外的解释或格式。
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