import React, { useState, useEffect } from 'react';
import { Button, Table, Space, Typography } from 'antd';
import { PlusOutlined, UploadOutlined } from '@ant-design/icons';

// 员工数据接口
interface Employee {
    id: number;
    name: string;
    department: string;
    position: string;
    email: string;
    phone: string;
}

const { Title } = Typography;

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

    const columns = [
        {
            title: 'ID',
            dataIndex: 'id',
            key: 'id',
        },
        {
            title: '姓名',
            dataIndex: 'name',
            key: 'name',
        },
        {
            title: '部门',
            dataIndex: 'department',
            key: 'department',
        },
        {
            title: '职位',
            dataIndex: 'position',
            key: 'position',
        },
        {
            title: '邮箱',
            dataIndex: 'email',
            key: 'email',
        },
        {
            title: '电话',
            dataIndex: 'phone',
            key: 'phone',
        },
        {
            title: '操作',
            key: 'action',
            render: (_: any, record: Employee) => (
                <Space size="middle">
                    <Button type="link" style={{ color: '#2196f3' }}>编辑</Button>
                    <Button type="link" danger>删除</Button>
                </Space>
            ),
        },
    ];

    if (loading) {
        return <div style={{ padding: '24px' }}>加载中...</div>;
    }

    if (error) {
        return <div style={{ padding: '24px' }}>错误: {error}</div>;
    }

    return (
        <div>
            <Title level={2} style={{ color: '#0d47a1' }}>员工管理</Title>

            <div style={{ marginBottom: '24px' }}>
                <Space>
                    <Button type="primary" icon={<PlusOutlined />} style={{ background: '#2196f3', borderColor: '#2196f3' }}>
                        添加员工
                    </Button>
                    <Button icon={<UploadOutlined />} style={{ borderColor: '#2196f3', color: '#2196f3' }}>
                        导入员工
                    </Button>
                </Space>
            </div>

            <Table
                dataSource={employees}
                columns={columns}
                pagination={{ pageSize: 10 }}
                style={{
                    background: '#fff',
                    borderRadius: '8px',
                    overflow: 'hidden',
                }}
            />
        </div>
    );
};

export default EmployeeManagement;