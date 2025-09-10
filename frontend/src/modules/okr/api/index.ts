import { OKR, CreateOKRRequest, UpdateOKRRequest, OKRQueryParams } from '../types';

const API_BASE = '/api/okrs';

// 获取OKR列表
export const getOKRs = async (params?: OKRQueryParams): Promise<OKR[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    const response = await fetch(url);
    if (!response.ok) {
        throw new Error('获取OKR列表失败');
    }
    return response.json();
};

// 获取单个OKR
export const getOKR = async (id: number): Promise<OKR> => {
    const response = await fetch(`${API_BASE}/${id}`);
    if (!response.ok) {
        throw new Error('获取OKR信息失败');
    }
    return response.json();
};

// 创建OKR
export const createOKR = async (data: CreateOKRRequest): Promise<OKR> => {
    const response = await fetch(API_BASE, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('创建OKR失败');
    }
    return response.json();
};

// 更新OKR
export const updateOKR = async (data: UpdateOKRRequest): Promise<OKR> => {
    const response = await fetch(`${API_BASE}/${data.id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('更新OKR失败');
    }
    return response.json();
};

// 删除OKR
export const deleteOKR = async (id: number): Promise<void> => {
    const response = await fetch(`${API_BASE}/${id}`, {
        method: 'DELETE',
    });

    if (!response.ok) {
        throw new Error('删除OKR失败');
    }
};

// 更新OKR进度
export const updateOKRProgress = async (id: number, progress: number): Promise<OKR> => {
    const response = await fetch(`${API_BASE}/${id}/progress`, {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ progress }),
    });

    if (!response.ok) {
        throw new Error('更新OKR进度失败');
    }
    return response.json();
};