import { Employee, CreateEmployeeRequest, UpdateEmployeeRequest, EmployeeQueryParams } from '../types';
import apiClient from '../../../utils/api';

const API_BASE = '/api/employees';

// 获取员工列表
export const getEmployees = async (params?: EmployeeQueryParams): Promise<Employee[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    return apiClient.get(url);
};

// 获取单个员工
export const getEmployee = async (id: number): Promise<Employee> => {
    return apiClient.get(`${API_BASE}/${id}`);
};

// 创建员工
export const createEmployee = async (data: CreateEmployeeRequest): Promise<Employee> => {
    return apiClient.post(API_BASE, data);
};

// 更新员工
export const updateEmployee = async (data: UpdateEmployeeRequest): Promise<Employee> => {
    return apiClient.put(`${API_BASE}/${data.id}`, data);
};

// 删除员工
export const deleteEmployee = async (id: number): Promise<void> => {
    return apiClient.delete(`${API_BASE}/${id}`);
};

// 批量导入员工
export const importEmployees = async (file: File): Promise<Employee[]> => {
    const formData = new FormData();
    formData.append('file', file);

    return apiClient.post(`${API_BASE}/import`, formData, {
        headers: {
            'Content-Type': 'multipart/form-data',
        },
    });
};