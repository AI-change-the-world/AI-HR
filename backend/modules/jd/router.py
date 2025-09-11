from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from typing import Dict, Any, List
import json

from config.database import get_db

from utils.document_parser import parse_document
from .models import JDCreate, JDInDB, JDUpdate
from .service import create_jd, delete_jd, get_jd, get_jds, update_jd, evaluate_resume, update_jd_evaluation_criteria, get_jd_evaluation_criteria

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
async def evaluate_resume_endpoint(
    jd_id: int,
    resume_file: UploadFile = File(...),
    scoring_rules: str = None,
    db: Session = Depends(get_db)
):
    """
    评估简历与JD的匹配度
    """
    filename = resume_file.filename
    file_extension = filename.split(".")[-1]

    # 读取简历文件内容
    resume_content = parse_document(await resume_file.read(), file_extension)
    
    # 解析评分规则
    rules = {}
    if scoring_rules:
        try:
            rules = json.loads(scoring_rules)
        except json.JSONDecodeError:
            raise HTTPException(status_code=400, detail="评分规则格式错误")
    
    # 调用评估服务
    try:
        evaluation_results = []
        for result in evaluate_resume(jd_id, resume_content, rules, db):
            evaluation_results.append(result)
        return {"results": evaluation_results}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"评估过程中发生错误: {str(e)}")


@router.put("/{jd_id}/evaluation-criteria")
async def update_evaluation_criteria(
    jd_id: int,
    criteria_data: Dict[str, Any],
    db: Session = Depends(get_db)
):
    """
    更新JD的评估标准
    """
    success = update_jd_evaluation_criteria(jd_id, criteria_data.get("criteria", {}), db)
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