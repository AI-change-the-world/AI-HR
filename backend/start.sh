#!/bin/bash
# AI HR 后端服务启动脚本

echo "启动AI HR后端服务..."

# 检查是否安装了Python
if ! command -v python &> /dev/null
then
    echo "未找到Python，请先安装Python"
    exit 1
fi

# 检查是否安装了pip
if ! command -v pip &> /dev/null
then
    echo "未找到pip，请先安装pip"
    exit 1
fi

# 安装依赖（如果需要）
echo "检查并安装依赖..."
pip install fastapi uvicorn

# 启动服务
echo "启动服务..."
python main.py