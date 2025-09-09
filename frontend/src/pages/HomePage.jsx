import React from 'react';

const HomePage = () => {
    return (
        <div className="page-container">
            <h1 className="page-title">欢迎使用AI HR系统</h1>

            <div className="card">
                <h2>系统简介</h2>
                <p>AI HR系统是一个智能化的人力资源管理系统，通过人工智能技术提升人力资源工作的效率和智能化水平。</p>
            </div>

            <div className="card">
                <h2>功能模块</h2>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '1rem', marginTop: '1rem' }}>
                    <div className="card" style={{ textAlign: 'center' }}>
                        <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>👥</div>
                        <h3>员工管理</h3>
                        <p>管理员工基本信息、合同、考勤等</p>
                    </div>

                    <div className="card" style={{ textAlign: 'center' }}>
                        <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>📄</div>
                        <h3>简历库</h3>
                        <p>存储和管理候选人简历，支持智能筛选</p>
                    </div>

                    <div className="card" style={{ textAlign: 'center' }}>
                        <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>🏢</div>
                        <h3>部门管理</h3>
                        <p>组织架构管理，部门信息维护</p>
                    </div>

                    <div className="card" style={{ textAlign: 'center' }}>
                        <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>📝</div>
                        <h3>JD管理</h3>
                        <p>职位描述管理，支持AI生成JD</p>
                    </div>

                    <div className="card" style={{ textAlign: 'center' }}>
                        <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>🎯</div>
                        <h3>OKR/KPI管理</h3>
                        <p>目标管理与绩效考核</p>
                    </div>
                </div>
            </div>

            <div className="card">
                <h2>系统优势</h2>
                <ul>
                    <li>智能化处理，提高工作效率</li>
                    <li>数据分析支持决策制定</li>
                    <li>灵活的配置选项</li>
                    <li>友好的用户界面</li>
                </ul>
            </div>
        </div>
    );
};

export default HomePage;