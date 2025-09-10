import React, { useState, useEffect } from 'react';

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

    return (
        <div className="page-container">
            {/* 首页滚动字幕 */}
            <div className="home-marquee-notice">
                <span className="notice-label">通知：</span>
                <div className="notice-content">
                    <span className="notice-text">{notices[currentNotice]}</span>
                </div>
            </div>

            <h1>AI HR 管理系统</h1>
            <div className="welcome-section">
                <p>欢迎使用AI HR管理系统，这是一个基于人工智能的人力资源管理平台。</p>
                <p>系统功能包括：</p>
                <ul>
                    <li>员工信息管理</li>
                    <li>简历库管理</li>
                    <li>部门组织架构管理</li>
                    <li>职位描述(JD)管理</li>
                    <li>OKR/KPI目标管理</li>
                </ul>
                <div className="home-features">
                    <div className="feature-card">
                        <h3>🤖 AI智能分析</h3>
                        <p>利用先进的人工智能技术，自动分析简历并匹配最佳候选人</p>
                    </div>
                    <div className="feature-card">
                        <h3>📊 数据驱动决策</h3>
                        <p>提供详尽的数据报告和可视化图表，辅助HR决策</p>
                    </div>
                    <div className="feature-card">
                        <h3>⚡ 高效流程</h3>
                        <p>自动化处理重复性工作，让HR专注于更有价值的任务</p>
                    </div>
                </div>
                <p>请使用左侧导航栏或右下角AI助手访问各个功能模块。</p>
            </div>
        </div>
    );
};

export default HomePage;