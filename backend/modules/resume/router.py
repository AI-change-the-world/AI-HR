from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session
from sse_starlette import EventSourceResponse

from config.database import get_db

from .models import ResumeCreate, ResumeInDB, ResumeUpdate
from .service import (
    delete_resume,
    get_resume,
    get_resumes,
    process_resume_stream,
    update_resume,
)

router = APIRouter(prefix="/api/resumes", tags=["简历管理"])


@router.post(
    "/upload-stream",
    response_class=EventSourceResponse,
    responses={200: {"description": "SSE 流式响应", "content": {}}},
    description="流式上传简历，返回 Server-Sent Events (SSE)",
)
async def upload_resume_stream(file: UploadFile = File(...)):
    """
    流式上传和处理简历（SSE）
    """

    async def error_generator(message: str):
        yield {"data": message}  # SSE 格式：data: ...\n\n

    if not file.filename.endswith((".pdf", ".docx")):
        return EventSourceResponse(error_generator("只支持PDF和DOCX格式的文件"))

    # 正常返回流式处理生成器
    return EventSourceResponse(process_resume_stream(file))


@router.get("/{resume_id}", response_model=ResumeInDB)
async def read_resume(resume_id: int, db: Session = Depends(get_db)):
    """获取简历详情"""
    resume = get_resume(resume_id, db)
    if resume is None:
        raise HTTPException(status_code=404, detail="简历未找到")
    return resume


@router.get("/", response_model=list[ResumeInDB])
async def read_resumes(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """获取简历列表"""
    return get_resumes(skip=skip, limit=limit, db=db)


@router.put("/{resume_id}", response_model=ResumeInDB)
async def update_resume_info(
    resume_id: int, resume_update: ResumeUpdate, db: Session = Depends(get_db)
):
    """更新简历信息"""
    update_data = resume_update.dict(exclude_unset=True)
    resume = update_resume(resume_id, update_data, db)
    if resume is None:
        raise HTTPException(status_code=404, detail="简历未找到")
    return resume


@router.delete("/{resume_id}")
async def delete_resume_info(resume_id: int, db: Session = Depends(get_db)):
    """删除简历"""
    success = delete_resume(resume_id, db)
    if not success:
        raise HTTPException(status_code=404, detail="简历未找到")
    return {"message": "简历删除成功"}
