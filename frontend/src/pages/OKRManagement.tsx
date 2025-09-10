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
        <div>
            <Title level={2}>OKR/KPI管理</Title>

            <div style={{ marginBottom: '24px' }}>
                <Space>
                    <Button type="primary" icon={<PlusOutlined />}>
                        添加OKR
                    </Button>
                </Space>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
                {okrs.map((okr) => (
                    <Card
                        key={okr.id}
                        title={
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <Text strong>{okr.objective}</Text>
                                <Text type="secondary">{okr.quarter}</Text>
                            </div>
                        }
                        extra={
                            <Space>
                                <Button type="link" icon={<EditOutlined />}>编辑</Button>
                                <Button type="link" danger icon={<DeleteOutlined />}>删除</Button>
                            </Space>
                        }
                    >
                        <div style={{ marginBottom: '16px' }}>
                            <Text strong>负责人: </Text>
                            <Text>{okr.employeeName}</Text>
                        </div>

                        <div style={{ marginBottom: '16px' }}>
                            <Text strong>进度: </Text>
                            <Progress percent={okr.progress} />
                        </div>

                        <div>
                            <Text strong>关键结果:</Text>
                            <List
                                size="small"
                                dataSource={okr.keyResults}
                                renderItem={item => <List.Item>{item}</List.Item>}
                            />
                        </div>
                    </Card>
                ))}
            </div>
        </div>
    );
};

export default OKRManagement;