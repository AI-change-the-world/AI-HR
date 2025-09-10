import { Resume, ResumeMatch, CreateResumeRequest, UpdateResumeRequest, ResumeQueryParams } from '../types';

const API_BASE = '/api/resumes';

// 获取简历列表
export const getResumes = async (params?: ResumeQueryParams): Promise<Resume[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    const response = await fetch(url);
    if (!response.ok) {
        throw new Error('获取简历列表失败');
    }
    return response.json();
};

// 获取单个简历
export const getResume = async (id: number): Promise<Resume> => {
    const response = await fetch(`${API_BASE}/${id}`);
    if (!response.ok) {
        throw new Error('获取简历信息失败');
    }
    return response.json();
};

// 创建简历
export const createResume = async (data: CreateResumeRequest): Promise<Resume> => {
    const response = await fetch(API_BASE, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('创建简历失败');
    }
    return response.json();
};

// 更新简历
export const updateResume = async (data: UpdateResumeRequest): Promise<Resume> => {
    const response = await fetch(`${API_BASE}/${data.id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('更新简历失败');
    }
    return response.json();
};

// 删除简历
export const deleteResume = async (id: number): Promise<void> => {
    const response = await fetch(`${API_BASE}/${id}`, {
        method: 'DELETE',
    });

    if (!response.ok) {
        throw new Error('删除简历失败');
    }
};

// 上传简历文件
export const uploadResumeFile = async (file: File): Promise<Resume> => {
    const formData = new FormData();
    formData.append('file', file);

    const response = await fetch(`${API_BASE}/upload`, {
        method: 'POST',
        body: formData,
    });

    if (!response.ok) {
        throw new Error('上传简历失败');
    }
    return response.json();
};

// 简历与JD匹配
export const matchResumeWithJD = async (resumeId: number, jdId: number): Promise<ResumeMatch> => {
    const response = await fetch(`${API_BASE}/${resumeId}/match/${jdId}`, {
        method: 'POST',
    });

    if (!response.ok) {
        throw new Error('简历匹配失败');
    }
    return response.json();
};

// 批量筛选简历
export const batchScreenResumes = async (jdId: number): Promise<ResumeMatch[]> => {
    const response = await fetch(`${API_BASE}/batch-screen`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ jdId }),
    });

    if (!response.ok) {
        throw new Error('批量筛选简历失败');
    }
    return response.json();
};