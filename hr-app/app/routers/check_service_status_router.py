from fastapi import APIRouter

from app.models import SystemInfo
from app.services import SystemMonitor

router = APIRouter(
    prefix="/system-monitor",
    tags=["system-monitor"],
)


@router.get("/system/info", response_model=SystemInfo)
def system_info():
    return SystemMonitor.get_system_info()
