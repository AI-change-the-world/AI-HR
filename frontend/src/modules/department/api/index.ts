import { Department, CreateDepartmentRequest, UpdateDepartmentRequest, DepartmentQueryParams } from '../types';

const API_BASE = '/api/departments';

// 获取部门列表
export const getDepartments = async (params?: DepartmentQueryParams): Promise<Department[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    const response = await fetch(url);
    if (!response.ok) {
        throw new Error('获取部门列表失败');
    }
    return response.json();
};

// 获取单个部门
export const getDepartment = async (id: number): Promise<Department> => {
    const response = await fetch(`${API_BASE}/${id}`);
    if (!response.ok) {
        throw new Error('获取部门信息失败');
    }
    return response.json();
};

// 创建部门
export const createDepartment = async (data: CreateDepartmentRequest): Promise<Department> => {
    const response = await fetch(API_BASE, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('创建部门失败');
    }
    return response.json();
};

// 更新部门
export const updateDepartment = async (data: UpdateDepartmentRequest): Promise<Department> => {
    const response = await fetch(`${API_BASE}/${data.id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('更新部门失败');
    }
    return response.json();
};

// 删除部门
export const deleteDepartment = async (id: number): Promise<void> => {
    const response = await fetch(`${API_BASE}/${id}`, {
        method: 'DELETE',
    });

    if (!response.ok) {
        throw new Error('删除部门失败');
    }
};