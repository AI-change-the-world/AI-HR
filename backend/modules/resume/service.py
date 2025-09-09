import os
import json
from typing import List, Optional
from datetime import datetime
from .models import ResumeCreate, ResumeUpdate, ResumeInDB

# 简历数据文件路径
RESUME_DB_FILE = "data/resumes.json"

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

def load_resumes() -> List[dict]:
    """加载所有简历"""
    init_data_dir()
    with open(RESUME_DB_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_resumes(resumes: List[dict]):
    """保存简历列表"""
    init_data_dir()
    with open(RESUME_DB_FILE, 'w', encoding='utf-8') as f:
        json.dump(resumes, f, ensure_ascii=False, indent=2)

def get_next_id() -> int:
    """获取下一个可用ID"""
    resumes = load_resumes()
    if not resumes:
        return 1
    return max(resume['id'] for resume in resumes) + 1

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

def create_resume(resume_create: ResumeCreate, file_content: str) -> ResumeInDB:
    """创建新简历"""
    # 提取简历信息
    extracted_info = extract_resume_info(file_content)
    
    # 创建简历记录
    now = datetime.now().isoformat()
    resume_dict = {
        "id": get_next_id(),
        "filename": resume_create.filename,
        "status": "待筛选",
        "score": 0.0,
        "created_at": now,
        "updated_at": now,
        **extracted_info
    }
    
    # 保存到数据库
    resumes = load_resumes()
    resumes.append(resume_dict)
    save_resumes(resumes)
    
    return ResumeInDB(**resume_dict)

def get_resume(resume_id: int) -> Optional[ResumeInDB]:
    """获取指定ID的简历"""
    resumes = load_resumes()
    for resume in resumes:
        if resume["id"] == resume_id:
            return ResumeInDB(**resume)
    return None

def get_resumes(skip: int = 0, limit: int = 100) -> List[ResumeInDB]:
    """获取简历列表"""
    resumes = load_resumes()
    # 分页处理
    paginated = resumes[skip:skip + limit]
    return [ResumeInDB(**resume) for resume in paginated]

def update_resume(resume_id: int, resume_update: ResumeUpdate) -> Optional[ResumeInDB]:
    """更新简历"""
    resumes = load_resumes()
    for i, resume in enumerate(resumes):
        if resume["id"] == resume_id:
            # 更新时间戳
            resume["updated_at"] = datetime.now().isoformat()
            
            # 更新字段
            update_data = resume_update.dict(exclude_unset=True)
            for key, value in update_data.items():
                if value is not None:
                    resume[key] = value
            
            # 保存更新
            resumes[i] = resume
            save_resumes(resumes)
            
            return ResumeInDB(**resume)
    return None

def delete_resume(resume_id: int) -> bool:
    """删除简历"""
    resumes = load_resumes()
    for i, resume in enumerate(resumes):
        if resume["id"] == resume_id:
            resumes.pop(i)
            save_resumes(resumes)
            return True
    return False