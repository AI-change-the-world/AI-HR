from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import json
import os

router = APIRouter(prefix="/api/okr", tags=["OKR/KPI管理"])

# OKR数据模型
class KeyResult(BaseModel):
    id: int
    description: str
    target: float
    current: float

class OKR(BaseModel):
    id: int
    objective: str
    quarter: str
    progress: float = 0.0
    owner: str
    key_results: List[KeyResult] = []

class OKRCreate(BaseModel):
    objective: str
    quarter: str
    owner: str

class OKRUpdate(BaseModel):
    objective: Optional[str] = None
    quarter: Optional[str] = None
    progress: Optional[float] = None
    owner: Optional[str] = None

# 模拟数据库存储
OKR_DB_FILE = "okrs.json"

def load_okrs():
    """加载OKR数据"""
    if os.path.exists(OKR_DB_FILE):
        with open(OKR_DB_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def save_okrs(okrs):
    """保存OKR数据"""
    with open(OKR_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(okrs, f, ensure_ascii=False, indent=2)

@router.get("/", response_model=List[OKR])
async def list_okrs():
    """获取OKR列表"""
    okrs = load_okrs()
    return [OKR(**okr) for okr in okrs]

@router.post("/", response_model=OKR)
async def create_okr(okr: OKRCreate):
    """创建OKR"""
    okrs = load_okrs()
    new_id = max([o.get("id", 0) for o in okrs], default=0) + 1
    
    new_okr = {
        "id": new_id,
        "progress": 0.0,
        "key_results": [],
        **okr.dict()
    }
    
    okrs.append(new_okr)
    save_okrs(okrs)
    
    return OKR(**new_okr)

@router.get("/{okr_id}", response_model=OKR)
async def get_okr(okr_id: int):
    """获取OKR详情"""
    okrs = load_okrs()
    for okr in okrs:
        if okr["id"] == okr_id:
            return OKR(**okr)
    raise HTTPException(status_code=404, detail="OKR未找到")

@router.put("/{okr_id}", response_model=OKR)
async def update_okr(okr_id: int, okr_update: OKRUpdate):
    """更新OKR信息"""
    okrs = load_okrs()
    for i, okr in enumerate(okrs):
        if okr["id"] == okr_id:
            # 更新信息
            update_data = okr_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                if value is not None:
                    okr[key] = value
            
            okrs[i] = okr
            save_okrs(okrs)
            return OKR(**okr)
    raise HTTPException(status_code=404, detail="OKR未找到")

@router.delete("/{okr_id}")
async def delete_okr(okr_id: int):
    """删除OKR"""
    okrs = load_okrs()
    for i, okr in enumerate(okrs):
        if okr["id"] == okr_id:
            okrs.pop(i)
            save_okrs(okrs)
            return {"message": "OKR删除成功"}
    raise HTTPException(status_code=404, detail="OKR未找到")