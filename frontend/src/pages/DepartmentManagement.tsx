import React, { useState } from 'react';

// 部门数据接口
interface Department {
    id: number;
    name: string;
    manager: string;
    employeeCount: number;
    description: string;
}

const DepartmentManagement: React.FC = () => {
    const [departments, setDepartments] = useState<Department[]>([
        {
            id: 1,
            name: '技术部',
            manager: '张三',
            employeeCount: 15,
            description: '负责产品研发和技术支持'
        },
        {
            id: 2,
            name: '人事部',
            manager: '李四',
            employeeCount: 5,
            description: '负责人力资源管理和员工关系'
        },
        {
            id: 3,
            name: '市场部',
            manager: '王五',
            employeeCount: 8,
            description: '负责市场推广和品牌建设'
        }
    ]);

    return (
        <div className="page-container">
            <h1>部门管理</h1>
            <div className="toolbar">
                <button className="btn btn-primary">添加部门</button>
            </div>
            <div className="table-container">
                <table className="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>部门名称</th>
                            <th>部门经理</th>
                            <th>员工数量</th>
                            <th>描述</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        {departments.map((department) => (
                            <tr key={department.id}>
                                <td>{department.id}</td>
                                <td>{department.name}</td>
                                <td>{department.manager}</td>
                                <td>{department.employeeCount}</td>
                                <td>{department.description}</td>
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

export default DepartmentManagement;
