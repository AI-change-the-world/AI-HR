import { JobDescription, CreateJDRequest, UpdateJDRequest, JDQueryParams, EvaluationStep } from '../types';

const API_BASE = '/api/jd';

// 获取JD列表
export const getJDs = async (params?: JDQueryParams): Promise<JobDescription[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    const response = await fetch(url);
    if (!response.ok) {
        throw new Error('获取JD列表失败');
    }
    return response.json();
};

// 获取单个JD
export const getJD = async (id: number): Promise<JobDescription> => {
    const response = await fetch(`${API_BASE}/${id}`);
    if (!response.ok) {
        throw new Error('获取JD信息失败');
    }
    return response.json();
};

// 创建JD
export const createJD = async (data: CreateJDRequest): Promise<JobDescription> => {
    const response = await fetch(API_BASE, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('创建JD失败');
    }
    return response.json();
};

// 更新JD
export const updateJD = async (data: UpdateJDRequest): Promise<JobDescription> => {
    const response = await fetch(`${API_BASE}/${data.id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });

    if (!response.ok) {
        throw new Error('更新JD失败');
    }
    return response.json();
};

// 删除JD
export const deleteJD = async (id: number): Promise<void> => {
    const response = await fetch(`${API_BASE}/${id}`, {
        method: 'DELETE',
    });

    if (!response.ok) {
        throw new Error('删除JD失败');
    }
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

    const response = await fetch(`${API_BASE}/${jdId}/evaluate-resume`, {
        method: 'POST',
        body: formData,
    });

    if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || '简历评估失败');
    }

    const data = await response.json();
    return data.results || [];
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

    const response = await fetch(`${API_BASE}/${jdId}/evaluate-resume`, {
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
    const response = await fetch(`${API_BASE}/${id}/evaluation-criteria`);
    if (!response.ok) {
        throw new Error('获取评估标准失败');
    }
    const data = await response.json();
    return data.criteria || {};
};

// 保存JD的评估标准
export const saveJDEvaluationCriteria = async (
    id: number,
    criteria: Record<string, any>
): Promise<void> => {
    // 这里需要后端支持保存评估标准到JD的evaluation_criteria字段
    const response = await fetch(`${API_BASE}/${id}/evaluation-criteria`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ criteria }),
    });

    if (!response.ok) {
        throw new Error('保存评估标准失败');
    }
};