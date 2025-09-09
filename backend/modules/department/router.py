from fastapi import APIRouter, HTTPException
from .models import DepartmentCreate, DepartmentUpdate, DepartmentInDB
from .service import create_department, get_department, get_departments, update_department, delete_department

router = APIRouter(
    prefix="/api/departments",
    tags=["部门管理"]
)

@router.post("/", response_model=DepartmentInDB)
async def create_department_info(department: DepartmentCreate):
    """创建部门"""
    return create_department(department)

@router.get("/{department_id}", response_model=DepartmentInDB)
async def read_department(department_id: int):
    """获取部门详情"""
    department = get_department(department_id)
    if department is None:
        raise HTTPException(status_code=404, detail="部门未找到")
    return department

@router.get("/", response_model=list[DepartmentInDB])
async def read_departments(skip: int = 0, limit: int = 100):
    """获取部门列表"""
    return get_departments(skip=skip, limit=limit)

@router.put("/{department_id}", response_model=DepartmentInDB)
async def update_department_info(department_id: int, department_update: DepartmentUpdate):
    """更新部门信息"""
    department = update_department(department_id, department_update)
    if department is None:
        raise HTTPException(status_code=404, detail="部门未找到")
    return department

@router.delete("/{department_id}")
async def delete_department_info(department_id: int):
    """删除部门"""
    success = delete_department(department_id)
    if not success:
        raise HTTPException(status_code=404, detail="部门未找到")
    return {"message": "部门删除成功"}