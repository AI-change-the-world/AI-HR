import React, { useState } from 'react';

// JD数据接口
interface JobDescription {
    id: number;
    title: string;
    department: string;
    location: string;
    isOpen: boolean;
    createdAt: string;
}

const JDManagement: React.FC = () => {
    const [jds, setJds] = useState<JobDescription[]>([
        {
            id: 1,
            title: '前端工程师',
            department: '技术部',
            location: '北京',
            isOpen: true,
            createdAt: '2023-05-01'
        },
        {
            id: 2,
            title: '后端工程师',
            department: '技术部',
            location: '上海',
            isOpen: true,
            createdAt: '2023-05-02'
        },
        {
            id: 3,
            title: '产品经理',
            department: '产品部',
            location: '深圳',
            isOpen: false,
            createdAt: '2023-04-15'
        }
    ]);

    const toggleJDStatus = (id: number) => {
        setJds(jds.map(jd =>
            jd.id === id ? { ...jd, isOpen: !jd.isOpen } : jd
        ));
    };

    return (
        <div className="page-container">
            <h1>JD管理</h1>
            <div className="toolbar">
                <button className="btn btn-primary">创建JD</button>
            </div>
            <div className="table-container">
                <table className="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>职位名称</th>
                            <th>部门</th>
                            <th>工作地点</th>
                            <th>状态</th>
                            <th>创建时间</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        {jds.map((jd) => (
                            <tr key={jd.id}>
                                <td>{jd.id}</td>
                                <td>{jd.title}</td>
                                <td>{jd.department}</td>
                                <td>{jd.location}</td>
                                <td>
                                    <span className={`status ${jd.isOpen ? 'status-open' : 'status-closed'}`}>
                                        {jd.isOpen ? '开放' : '关闭'}
                                    </span>
                                </td>
                                <td>{jd.createdAt}</td>
                                <td>
                                    <button className="btn btn-small btn-secondary">编辑</button>
                                    <button
                                        className={`btn btn-small ${jd.isOpen ? 'btn-warning' : 'btn-success'}`}
                                        onClick={() => toggleJDStatus(jd.id)}
                                    >
                                        {jd.isOpen ? '关闭' : '开放'}
                                    </button>
                                    <button className="btn btn-small btn-danger">删除</button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default JDManagement;
