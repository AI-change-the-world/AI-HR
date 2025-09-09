import React, { useState } from 'react';

// 简历数据接口
interface Resume {
    id: number;
    name: string;
    position: string;
    score: number;
    status: string;
    createdAt: string;
}

const ResumeLibrary: React.FC = () => {
    const [resumes, setResumes] = useState<Resume[]>([
        {
            id: 1,
            name: '张三',
            position: '前端工程师',
            score: 8.5,
            status: '已筛选',
            createdAt: '2023-05-15'
        },
        {
            id: 2,
            name: '李四',
            position: '后端工程师',
            score: 9.2,
            status: '待筛选',
            createdAt: '2023-05-16'
        },
        {
            id: 3,
            name: '王五',
            position: '产品经理',
            score: 7.8,
            status: '已筛选',
            createdAt: '2023-05-17'
        }
    ]);

    const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
        const files = event.target.files;
        if (files && files.length > 0) {
            // 这里应该是实际的文件上传逻辑
            alert(`选择了文件: ${files[0].name}`);
        }
    };

    return (
        <div className="page-container">
            <h1>简历库</h1>
            <div className="toolbar">
                <div className="upload-section">
                    <label htmlFor="resume-upload" className="btn btn-primary">
                        上传简历
                    </label>
                    <input
                        id="resume-upload"
                        type="file"
                        accept=".pdf,.doc,.docx"
                        onChange={handleFileUpload}
                        style={{ display: 'none' }}
                    />
                </div>
                <button className="btn btn-secondary">筛选简历</button>
            </div>
            <div className="table-container">
                <table className="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>姓名</th>
                            <th>职位</th>
                            <th>评分</th>
                            <th>状态</th>
                            <th>上传时间</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        {resumes.map((resume) => (
                            <tr key={resume.id}>
                                <td>{resume.id}</td>
                                <td>{resume.name}</td>
                                <td>{resume.position}</td>
                                <td>{resume.score}</td>
                                <td>{resume.status}</td>
                                <td>{resume.createdAt}</td>
                                <td>
                                    <button className="btn btn-small btn-secondary">查看</button>
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

export default ResumeLibrary;
