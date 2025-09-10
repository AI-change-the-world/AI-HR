// JD数据接口
export interface JobDescription {
    id: number;
    title: string;
    department: string;
    departmentId?: number;
    location: string;
    isOpen: boolean;
    createdAt: string;
    updatedAt?: string;
    description?: string;
    requirements?: string[];
    benefits?: string[];
    salaryRange?: {
        min: number;
        max: number;
    };
}

// 创建JD请求接口
export interface CreateJDRequest {
    title: string;
    departmentId: number;
    location: string;
    description: string;
    requirements: string[];
    benefits?: string[];
    salaryRange?: {
        min: number;
        max: number;
    };
}

// 更新JD请求接口
export interface UpdateJDRequest {
    id: number;
    title?: string;
    departmentId?: number;
    location?: string;
    description?: string;
    requirements?: string[];
    benefits?: string[];
    isOpen?: boolean;
    salaryRange?: {
        min: number;
        max: number;
    };
}

// JD查询参数接口
export interface JDQueryParams {
    page?: number;
    pageSize?: number;
    title?: string;
    department?: string;
    location?: string;
    isOpen?: boolean;
}