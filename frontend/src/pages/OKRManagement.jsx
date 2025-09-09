import React, { useState } from 'react';

const OKRManagement = () => {
    const [okrs, setOKRs] = useState([
        {
            id: 1,
            objective: '提升产品用户体验',
            quarter: 'Q2 2025',
            progress: 75,
            owner: '产品部',
            keyResults: [
                { id: 1, description: '用户满意度提升至90%', target: 90, current: 85 },
                { id: 2, description: '产品bug率降低至1%以下', target: 1, current: 1.2 }
            ]
        },
        {
            id: 2,
            objective: '扩大市场份额',
            quarter: 'Q2 2025',
            progress: 60,
            owner: '市场部',
            keyResults: [
                { id: 3, description: '新增注册用户10万', target: 100000, current: 60000 },
                { id: 4, description: '市场占有率提升至15%', target: 15, current: 12 }
            ]
        }
    ]);

    const [showForm, setShowForm] = useState(false);
    const [formData, setFormData] = useState({
        objective: '',
        quarter: 'Q2 2025',
        owner: ''
    });

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (formData.objective && formData.quarter && formData.owner) {
            const newOKR = {
                id: okrs.length + 1,
                ...formData,
                progress: 0,
                keyResults: []
            };
            setOKRs(prev => [...prev, newOKR]);
            setFormData({ objective: '', quarter: 'Q2 2025', owner: '' });
            setShowForm(false);
        }
    };

    const handleDelete = (id) => {
        setOKRs(prev => prev.filter(okr => okr.id !== id));
    };

    return (
        <div className="page-container">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
                <h1 className="page-title" style={{ margin: 0 }}>OKR/KPI管理</h1>
                <button className="btn" onClick={() => setShowForm(!showForm)}>
                    {showForm ? '取消添加' : '添加OKR'}
                </button>
            </div>

            {showForm && (
                <div className="card" style={{ marginBottom: '1.5rem' }}>
                    <h2>添加新OKR</h2>
                    <form onSubmit={handleSubmit}>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem' }}>
                            <div className="form-group">
                                <label>目标(Objective):</label>
                                <input
                                    type="text"
                                    name="objective"
                                    value={formData.objective}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>所属季度:</label>
                                <select
                                    name="quarter"
                                    value={formData.quarter}
                                    onChange={handleInputChange}
                                >
                                    <option value="Q2 2025">Q2 2025</option>
                                    <option value="Q3 2025">Q3 2025</option>
                                    <option value="Q4 2025">Q4 2025</option>
                                    <option value="Q1 2026">Q1 2026</option>
                                </select>
                            </div>
                            <div className="form-group">
                                <label>负责人:</label>
                                <input
                                    type="text"
                                    name="owner"
                                    value={formData.owner}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                        </div>
                        <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem' }}>
                            <button type="submit" className="btn">添加OKR</button>
                            <button type="button" className="btn btn-secondary" onClick={() => setShowForm(false)}>取消</button>
                        </div>
                    </form>
                </div>
            )}

            <div>
                {okrs.map(okr => (
                    <div key={okr.id} className="card" style={{ marginBottom: '1.5rem' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
                            <h2 style={{ margin: 0 }}>{okr.objective}</h2>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                                <span style={{
                                    padding: '0.25rem 0.5rem',
                                    borderRadius: '4px',
                                    backgroundColor: '#e3f2fd',
                                    color: '#0d47a1'
                                }}>
                                    {okr.quarter}
                                </span>
                                <span>{okr.owner}</span>
                                <button
                                    className="btn btn-danger"
                                    onClick={() => handleDelete(okr.id)}
                                    style={{ padding: '0.25rem 0.5rem', fontSize: '0.9rem' }}
                                >
                                    删除
                                </button>
                            </div>
                        </div>

                        <div style={{ margin: '1.5rem 0' }}>
                            <div style={{ display: 'flex', alignItems: 'center', marginBottom: '0.5rem' }}>
                                <span style={{ marginRight: '1rem', fontWeight: '500' }}>进度: {okr.progress}%</span>
                                <div className="progress-bar" style={{ flex: 1 }}>
                                    <div
                                        className="progress-fill"
                                        style={{
                                            width: `${okr.progress}%`,
                                            backgroundColor: okr.progress >= 80 ? '#4caf50' : okr.progress >= 50 ? '#ff9800' : '#f44336'
                                        }}
                                    />
                                </div>
                            </div>
                        </div>

                        <h3>关键结果(Key Results):</h3>
                        <div style={{ overflowX: 'auto' }}>
                            <table className="table">
                                <thead>
                                    <tr>
                                        <th>描述</th>
                                        <th>目标值</th>
                                        <th>当前值</th>
                                        <th>完成度</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {okr.keyResults.map(kr => (
                                        <tr key={kr.id}>
                                            <td>{kr.description}</td>
                                            <td>{kr.target}</td>
                                            <td>{kr.current}</td>
                                            <td>
                                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                                    <span>
                                                        {kr.target > 0 ?
                                                            `${Math.round((kr.current / kr.target) * 100)}%` :
                                                            `${Math.round((kr.target / kr.current) * 100)}%`}
                                                    </span>
                                                    <div className="progress-bar" style={{ width: '80px' }}>
                                                        <div
                                                            className="progress-fill"
                                                            style={{
                                                                width: `${Math.min(100, kr.target > 0 ? (kr.current / kr.target) * 100 : (kr.target / kr.current) * 100)}%`,
                                                                backgroundColor:
                                                                    (kr.target > 0 ? (kr.current / kr.target) : (kr.target / kr.current)) >= 1 ? '#4caf50' :
                                                                        (kr.target > 0 ? (kr.current / kr.target) : (kr.target / kr.current)) >= 0.7 ? '#ff9800' : '#f44336'
                                                            }}
                                                        />
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>

                        <button className="btn" style={{ marginTop: '1rem' }}>
                            添加关键结果
                        </button>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default OKRManagement;