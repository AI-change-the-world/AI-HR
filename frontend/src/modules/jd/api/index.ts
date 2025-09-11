// JD管理相关的API调用
import { JobDescription } from '../types';

// 模拟API调用
export const getJDs = async (): Promise<JobDescription[]> => {
    // 模拟网络请求
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve([
                {
                    id: 1,
                    title: '前端工程师',
                    department: '技术部',
                    location: '北京',
                    status: '开放',
                    createdAt: '2023-05-01'
                },
                {
                    id: 2,
                    title: '后端工程师',
                    department: '技术部',
                    location: '上海',
                    status: '开放',
                    createdAt: '2023-05-02'
                },
                {
                    id: 3,
                    title: '产品经理',
                    department: '产品部',
                    location: '深圳',
                    status: '关闭',
                    createdAt: '2023-04-15'
                }
            ]);
        }, 500);
    });
};

export const toggleJDStatus = async (id: number): Promise<boolean> => {
    // 模拟网络请求
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve(true);
        }, 300);
    });
};

// 简历评估API
export const evaluateResume = async (jdId: number, file: File): Promise<any[]> => {
    // 实际应该调用后端API
    // 示例: POST /api/jd/{jdId}/evaluate-resume
    const formData = new FormData();
    formData.append('resume_file', file);

    // 模拟网络请求和评估过程
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve([
                {
                    step: 0,
                    name: "任务拆解",
                    steps: [
                        { id: 1, name: "学历匹配评估", desc: "评估候选人学历与职位要求的匹配程度" },
                        { id: 2, name: "技能匹配评估", desc: "评估候选人技能与职位要求的匹配程度" },
                        { id: 3, name: "经验年限评估", desc: "评估候选人工作年限与职位要求的匹配程度" },
                        { id: 4, name: "总分计算与匹配结论", desc: "综合各项评估结果，计算总分并给出匹配结论" }
                    ]
                },
                {
                    step: 1,
                    name: "学历匹配评估",
                    score: 10,
                    reason: "候选人拥有研究生学历，符合职位要求"
                },
                {
                    step: 2,
                    name: "技能匹配评估",
                    score: 18,
                    reason: "候选人掌握Python和深度学习技能，部分符合职位要求"
                },
                {
                    step: 3,
                    name: "经验年限评估",
                    score: 10,
                    reason: "候选人拥有4年开发经验，超过职位要求的3年"
                },
                {
                    step: 4,
                    name: "总分计算与匹配结论",
                    score: 38,
                    reason: "总体匹配度较高，建议进入下一轮面试"
                }
            ]);
        }, 2000);
    });
};