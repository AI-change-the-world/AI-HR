// 员工数据接口
export interface Employee {
    id: number;
    name: string;
    department: string;
    position: string;
    email: string;
    phone: string;
}

// 部门数据接口
export interface Department {
    id: number;
    name: string;
    manager: string;
    employeeCount: number;
    description: string;
}

// JD数据接口
export interface JobDescription {
    id: number;
    title: string;
    department: string;
    location: string;
    isOpen: boolean;
    createdAt: string;
}

// 简历数据接口
export interface Resume {
    id: number;
    name: string;
    position: string;
    score: number;
    status: string;
    createdAt: string;
}

// OKR数据接口
export interface OKR {
    id: number;
    employeeName: string;
    objective: string;
    keyResults: string[];
    quarter: string;
    progress: number;
}