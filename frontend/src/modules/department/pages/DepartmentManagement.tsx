import React, { useState } from 'react';
import { Button, Table, Space, Typography } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import { Department } from '../types';
import { getDepartments } from '../api';

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

    return (
        <div className="animate-fade-in">
            <div className="mb-6 ">
                <Title level={5} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2 text-left">
                    部门管理
                </Title>
                <div className="w-24 h-1 bg-gradient-to-r from-primary-500 to-primary-600 rounded-full mb-4"></div>
            </div>

            <div className="mb-6 flex justify-end">
                <Space>
                    <Button
                        type="primary"
                        icon={<PlusOutlined />}
                        className="bg-gradient-to-r from-primary-500 to-primary-600 border-none shadow-soft hover:shadow-medium hover:scale-105 transition-all duration-200 h-10 px-6 font-medium"
                    >
                        添加部门
                    </Button>
                </Space>
            </div>

            <div className="bg-white/70 backdrop-blur-sm rounded-2xl shadow-soft border border-white/50 overflow-hidden hover:shadow-medium transition-all duration-300">
                <Table
                    dataSource={departments}
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

export default DepartmentManagement;