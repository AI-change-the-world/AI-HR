import React, { useState } from 'react';

const ResumeLibrary = () => {
    const [resumes, setResumes] = useState([
        { id: 1, name: '张三', position: '前端工程师', experience: '3年', education: '本科', status: '待筛选' },
        { id: 2, name: '李四', position: '后端工程师', experience: '5年', education: '硕士', status: '面试中' },
        { id: 3, name: '王五', position: '产品经理', experience: '4年', education: '本科', status: '已录用' }
    ]);

    const [showForm, setShowForm] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        position: '',
        experience: '',
        education: ''
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
        if (formData.name && formData.position && formData.experience && formData.education) {
            const newResume = {
                id: resumes.length + 1,
                ...formData,
                status: '待筛选'
            };
            setResumes(prev => [...prev, newResume]);
            setFormData({ name: '', position: '', experience: '', education: '' });
            setShowForm(false);
        }
    };

    const handleDelete = (id) => {
        setResumes(prev => prev.filter(resume => resume.id !== id));
    };

    const updateStatus = (id, status) => {
        setResumes(prev =>
            prev.map(resume =>
                resume.id === id ? { ...resume, status } : resume
            )
        );
    };

    return (
        <div className="page-container">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
                <h1 className="page-title" style={{ margin: 0 }}>简历库</h1>
                <button className="btn" onClick={() => setShowForm(!showForm)}>
                    {showForm ? '取消添加' : '添加简历'}
                </button>
            </div>

            {showForm && (
                <div className="card" style={{ marginBottom: '1.5rem' }}>
                    <h2>添加新简历</h2>
                    <form onSubmit={handleSubmit}>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem' }}>
                            <div className="form-group">
                                <label>姓名:</label>
                                <input
                                    type="text"
                                    name="name"
                                    value={formData.name}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>应聘职位:</label>
                                <input
                                    type="text"
                                    name="position"
                                    value={formData.position}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>工作经验:</label>
                                <input
                                    type="text"
                                    name="experience"
                                    value={formData.experience}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>学历:</label>
                                <input
                                    type="text"
                                    name="education"
                                    value={formData.education}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                        </div>
                        <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem' }}>
                            <button type="submit" className="btn">添加简历</button>
                            <button type="button" className="btn btn-secondary" onClick={() => setShowForm(false)}>取消</button>
                        </div>
                    </form>
                </div>
            )}

            <div className="card">
                <h2>简历列表</h2>
                <div style={{ overflowX: 'auto' }}>
                    <table className="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>姓名</th>
                                <th>应聘职位</th>
                                <th>工作经验</th>
                                <th>学历</th>
                                <th>状态</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            {resumes.map(resume => (
                                <tr key={resume.id}>
                                    <td>{resume.id}</td>
                                    <td>{resume.name}</td>
                                    <td>{resume.position}</td>
                                    <td>{resume.experience}</td>
                                    <td>{resume.education}</td>
                                    <td>
                                        <span style={{
                                            padding: '0.25rem 0.5rem',
                                            borderRadius: '4px',
                                            backgroundColor:
                                                resume.status === '待筛选' ? '#ffebee' :
                                                    resume.status === '面试中' ? '#fff8e1' : '#e8f5e9',
                                            color:
                                                resume.status === '待筛选' ? '#c62828' :
                                                    resume.status === '面试中' ? '#f57f17' : '#2e7d32'
                                        }}>
                                            {resume.status}
                                        </span>
                                    </td>
                                    <td>
                                        <div style={{ display: 'flex', gap: '0.5rem' }}>
                                            <button
                                                className="btn btn-success"
                                                onClick={() => updateStatus(resume.id, '面试中')}
                                                style={{ padding: '0.25rem 0.5rem', fontSize: '0.9rem' }}
                                            >
                                                面试
                                            </button>
                                            <button
                                                className="btn btn-danger"
                                                onClick={() => handleDelete(resume.id)}
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
        </div>
    );
};

export default ResumeLibrary;