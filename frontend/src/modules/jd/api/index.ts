import { JobDescription, CreateJDRequest, UpdateJDRequest, JDQueryParams, EvaluationStep } from '../types';
import apiClient from '../../../utils/api';

const API_BASE = '/api/jd';

// 获取JD列表
export const getJDs = async (params?: JDQueryParams): Promise<JobDescription[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    return apiClient.get(url);
};

// 获取单个JD
export const getJD = async (id: number): Promise<JobDescription> => {
    return apiClient.get(`${API_BASE}/${id}`);
};

// 创建JD
export const createJD = async (data: CreateJDRequest): Promise<JobDescription> => {
    return apiClient.post(API_BASE, data);
};

// 更新JD
export const updateJD = async (data: UpdateJDRequest): Promise<JobDescription> => {
    return apiClient.put(`${API_BASE}/${data.id}`, data);
};

// 删除JD
export const deleteJD = async (id: number): Promise<void> => {
    return apiClient.delete(`${API_BASE}/${id}`);
};

// 切换JD状态
export const toggleJDStatus = async (id: number): Promise<JobDescription> => {
    // 先获取当前JD信息
    const currentJD = await getJD(id);
    const newStatus = currentJD.status === '开放' ? '关闭' : '开放';

    // 更新状态
    return updateJD({ id, status: newStatus });
};

// 简历评估API
export const evaluateResume = async (
    jdId: number,
    file: File,
    scoringRules?: Record<string, any>
): Promise<EvaluationStep[]> => {
    const formData = new FormData();
    formData.append('resume_file', file);

    // 如果有评分规则，添加到请求中
    if (scoringRules) {
        formData.append('scoring_rules', JSON.stringify(scoringRules));
    }

    const response = await apiClient.post(`${API_BASE}/${jdId}/evaluate-resume`, formData, {
        headers: {
            'Content-Type': 'multipart/form-data',
        },
    });

    return response.results || [];
};

// 流式简历评估API（实时返回评估进度）
export const evaluateResumeStream = async (
    jdId: number,
    file: File,
    scoringRules?: Record<string, any>,
    onProgress?: (step: EvaluationStep) => void
): Promise<EvaluationStep[]> => {
    const formData = new FormData();
    formData.append('resume_file', file);

    if (scoringRules) {
        formData.append('scoring_rules', JSON.stringify(scoringRules));
    }

    // 注意：流式接口不使用axios，使用原生fetch支持流式读取
    const baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';
    const response = await fetch(`${baseURL}${API_BASE}/${jdId}/evaluate-resume`, {
        method: 'POST',
        body: formData,
    });

    if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || '简历评估失败');
    }

    const data = await response.json();
    const results = data.results || [];

    // 模拟流式返回，实际可以用WebSocket或Server-Sent Events
    if (onProgress) {
        for (let i = 0; i < results.length; i++) {
            setTimeout(() => {
                onProgress(results[i]);
            }, i * 1000); // 每秒返回一个步骤
        }
    }

    return results;
};

// 获取JD的评估标准
export const getJDEvaluationCriteria = async (id: number): Promise<Record<string, any>> => {
    const response = await apiClient.get(`${API_BASE}/${id}/evaluation-criteria`);
    return response.criteria || {};
};

// 保存JD的评估标准
export const saveJDEvaluationCriteria = async (
    id: number,
    criteria: Record<string, any>
): Promise<void> => {
    return apiClient.put(`${API_BASE}/${id}/evaluation-criteria`, { criteria });
};