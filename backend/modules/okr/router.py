from fastapi import APIRouter, HTTPException
from .models import OKRCreate, OKRUpdate, OKRInDB
from .service import create_okr, get_okr, get_okrs, update_okr, delete_okr

router = APIRouter(
    prefix="/api/okr",
    tags=["OKR/KPI管理"]
)

@router.post("/", response_model=OKRInDB)
async def create_okr_info(okr: OKRCreate):
    """创建OKR"""
    return create_okr(okr)

@router.get("/{okr_id}", response_model=OKRInDB)
async def read_okr(okr_id: int):
    """获取OKR详情"""
    okr = get_okr(okr_id)
    if okr is None:
        raise HTTPException(status_code=404, detail="OKR未找到")
    return okr

@router.get("/", response_model=list[OKRInDB])
async def read_okrs(skip: int = 0, limit: int = 100):
    """获取OKR列表"""
    return get_okrs(skip=skip, limit=limit)

@router.put("/{okr_id}", response_model=OKRInDB)
async def update_okr_info(okr_id: int, okr_update: OKRUpdate):
    """更新OKR信息"""
    okr = update_okr(okr_id, okr_update)
    if okr is None:
        raise HTTPException(status_code=404, detail="OKR未找到")
    return okr

@router.delete("/{okr_id}")
async def delete_okr_info(okr_id: int):
    """删除OKR"""
    success = delete_okr(okr_id)
    if not success:
        raise HTTPException(status_code=404, detail="OKR未找到")
    return {"message": "OKR删除成功"}