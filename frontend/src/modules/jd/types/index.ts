import type { BaseResponse, PageResponse } from '../../../utils/api';

// JD数据接口
export interface JobDescription {
    id: number;
    title: string;
    department: string;
    location: string;
    description?: string;
    requirements?: string;
    status: string; // '开放' | '关闭'
    created_at?: string;
    updated_at?: string;
    is_open?: boolean;
    salary_range?: string;
    full_text?: string;
    evaluation_criteria?: Record<string, any>; // 改为对象类型
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

// JD完整信息更新接口
export interface JDFullInfoUpdate {
    full_text?: string;
    evaluation_criteria?: Record<string, any>;
}

// 评价标准更新接口
export interface EvaluationCriteriaUpdate {
    criteria: Record<string, any>;
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

// AI润色响应接口
export interface PolishResponse {
    polished_text: string;
}

// 从文本创建JD请求接口
export interface CreateFromTextRequest {
    text: string;
}