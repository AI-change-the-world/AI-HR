// 员工数据接口
export interface Employee {
    id: number;
    name: string;
    department: string;
    departmentId?: number;
    position: string;
    email: string;
    phone: string;
    hireDate?: string;
    status?: 'active' | 'inactive' | 'pending';
}

// 创建员工请求接口
export interface CreateEmployeeRequest {
    name: string;
    departmentId: number;
    position: string;
    email: string;
    phone: string;
    hireDate?: string;
}

// 更新员工请求接口
export interface UpdateEmployeeRequest {
    id: number;
    name?: string;
    departmentId?: number;
    position?: string;
    email?: string;
    phone?: string;
    status?: 'active' | 'inactive' | 'pending';
}

// 员工查询参数接口
export interface EmployeeQueryParams {
    page?: number;
    pageSize?: number;
    name?: string;
    department?: string;
    position?: string;
    status?: string;
}