# 查询注册表使用指南

## 概述

查询注册表是一个简洁的系统，使用 `Dict[str, Any]` 结构配合可执行函数来管理预定义查询。这种设计使得系统易于扩展，只需注册新的查询函数即可。

## 核心组件

### 1. 查询注册表 (query_registry.py)

核心数据结构：
```python
QUERY_REGISTRY: Dict[str, Dict[str, Any]] = {
    "查询名称": {
        "description": "查询描述",
        "executor": 可执行函数,
        "chart_generator": 可选的图表生成函数
    }
}
```

### 2. 注册函数

```python
def register_query(
    name: str,
    description: str,
    executor: Callable[[Dict[str, Any], Session], Dict[str, Any]],
    chart_generator: Optional[Callable[[Dict[str, Any]], Dict[str, Any]]] = None
):
    """注册一个新的查询"""
```

## 如何添加新查询

### 1. 创建查询函数

查询函数需要遵循特定的签名：
```python
def my_query_function(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    # 执行查询逻辑
    # 返回结果字典
    return {
        "result": 查询结果,
        "message": "查询结果的自然语言描述"
    }
```

### 2. 注册查询

在 [predefined_queries.py](./predefined_queries.py) 或单独的文件中注册查询：
```python
from .query_registry import register_query

def my_query_function(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    # 查询实现
    pass

register_query("我的查询", "查询描述", my_query_function)
```

### 3. 可选：添加图表生成器

如果需要为查询结果生成图表，可以实现图表生成函数：
```python
def my_chart_generator(query_result: Dict[str, Any]) -> Dict[str, Any]:
    # 生成图表数据
    return {
        "type": "图表类型",
        "title": "图表标题",
        "data": 图表数据
    }

# 注册时添加图表生成器
register_query("我的查询", "查询描述", my_query_function, my_chart_generator)
```

## 预定义查询列表

系统已预定义以下查询：

1. **员工相关**：
   - 员工总数
   - 在职员工数
   - 离职员工数
   - 各部门人数
   - 员工状态分布

2. **部门相关**：
   - 部门总数

3. **职位相关**：
   - 职位总数
   - 开放职位数

4. **简历相关**：
   - 简历总数
   - 待筛选简历数

5. **OKR相关**：
   - OKR总数

## 测试新查询

使用测试脚本验证新添加的查询：
```bash
cd backend
python -m modules.ai_qa.test_registry
```

## 扩展示例

### 简单计数查询
```python
def employee_count_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """员工总数查询"""
    count = db.query(func.count(EmployeeModel.id)).scalar()
    return {
        "result": {"total": count},
        "message": f"公司目前共有 {count} 名员工"
    }

register_query("员工总数", "查询公司员工总数", employee_count_query)
```

### 带分组和图表的查询
```python
def department_stats_query(params: Dict[str, Any], db: Session) -> Dict[str, Any]:
    """各部门人数统计查询"""
    # 执行分组查询
    result = db.query(
        DepartmentModel.name,
        func.count(EmployeeModel.id).label('count')
    ).outerjoin(
        EmployeeModel, DepartmentModel.id == EmployeeModel.department_id
    ).group_by(
        DepartmentModel.id, DepartmentModel.name
    ).all()
    
    # 转换为字典列表
    department_stats = [
        {"department": row[0], "count": row[1]} 
        for row in result
    ]
    
    return {
        "result": department_stats,
        "message": "各部门员工数量统计已完成"
    }

def department_stats_chart_generator(query_result: Dict[str, Any]) -> Dict[str, Any]:
    """各部门人数统计图表生成器"""
    # 生成柱状图数据
    # ... 图表生成逻辑 ...
    return chart_data

register_query(
    "各部门人数", 
    "按部门统计员工人数", 
    department_stats_query, 
    department_stats_chart_generator
)
```

## 优势

1. **简洁性**：使用简单的字典结构
2. **可扩展性**：通过注册函数轻松添加新查询
3. **灵活性**：支持复杂的查询逻辑和图表生成
4. **解耦**：查询逻辑与意图识别分离
5. **可测试性**：每个查询函数都可以独立测试