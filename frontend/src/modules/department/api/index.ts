import { Department, CreateDepartmentRequest, UpdateDepartmentRequest, DepartmentQueryParams } from '../types';
import apiClient from '../../../utils/api';

const API_BASE = '/api/departments';

// 获取部门列表
export const getDepartments = async (params?: DepartmentQueryParams): Promise<Department[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    return apiClient.get(url);
};

// 获取单个部门
export const getDepartment = async (id: number): Promise<Department> => {
    return apiClient.get(`${API_BASE}/${id}`);
};

// 创建部门
export const createDepartment = async (data: CreateDepartmentRequest): Promise<Department> => {
    return apiClient.post(API_BASE, data);
};

// 更新部门
export const updateDepartment = async (data: UpdateDepartmentRequest): Promise<Department> => {
    return apiClient.put(`${API_BASE}/${data.id}`, data);
};

// 删除部门
export const deleteDepartment = async (id: number): Promise<void> => {
    return apiClient.delete(`${API_BASE}/${id}`);
};