import { OKR, CreateOKRRequest, UpdateOKRRequest, OKRQueryParams } from '../types';
import apiClient from '../../../utils/api';

const API_BASE = '/api/okrs';

// 获取OKR列表
export const getOKRs = async (params?: OKRQueryParams): Promise<OKR[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    return apiClient.get(url);
};

// 获取单个OKR
export const getOKR = async (id: number): Promise<OKR> => {
    return apiClient.get(`${API_BASE}/${id}`);
};

// 创建OKR
export const createOKR = async (data: CreateOKRRequest): Promise<OKR> => {
    return apiClient.post(API_BASE, data);
};

// 更新OKR
export const updateOKR = async (data: UpdateOKRRequest): Promise<OKR> => {
    return apiClient.put(`${API_BASE}/${data.id}`, data);
};

// 删除OKR
export const deleteOKR = async (id: number): Promise<void> => {
    return apiClient.delete(`${API_BASE}/${id}`);
};

// 更新OKR进度
export const updateOKRProgress = async (id: number, progress: number): Promise<OKR> => {
    return apiClient.patch(`${API_BASE}/${id}/progress`, { progress });
};