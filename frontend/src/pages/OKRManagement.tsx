import React, { useState } from 'react';

// OKR数据接口
interface OKR {
    id: number;
    employeeName: string;
    objective: string;
    keyResults: string[];
    quarter: string;
    progress: number;
}

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
        <div className="page-container">
            <h1>OKR/KPI管理</h1>
            <div className="toolbar">
                <button className="btn btn-primary">添加OKR</button>
            </div>
            <div className="okr-list">
                {okrs.map((okr) => (
                    <div key={okr.id} className="okr-card">
                        <div className="okr-header">
                            <h3>{okr.objective}</h3>
                            <span className="quarter-tag">{okr.quarter}</span>
                        </div>
                        <div className="okr-body">
                            <p className="employee-name">负责人: {okr.employeeName}</p>
                            <div className="progress-section">
                                <span>进度: {okr.progress}%</span>
                                <div className="progress-bar">
                                    <div
                                        className="progress-fill"
                                        style={{ width: `${okr.progress}%` }}
                                    ></div>
                                </div>
                            </div>
                            <div className="key-results">
                                <h4>关键结果:</h4>
                                <ul>
                                    {okr.keyResults.map((kr, index) => (
                                        <li key={index}>{kr}</li>
                                    ))}
                                </ul>
                            </div>
                        </div>
                        <div className="okr-footer">
                            <button className="btn btn-small btn-secondary">编辑</button>
                            <button className="btn btn-small btn-danger">删除</button>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default OKRManagement;