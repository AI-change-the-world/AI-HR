import asyncio
import json
import os
from datetime import datetime
from typing import List, Optional

from fastapi import UploadFile
from fastapi.responses import StreamingResponse
from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from config.database import SessionLocal, engine

# 创建数据库表
from models import department, employee, jd, okr, resume
from models.resume import Resume
from utils.document_parser import parse_document
from utils.jd_matcher import find_best_match
from utils.llm_mock import mock_llm_analysis

resume.Base.metadata.create_all(bind=engine)


def extract_resume_info(content: str) -> dict:
    """从文件内容中提取简历信息（模拟实现）"""
    # 简单的信息提取逻辑
    info = {
        "name": None,
        "email": None,
        "phone": None,
        "education": None,
        "experience": None,
        "skills": None,
        "position": None,
    }

    # 这里可以添加更复杂的解析逻辑
    # 现在只是简单示例
    lines = content.split("\n")
    if lines:
        info["name"] = lines[0].strip() if lines[0].strip() else "未知"

    # 查找邮箱
    for line in lines:
        if "@" in line and "." in line:
            info["email"] = line.strip()
            break

    return info


async def process_resume_stream(file: UploadFile) -> StreamingResponse:
    """流式处理简历上传"""

    async def event_generator():
        try:
            # 步骤1: 读取内容
            yield f"data: {json.dumps({'status': 'reading', 'message': '正在读取文件内容...'})}\n\n"

            # 读取文件内容
            file_content = await file.read()
            file_extension = os.path.splitext(file.filename)[1]

            # 解析文档内容
            try:
                content = parse_document(file_content, file_extension)
                yield f"data: {json.dumps({'status': 'parsed', 'message': '文件解析完成'})}\n\n"
            except Exception as e:
                yield f"data: {json.dumps({'status': 'error', 'message': f'文件解析失败: {str(e)}'})}\n\n"
                return

            # 步骤2: 用大模型分析要点
            yield f"data: {json.dumps({'status': 'analyzing', 'message': '正在使用AI分析简历...'})}\n\n"

            # 使用模拟的大模型分析
            async for chunk in mock_llm_analysis(content):
                yield chunk

            # 步骤3: 与JD匹配
            yield f"data: {json.dumps({'status': 'matching', 'message': '正在匹配职位描述...'})}\n\n"

            # 查找最佳匹配的JD
            best_jd, match_score = find_best_match(content)

            # 保存到数据库
            db = SessionLocal()
            try:
                # 创建简历记录
                now = datetime.now()
                resume_dict = {
                    "filename": file.filename,
                    "content": content,
                    "status": "已处理",
                    "score": match_score if match_score > 0 else 0.0,
                    "matched_jd_id": best_jd.id if best_jd else None,
                    "match_score": match_score,
                    "created_at": now,
                    "updated_at": now,
                    **extract_resume_info(content),
                }

                db_resume = Resume(**resume_dict)
                db.add(db_resume)
                db.commit()
                db.refresh(db_resume)

                yield f"data: {json.dumps({'status': 'saved', 'message': '简历已保存到数据库', 'resume_id': db_resume.id})}\n\n"
            except Exception as e:
                db.rollback()
                yield f"data: {json.dumps({'status': 'error', 'message': f'数据库保存失败: {str(e)}'})}\n\n"
            finally:
                db.close()

            # 完成
            yield f"data: {json.dumps({'status': 'completed', 'message': '简历处理完成'})}\n\n"

        except Exception as e:
            yield f"data: {json.dumps({'status': 'error', 'message': f'处理过程中发生错误: {str(e)}'})}\n\n"
        finally:
            yield "data: [DONE]\n\n"

    return StreamingResponse(event_generator(), media_type="text/event-stream")


def get_resume(resume_id: int, db: Session) -> Optional[Resume]:
    """获取指定ID的简历"""
    return db.query(Resume).filter(Resume.id == resume_id).first()


def get_resumes(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> List[Resume]:
    """获取简历列表"""
    return db.query(Resume).offset(skip).limit(limit).all()


def update_resume(resume_id: int, resume_update: dict, db: Session) -> Optional[Resume]:
    """更新简历"""
    db_resume = db.query(Resume).filter(Resume.id == resume_id).first()
    if db_resume:
        for key, value in resume_update.items():
            setattr(db_resume, key, value)
        db_resume.updated_at = datetime.now()
        db.commit()
        db.refresh(db_resume)
        return db_resume
    return None


def delete_resume(resume_id: int, db: Session) -> bool:
    """删除简历"""
    db_resume = db.query(Resume).filter(Resume.id == resume_id).first()
    if db_resume:
        db.delete(db_resume)
        db.commit()
        return True
    return False
