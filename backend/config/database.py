from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from common.logger import logger
from config.settings import settings

# 创建数据库引擎
engine = create_engine(
    settings.DATABASE_URL, pool_pre_ping=True, pool_recycle=3600, echo=settings.DEBUG
)

# 创建会话工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 创建基础类
Base = declarative_base()


def get_db():
    """获取数据库会话"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    from models import OKR, Department, Employee, JobDescription, Resume

    logger.info(f"init db, url: {engine.url}")
    Base.metadata.create_all(bind=engine)
    logger.info(
        f"注册的表：{Base.metadata.tables.keys()}",
    )
