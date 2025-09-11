from typing import Any, Generic, Optional, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class PageRequest(BaseModel):
    page: int = 1
    page_size: int = 10
    # 扩展参数, 查询条件
    extras: Optional[dict[str, Any]] = None


class PageResponse(BaseModel, Generic[T]):
    total: int = 0
    data: Optional[list[T]] = None


class BaseResponse(BaseModel, Generic[T]):
    code: int = 200
    message: str = "success"
    data: Optional[T] = None
