import os
import json
from typing import List, Optional
from .models import JDCreate, JDUpdate, JDInDB

# JD数据文件路径
JD_DB_FILE = "data/job_descriptions.json"

def init_data_dir():
    """初始化数据目录"""
    data_dir = "data"
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)
        # 初始化空的JSON文件
        init_files = [
            "data/resumes.json",
            "data/employees.json", 
            "data/departments.json",
            "data/job_descriptions.json",
            "data/okrs.json"
        ]
        
        for file_path in init_files:
            if not os.path.exists(file_path):
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump([], f)

def load_jds() -> List[dict]:
    """加载所有JD"""
    init_data_dir()
    with open(JD_DB_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_jds(jds: List[dict]):
    """保存JD列表"""
    init_data_dir()
    with open(JD_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(jds, f, ensure_ascii=False, indent=2)

def get_next_id() -> int:
    """获取下一个可用ID"""
    jds = load_jds()
    if not jds:
        return 1
    return max(jd['id'] for jd in jds) + 1

def create_jd(jd_create: JDCreate) -> JDInDB:
    """创建新JD"""
    # 创建JD记录
    jd_dict = {
        "id": get_next_id(),
        **jd_create.dict()
    }
    
    # 保存到数据库
    jds = load_jds()
    jds.append(jd_dict)
    save_jds(jds)
    
    return JDInDB(**jd_dict)

def get_jd(jd_id: int) -> Optional[JDInDB]:
    """获取指定ID的JD"""
    jds = load_jds()
    for jd in jds:
        if jd["id"] == jd_id:
            return JDInDB(**jd)
    return None

def get_jds(skip: int = 0, limit: int = 100) -> List[JDInDB]:
    """获取JD列表"""
    jds = load_jds()
    # 分页处理
    paginated = jds[skip:skip + limit]
    return [JDInDB(**jd) for jd in paginated]

def update_jd(jd_id: int, jd_update: JDUpdate) -> Optional[JDInDB]:
    """更新JD"""
    jds = load_jds()
    for i, jd in enumerate(jds):
        if jd["id"] == jd_id:
            # 更新字段
            update_data = jd_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                if value is not None:
                    jd[key] = value
            
            # 保存更新
            jds[i] = jd
            save_jds(jds)
            
            return JDInDB(**jd)
    return None

def delete_jd(jd_id: int) -> bool:
    """删除JD"""
    jds = load_jds()
    for i, jd in enumerate(jds):
        if jd["id"] == jd_id:
            jds.pop(i)
            save_jds(jds)
            return True
    return False