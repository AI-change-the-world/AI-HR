from typing import Optional, Any

from pydantic import BaseModel


class ChatMessage(BaseModel):
    """聊天消息模型"""
    text: str
    is_user: bool = True


class ChatRequest(BaseModel):
    """聊天请求模型"""
    message: str


class EmployeeStatsResponse(BaseModel):
    """员工统计响应模型"""
    total: int
    active: int
    inactive: int
    pending: int
    department_stats: dict[str, int]


class IntentResponse(BaseModel):
    """意图识别响应模型"""
    intent: str
    parameters: dict[str, Any]
    confidence: float


class ChartData(BaseModel):
    """图表数据模型"""
    type: str  # 图表类型: 'bar', 'pie', 'line'
    title: str
    data: dict[str, Any]


class AIChatResponse(BaseModel):
    """AI聊天响应模型"""
    message: str
    chart_data: Optional[ChartData] = None
    raw_data: Optional[dict[str, Any]] = None