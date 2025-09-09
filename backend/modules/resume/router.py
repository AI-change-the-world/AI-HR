from fastapi import APIRouter, UploadFile, File, HTTPException
from .models import ResumeCreate, ResumeUpdate, ResumeInDB
from .service import create_resume, get_resume, get_resumes, update_resume, delete_resume

router = APIRouter(
    prefix="/api/resumes",
    tags=["简历管理"]
)

@router.post("/upload")
async def upload_resume(file: UploadFile = File(...)):
    """上传简历"""
    try:
        # 读取文件内容
        content = await file.read()
        content_str = content.decode('utf-8')
        
        # 创建简历对象
        resume_create = ResumeCreate(filename=file.filename)
        
        # 保存简历
        resume = create_resume(resume_create, content_str)
        
        return {
            "message": "简历上传成功",
            "resume": resume
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"上传失败: {str(e)}")

@router.get("/{resume_id}", response_model=ResumeInDB)
async def read_resume(resume_id: int):
    """获取简历详情"""
    resume = get_resume(resume_id)
    if resume is None:
        raise HTTPException(status_code=404, detail="简历未找到")
    return resume

@router.get("/", response_model=list[ResumeInDB])
async def read_resumes(skip: int = 0, limit: int = 100):
    """获取简历列表"""
    return get_resumes(skip=skip, limit=limit)

@router.put("/{resume_id}", response_model=ResumeInDB)
async def update_resume_info(resume_id: int, resume_update: ResumeUpdate):
    """更新简历信息"""
    resume = update_resume(resume_id, resume_update)
    if resume is None:
        raise HTTPException(status_code=404, detail="简历未找到")
    return resume

@router.delete("/{resume_id}")
async def delete_resume_info(resume_id: int):
    """删除简历"""
    success = delete_resume(resume_id)
    if not success:
        raise HTTPException(status_code=404, detail="简历未找到")
    return {"message": "简历删除成功"}