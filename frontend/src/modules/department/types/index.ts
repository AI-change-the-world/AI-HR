// 部门数据接口
export interface Department {
    id: number;
    name: string;
    manager: string;
    employeeCount: number;
    description: string;
}

// 创建部门请求接口
export interface CreateDepartmentRequest {
    name: string;
    manager: string;
    description: string;
}

// 更新部门请求接口
export interface UpdateDepartmentRequest {
    id: number;
    name?: string;
    manager?: string;
    description?: string;
}

// 部门查询参数接口
export interface DepartmentQueryParams {
    page?: number;
    pageSize?: number;
    name?: string;
    manager?: string;
}