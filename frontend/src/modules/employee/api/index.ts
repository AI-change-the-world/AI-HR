import { Employee, CreateEmployeeRequest, UpdateEmployeeRequest, EmployeeQueryParams } from '../types';

const API_BASE = '/api/employees';

// 获取员工列表
export const getEmployees = async (params?: EmployeeQueryParams): Promise<Employee[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    const response = await fetch(url);
    if (!response.ok) {
        throw new Error('获取员工列表失败');
    }
    return response.json();
};

// 获取单个员工
export const getEmployee = async (id: number): Promise<Employee> => {
    const response = await fetch(`${API_BASE}/${id}`);
    if (!response.ok) {
        throw new Error('获取员工信息失败');
    }
    return response.json();
};

// 创建员工
export const createEmployee = async (data: CreateEmployeeRequest): Promise<Employee> => {
    const response = await fetch(API_BASE, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('创建员工失败');
    }
    return response.json();
};

// 更新员工
export const updateEmployee = async (data: UpdateEmployeeRequest): Promise<Employee> => {
    const response = await fetch(`${API_BASE}/${data.id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('更新员工失败');
    }
    return response.json();
};

// 删除员工
export const deleteEmployee = async (id: number): Promise<void> => {
    const response = await fetch(`${API_BASE}/${id}`, {
        method: 'DELETE',
    });

    if (!response.ok) {
        throw new Error('删除员工失败');
    }
};

// 批量导入员工
export const importEmployees = async (file: File): Promise<Employee[]> => {
    const formData = new FormData();
    formData.append('file', file);

    const response = await fetch(`${API_BASE}/import`, {
        method: 'POST',
        body: formData,
    });

    if (!response.ok) {
        throw new Error('导入员工失败');
    }
    return response.json();
};