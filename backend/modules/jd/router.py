from fastapi import APIRouter, HTTPException
from .models import JDCreate, JDUpdate, JDInDB
from .service import create_jd, get_jd, get_jds, update_jd, delete_jd

router = APIRouter(
    prefix="/api/jd",
    tags=["JD管理"]
)

@router.post("/", response_model=JDInDB)
async def create_jd_info(jd: JDCreate):
    """创建JD"""
    return create_jd(jd)

@router.get("/{jd_id}", response_model=JDInDB)
async def read_jd(jd_id: int):
    """获取JD详情"""
    jd = get_jd(jd_id)
    if jd is None:
        raise HTTPException(status_code=404, detail="JD未找到")
    return jd

@router.get("/", response_model=list[JDInDB])
async def read_jds(skip: int = 0, limit: int = 100):
    """获取JD列表"""
    return get_jds(skip=skip, limit=limit)

@router.put("/{jd_id}", response_model=JDInDB)
async def update_jd_info(jd_id: int, jd_update: JDUpdate):
    """更新JD信息"""
    jd = update_jd(jd_id, jd_update)
    if jd is None:
        raise HTTPException(status_code=404, detail="JD未找到")
    return jd

@router.delete("/{jd_id}")
async def delete_jd_info(jd_id: int):
    """删除JD"""
    success = delete_jd(jd_id)
    if not success:
        raise HTTPException(status_code=404, detail="JD未找到")
    return {"message": "JD删除成功"}