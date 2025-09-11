import axios, { AxiosResponse } from 'axios';
import { message } from 'antd';

// BaseResponse类型定义
interface BaseResponse<T = any> {
    code: number;
    message: string;
    data: T | null;
}

// PageResponse类型定义
interface PageResponse<T = any> {
    total: number;
    data: T[] | null;
}

// 自定义axios实例类型，确保返回的是数据而不是完整的response
interface ApiClient {
    get<T = any>(url: string, config?: any): Promise<T>;
    post<T = any>(url: string, data?: any, config?: any): Promise<T>;
    put<T = any>(url: string, data?: any, config?: any): Promise<T>;
    patch<T = any>(url: string, data?: any, config?: any): Promise<T>;
    delete<T = any>(url: string, config?: any): Promise<T>;
}

// 创建axios实例
const axiosInstance = axios.create({
    baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000',
    timeout: 30 * 1000,
    headers: {
        'Content-Type': 'application/json',
    },
});

// 请求拦截器
axiosInstance.interceptors.request.use(
    (config) => {
        // 可以在这里添加认证token等
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// 响应拦截器
axiosInstance.interceptors.response.use(
    (response: AxiosResponse) => {
        const data = response.data as BaseResponse;

        // 如果是BaseResponse格式，检查code
        if (data && typeof data === 'object' && 'code' in data) {
            if (data.code !== 200) {
                // 显示错误消息
                message.error(data.message || '请求失败');
                // 抛出包含错误信息的异常
                const error = new Error(data.message || '请求失败');
                (error as any).code = data.code;
                return Promise.reject(error);
            }
            // 返回data字段内容
            return data.data;
        }

        // 如果不是BaseResponse格式（流式接口等），直接返回
        return response.data;
    },
    (error) => {
        // 统一错误处理
        let errorMessage = '请求失败';

        if (error.response?.data) {
            const data = error.response.data;
            if (typeof data === 'object' && 'message' in data) {
                errorMessage = data.message;
            } else if (typeof data === 'string') {
                errorMessage = data;
            }
        } else if (error.message) {
            errorMessage = error.message;
        }

        // 显示错误消息
        message.error(errorMessage);
        console.error('API Error:', errorMessage);
        return Promise.reject(new Error(errorMessage));
    }
);

// 导出具有正确类型的API客户端
const apiClient: ApiClient = axiosInstance as any;

export default apiClient;

// 导出类型定义
export type { BaseResponse, PageResponse };