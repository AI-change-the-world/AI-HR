from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from config.database import get_db

from .models import JDCreate, JDInDB, JDUpdate
from .service import create_jd, delete_jd, get_jd, get_jds, update_jd

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
