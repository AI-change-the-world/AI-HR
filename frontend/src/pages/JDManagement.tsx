import React, { useState } from 'react';
import { Button, Table, Space, Typography, Tag } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';

// JD数据接口
interface JobDescription {
    id: number;
    title: string;
    department: string;
    location: string;
    isOpen: boolean;
    createdAt: string;
}

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
                <Tag color={isOpen ? 'green' : 'red'}>
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
                <Space size="middle">
                    <Button type="link" icon={<EditOutlined />}>编辑</Button>
                    <Button
                        type="link"
                        onClick={() => toggleJDStatus(record.id)}
                    >
                        {record.isOpen ? '关闭' : '开放'}
                    </Button>
                    <Button type="link" danger icon={<DeleteOutlined />}>删除</Button>
                </Space>
            ),
        },
    ];

    return (
        <div>
            <Title level={2}>JD管理</Title>

            <div style={{ marginBottom: '24px' }}>
                <Space>
                    <Button type="primary" icon={<PlusOutlined />}>
                        创建JD
                    </Button>
                </Space>
            </div>

            <Table
                dataSource={jds}
                columns={columns}
                pagination={{ pageSize: 10 }}
            />
        </div>
    );
};

export default JDManagement;