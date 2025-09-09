import React, { useState } from 'react';

const JDManagement = () => {
    const [jobDescriptions, setJobDescriptions] = useState([
        { id: 1, title: '前端工程师', department: '技术部', location: '北京', status: '发布中' },
        { id: 2, title: '后端工程师', department: '技术部', location: '上海', status: '草稿' },
        { id: 3, title: '产品经理', department: '产品部', location: '深圳', status: '发布中' }
    ]);

    const [showForm, setShowForm] = useState(false);
    const [formData, setFormData] = useState({
        title: '',
        department: '',
        location: '',
        status: '草稿'
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
        if (formData.title && formData.department && formData.location) {
            const newJD = {
                id: jobDescriptions.length + 1,
                ...formData
            };
            setJobDescriptions(prev => [...prev, newJD]);
            setFormData({ title: '', department: '', location: '', status: '草稿' });
            setShowForm(false);
        }
    };

    const handleDelete = (id) => {
        setJobDescriptions(prev => prev.filter(jd => jd.id !== id));
    };

    const toggleStatus = (id) => {
        setJobDescriptions(prev =>
            prev.map(jd =>
                jd.id === id ? {
                    ...jd,
                    status: jd.status === '发布中' ? '草稿' : '发布中'
                } : jd
            )
        );
    };

    return (
        <div className="page-container">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
                <h1 className="page-title" style={{ margin: 0 }}>JD管理</h1>
                <button className="btn" onClick={() => setShowForm(!showForm)}>
                    {showForm ? '取消添加' : '添加JD'}
                </button>
            </div>

            {showForm && (
                <div className="card" style={{ marginBottom: '1.5rem' }}>
                    <h2>添加新职位描述</h2>
                    <form onSubmit={handleSubmit}>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem' }}>
                            <div className="form-group">
                                <label>职位名称:</label>
                                <input
                                    type="text"
                                    name="title"
                                    value={formData.title}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>所属部门:</label>
                                <input
                                    type="text"
                                    name="department"
                                    value={formData.department}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>工作地点:</label>
                                <input
                                    type="text"
                                    name="location"
                                    value={formData.location}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>状态:</label>
                                <select
                                    name="status"
                                    value={formData.status}
                                    onChange={handleInputChange}
                                >
                                    <option value="草稿">草稿</option>
                                    <option value="发布中">发布中</option>
                                </select>
                            </div>
                        </div>
                        <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem' }}>
                            <button type="submit" className="btn">添加JD</button>
                            <button type="button" className="btn btn-secondary" onClick={() => setShowForm(false)}>取消</button>
                        </div>
                    </form>
                </div>
            )}

            <div className="card">
                <h2>职位描述列表</h2>
                <div style={{ overflowX: 'auto' }}>
                    <table className="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>职位名称</th>
                                <th>所属部门</th>
                                <th>工作地点</th>
                                <th>状态</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            {jobDescriptions.map(jd => (
                                <tr key={jd.id}>
                                    <td>{jd.id}</td>
                                    <td>{jd.title}</td>
                                    <td>{jd.department}</td>
                                    <td>{jd.location}</td>
                                    <td>
                                        <span style={{
                                            padding: '0.25rem 0.5rem',
                                            borderRadius: '4px',
                                            backgroundColor:
                                                jd.status === '草稿' ? '#fff8e1' : '#e8f5e9',
                                            color:
                                                jd.status === '草稿' ? '#f57f17' : '#2e7d32'
                                        }}>
                                            {jd.status}
                                        </span>
                                    </td>
                                    <td>
                                        <div style={{ display: 'flex', gap: '0.5rem' }}>
                                            <button
                                                className={`btn ${jd.status === '发布中' ? 'btn-secondary' : 'btn-success'}`}
                                                onClick={() => toggleStatus(jd.id)}
                                                style={{ padding: '0.25rem 0.5rem', fontSize: '0.9rem' }}
                                            >
                                                {jd.status === '发布中' ? '设为草稿' : '发布'}
                                            </button>
                                            <button
                                                className="btn btn-danger"
                                                onClick={() => handleDelete(jd.id)}
                                                style={{ padding: '0.25rem 0.5rem', fontSize: '0.9rem' }}
                                            >
                                                删除
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>

            <div className="card">
                <h2>AI生成JD</h2>
                <p>使用AI技术快速生成标准化职位描述</p>
                <button className="btn" style={{ marginTop: '1rem' }}>
                    使用AI生成JD
                </button>
            </div>
        </div>
    );
};

export default JDManagement;