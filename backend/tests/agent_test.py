import json
import os
import re

from openai import OpenAI

client = OpenAI(
    api_key=os.environ["OPENAI_API_KEY"], base_url=os.environ["OPENAI_BASE_URL"]
)


def safe_json_parse(s: str):
    """
    尝试容错解析 JSON，允许有多余文本/```json 包裹。
    """
    if not s or not s.strip():
        raise ValueError("模型返回空字符串")

    # 去掉 markdown 包裹
    s = s.strip()
    if s.startswith("```"):
        s = re.sub(r"^```(json)?", "", s, flags=re.I).strip()
        s = re.sub(r"```$", "", s).strip()

    try:
        return json.loads(s)
    except json.JSONDecodeError:
        # 再尝试提取 {...} 结构
        match = re.search(r"\{.*\}", s, re.S)
        if match:
            try:
                return json.loads(match.group())
            except Exception as e:
                raise ValueError(f"JSON 部分解析失败: {e}\n原始内容: {s}") from e
        raise ValueError(f"无法解析为 JSON: {s}")


def evaluate_resume_stepwise(jd_text: str, resume_text: str, scoring_rules: dict):
    """
    基于用户自定义评分规则，对简历与JD逐步评估。
    - 第一步：任务拆分
    - 后续步骤：逐个执行打分
    每一步结果用 yield 返回。
    """

    # 第一步：任务拆解
    step_prompt = f"""
你是一个招聘评估专家。
用户提供了一套简历评分标准，请你拆解整个评估流程，分为 3-6 个步骤。

拆解要求：
1. 每个步骤必须对应标准中的一个维度或一类维度。
2. 步骤要有明确的任务描述，告诉如何对简历和 JD 进行比对。
3. 最后增加一个“总分计算与匹配结论”步骤。

请输出 JSON，格式如下：
{{
  "steps": [
    {{"id": 1, "name": "步骤名称", "desc": "任务说明"}},
    ...
  ]
}}

【用户提供的评分标准】
{scoring_rules}
"""
    step_response = client.chat.completions.create(
        model="qwen-max",
        messages=[{"role": "user", "content": step_prompt}],
        response_format={"type": "json_object"},
    )
    steps_json = step_response.choices[0].message.content
    steps = json.loads(steps_json)["steps"]

    # 先返回任务拆解结果
    yield {"step": 0, "name": "任务拆解", "steps": steps}

    # 然后逐个执行步骤
    for step in steps:
        score_prompt = f"""
你是一个招聘评估专家，请执行以下评估步骤：

步骤名称：{step['name']}
任务说明：{step['desc']}

请根据用户提供的评分标准，对 JD 与简历进行评估。
要求输出 JSON，包含：
{{
  "step": {step['id']},
  "name": "{step['name']}",
  "score": 数字,
  "reason": "评分理由"
}}

【评分标准】
{scoring_rules}

【JD 内容】
{jd_text}

【简历内容】
{resume_text}
"""
        score_response = client.chat.completions.create(
            model="qwen-max",
            messages=[{"role": "user", "content": score_prompt}],
            response_format={"type": "json_object"},
        )
        result = score_response.choices[0].message.content
        step_result = safe_json_parse(result)
        yield step_result


if __name__ == "__main__":
    jd = """
岗位要求：
1. 本科及以上学历，计算机相关专业。
2. 熟练掌握 Python、SQL。
3. 具备 3 年以上开发经验。
"""

    resume = """
姓名：张三
学历：研究生，计算机科学与技术
技能：Python，深度学习
工作经历：4 年开发经验
"""

    rules = {
        "学历": {"本科": 5, "研究生": 10, "博士及以上": 20},
        "技能": {"Python": 10, "SQL": 5, "深度学习": 15},
        "年限": {">=3年": 10, "<3年": 5, "<1年": 0},
        "真实性": {"AI生成嫌疑": -10, "具体案例丰富": 10},
    }

    for step_result in evaluate_resume_stepwise(jd, resume, rules):
        print(step_result)
        print("\n")
