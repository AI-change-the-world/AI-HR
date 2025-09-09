# AI HR 后端服务

这是一个基于FastAPI的模块化后端服务，为AI HR系统提供API接口。

## 项目结构

```
backend/
├── app.py                    # 主应用文件
├── data/                     # 数据存储目录
│   ├── resumes.json          # 简历数据
│   ├── employees.json        # 员工数据
│   ├── departments.json      # 部门数据
│   ├── job_descriptions.json # JD数据
│   └── okrs.json             # OKR数据
├── modules/                  # 业务模块目录
│   ├── resume/               # 简历管理模块
│   │   ├── __init__.py
│   │   ├── models.py         # 数据模型
│   │   ├── service.py        # 业务逻辑
│   │   └── router.py         # 路由定义
│   ├── employee/             # 员工管理模块
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── service.py
│   │   └── router.py
│   ├── department/           # 部门管理模块
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── service.py
│   │   └── router.py
│   ├── jd/                   # JD管理模块
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── service.py
│   │   └── router.py
│   └── okr/                  # OKR/KPI管理模块
│       ├── __init__.py
│       ├── models.py
│       ├── service.py
│       └── router.py
├── test_resume.txt           # 测试简历文件
├── start.bat                 # Windows启动脚本
├── start.sh                  # Linux/Mac启动脚本
└── test_api.py               # API测试脚本
```

## 功能模块

1. **简历管理** - 简历上传、查看
2. **员工管理** - 员工信息的增删改查
3. **部门管理** - 部门信息的增删改查
4. **JD管理** - 职位描述的增删改查
5. **OKR/KPI管理** - 目标管理的增删改查

## 快速开始

### 安装依赖

```bash
pip install fastapi uvicorn
```

### 启动服务

Windows:
```cmd
start.bat
```

Linux/Mac:
```bash
chmod +x start.sh
./start.sh
```

或者直接运行:
```bash
python app.py
```

服务将在 `http://localhost:8000` 启动。

## API接口

### 简历管理
- `POST /api/resumes/upload` - 上传简历
- `GET /api/resumes` - 获取简历列表
- `GET /api/resumes/{id}` - 获取简历详情
- `PUT /api/resumes/{id}` - 更新简历信息
- `DELETE /api/resumes/{id}` - 删除简历

### 员工管理
- `GET /api/employees` - 获取员工列表
- `POST /api/employees` - 创建员工
- `GET /api/employees/{id}` - 获取员工详情
- `PUT /api/employees/{id}` - 更新员工信息
- `DELETE /api/employees/{id}` - 删除员工

### 部门管理
- `GET /api/departments` - 获取部门列表
- `POST /api/departments` - 创建部门
- `GET /api/departments/{id}` - 获取部门详情
- `PUT /api/departments/{id}` - 更新部门信息
- `DELETE /api/departments/{id}` - 删除部门

### JD管理
- `GET /api/jd` - 获取JD列表
- `POST /api/jd` - 创建JD
- `GET /api/jd/{id}` - 获取JD详情
- `PUT /api/jd/{id}` - 更新JD信息
- `DELETE /api/jd/{id}` - 删除JD

### OKR/KPI管理
- `GET /api/okr` - 获取OKR列表
- `POST /api/okr` - 创建OKR
- `GET /api/okr/{id}` - 获取OKR详情
- `PUT /api/okr/{id}` - 更新OKR信息
- `DELETE /api/okr/{id}` - 删除OKR

## 测试API

运行测试脚本验证接口：

```bash
python test_api.py
```

## 模块化设计

每个业务模块都遵循以下结构：
- `models.py` - 定义数据模型
- `service.py` - 实现业务逻辑
- `router.py` - 定义API路由

这种设计使得代码更易于维护和扩展。