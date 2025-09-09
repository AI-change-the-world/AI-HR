from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import os
import json
from datetime import datetime
import employee
import department
import jd
import okr

app = FastAPI(title="AI HR 后端服务", description="AI HR 简历管理系统后端API", version="1.0.0")

# 添加CORS中间件，允许前端访问
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 包含各个模块的路由
app.include_router(employee.router)
app.include_router(department.router)
app.include_router(jd.router)
app.include_router(okr.router)

# 简历数据模型
class Resume(BaseModel):
    id: int
    filename: str
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    education: Optional[str] = None
    experience: Optional[str] = None
    skills: Optional[str] = None
    position: Optional[str] = None
    status: str = "待筛选"
    score: float = 0.0
    created_at: str

class ResumeResponse(BaseModel):
    message: str
    resume: Resume

# 模拟数据库存储
RESUME_DB_FILE = "resumes.json"

def load_resumes():
    """加载简历数据"""
    if os.path.exists(RESUME_DB_FILE):
        with open(RESUME_DB_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def save_resumes(resumes):
    """保存简历数据"""
    with open(RESUME_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(resumes, f, ensure_ascii=False, indent=2)

def extract_resume_info(content: str) -> dict:
    """从文件内容中提取简历信息"""
    # 简单的信息提取逻辑
    info = {
        "name": None,
        "email": None,
        "phone": None,
        "education": None,
        "experience": None,
        "skills": None,
        "position": None
    }
    
    # 这里可以添加更复杂的解析逻辑
    # 现在只是简单示例
    lines = content.split('\n')
    if lines:
        info["name"] = lines[0].strip() if lines[0].strip() else "未知"
    
    # 查找邮箱
    for line in lines:
        if '@' in line and '.' in line:
            info["email"] = line.strip()
            break
    
    return info

@app.get("/")
async def root():
    return {"message": "AI HR 后端服务已启动"}

@app.post("/api/resumes/upload", response_model=ResumeResponse)
async def upload_resume(file: UploadFile = File(...)):
    """上传简历接口"""
    try:
        # 读取文件内容
        content = await file.read()
        content_str = content.decode('utf-8')
        
        # 提取简历信息
        resume_info = extract_resume_info(content_str)
        
        # 创建简历记录
        resumes = load_resumes()
        new_id = max([r.get("id", 0) for r in resumes], default=0) + 1
        
        resume = {
            "id": new_id,
            "filename": file.filename,
            "created_at": datetime.now().isoformat(),
            "status": "待筛选",
            "score": 0.0,
            **resume_info
        }
        
        # 保存简历
        resumes.append(resume)
        save_resumes(resumes)
        
        return ResumeResponse(
            message="简历上传成功",
            resume=Resume(**resume)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"上传失败: {str(e)}")

@app.get("/api/resumes")
async def list_resumes():
    """获取简历列表"""
    resumes = load_resumes()
    return [Resume(**resume) for resume in resumes]

@app.get("/api/resumes/{resume_id}")
async def get_resume(resume_id: int):
    """获取单个简历详情"""
    resumes = load_resumes()
    for resume in resumes:
        if resume["id"] == resume_id:
            return Resume(**resume)
    raise HTTPException(status_code=404, detail="简历未找到")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)