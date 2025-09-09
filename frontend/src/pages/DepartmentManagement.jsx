import React, { useState } from 'react';

const DepartmentManagement = () => {
    const [departments, setDepartments] = useState([
        { id: 1, name: '技术部', manager: '张三', employeeCount: 15, description: '负责产品开发与技术维护' },
        { id: 2, name: '人事部', manager: '李四', employeeCount: 10, description: '负责员工招聘与管理' },
        { id: 3, name: '市场部', manager: '王五', employeeCount: 8, description: '负责市场推广与品牌建设' }
    ]);

    const [showForm, setShowForm] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        manager: '',
        description: ''
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
        if (formData.name && formData.manager) {
            const newDepartment = {
                id: departments.length + 1,
                ...formData,
                employeeCount: 0
            };
            setDepartments(prev => [...prev, newDepartment]);
            setFormData({ name: '', manager: '', description: '' });
            setShowForm(false);
        }
    };

    const handleDelete = (id) => {
        setDepartments(prev => prev.filter(dept => dept.id !== id));
    };

    return (
        <div className="page-container">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
                <h1 className="page-title" style={{ margin: 0 }}>部门管理</h1>
                <button className="btn" onClick={() => setShowForm(!showForm)}>
                    {showForm ? '取消添加' : '添加部门'}
                </button>
            </div>

            {showForm && (
                <div className="card" style={{ marginBottom: '1.5rem' }}>
                    <h2>添加新部门</h2>
                    <form onSubmit={handleSubmit}>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem' }}>
                            <div className="form-group">
                                <label>部门名称:</label>
                                <input
                                    type="text"
                                    name="name"
                                    value={formData.name}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>部门经理:</label>
                                <input
                                    type="text"
                                    name="manager"
                                    value={formData.manager}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group" style={{ gridColumn: '1 / -1' }}>
                                <label>部门描述:</label>
                                <textarea
                                    name="description"
                                    value={formData.description}
                                    onChange={handleInputChange}
                                    rows="3"
                                />
                            </div>
                        </div>
                        <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem' }}>
                            <button type="submit" className="btn">添加部门</button>
                            <button type="button" className="btn btn-secondary" onClick={() => setShowForm(false)}>取消</button>
                        </div>
                    </form>
                </div>
            )}

            <div className="card">
                <h2>部门列表</h2>
                <div style={{ overflowX: 'auto' }}>
                    <table className="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>部门名称</th>
                                <th>部门经理</th>
                                <th>员工数量</th>
                                <th>描述</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            {departments.map(dept => (
                                <tr key={dept.id}>
                                    <td>{dept.id}</td>
                                    <td>{dept.name}</td>
                                    <td>{dept.manager}</td>
                                    <td>{dept.employeeCount}</td>
                                    <td>{dept.description}</td>
                                    <td>
                                        <button
                                            className="btn btn-danger"
                                            onClick={() => handleDelete(dept.id)}
                                            style={{ padding: '0.25rem 0.5rem', fontSize: '0.9rem' }}
                                        >
                                            删除
                                        </button>
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

export default DepartmentManagement;