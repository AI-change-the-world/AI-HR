from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from typing import Dict, Any, List
import json

from config.database import get_db
from models.jd import JobDescription

from utils.document_parser import parse_document
from .models import JDCreate, JDInDB, JDUpdate, JDFullInfoUpdate, EvaluationCriteriaUpdate
from .service import (
    create_jd, delete_jd, get_jd, get_jds, update_jd, evaluate_resume, 
    update_jd_evaluation_criteria, get_jd_evaluation_criteria, update_jd_full_info,
    polish_jd_text, create_jd_from_text
)

router = APIRouter(prefix="/api/jd", tags=["JD管理"])


@router.post("/", response_model=JDInDB)
async def create_jd_info(jd: JDCreate, db: Session = Depends(get_db)):
    """创建JD"""
    return create_jd(jd, db)


@router.get("/{jd_id}", response_model=JDInDB)
async def read_jd(jd_id: int, db: Session = Depends(get_db)):
    """获取JD详情"""
    jd = get_jd(jd_id, db)
    if jd is None:
        raise HTTPException(status_code=404, detail="JD未找到")
    return jd


@router.get("/", response_model=list[JDInDB])
async def read_jds(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """获取JD列表"""
    return get_jds(skip=skip, limit=limit, db=db)


@router.put("/{jd_id}", response_model=JDInDB)
async def update_jd_info(
    jd_id: int, jd_update: JDUpdate, db: Session = Depends(get_db)
):
    """更新JD信息"""
    jd = update_jd(jd_id, jd_update, db)
    if jd is None:
        raise HTTPException(status_code=404, detail="JD未找到")
    return jd


@router.delete("/{jd_id}")
async def delete_jd_info(jd_id: int, db: Session = Depends(get_db)):
    """删除JD"""
    success = delete_jd(jd_id, db)
    if not success:
        raise HTTPException(status_code=404, detail="JD未找到")
    return {"message": "JD删除成功"}


@router.post("/{jd_id}/evaluate-resume")
async def evaluate_resume_stream(
    jd_id: int,
    resume_file: UploadFile = File(...),
    db: Session = Depends(get_db)
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
            error_data = {"error": f"评估过程中发生错误: {str(e)}", "type": "server_error"}
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
            "Access-Control-Allow-Headers": "*"
        }
    )


@router.put("/{jd_id}/evaluation-criteria")
async def update_evaluation_criteria(
    jd_id: int,
    criteria_data: EvaluationCriteriaUpdate,
    db: Session = Depends(get_db)
):
    """
    更新JD的评估标准
    """
    success = update_jd_evaluation_criteria(jd_id, criteria_data.criteria, db)
    if not success:
        raise HTTPException(status_code=404, detail="JD未找到")
    return {"message": "评估标准更新成功"}


@router.get("/{jd_id}/evaluation-criteria")
async def get_evaluation_criteria(
    jd_id: int,
    db: Session = Depends(get_db)
):
    """
    获取JD的评估标准
    """
    criteria = get_jd_evaluation_criteria(jd_id, db)
    if criteria is None:
        raise HTTPException(status_code=404, detail="JD未找到")
    return {"criteria": criteria}


@router.put("/{jd_id}/full-info")
async def update_jd_full_info_endpoint(
    jd_id: int,
    full_info: JDFullInfoUpdate,
    db: Session = Depends(get_db)
):
    """
    更新JD的完整信息和评估标准
    """
    updated_jd = update_jd_full_info(jd_id, full_info, db)
    if updated_jd is None:
        raise HTTPException(status_code=404, detail="JD未找到")
    return updated_jd


@router.get("/{jd_id}/full-info")
async def get_jd_full_info(
    jd_id: int,
    db: Session = Depends(get_db)
):
    """
    获取JD的完整信息
    """
    jd = get_jd(jd_id, db)
    if jd is None:
        raise HTTPException(status_code=404, detail="JD未找到")
    
    return {
        "full_text": jd.full_text,
        "evaluation_criteria": jd.evaluation_criteria
    }


@router.post("/{jd_id}/extract-keywords")
async def extract_keywords_from_jd(
    jd_id: int,
    request_data: dict,
    db: Session = Depends(get_db)
):
    """
    从完整JD描述中提取关键字并更新JD字段
    """
    # 获取JD
    db_jd = db.query(JobDescription).filter(JobDescription.id == jd_id).first()
    if db_jd is None:
        raise HTTPException(status_code=404, detail="JD未找到")
    
    full_text = request_data.get('full_text', '')
    if not full_text.strip():
        raise HTTPException(status_code=400, detail="完整职位描述不能为空")
    
    try:
        # 调用大模型提取关键字
        from .keyword_extractor import extract_jd_keywords
        extracted_data = extract_jd_keywords(full_text)
        
        # 更新JD字段
        if extracted_data.get('title'):
            db_jd.title = extracted_data['title']
        if extracted_data.get('department'):
            db_jd.department = extracted_data['department']
        if extracted_data.get('location'):
            db_jd.location = extracted_data['location']
        if extracted_data.get('description'):
            db_jd.description = extracted_data['description']
        if extracted_data.get('requirements'):
            db_jd.requirements = extracted_data['requirements']
        if extracted_data.get('salary_range'):
            db_jd.salary_range = extracted_data['salary_range']
            
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
        
        return JDInDB(
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
            evaluation_criteria=evaluation_criteria
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"关键字提取失败: {str(e)}")


@router.post("/polish-text")
async def polish_jd_text_endpoint(request_data: dict):
    """
    AI润色JD文本
    """
    original_text = request_data.get('original_text', '')
    if not original_text.strip():
        raise HTTPException(status_code=400, detail="原始文本不能为空")
    
    try:
        polished_text = polish_jd_text(original_text)
        return {"polished_text": polished_text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"润色失败: {str(e)}")


@router.post("/create-from-text", response_model=JDInDB)
async def create_jd_from_text_endpoint(
    request_data: dict,
    db: Session = Depends(get_db)
):
    """
    从文本创建JD
    """
    text = request_data.get('text', '')
    if not text.strip():
        raise HTTPException(status_code=400, detail="文本内容不能为空")
    
    try:
        jd = create_jd_from_text(text, db)
        return jd
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"创建JD失败: {str(e)}")
