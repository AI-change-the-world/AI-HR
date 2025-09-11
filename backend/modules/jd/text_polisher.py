import json
from typing import Any, Dict

from config.openai_client import openai_client as client
from config.settings import settings


class JDTextPolisher:
    """JD文本AI润色处理类"""

    def __init__(self):
        self.model = settings.OPENAI_MODEL

    def polish_text(self, original_text: str) -> str:
        """
        使用AI对JD原文进行润色，输出格式化的Markdown文本
        """
        prompt = f"""
你是一个专业的HR文档编辑专家。请对以下JD原文进行润色和格式化，输出符合专业标准的Markdown格式文本。

润色要求：
1. 保持原有核心信息，但优化表达方式和语言风格
2. 使用清晰的Markdown格式结构，包含合适的标题、列表、重点标记等
3. 突出关键信息，如薪资范围、技能要求、工作亮点等
4. 语言专业、简洁、吸引人，符合现代招聘标准
5. 如果原文信息不完整，可适当补充标准化的段落结构
6. 添加合适的emoji来提升可读性（但不要过度使用）

输出格式要求：
- 使用# ## ###等标题层级
- 用**粗体**突出重要信息
- 用`代码标记`标注技术技能
- 用> 引用块突出亮点
- 用- 无序列表展示要求和职责

原文内容：
{original_text}

请输出润色后的Markdown格式文本：
"""

        try:
            response = client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.7,
                max_tokens=2000,
            )

            polished_text = response.choices[0].message.content.strip()
            return polished_text

        except Exception as e:
            raise ValueError(f"AI润色失败: {str(e)}")

    def extract_jd_fields(self, text: str) -> Dict[str, Any]:
        """
        从文本中提取JD的结构化字段信息
        """
        prompt = f"""
你是一个专业的HR信息提取专家。请从以下JD文本中提取关键信息，并以JSON格式输出。

提取要求：
1. 尽可能准确地提取所有可识别的信息
2. 如果某些信息未明确提及，可设为null
3. 薪资范围请提取数字范围，格式如"15-25K"
4. 技能要求请提取具体的技术栈和工具
5. 工作年限要求请提取数字范围

输出JSON格式：
{{
    "title": "职位名称",
    "department": "部门名称",
    "location": "工作地点",
    "description": "职位描述（简洁版本）",
    "requirements": "任职要求（简洁版本）",
    "salary_range": "薪资范围",
    "skills": ["技能1", "技能2", "技能3"],
    "experience": "工作年限要求",
    "education": "学历要求",
    "company_size": "公司规模",
    "industry": "所属行业"
}}

JD文本内容：
{text}

请输出提取的JSON数据：
"""

        try:
            response = client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                response_format={"type": "json_object"},
                temperature=0.3,
            )

            result = json.loads(response.choices[0].message.content)
            return result

        except Exception as e:
            raise ValueError(f"信息提取失败: {str(e)}")

    def generate_evaluation_criteria(self, text: str) -> Dict[str, Any]:
        """
        根据JD内容生成智能评估标准
        """
        prompt = f"""
你是一个专业的HR评估标准制定专家。请根据以下JD内容，制定合理的简历评估标准。

评估标准要求：
1. 根据职位特点设定不同的评估维度
2. 每个维度设定具体的评分标准和分值
3. 分值应该合理分配，总分控制在80-120分左右
4. 考虑技能匹配、经验匹配、学历要求、项目经验等维度

输出JSON格式：
{{
    "学历要求": {{
        "大专": 分值,
        "本科": 分值,
        "硕士": 分值,
        "博士": 分值
    }},
    "工作经验": {{
        "1年以下": 分值,
        "1-3年": 分值,
        "3-5年": 分值,
        "5年以上": 分值
    }},
    "技能匹配": {{
        "核心技能": 分值,
        "相关技能": 分值,
        "加分技能": 分值
    }},
    "项目经验": {{
        "相关项目": 分值,
        "大型项目": 分值,
        "创新项目": 分值
    }},
    "综合评价": {{
        "逻辑清晰": 分值,
        "表达能力": 分值,
        "真实性": 分值
    }}
}}

JD内容：
{text}

请输出评估标准的JSON数据：
"""

        try:
            response = client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                response_format={"type": "json_object"},
                temperature=0.5,
            )

            criteria = json.loads(response.choices[0].message.content)
            return criteria

        except Exception as e:
            raise ValueError(f"评估标准生成失败: {str(e)}")


# 全局实例
jd_polisher = JDTextPolisher()
