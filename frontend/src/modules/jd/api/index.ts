import { JobDescription, CreateJDRequest, UpdateJDRequest, JDQueryParams, EvaluationStep, JDFullInfoUpdate, EvaluationCriteriaUpdate, PolishResponse } from '../types';
import apiClient, { PageResponse } from '../../../utils/api';

const API_BASE = '/api/jd';

// 获取JD列表
export const getJDs = async (params?: JDQueryParams): Promise<JobDescription[]> => {
    const queryString = params ? new URLSearchParams(params as any).toString() : '';
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    const pageResponse: PageResponse<JobDescription> = await apiClient.get(url);
    return pageResponse.data || [];
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

// 简历评估API（非流式）
export const evaluateResume = async (
    jdId: number,
    file: File
): Promise<EvaluationStep[]> => {
    const formData = new FormData();
    formData.append('resume_file', file);

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
    onProgress?: (step: EvaluationStep) => void,
    onError?: (error: string) => void
): Promise<EvaluationStep[]> => {
    const formData = new FormData();
    formData.append('resume_file', file);

    // 流式接口使用原生fetch支持流式读取
    const baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';
    const response = await fetch(`${baseURL}${API_BASE}/${jdId}/evaluate-resume`, {
        method: 'POST',
        body: formData,
    });

    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }

    const reader = response.body?.getReader();
    const decoder = new TextDecoder();
    const results: EvaluationStep[] = [];

    if (!reader) {
        throw new Error('响应流不可用');
    }

    try {
        while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            const chunk = decoder.decode(value, { stream: true });
            const lines = chunk.split('\n');

            for (const line of lines) {
                if (line.startsWith('data: ')) {
                    const data = line.slice(6).trim();

                    if (data === '[DONE]') {
                        return results;
                    }

                    try {
                        const stepData = JSON.parse(data);

                        if (stepData.error) {
                            if (onError) {
                                onError(stepData.error);
                            }
                            throw new Error(stepData.error);
                        }

                        results.push(stepData);
                        if (onProgress) {
                            onProgress(stepData);
                        }
                    } catch (parseError) {
                        console.warn('解析流式数据失败:', parseError);
                    }
                }
            }
        }
    } finally {
        reader.releaseLock();
    }

    return results;
};

// 获取JD的评估标准
export const getJDEvaluationCriteria = async (id: number): Promise<Record<string, any>> => {
    const response: { criteria: Record<string, any> } = await apiClient.get(`${API_BASE}/${id}/evaluation-criteria`);
    return response.criteria || {};
};

// 保存JD的评估标准
export const saveJDEvaluationCriteria = async (
    id: number,
    criteria: Record<string, any>
): Promise<void> => {
    return apiClient.put(`${API_BASE}/${id}/evaluation-criteria`, { criteria });
};

// 更新JD的完整信息
export const updateJDFullInfo = async (
    id: number,
    fullInfo: JDFullInfoUpdate
): Promise<JobDescription> => {
    return apiClient.put(`${API_BASE}/${id}/full-info`, fullInfo);
};

// 获取JD的完整信息
export const getJDFullInfo = async (id: number): Promise<{ full_text?: string; evaluation_criteria?: Record<string, any> }> => {
    return apiClient.get(`${API_BASE}/${id}/full-info`);
};

// 提取关键字并更新JD字段
export const extractJDKeywords = async (id: number, fullText: string): Promise<JobDescription> => {
    return apiClient.post(`${API_BASE}/${id}/extract-keywords`, { full_text: fullText });
};

// AI润色JD文本 - 流式接口
export const polishJDTextStream = async (
    originalText: string,
    onProgress?: (data: { message: string; progress?: number }) => void,
    onComplete?: (polishedText: string) => void,
    onError?: (error: string) => void
): Promise<void> => {
    const baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';

    try {
        const response = await fetch(`${baseURL}${API_BASE}/polish-text`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ original_text: originalText })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const reader = response.body?.getReader();
        const decoder = new TextDecoder();

        if (!reader) {
            throw new Error('响应流不可用');
        }

        let buffer = '';

        try {
            while (true) {
                const { done, value } = await reader.read();
                if (done) break;

                // 将新数据添加到缓冲区
                buffer += decoder.decode(value, { stream: true });

                // 按行分割处理
                const lines = buffer.split('\n');

                // 保留最后一行（可能是不完整的）
                buffer = lines.pop() || '';

                for (const line of lines) {
                    const trimmedLine = line.trim();

                    // 处理SSE格式的数据
                    if (trimmedLine.startsWith('data: ')) {
                        const dataStr = trimmedLine.slice(6).trim();

                        // 检查是否是结束信号
                        if (dataStr === '[DONE]') {
                            return;
                        }

                        // 跳过空数据
                        if (!dataStr) {
                            continue;
                        }

                        try {
                            const eventData = JSON.parse(dataStr);

                            console.log('Received SSE data:', eventData); // 调试日志

                            // 处理错误事件
                            if (eventData.event === 'error') {
                                if (onError) {
                                    onError(eventData.data?.message || '未知错误');
                                }
                                return;
                            }

                            // 处理进度事件
                            if (eventData.event === 'progress' || eventData.event === 'start') {
                                if (onProgress && eventData.data) {
                                    onProgress({
                                        message: eventData.data.message || '',
                                        progress: eventData.data.progress
                                    });
                                }
                            }

                            // 处理完成事件
                            if (eventData.event === 'complete') {
                                if (eventData.data) {
                                    // 发送最终进度
                                    if (onProgress) {
                                        onProgress({
                                            message: eventData.data.message || 'AI润色完成',
                                            progress: eventData.data.progress || 100
                                        });
                                    }
                                    // 返回最终结果
                                    if (onComplete && eventData.data.polished_text) {
                                        onComplete(eventData.data.polished_text);
                                    }
                                }
                                return;
                            }

                        } catch (parseError) {
                            console.warn('解析SSE数据失败:', parseError, '原始数据:', dataStr);
                        }
                    }
                    // 处理空行或其他SSE事件类型
                    else if (trimmedLine.startsWith('event:') || trimmedLine.startsWith('id:') || trimmedLine === '') {
                        // 跳过SSE控制字段
                        continue;
                    }
                }
            }
        } finally {
            reader.releaseLock();
        }
    } catch (error) {
        const message = error instanceof Error ? error.message : '润色请求失败';
        if (onError) {
            onError(message);
        }
        throw error;
    }
};

// 兼容旧的非流式接口（可选）
export const polishJDText = async (originalText: string): Promise<PolishResponse> => {
    return new Promise((resolve, reject) => {
        polishJDTextStream(
            originalText,
            undefined, // onProgress
            (polishedText) => resolve({ polished_text: polishedText }), // onComplete
            (error) => reject(new Error(error)) // onError
        );
    });
};

// 从文本创建JD
export const createJDFromText = async (text: string): Promise<JobDescription> => {
    return apiClient.post(`${API_BASE}/create-from-text`, { text });
};