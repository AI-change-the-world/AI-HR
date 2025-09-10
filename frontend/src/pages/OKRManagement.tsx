import React, { useState } from 'react';
import { Button, Card, Progress, Typography, Space, List } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';

// OKR数据接口
interface OKR {
    id: number;
    employeeName: string;
    objective: string;
    keyResults: string[];
    quarter: string;
    progress: number;
}

const { Title, Text } = Typography;

const OKRManagement: React.FC = () => {
    const [okrs, setOkrs] = useState<OKR[]>([
        {
            id: 1,
            employeeName: '张三',
            objective: '提升前端性能',
            keyResults: [
                '将页面加载时间减少30%',
                '优化核心组件渲染性能',
                '提升用户交互响应速度'
            ],
            quarter: 'Q2-2023',
            progress: 75
        },
        {
            id: 2,
            employeeName: '李四',
            objective: '完善后端架构',
            keyResults: [
                '完成微服务拆分',
                '实现服务监控告警',
                '提升系统稳定性'
            ],
            quarter: 'Q2-2023',
            progress: 60
        }
    ]);

    return (
        <div className="animate-fade-in">
            <div className="mb-6">
                <Title level={2} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2">
                    OKR/KPI管理
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
                        添加OKR
                    </Button>
                </Space>
            </div>

            <div className="flex flex-col gap-6">
                {okrs.map((okr, index) => (
                    <Card
                        key={okr.id}
                        className={`bg-white/70 backdrop-blur-sm border-gray-200/50 shadow-soft hover:shadow-medium transition-all duration-300 hover:-translate-y-1 animate-slide-up`}
                        style={{ animationDelay: `${index * 100}ms` }}
                        title={
                            <div className="flex justify-between items-center">
                                <Text strong className="text-primary-700 text-lg">{okr.objective}</Text>
                                <div className="bg-primary-100 text-primary-700 px-3 py-1 rounded-full text-sm font-medium">
                                    {okr.quarter}
                                </div>
                            </div>
                        }
                        extra={
                            <Space>
                                <Button
                                    type="link"
                                    icon={<EditOutlined />}
                                    className="text-primary-600 hover:text-primary-700 p-0 h-auto font-medium"
                                >
                                    编辑
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
                        }
                    >
                        <div className="space-y-4">
                            <div className="flex items-center space-x-2">
                                <div className="w-2 h-2 bg-primary-500 rounded-full"></div>
                                <Text strong className="text-gray-700">负责人: </Text>
                                <Text className="text-gray-600">{okr.employeeName}</Text>
                            </div>

                            <div>
                                <div className="flex items-center justify-between mb-2">
                                    <Text strong className="text-gray-700">进度: </Text>
                                    <Text className="text-primary-600 font-semibold">{okr.progress}%</Text>
                                </div>
                                <Progress
                                    percent={okr.progress}
                                    strokeColor={{
                                        '0%': '#22d3ee',
                                        '50%': '#3b82f6',
                                        '100%': '#1d4ed8',
                                    }}
                                    className="[&_.ant-progress-bg]:rounded-full"
                                />
                            </div>

                            <div>
                                <Text strong className="text-gray-700 block mb-3">关键结果:</Text>
                                <div className="bg-gray-50/80 rounded-xl p-4">
                                    <List
                                        size="small"
                                        dataSource={okr.keyResults}
                                        renderItem={(item, itemIndex) => (
                                            <List.Item className="border-none py-2">
                                                <div className="flex items-start space-x-3">
                                                    <div className={`w-2 h-2 rounded-full mt-2 animate-pulse`}
                                                        style={{ backgroundColor: `hsl(${210 + itemIndex * 30}, 70%, 60%)`, animationDelay: `${itemIndex * 200}ms` }}></div>
                                                    <span className="text-gray-700">{item}</span>
                                                </div>
                                            </List.Item>
                                        )}
                                    />
                                </div>
                            </div>
                        </div>
                    </Card>
                ))}
            </div>
        </div>
    );
};

export default OKRManagement;