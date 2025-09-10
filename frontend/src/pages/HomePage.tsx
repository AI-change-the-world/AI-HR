import React, { useState, useEffect } from 'react';
import { Card, Row, Col, Typography, List } from 'antd';
import { RobotOutlined, BarChartOutlined, ThunderboltOutlined } from '@ant-design/icons';

const { Title, Paragraph } = Typography;

const HomePage: React.FC = () => {
    const notices = [
        "系统升级通知：新版AI模型已上线，简历分析准确率提升15%",
        "功能更新：OKR模块新增季度目标对比功能",
        "维护提醒：今晚00:00-02:00系统维护，期间服务可能中断",
        "新功能上线：员工绩效分析报告功能现已开放"
    ];

    const [currentNotice, setCurrentNotice] = useState(0);

    useEffect(() => {
        const interval = setInterval(() => {
            setCurrentNotice(prev => (prev + 1) % notices.length);
        }, 5000); // 每5秒切换一次

        return () => clearInterval(interval);
    }, []);

    const features = [
        {
            title: "AI智能分析",
            description: "利用先进的人工智能技术，自动分析简历并匹配最佳候选人",
            icon: <RobotOutlined style={{ color: '#2196f3' }} />
        },
        {
            title: "数据驱动决策",
            description: "提供详尽的数据报告和可视化图表，辅助HR决策",
            icon: <BarChartOutlined style={{ color: '#2196f3' }} />
        },
        {
            title: "高效流程",
            description: "自动化处理重复性工作，让HR专注于更有价值的任务",
            icon: <ThunderboltOutlined style={{ color: '#2196f3' }} />
        }
    ];

    return (
        <div>
            {/* 通知横幅 */}
            <div
                style={{
                    background: '#e3f2fd',
                    padding: '12px 16px',
                    borderRadius: '8px',
                    marginBottom: '24px',
                    border: '1px solid #bbdefb',
                }}
            >
                <div style={{ display: 'flex', alignItems: 'center' }}>
                    <span style={{ fontWeight: 'bold', marginRight: '10px', color: '#0d47a1' }}>通知：</span>
                    <div style={{ flex: 1, overflow: 'hidden' }}>
                        <span
                            style={{
                                whiteSpace: 'nowrap',
                                animation: 'marquee 15s linear infinite',
                                display: 'inline-block',
                                color: '#0d47a1',
                            }}
                        >
                            {notices[currentNotice]}
                        </span>
                    </div>
                </div>
            </div>

            <Title level={2} style={{ color: '#0d47a1' }}>AI HR 管理系统</Title>

            <Paragraph>
                <p>欢迎使用AI HR管理系统，这是一个基于人工智能的人力资源管理平台。</p>
            </Paragraph>

            <Title level={4} style={{ color: '#0d47a1' }}>系统功能</Title>
            <List
                size="small"
                dataSource={[
                    '员工信息管理',
                    '简历库管理',
                    '部门组织架构管理',
                    '职位描述(JD)管理',
                    'OKR/KPI目标管理'
                ]}
                renderItem={item => <List.Item>{item}</List.Item>}
            />

            <Title level={4} style={{ marginTop: '32px', color: '#0d47a1' }}>核心特性</Title>
            <Row gutter={[24, 24]}>
                {features.map((feature, index) => (
                    <Col xs={24} sm={12} lg={8} key={index}>
                        <Card
                            hoverable
                            style={{
                                background: '#f5f9ff',
                                borderColor: '#bbdefb',
                            }}
                        >
                            <div style={{ textAlign: 'center', marginBottom: '16px' }}>
                                {feature.icon}
                            </div>
                            <Title level={4} style={{ textAlign: 'center', color: '#0d47a1' }}>{feature.title}</Title>
                            <Paragraph style={{ textAlign: 'center' }}>{feature.description}</Paragraph>
                        </Card>
                    </Col>
                ))}
            </Row>

            <Paragraph>
                <p>请使用左侧导航栏访问各个功能模块。</p>
            </Paragraph>

            <style>
                {`
                @keyframes marquee {
                    0% {
                        transform: translateX(100%);
                    }
                    100% {
                        transform: translateX(-100%);
                    }
                }
                `}
            </style>
        </div>
    );
};

export default HomePage;