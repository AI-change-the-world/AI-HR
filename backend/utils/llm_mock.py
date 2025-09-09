import asyncio
import json
from typing import AsyncGenerator


async def mock_llm_analysis(content: str) -> AsyncGenerator[str, None]:
    """模拟大模型分析过程，流式返回结果"""
    # 模拟分析步骤
    steps = [
        {"status": "开始解析简历内容", "progress": 10},
        {"status": "提取关键信息", "progress": 30},
        {"status": "分析技能匹配度", "progress": 50},
        {"status": "检查工作经历相关性", "progress": 70},
        {"status": "生成匹配报告", "progress": 90},
        {"status": "完成分析", "progress": 100},
    ]

    for step in steps:
        # 模拟处理时间
        await asyncio.sleep(0.5)

        # 生成模拟的分析结果
        if step["progress"] == 100:
            result = {
                "name": "张三",
                "email": "zhangsan@example.com",
                "phone": "13800138000",
                "education": "计算机科学硕士",
                "experience": "5年软件开发经验",
                "skills": "Python, Java, React, MySQL",
                "position": "高级软件工程师",
                "score": 8.5,
                "analysis": "候选人具备丰富的软件开发经验，技能匹配度高",
            }
            yield f"data: {json.dumps({'status': 'completed', 'result': result})}\n\n"
        else:
            yield f"data: {json.dumps(step)}\n\n"
