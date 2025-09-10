// 简历数据接口
export interface Resume {
    id: number;
    name: string;
    position: string;
    score: number;
    status: 'pending' | 'reviewed' | 'shortlisted' | 'rejected';
    createdAt: string;
    updatedAt?: string;
    email?: string;
    phone?: string;
    experience?: number;
    education?: string;
    skills?: string[];
    filePath?: string;
    fileSize?: number;
    fileType?: string;
}

// 简历匹配结果接口
export interface ResumeMatch {
    resumeId: number;
    jdId: number;
    score: number;
    matchDetails: {
        skillsMatch: number;
        experienceMatch: number;
        educationMatch: number;
    };
    recommendations: string[];
}

// 创建简历请求接口
export interface CreateResumeRequest {
    name: string;
    position: string;
    email?: string;
    phone?: string;
    experience?: number;
    education?: string;
    skills?: string[];
}

// 更新简历请求接口
export interface UpdateResumeRequest {
    id: number;
    name?: string;
    position?: string;
    status?: 'pending' | 'reviewed' | 'shortlisted' | 'rejected';
    email?: string;
    phone?: string;
    experience?: number;
    education?: string;
    skills?: string[];
}

// 简历查询参数接口
export interface ResumeQueryParams {
    page?: number;
    pageSize?: number;
    name?: string;
    position?: string;
    status?: string;
    minScore?: number;
    maxScore?: number;
}