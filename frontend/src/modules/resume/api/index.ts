import { Resume, ResumeMatch, CreateResumeRequest, UpdateResumeRequest, ResumeQueryParams } from '../types';
import apiClient from '../../../utils/api';

const API_BASE = '/api/resumes';

// 获取简历列表
export const getResumes = async (params?: ResumeQueryParams): Promise<Resume[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    return apiClient.get(url);
};

// 获取单个简历
export const getResume = async (id: number): Promise<Resume> => {
    return apiClient.get(`${API_BASE}/${id}`);
};

// 创建简历
export const createResume = async (data: CreateResumeRequest): Promise<Resume> => {
    return apiClient.post(API_BASE, data);
};

// 更新简历
export const updateResume = async (data: UpdateResumeRequest): Promise<Resume> => {
    return apiClient.put(`${API_BASE}/${data.id}`, data);
};

// 删除简历
export const deleteResume = async (id: number): Promise<void> => {
    return apiClient.delete(`${API_BASE}/${id}`);
};

// 上传简历文件
export const uploadResumeFile = async (file: File): Promise<Resume> => {
    const formData = new FormData();
    formData.append('file', file);

    return apiClient.post(`${API_BASE}/upload`, formData, {
        headers: {
            'Content-Type': 'multipart/form-data',
        },
    });
};

// 简历与JD匹配
export const matchResumeWithJD = async (resumeId: number, jdId: number): Promise<ResumeMatch> => {
    return apiClient.post(`${API_BASE}/${resumeId}/match/${jdId}`);
};

// 批量筛选简历
export const batchScreenResumes = async (jdId: number): Promise<ResumeMatch[]> => {
    return apiClient.post(`${API_BASE}/batch-screen`, { jdId });
};