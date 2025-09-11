// JD数据接口
export interface JobDescription {
    id: number;
    title: string;
    department: string;
    location: string;
    description?: string;
    status: string; // '开放' | '关闭'
    createdAt: string;
}

export interface EvaluationStep {
    step: number;
    name: string;
    score?: number;
    reason?: string;
    steps?: Array<{ id: number; name: string; desc: string }>;
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