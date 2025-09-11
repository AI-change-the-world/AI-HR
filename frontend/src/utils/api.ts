import axios, { AxiosResponse } from 'axios';

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
    timeout: 10000,
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
        // 直接返回response.data，这样调用时就不需要再访问.data属性
        return response.data;
    },
    (error) => {
        // 统一错误处理
        const message = error.response?.data?.message || error.message || '请求失败';
        console.error('API Error:', message);
        return Promise.reject(new Error(message));
    }
);

// 导出具有正确类型的API客户端
const apiClient: ApiClient = axiosInstance as any;

export default apiClient;