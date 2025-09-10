import React, { useState, useEffect } from 'react';
import { Card, Row, Col, Typography, List } from 'antd';
import { RobotOutlined, BarChartOutlined, ThunderboltOutlined } from '@ant-design/icons';

const { Title, Paragraph } = Typography;

const HomePage: React.FC = () => {
    const notices = [
        "AI 人事办人事",
        "做有温度的人工智能系统",
        "客观，公平"
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
        <div className="animate-fade-in">
            {/* 通知横幅 */}
            <div className="bg-gradient-to-r from-primary-50 to-blue-50 p-4 rounded-2xl mb-6 border border-primary-200/50 shadow-soft hover:shadow-medium transition-all duration-300">
                <div className="flex items-center">
                    <div className="flex items-center space-x-2 mr-4">
                        <div className="w-3 h-3 bg-gradient-to-r from-primary-500 to-primary-600 rounded-full animate-pulse"></div>
                        <span className="font-bold text-primary-700">通知：</span>
                    </div>
                    <div className="flex-1 overflow-hidden">
                        <span className="text-primary-600 font-medium animate-slide-up">
                            {notices[currentNotice]}
                        </span>
                    </div>
                </div>
            </div>

            <div className="mb-8">
                <Title level={2} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2">
                    AI HR 管理系统
                </Title>
                <div className="w-24 h-1 bg-gradient-to-r from-primary-500 to-primary-600 rounded-full mb-4"></div>
                <Paragraph className="text-gray-600 text-lg leading-relaxed">
                    欢迎使用AI HR管理系统，这是一个基于人工智能的人力资源管理平台。
                </Paragraph>
            </div>

            <div className="mb-8">
                <Title level={4} className="text-primary-700 mb-4 flex items-center">
                    <div className="w-1 h-6 bg-gradient-to-b from-primary-500 to-primary-600 rounded-full mr-3"></div>
                    系统功能
                </Title>
                <div className="bg-white/50 backdrop-blur-sm rounded-xl p-6 border border-gray-200/50 shadow-soft">
                    <List
                        size="small"
                        dataSource={[
                            '员工信息管理',
                            '简历库管理',
                            '部门组织架构管理',
                            '职位描述(JD)管理',
                            'OKR/KPI目标管理'
                        ]}
                        renderItem={(item, index) => (
                            <List.Item className="border-none py-3">
                                <div className="flex items-center space-x-3">
                                    <div className={`w-2 h-2 rounded-full animate-pulse delay-${index * 100}`}
                                        style={{ backgroundColor: `hsl(${210 + index * 20}, 70%, 60%)` }}></div>
                                    <span className="text-gray-700 font-medium">{item}</span>
                                </div>
                            </List.Item>
                        )}
                    />
                </div>
            </div>

            <div className="mb-8">
                <Title level={4} className="text-primary-700 mb-6 flex items-center">
                    <div className="w-1 h-6 bg-gradient-to-b from-primary-500 to-primary-600 rounded-full mr-3"></div>
                    核心特性
                </Title>
                <Row gutter={[24, 24]}>
                    {features.map((feature, index) => (
                        <Col xs={24} sm={12} lg={8} key={index}>
                            <Card
                                hoverable
                                className={`bg-gradient-to-br from-white to-gray-50/50 border-gray-200/50 shadow-soft hover:shadow-medium transition-all duration-300 hover:-translate-y-1 animate-slide-up`}
                                style={{ animationDelay: `${index * 100}ms` }}
                            >
                                <div className="text-center mb-4">
                                    <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-primary-100 to-primary-200 rounded-2xl mb-4">
                                        <div className="text-2xl">{feature.icon}</div>
                                    </div>
                                </div>
                                <Title level={4} className="text-center text-primary-700 mb-3">
                                    {feature.title}
                                </Title>
                                <Paragraph className="text-center text-gray-600 leading-relaxed">
                                    {feature.description}
                                </Paragraph>
                            </Card>
                        </Col>
                    ))}
                </Row>
            </div>

            <div className="bg-gradient-to-r from-primary-50 to-blue-50 p-6 rounded-xl border border-primary-200/50 shadow-soft">
                <Paragraph className="text-center text-gray-600 text-lg m-0">
                    请使用左侧导航栏访问各个功能模块。
                </Paragraph>
            </div>
        </div>
    );
};

export default HomePage;