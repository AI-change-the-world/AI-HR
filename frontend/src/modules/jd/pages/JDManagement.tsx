import React, { useState } from 'react';
import { Button, Table, Space, Typography, Tag } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import { JobDescription } from '../types';
import { getJDs, toggleJDStatus } from '../api';

const { Title } = Typography;

const JDManagement: React.FC = () => {
    const [jds, setJds] = useState<JobDescription[]>([
        {
            id: 1,
            title: '前端工程师',
            department: '技术部',
            location: '北京',
            isOpen: true,
            createdAt: '2023-05-01'
        },
        {
            id: 2,
            title: '后端工程师',
            department: '技术部',
            location: '上海',
            isOpen: true,
            createdAt: '2023-05-02'
        },
        {
            id: 3,
            title: '产品经理',
            department: '产品部',
            location: '深圳',
            isOpen: false,
            createdAt: '2023-04-15'
        }
    ]);

    const toggleJDStatus = (id: number) => {
        setJds(jds.map(jd =>
            jd.id === id ? { ...jd, isOpen: !jd.isOpen } : jd
        ));
    };

    const columns = [
        {
            title: 'ID',
            dataIndex: 'id',
            key: 'id',
        },
        {
            title: '职位名称',
            dataIndex: 'title',
            key: 'title',
        },
        {
            title: '部门',
            dataIndex: 'department',
            key: 'department',
        },
        {
            title: '工作地点',
            dataIndex: 'location',
            key: 'location',
        },
        {
            title: '状态',
            dataIndex: 'isOpen',
            key: 'isOpen',
            render: (isOpen: boolean) => (
                <Tag
                    color={isOpen ? 'green' : 'red'}
                    className={`px-3 py-1 rounded-full font-medium ${isOpen
                        ? 'bg-success-50 text-success-600 border-success-200'
                        : 'bg-danger-50 text-danger-600 border-danger-200'
                        }`}
                >
                    {isOpen ? '开放' : '关闭'}
                </Tag>
            ),
        },
        {
            title: '创建时间',
            dataIndex: 'createdAt',
            key: 'createdAt',
        },
        {
            title: '操作',
            key: 'action',
            render: (_: any, record: JobDescription) => (
                <Space size="small">
                    <Button
                        type="link"
                        icon={<EditOutlined />}
                        className="text-primary-600 hover:text-primary-700 p-0 h-auto font-medium"
                    >
                        编辑
                    </Button>
                    <Button
                        type="link"
                        onClick={() => toggleJDStatus(record.id)}
                        className={`p-0 h-auto font-medium ${record.isOpen
                            ? 'text-warning-600 hover:text-warning-700'
                            : 'text-success-600 hover:text-success-700'
                            }`}
                    >
                        {record.isOpen ? '关闭' : '开放'}
                    </Button>
                    <Button
                        type="link"
                        danger
                        icon={<DeleteOutlined />}
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
            <div className="mb-6">
                <Title level={2} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2">
                    JD管理
                </Title>
                <div className="w-24 h-1 bg-gradient-to-r from-primary-500 to-primary-600 rounded-full mb-4"></div>
            </div>

            <div className="mb-6">
                <Space>
                    <Button
                        type="primary"
                        icon={<PlusOutlined />}
                        className="bg-gradient-to-r from-primary-500 to-primary-600 border-none shadow-soft hover:shadow-medium hover:scale-105 transition-all duration-200 h-10 px-6 font-medium"
                    >
                        创建JD
                    </Button>
                </Space>
            </div>

            <div className="bg-white/70 backdrop-blur-sm rounded-2xl shadow-soft border border-white/50 overflow-hidden hover:shadow-medium transition-all duration-300">
                <Table
                    dataSource={jds}
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

export default JDManagement;