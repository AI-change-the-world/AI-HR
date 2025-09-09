import os
import json
from typing import List, Optional
from .models import OKRCreate, OKRUpdate, OKRInDB, KeyResult

# OKR数据文件路径
OKR_DB_FILE = "data/okrs.json"

def init_data_dir():
    """初始化数据目录"""
    data_dir = "data"
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)
    
    # 如果OKR数据库文件不存在，创建一个空的
    if not os.path.exists(OKR_DB_FILE):
        with open(OKR_DB_FILE, 'w', encoding='utf-8') as f:
            json.dump([], f)

def load_okrs() -> List[dict]:
    """加载所有OKR"""
    init_data_dir()
    with open(OKR_DB_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_okrs(okrs: List[dict]):
    """保存OKR列表"""
    init_data_dir()
    with open(OKR_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(okrs, f, ensure_ascii=False, indent=2)

def get_next_id() -> int:
    """获取下一个可用ID"""
    okrs = load_okrs()
    if not okrs:
        return 1
    return max(okr['id'] for okr in okrs) + 1

def create_okr(okr_create: OKRCreate) -> OKRInDB:
    """创建新OKR"""
    # 创建OKR记录
    okr_dict = {
        "id": get_next_id(),
        "key_results": [],
        **okr_create.dict()
    }
    
    # 保存到数据库
    okrs = load_okrs()
    okrs.append(okr_dict)
    save_okrs(okrs)
    
    return OKRInDB(**okr_dict)

def get_okr(okr_id: int) -> Optional[OKRInDB]:
    """获取指定ID的OKR"""
    okrs = load_okrs()
    for okr in okrs:
        if okr["id"] == okr_id:
            return OKRInDB(**okr)
    return None

def get_okrs(skip: int = 0, limit: int = 100) -> List[OKRInDB]:
    """获取OKR列表"""
    okrs = load_okrs()
    # 分页处理
    paginated = okrs[skip:skip + limit]
    return [OKRInDB(**okr) for okr in paginated]

def update_okr(okr_id: int, okr_update: OKRUpdate) -> Optional[OKRInDB]:
    """更新OKR"""
    okrs = load_okrs()
    for i, okr in enumerate(okrs):
        if okr["id"] == okr_id:
            # 更新字段
            update_data = okr_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                if value is not None:
                    okr[key] = value
            
            # 保存更新
            okrs[i] = okr
            save_okrs(okrs)
            
            return OKRInDB(**okr)
    return None

def delete_okr(okr_id: int) -> bool:
    """删除OKR"""
    okrs = load_okrs()
    for i, okr in enumerate(okrs):
        if okr["id"] == okr_id:
            okrs.pop(i)
            save_okrs(okrs)
            return True
    return False