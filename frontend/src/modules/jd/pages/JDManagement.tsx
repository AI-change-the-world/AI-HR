import React, { useState, useEffect } from 'react';
import { Button, Table, Space, Typography, Tag, message, Dropdown } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, UploadOutlined, MoreOutlined } from '@ant-design/icons';
import type { MenuProps } from 'antd';
import { JobDescription } from '../types';
import { getJDs, toggleJDStatus as apiToggleJDStatus, deleteJD } from '../api';
import { ResumeEvaluator } from '../components';

const { Title } = Typography;

const JDManagement: React.FC = () => {
    const [jds, setJds] = useState<JobDescription[]>([]);
    const [loading, setLoading] = useState(true);
    const [showEvaluator, setShowEvaluator] = useState(false);
    const [selectedJD, setSelectedJD] = useState<JobDescription | null>(null);

    // 加载JD列表
    const loadJDs = async () => {
        try {
            setLoading(true);
            const data = await getJDs();
            setJds(data);
        } catch (error) {
            message.error('加载JD列表失败');
            console.error('Error loading JDs:', error);
        } finally {
            setLoading(false);
        }
    };

    // 组件加载时获取数据
    useEffect(() => {
        loadJDs();
    }, []);

    // 切换JD状态
    const handleToggleJDStatus = async (id: number) => {
        try {
            await apiToggleJDStatus(id);
            message.success('状态更新成功');
            loadJDs(); // 重新加载数据
        } catch (error) {
            message.error('状态更新失败');
            console.error('Error toggling JD status:', error);
        }
    };

    // 删除JD
    const handleDeleteJD = async (id: number) => {
        try {
            await deleteJD(id);
            message.success('删除成功');
            loadJDs(); // 重新加载数据
        } catch (error) {
            message.error('删除失败');
            console.error('Error deleting JD:', error);
        }
    };

    const handleEvaluateClick = (jd: JobDescription) => {
        if (jd.status !== '开放') {
            message.warning('只能对开放的JD进行简历评估');
            return;
        }
        setSelectedJD(jd);
        setShowEvaluator(true);
    };

    const handleEvaluatorCancel = () => {
        setShowEvaluator(false);
        setSelectedJD(null);
    };

    const handleEvaluateSuccess = () => {
        // 评估成功后的回调
        message.success('简历评估完成');
    };

    const getMenuItems = (record: JobDescription): MenuProps['items'] => [
        {
            key: 'evaluate',
            icon: <UploadOutlined />,
            label: '评估简历',
            onClick: () => handleEvaluateClick(record),
        },
        {
            key: 'delete',
            icon: <DeleteOutlined />,
            label: '删除',
            danger: true,
            onClick: () => handleDeleteJD(record.id),
        },
    ];

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
            dataIndex: 'status',
            key: 'status',
            render: (status: string) => (
                <Tag
                    color={status === '开放' ? 'green' : 'red'}
                    className={`px-3 py-1 rounded-full font-medium ${status === '开放'
                        ? 'bg-success-50 text-success-600 border-success-200'
                        : 'bg-danger-50 text-danger-600 border-danger-200'
                        }`}
                >
                    {status}
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
                        onClick={() => handleToggleJDStatus(record.id)}
                        className={`p-0 h-auto font-medium ${record.status === '开放'
                                ? 'text-warning-600 hover:text-warning-700'
                                : 'text-success-600 hover:text-success-700'
                            }`}
                    >
                        {record.status === '开放' ? '关闭' : '开放'}
                    </Button>
                    <Dropdown menu={{ items: getMenuItems(record) }} trigger={['click']}>
                        <Button
                            type="link"
                            icon={<MoreOutlined />}
                            className="text-gray-600 hover:text-gray-800 p-0 h-auto font-medium"
                        />
                    </Dropdown>
                </Space>
            ),
        },
    ];

    return (
        <div className="animate-fade-in">
            <div className="mb-6">
                <Title level={5} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2 text-left">
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
                    loading={loading}
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

            {showEvaluator && selectedJD && (
                <ResumeEvaluator
                    jdId={selectedJD.id}
                    jdTitle={selectedJD.title}
                    onCancel={handleEvaluatorCancel}
                    onEvaluate={handleEvaluateSuccess}
                />
            )}
        </div>
    );
};

export default JDManagement;