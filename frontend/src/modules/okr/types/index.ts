// OKR数据接口
export interface OKR {
    id: number;
    employeeId: number;
    employeeName: string;
    objective: string;
    keyResults: KeyResult[];
    quarter: string;
    year: number;
    progress: number;
    status: 'draft' | 'active' | 'completed' | 'cancelled';
    createdAt: string;
    updatedAt?: string;
}

// 关键结果接口
export interface KeyResult {
    id: number;
    description: string;
    progress: number;
    target: number;
    unit: string;
    status: 'not_started' | 'in_progress' | 'completed';
}

// 创建OKR请求接口
export interface CreateOKRRequest {
    employeeId: number;
    objective: string;
    keyResults: Omit<KeyResult, 'id'>[];
    quarter: string;
    year: number;
}

// 更新OKR请求接口
export interface UpdateOKRRequest {
    id: number;
    objective?: string;
    keyResults?: KeyResult[];
    status?: 'draft' | 'active' | 'completed' | 'cancelled';
}

// OKR查询参数接口
export interface OKRQueryParams {
    page?: number;
    pageSize?: number;
    employeeId?: number;
    quarter?: string;
    year?: number;
    status?: string;
}