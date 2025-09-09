import React, { useState } from 'react';

const EmployeeManagement = () => {
    const [employees, setEmployees] = useState([
        { id: 1, name: '张三', department: '技术部', position: '前端工程师', email: 'zhangsan@company.com' },
        { id: 2, name: '李四', department: '人事部', position: 'HR专员', email: 'lisi@company.com' },
        { id: 3, name: '王五', department: '市场部', position: '市场经理', email: 'wangwu@company.com' }
    ]);

    const [showForm, setShowForm] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        department: '',
        position: '',
        email: ''
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
        if (formData.name && formData.department && formData.position && formData.email) {
            const newEmployee = {
                id: employees.length + 1,
                ...formData
            };
            setEmployees(prev => [...prev, newEmployee]);
            setFormData({ name: '', department: '', position: '', email: '' });
            setShowForm(false);
        }
    };

    const handleDelete = (id) => {
        setEmployees(prev => prev.filter(emp => emp.id !== id));
    };

    return (
        <div className="page-container">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
                <h1 className="page-title" style={{ margin: 0 }}>员工管理</h1>
                <button className="btn" onClick={() => setShowForm(!showForm)}>
                    {showForm ? '取消添加' : '添加员工'}
                </button>
            </div>

            {showForm && (
                <div className="card" style={{ marginBottom: '1.5rem' }}>
                    <h2>添加新员工</h2>
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
                                <label>部门:</label>
                                <input
                                    type="text"
                                    name="department"
                                    value={formData.department}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>职位:</label>
                                <input
                                    type="text"
                                    name="position"
                                    value={formData.position}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>邮箱:</label>
                                <input
                                    type="email"
                                    name="email"
                                    value={formData.email}
                                    onChange={handleInputChange}
                                    required
                                />
                            </div>
                        </div>
                        <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem' }}>
                            <button type="submit" className="btn">添加员工</button>
                            <button type="button" className="btn btn-secondary" onClick={() => setShowForm(false)}>取消</button>
                        </div>
                    </form>
                </div>
            )}

            <div className="card">
                <h2>员工列表</h2>
                <div style={{ overflowX: 'auto' }}>
                    <table className="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>姓名</th>
                                <th>部门</th>
                                <th>职位</th>
                                <th>邮箱</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            {employees.map(employee => (
                                <tr key={employee.id}>
                                    <td>{employee.id}</td>
                                    <td>{employee.name}</td>
                                    <td>{employee.department}</td>
                                    <td>{employee.position}</td>
                                    <td>{employee.email}</td>
                                    <td>
                                        <button
                                            className="btn btn-danger"
                                            onClick={() => handleDelete(employee.id)}
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

export default EmployeeManagement;