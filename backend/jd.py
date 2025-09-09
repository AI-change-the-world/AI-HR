from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import json
import os

router = APIRouter(prefix="/api/jd", tags=["JD管理"])

# JD数据模型
class JobDescription(BaseModel):
    id: int
    title: str
    department: str
    location: str
    status: str = "草稿"
    description: Optional[str] = None

class JDCreate(BaseModel):
    title: str
    department: str
    location: str
    status: str = "草稿"
    description: Optional[str] = None

class JDUpdate(BaseModel):
    title: Optional[str] = None
    department: Optional[str] = None
    location: Optional[str] = None
    status: Optional[str] = None
    description: Optional[str] = None

# 模拟数据库存储
JD_DB_FILE = "job_descriptions.json"

def load_jds():
    """加载JD数据"""
    if os.path.exists(JD_DB_FILE):
        with open(JD_DB_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def save_jds(jds):
    """保存JD数据"""
    with open(JD_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(jds, f, ensure_ascii=False, indent=2)

@router.get("/", response_model=List[JobDescription])
async def list_jds():
    """获取JD列表"""
    jds = load_jds()
    return [JobDescription(**jd) for jd in jds]

@router.post("/", response_model=JobDescription)
async def create_jd(jd: JDCreate):
    """创建JD"""
    jds = load_jds()
    new_id = max([j.get("id", 0) for j in jds], default=0) + 1
    
    new_jd = {
        "id": new_id,
        **jd.dict()
    }
    
    jds.append(new_jd)
    save_jds(jds)
    
    return JobDescription(**new_jd)

@router.get("/{jd_id}", response_model=JobDescription)
async def get_jd(jd_id: int):
    """获取JD详情"""
    jds = load_jds()
    for jd in jds:
        if jd["id"] == jd_id:
            return JobDescription(**jd)
    raise HTTPException(status_code=404, detail="JD未找到")

@router.put("/{jd_id}", response_model=JobDescription)
async def update_jd(jd_id: int, jd_update: JDUpdate):
    """更新JD信息"""
    jds = load_jds()
    for i, jd in enumerate(jds):
        if jd["id"] == jd_id:
            # 更新信息
            update_data = jd_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                if value is not None:
                    jd[key] = value
            
            jds[i] = jd
            save_jds(jds)
            return JobDescription(**jd)
    raise HTTPException(status_code=404, detail="JD未找到")

@router.delete("/{jd_id}")
async def delete_jd(jd_id: int):
    """删除JD"""
    jds = load_jds()
    for i, jd in enumerate(jds):
        if jd["id"] == jd_id:
            jds.pop(i)
            save_jds(jds)
            return {"message": "JD删除成功"}
    raise HTTPException(status_code=404, detail="JD未找到")