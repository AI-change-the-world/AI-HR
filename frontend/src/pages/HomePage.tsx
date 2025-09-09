import React from 'react';

const HomePage: React.FC = () => {
    return (
        <div className="page-container">
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
                <p>请使用左侧导航栏访问各个功能模块。</p>
            </div>
        </div>
    );
};

export default HomePage;
