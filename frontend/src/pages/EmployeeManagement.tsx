import React, { useState, useEffect } from 'react';

// 员工数据接口
interface Employee {
    id: number;
    name: string;
    department: string;
    position: string;
    email: string;
    phone: string;
}

const EmployeeManagement: React.FC = () => {
    const [employees, setEmployees] = useState<Employee[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        // 模拟从后端获取员工数据
        const fetchEmployees = async () => {
            try {
                // 这里应该是实际的API调用
                // const response = await fetch('/api/employees');
                // const data = await response.json();

                // 模拟数据
                const mockData: Employee[] = [
                    {
                        id: 1,
                        name: '张三',
                        department: '技术部',
                        position: '前端工程师',
                        email: 'zhangsan@example.com',
                        phone: '13800138001'
                    },
                    {
                        id: 2,
                        name: '李四',
                        department: '技术部',
                        position: '后端工程师',
                        email: 'lisi@example.com',
                        phone: '13800138002'
                    },
                    {
                        id: 3,
                        name: '王五',
                        department: '人事部',
                        position: 'HR专员',
                        email: 'wangwu@example.com',
                        phone: '13800138003'
                    }
                ];

                setEmployees(mockData);
                setLoading(false);
            } catch (err) {
                setError('获取员工数据失败');
                setLoading(false);
            }
        };

        fetchEmployees();
    }, []);

    if (loading) {
        return <div className="page-container">加载中...</div>;
    }

    if (error) {
        return <div className="page-container">错误: {error}</div>;
    }

    return (
        <div className="page-container">
            <h1>员工管理</h1>
            <div className="toolbar">
                <button className="btn btn-primary">添加员工</button>
                <button className="btn btn-secondary">导入员工</button>
            </div>
            <div className="table-container">
                <table className="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>姓名</th>
                            <th>部门</th>
                            <th>职位</th>
                            <th>邮箱</th>
                            <th>电话</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        {employees.map((employee) => (
                            <tr key={employee.id}>
                                <td>{employee.id}</td>
                                <td>{employee.name}</td>
                                <td>{employee.department}</td>
                                <td>{employee.position}</td>
                                <td>{employee.email}</td>
                                <td>{employee.phone}</td>
                                <td>
                                    <button className="btn btn-small btn-secondary">编辑</button>
                                    <button className="btn btn-small btn-danger">删除</button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default EmployeeManagement;