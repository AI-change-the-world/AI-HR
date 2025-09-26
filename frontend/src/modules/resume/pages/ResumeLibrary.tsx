import React, { useState } from 'react';
import { Button, Table, Space, Typography, Upload } from 'antd';
import { PlusOutlined, UploadOutlined } from '@ant-design/icons';
import { Resume } from '../types';
import { getResumes, uploadResumeFile } from '../api';

const { Title } = Typography;

const ResumeLibrary: React.FC = () => {
    const [resumes, setResumes] = useState<Resume[]>([
        {
            id: 1,
            name: '张三',
            position: '前端工程师',
            score: 8.5,
            status: 'reviewed',
            createdAt: '2023-05-15'
        },
        {
            id: 2,
            name: '李四',
            position: '后端工程师',
            score: 9.2,
            status: 'pending',
            createdAt: '2023-05-16'
        },
        {
            id: 3,
            name: '王五',
            position: '产品经理',
            score: 7.8,
            status: 'reviewed',
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
                <Space size="small">
                    <Button
                        type="link"
                        className="text-primary-600 hover:text-primary-700 p-0 h-auto font-medium"
                    >
                        查看
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
            <div className="mb-6">
                <Title level={5} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2 text-left">
                    简历库
                </Title>
                <div className="w-24 h-1 bg-gradient-to-r from-primary-500 to-primary-600 rounded-full mb-4"></div>
            </div>

            <div className="mb-6 flex justify-end">
                <Space>
                    <Upload beforeUpload={handleFileUpload}>
                        <Button
                            type="primary"
                            icon={<UploadOutlined />}
                            className="bg-gradient-to-r from-primary-500 to-primary-600 border-none shadow-soft hover:shadow-medium hover:scale-105 transition-all duration-200 h-10 px-6 font-medium"
                        >
                            上传简历
                        </Button>
                    </Upload>
                    <Button
                        icon={<PlusOutlined />}
                        className="border-primary-300 text-primary-600 hover:bg-primary-50 hover:border-primary-400 transition-all duration-200 h-10 px-6 font-medium"
                    >
                        筛选简历
                    </Button>
                </Space>
            </div>

            <div className="bg-white/70 backdrop-blur-sm rounded-2xl shadow-soft border border-white/50 overflow-hidden hover:shadow-medium transition-all duration-300">
                <Table
                    dataSource={resumes}
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

export default ResumeLibrary;