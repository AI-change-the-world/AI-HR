@echo off
REM AI HR 后端服务启动脚本 (Windows)

echo 启动AI HR后端服务...

REM 检查是否安装了Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 未找到Python，请先安装Python
    pause
    exit /b 1
)

REM 检查是否安装了pip
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 未找到pip，请先安装pip
    pause
    exit /b 1
)

REM 安装依赖（如果需要）
echo 检查并安装依赖...
pip install fastapi uvicorn

REM 启动服务
echo 启动服务...
python main.py

pause