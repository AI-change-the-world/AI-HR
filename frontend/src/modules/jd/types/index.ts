// JD数据接口
export interface JobDescription {
    id: number;
    title: string;
    department: string;
    location: string;
    description?: string;
    requirements?: string;
    status: string; // '开放' | '关闭'
    createdAt: string;
    updatedAt?: string;
    is_open?: boolean;
    salary_range?: string;
    full_text?: string;
    evaluation_criteria?: string;
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
    department: string;
    location: string;
    description?: string;
    requirements?: string;
    status?: string;
    salary_range?: string;
}

// 更新JD请求接口
export interface UpdateJDRequest {
    id: number;
    title?: string;
    department?: string;
    location?: string;
    description?: string;
    requirements?: string;
    status?: string;
    salary_range?: string;
}

// JD查询参数接口
export interface JDQueryParams {
    skip?: number;
    limit?: number;
    title?: string;
    department?: string;
    location?: string;
    status?: string;
}