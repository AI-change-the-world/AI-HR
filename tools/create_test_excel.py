import pandas as pd

# 创建测试数据
data = {
    '姓名': ['张三', '李四', '王五', '赵六', '钱七', '孙八', '周九', '吴十', '郑一', '陈二'],
    '职位': ['软件工程师', '产品经理', '设计师', '人事专员', '财务主管', '市场经理', '测试工程师', '运维工程师', '产品助理', 'UI设计师'],
    '部门': ['技术部', '产品部', '设计部', '人力资源部', '财务部', '市场部', '技术部', '技术部', '产品部', '设计部']
}

# 创建DataFrame
df = pd.DataFrame(data)

# 保存为Excel文件
df.to_excel('test_employees.xlsx', index=False, engine='openpyxl')

print("测试Excel文件已创建: test_employees.xlsx")