import React, { useState, useEffect } from 'react';
import { Button, Table, Space, Typography } from 'antd';
import { PlusOutlined, UploadOutlined } from '@ant-design/icons';
import { Employee } from '../types';
import { getEmployees } from '../api';

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
                <Space size="small">
                    <Button
                        type="link"
                        className="text-primary-600 hover:text-primary-700 p-0 h-auto font-medium"
                    >
                        编辑
                    </Button>
                    <Button
                        type="link"
                        danger
                        className="text-danger-500 hover:text-danger-600 p-0 h-auto font-medium"
                    >
                        删除
                    </Button>
                </Space>
            ),
        },
    ];

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="text-center">
                    <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mb-4"></div>
                    <p className="text-gray-600">加载中...</p>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="text-center">
                    <div className="text-danger-500 text-xl mb-2">⚠️</div>
                    <p className="text-danger-600">错误: {error}</p>
                </div>
            </div>
        );
    }

    return (
        <div className="animate-fade-in">
            <div className="mb-6">
                <Title level={2} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2">
                    员工管理
                </Title>
                <div className="w-24 h-1 bg-gradient-to-r from-primary-500 to-primary-600 rounded-full mb-4"></div>
            </div>

            <div className="mb-6">
                <Space size="middle">
                    <Button
                        type="primary"
                        icon={<PlusOutlined />}
                        className="bg-gradient-to-r from-primary-500 to-primary-600 border-none shadow-soft hover:shadow-medium hover:scale-105 transition-all duration-200 h-10 px-6 font-medium"
                    >
                        添加员工
                    </Button>
                    <Button
                        icon={<UploadOutlined />}
                        className="border-primary-300 text-primary-600 hover:bg-primary-50 hover:border-primary-400 transition-all duration-200 h-10 px-6 font-medium"
                    >
                        导入员工
                    </Button>
                </Space>
            </div>

            <div className="bg-white/70 backdrop-blur-sm rounded-2xl shadow-soft border border-white/50 overflow-hidden hover:shadow-medium transition-all duration-300">
                <Table
                    dataSource={employees}
                    columns={columns}
                    pagination={{
                        pageSize: 10,
                        showSizeChanger: true,
                        showQuickJumper: true,
                        showTotal: (total, range) => `第 ${range[0]}-${range[1]} 条，共 ${total} 条数据`,
                        className: 'px-4 py-2'
                    }}
                    className="[&_.ant-table-thead>tr>th]:bg-gray-50/80 [&_.ant-table-thead>tr>th]:border-gray-200/50 [&_.ant-table-tbody>tr:hover>td]:bg-primary-50/30 [&_.ant-table-tbody>tr>td]:border-gray-200/30"
                />
            </div>
        </div>
    );
};

export default EmployeeManagement;