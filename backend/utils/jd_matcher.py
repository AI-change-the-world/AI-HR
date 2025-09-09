from typing import List, Optional, Tuple
from models.jd import JobDescription
from config.database import SessionLocal

def get_open_jds() -> List[JobDescription]:
    """获取所有未关闭的JD"""
    db = SessionLocal()
    try:
        jds = db.query(JobDescription).filter(JobDescription.is_open == True).all()
        return jds
    finally:
        db.close()

def calculate_match_score(resume_content: str, jd: JobDescription) -> float:
    """计算简历与JD的匹配度分数（模拟实现）"""
    # 这里应该实现实际的匹配算法
    # 目前使用简单的模拟逻辑
    import random
    return round(random.uniform(0, 10), 1)

def find_best_match(resume_content: str) -> Tuple[Optional[JobDescription], float]:
    """找到最佳匹配的JD"""
    open_jds = get_open_jds()
    
    if not open_jds:
        return None, 0.0
    
    best_jd = None
    best_score = 0.0
    
    for jd in open_jds:
        score = calculate_match_score(resume_content, jd)
        if score > best_score:
            best_score = score
            best_jd = jd
    
    return best_jd, best_score