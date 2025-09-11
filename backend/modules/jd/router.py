import asyncio
import json
from typing import Any, Dict, List

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from sse_starlette.sse import EventSourceResponse

from config.database import get_db
from models.jd import JobDescription
from modules import BaseResponse, PageResponse
from utils.document_parser import parse_document

from .models import (
    EvaluationCriteriaUpdate,
    JDCreate,
    JDFullInfoUpdate,
    JDInDB,
    JDUpdate,
)
from .service import (
    create_jd,
    create_jd_from_text,
    delete_jd,
    evaluate_resume,
    get_jd,
    get_jd_evaluation_criteria,
    get_jds,
    polish_jd_text,
    update_jd,
    update_jd_evaluation_criteria,
    update_jd_full_info,
)

router = APIRouter(prefix="/api/jd", tags=["JD管理"])


@router.post("/", response_model=BaseResponse[JDInDB])
async def create_jd_info(jd: JDCreate, db: Session = Depends(get_db)):
    """创建JD"""
    try:
        result = create_jd(jd, db)
        return BaseResponse(data=result)
    except Exception as e:
        return BaseResponse(code=500, message=f"创建JD失败: {str(e)}", data=None)


@router.get("/{jd_id}", response_model=BaseResponse[JDInDB])
async def read_jd(jd_id: int, db: Session = Depends(get_db)):
    """获取JD详情"""
    try:
        jd = get_jd(jd_id, db)
        if jd is None:
            return BaseResponse(code=404, message="JD未找到", data=None)
        return BaseResponse(data=jd)
    except Exception as e:
        return BaseResponse(code=500, message=f"获取JD失败: {str(e)}", data=None)


@router.get("/", response_model=BaseResponse[PageResponse[JDInDB]])
async def read_jds(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """获取JD列表"""
    try:
        jds = get_jds(skip=skip, limit=limit, db=db)
        # 获取总数
        total = db.query(JobDescription).count()
        page_response = PageResponse(total=total, data=jds)
        return BaseResponse(data=page_response)
    except Exception as e:
        return BaseResponse(code=500, message=f"获取JD列表失败: {str(e)}", data=None)


@router.put("/{jd_id}", response_model=BaseResponse[JDInDB])
async def update_jd_info(
    jd_id: int, jd_update: JDUpdate, db: Session = Depends(get_db)
):
    """更新JD信息"""
    try:
        jd = update_jd(jd_id, jd_update, db)
        if jd is None:
            return BaseResponse(code=404, message="JD未找到", data=None)
        return BaseResponse(data=jd)
    except Exception as e:
        return BaseResponse(code=500, message=f"更新JD失败: {str(e)}", data=None)


@router.delete("/{jd_id}", response_model=BaseResponse[dict])
async def delete_jd_info(jd_id: int, db: Session = Depends(get_db)):
    """删除JD"""
    try:
        success = delete_jd(jd_id, db)
        if not success:
            return BaseResponse(code=404, message="JD未找到", data=None)
        return BaseResponse(data={"message": "JD删除成功"})
    except Exception as e:
        return BaseResponse(code=500, message=f"删除JD失败: {str(e)}", data=None)


@router.post("/{jd_id}/evaluate-resume")
async def evaluate_resume_stream(
    jd_id: int, resume_file: UploadFile = File(...), db: Session = Depends(get_db)
):
    """
    流式评估简历与JD的匹配度
    """
    filename = resume_file.filename
    file_extension = filename.split(".")[-1]

    # 读取简历文件内容
    resume_content = parse_document(await resume_file.read(), file_extension)

    def generate_evaluation_stream():
        try:
            for result in evaluate_resume(jd_id, resume_content, db):
                yield f"data: {json.dumps(result, ensure_ascii=False)}\n\n"
        except ValueError as e:
            error_data = {"error": str(e), "type": "not_found"}
            yield f"data: {json.dumps(error_data, ensure_ascii=False)}\n\n"
        except Exception as e:
            error_data = {
                "error": f"评估过程中发生错误: {str(e)}",
                "type": "server_error",
            }
            yield f"data: {json.dumps(error_data, ensure_ascii=False)}\n\n"
        finally:
            # 发送结束信号
            yield "data: [DONE]\n\n"

    return StreamingResponse(
        generate_evaluation_stream(),
        media_type="text/plain",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
        },
    )


@router.put("/{jd_id}/evaluation-criteria", response_model=BaseResponse[dict])
async def update_evaluation_criteria(
    jd_id: int, criteria_data: EvaluationCriteriaUpdate, db: Session = Depends(get_db)
):
    """
    更新JD的评估标准
    """
    try:
        success = update_jd_evaluation_criteria(jd_id, criteria_data.criteria, db)
        if not success:
            return BaseResponse(code=404, message="JD未找到", data=None)
        return BaseResponse(data={"message": "评估标准更新成功"})
    except Exception as e:
        return BaseResponse(code=500, message=f"更新评估标准失败: {str(e)}", data=None)


@router.get("/{jd_id}/evaluation-criteria", response_model=BaseResponse[dict])
async def get_evaluation_criteria(jd_id: int, db: Session = Depends(get_db)):
    """
    获取JD的评估标准
    """
    try:
        criteria = get_jd_evaluation_criteria(jd_id, db)
        if criteria is None:
            return BaseResponse(code=404, message="JD未找到", data=None)
        return BaseResponse(data={"criteria": criteria})
    except Exception as e:
        return BaseResponse(code=500, message=f"获取评估标准失败: {str(e)}", data=None)


@router.put("/{jd_id}/full-info", response_model=BaseResponse[JDInDB])
async def update_jd_full_info_endpoint(
    jd_id: int, full_info: JDFullInfoUpdate, db: Session = Depends(get_db)
):
    """
    更新JD的完整信息和评估标准
    """
    try:
        updated_jd = update_jd_full_info(jd_id, full_info, db)
        if updated_jd is None:
            return BaseResponse(code=404, message="JD未找到", data=None)
        return BaseResponse(data=updated_jd)
    except Exception as e:
        return BaseResponse(
            code=500, message=f"更新JD完整信息失败: {str(e)}", data=None
        )


@router.get("/{jd_id}/full-info", response_model=BaseResponse[dict])
async def get_jd_full_info(jd_id: int, db: Session = Depends(get_db)):
    """
    获取JD的完整信息
    """
    try:
        jd = get_jd(jd_id, db)
        if jd is None:
            return BaseResponse(code=404, message="JD未找到", data=None)

        return BaseResponse(
            data={
                "full_text": jd.full_text,
                "evaluation_criteria": jd.evaluation_criteria,
            }
        )
    except Exception as e:
        return BaseResponse(
            code=500, message=f"获取JD完整信息失败: {str(e)}", data=None
        )


@router.post("/{jd_id}/extract-keywords", response_model=BaseResponse[JDInDB])
async def extract_keywords_from_jd(
    jd_id: int, request_data: dict, db: Session = Depends(get_db)
):
    """
    从完整JD描述中提取关键字并更新JD字段
    """
    try:
        # 获取JD
        db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
        if db_jd is None:
            return BaseResponse(code=404, message="JD未找到", data=None)

        full_text = request_data.get("full_text", "")
        if not full_text.strip():
            return BaseResponse(code=400, message="完整职位描述不能为空", data=None)

        # 调用大模型提取关键字
        from .keyword_extractor import extract_jd_keywords

        extracted_data = extract_jd_keywords(full_text)

        # 更新JD字段
        if extracted_data.get("title"):
            db_jd.title = extracted_data["title"]
        if extracted_data.get("department"):
            db_jd.department = extracted_data["department"]
        if extracted_data.get("location"):
            db_jd.location = extracted_data["location"]
        if extracted_data.get("description"):
            db_jd.description = extracted_data["description"]
        if extracted_data.get("requirements"):
            db_jd.requirements = extracted_data["requirements"]
        if extracted_data.get("salary_range"):
            db_jd.salary_range = extracted_data["salary_range"]

        # 更新full_text
        db_jd.full_text = full_text

        db.commit()
        db.refresh(db_jd)

        # 返回更新后的JD信息
        # 解析evaluation_criteria
        evaluation_criteria = None
        if db_jd.evaluation_criteria:
            try:
                evaluation_criteria = json.loads(db_jd.evaluation_criteria)
            except json.JSONDecodeError:
                evaluation_criteria = None

        result = JDInDB(
            id=db_jd.id,
            title=db_jd.title,
            department=db_jd.department,
            location=db_jd.location,
            description=db_jd.description,
            requirements=db_jd.requirements,
            status="开放" if db_jd.is_open else "关闭",
            created_at=db_jd.created_at,
            updated_at=db_jd.updated_at,
            full_text=db_jd.full_text,
            evaluation_criteria=evaluation_criteria,
        )

        return BaseResponse(data=result)

    except Exception as e:
        return BaseResponse(code=500, message=f"关键字提取失败: {str(e)}", data=None)


@router.post("/polish-text")
async def polish_jd_text_endpoint(request_data: dict):
    """
    AI润色JD文本 - 流式接口
    """
    original_text = request_data.get("original_text", "")
    if not original_text.strip():
        # 对于验证错误，直接返回错误响应
        return BaseResponse(code=400, message="原始文本不能为空", data=None)

    async def generate_polish_stream():
        try:
            # 发送开始信号
            yield json.dumps({
                "event": "start",
                "data": {"message": "开始AI润色处理..."}
            }, ensure_ascii=False)
            
            # 模拟分步处理（实际可以根据需要调整）
            yield json.dumps({
                "event": "progress", 
                "data": {"message": "正在分析文本内容...", "progress": 20}
            }, ensure_ascii=False)
            
            await asyncio.sleep(0.5)  # 模拟处理时间
            
            yield json.dumps({
                "event": "progress",
                "data": {"message": "正在生成润色文本...", "progress": 60}
            }, ensure_ascii=False)
            
            # 调用润色服务
            polished_text = polish_jd_text(original_text)
            
            yield json.dumps({
                "event": "progress",
                "data": {"message": "润色完成，正在格式化...", "progress": 90}
            }, ensure_ascii=False)
            
            await asyncio.sleep(0.2)
            
            # 发送最终结果
            yield json.dumps({
                "event": "complete",
                "data": {
                    "polished_text": polished_text,
                    "message": "AI润色完成",
                    "progress": 100
                }
            }, ensure_ascii=False)
            
        except Exception as e:
            yield json.dumps({
                "event": "error",
                "data": {"message": f"润色失败: {str(e)}"}
            }, ensure_ascii=False)

    return EventSourceResponse(generate_polish_stream())


@router.post("/create-from-text", response_model=BaseResponse[JDInDB])
async def create_jd_from_text_endpoint(
    request_data: dict, db: Session = Depends(get_db)
):
    """
    从文本创建JD
    """
    try:
        text = request_data.get("text", "")
        if not text.strip():
            return BaseResponse(code=400, message="文本内容不能为空", data=None)

        jd = create_jd_from_text(text, db)
        return BaseResponse(data=jd)
    except Exception as e:
        return BaseResponse(code=500, message=f"创建JD失败: {str(e)}", data=None)
