import React, { useState } from 'react';
import { Button, Table, Space, Typography, Upload } from 'antd';
import { PlusOutlined, UploadOutlined } from '@ant-design/icons';

// 简历数据接口
interface Resume {
    id: number;
    name: string;
    position: string;
    score: number;
    status: string;
    createdAt: string;
}

const { Title } = Typography;

const ResumeLibrary: React.FC = () => {
    const [resumes, setResumes] = useState<Resume[]>([
        {
            id: 1,
            name: '张三',
            position: '前端工程师',
            score: 8.5,
            status: '已筛选',
            createdAt: '2023-05-15'
        },
        {
            id: 2,
            name: '李四',
            position: '后端工程师',
            score: 9.2,
            status: '待筛选',
            createdAt: '2023-05-16'
        },
        {
            id: 3,
            name: '王五',
            position: '产品经理',
            score: 7.8,
            status: '已筛选',
            createdAt: '2023-05-17'
        }
    ]);

    const handleFileUpload = (file: any) => {
        // 这里应该是实际的文件上传逻辑
        alert(`选择了文件: ${file.name}`);
        return false; // 阻止自动上传
    };

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
            title: '职位',
            dataIndex: 'position',
            key: 'position',
        },
        {
            title: '评分',
            dataIndex: 'score',
            key: 'score',
        },
        {
            title: '状态',
            dataIndex: 'status',
            key: 'status',
        },
        {
            title: '上传时间',
            dataIndex: 'createdAt',
            key: 'createdAt',
        },
        {
            title: '操作',
            key: 'action',
            render: (_: any, record: Resume) => (
                <Space size="middle">
                    <Button type="link">查看</Button>
                    <Button type="link" danger>删除</Button>
                </Space>
            ),
        },
    ];

    return (
        <div>
            <Title level={2}>简历库</Title>

            <div style={{ marginBottom: '24px' }}>
                <Space>
                    <Upload beforeUpload={handleFileUpload}>
                        <Button type="primary" icon={<UploadOutlined />}>
                            上传简历
                        </Button>
                    </Upload>
                    <Button icon={<PlusOutlined />}>
                        筛选简历
                    </Button>
                </Space>
            </div>

            <Table
                dataSource={resumes}
                columns={columns}
                pagination={{ pageSize: 10 }}
            />
        </div>
    );
};

export default ResumeLibrary;