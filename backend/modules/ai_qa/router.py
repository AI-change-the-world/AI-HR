import traceback
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from config.database import get_db
from modules import BaseResponse
from .models import ChatRequest, AIChatResponse
from .service import process_employee_query
from common.logger import logger
from utils.logger_format_utils import log_safe_json

router = APIRouter(prefix="/api/ai-qa", tags=["AI问答"])


@router.post("/chat", response_model=BaseResponse[AIChatResponse])
async def chat_with_ai(
    request: ChatRequest,
    db: Session = Depends(get_db)
):
    """
    与AI助手聊天
    
    Args:
        request: 聊天请求，包含用户消息
        db: 数据库会话
        
    Returns:
        AI助手的回复，可能包含文本和图表数据
    """
    try:
        # 处理用户查询
        result = process_employee_query(request.message, db) 
        
        # 检查结果并构造响应
        if result is None:
            return BaseResponse(
                code=500,
                message="处理请求时发生错误: 未返回有效结果",
                data=None
            )
        
        # 构造响应
        response_data = AIChatResponse(
            message=result.get("message", ""),
            chart_data=result.get("chart_data"),
            raw_data=result.get("raw_data")
        )
        
        return BaseResponse(
            code=200,
            message="success",
            data=response_data
        )
    except Exception as e:
        # logger.error(f"处理AI问答请求时发生错误: {str(e)}")
        log_safe_json(logger, "处理AI问答请求时发生错误", {"error": str(e)})
        traceback.print_exc()
        return BaseResponse(
            code=500,
            message=f"处理请求时发生错误: {str(e)}",
            data=None
        )