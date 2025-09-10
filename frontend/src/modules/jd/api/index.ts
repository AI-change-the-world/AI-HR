import { JobDescription, CreateJDRequest, UpdateJDRequest, JDQueryParams } from '../types';

const API_BASE = '/api/jds';

// 获取JD列表
export const getJDs = async (params?: JDQueryParams): Promise<JobDescription[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    const response = await fetch(url);
    if (!response.ok) {
        throw new Error('获取JD列表失败');
    }
    return response.json();
};

// 获取单个JD
export const getJD = async (id: number): Promise<JobDescription> => {
    const response = await fetch(`${API_BASE}/${id}`);
    if (!response.ok) {
        throw new Error('获取JD信息失败');
    }
    return response.json();
};

// 创建JD
export const createJD = async (data: CreateJDRequest): Promise<JobDescription> => {
    const response = await fetch(API_BASE, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('创建JD失败');
    }
    return response.json();
};

// 更新JD
export const updateJD = async (data: UpdateJDRequest): Promise<JobDescription> => {
    const response = await fetch(`${API_BASE}/${data.id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('更新JD失败');
    }
    return response.json();
};

// 删除JD
export const deleteJD = async (id: number): Promise<void> => {
    const response = await fetch(`${API_BASE}/${id}`, {
        method: 'DELETE',
    });

    if (!response.ok) {
        throw new Error('删除JD失败');
    }
};

// 切换JD状态
export const toggleJDStatus = async (id: number): Promise<JobDescription> => {
    const response = await fetch(`${API_BASE}/${id}/toggle`, {
        method: 'PATCH',
    });

    if (!response.ok) {
        throw new Error('切换JD状态失败');
    }
    return response.json();
};