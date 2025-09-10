import React, { useState } from 'react';
import { Button, Table, Space, Typography } from 'antd';
import { PlusOutlined } from '@ant-design/icons';

// 部门数据接口
interface Department {
    id: number;
    name: string;
    manager: string;
    employeeCount: number;
    description: string;
}

const { Title } = Typography;

const DepartmentManagement = () => {
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

    const columns = [
        {
            title: 'ID',
            dataIndex: 'id',
            key: 'id',
        },
        {
            title: '部门名称',
            dataIndex: 'name',
            key: 'name',
        },
        {
            title: '部门经理',
            dataIndex: 'manager',
            key: 'manager',
        },
        {
            title: '员工数量',
            dataIndex: 'employeeCount',
            key: 'employeeCount',
        },
        {
            title: '描述',
            dataIndex: 'description',
            key: 'description',
        },
        {
            title: '操作',
            key: 'action',
            render: (_: any, record: Department) => (
                <Space size="middle">
                    <Button type="link">编辑</Button>
                    <Button type="link" danger>删除</Button>
                </Space>
            ),
        },
    ];

    return (
        <div>
            <Title level={2}>部门管理</Title>

            <div style={{ marginBottom: '24px' }}>
                <Space>
                    <Button type="primary" icon={<PlusOutlined />}>
                        添加部门
                    </Button>
                </Space>
            </div>

            <Table
                dataSource={departments}
                columns={columns}
                pagination={{ pageSize: 10 }}
            />
        </div>
    );
};

export default DepartmentManagement;