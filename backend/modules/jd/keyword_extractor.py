import json
from typing import Dict, Any
from config.settings import settings
from config.openai_client import openai_client as client


def extract_jd_keywords(full_text: str) -> Dict[str, Any]:
    """
    从完整的JD描述中提取关键字并结构化
    """
    
    prompt = f"""
你是一个专业的HR和招聘专家。请从以下完整的职位描述中提取结构化信息。

请仔细分析职位描述，提取以下字段：
1. title: 职位名称/标题
2. department: 所属部门
3. location: 工作地点
4. description: 职位职责和描述（简洁版本）
5. requirements: 任职要求（简洁版本）
6. salary_range: 薪资范围（如果提到的话）

注意事项：
- 如果某个字段在原文中没有明确提到，请返回null
- 提取的内容要简洁准确，避免冗余
- 保持原文的核心意思不变

请以JSON格式返回结果：
{{
  "title": "职位名称",
  "department": "部门名称",
  "location": "工作地点",
  "description": "职位描述",
  "requirements": "任职要求",
  "salary_range": "薪资范围"
}}

【原始职位描述】
{full_text}
"""
    
    try:
        response = client.chat.completions.create(
            model=settings.OPENAI_MODEL,
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"},
            temperature=0.3
        )
        
        result = response.choices[0].message.content
        extracted_data = json.loads(result)
        
        # 清理空值
        cleaned_data = {}
        for key, value in extracted_data.items():
            if value and str(value).strip() and str(value).lower() != 'null':
                cleaned_data[key] = str(value).strip()
        
        return cleaned_data
        
    except Exception as e:
        raise Exception(f"关键字提取失败: {str(e)}")