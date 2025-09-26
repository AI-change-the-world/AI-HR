import React, { useState, useEffect } from 'react';
import { Button, Table, Space, Typography, Tag, Drawer, Form, Input, Select, Rate } from 'antd';
import { PlusOutlined, UploadOutlined, TrophyOutlined } from '@ant-design/icons';
import { Employee } from '../types';
import { getEmployees } from '../api';

const { Title } = Typography;
const { Option } = Select;

interface EmployeeSkill {
    id: number;
    employee_id: number;
    skill_name: string;
    skill_category: string;
    level: string;
    assessment_date?: string;
    assessor_name?: string;
    source?: 'jd' | 'manual';
    jd_id?: number;
}

const EmployeeManagement: React.FC = () => {
    const [employees, setEmployees] = useState<Employee[]>([]);
    const [employeeSkills, setEmployeeSkills] = useState<EmployeeSkill[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [showSkillDrawer, setShowSkillDrawer] = useState(false);
    const [selectedEmployee, setSelectedEmployee] = useState<Employee | null>(null);

    // Mock数据
    const mockEmployees: Employee[] = [
        {
            id: 1,
            name: '张三',
            department: '技术部',
            position: '前端工程师',
            email: 'zhangsan@example.com',
            phone: '13800138001'
        },
        {
            id: 2,
            name: '李四',
            department: '技术部',
            position: '后端工程师',
            email: 'lisi@example.com',
            phone: '13800138002'
        },
        {
            id: 3,
            name: '王五',
            department: '人事部',
            position: 'HR专员',
            email: 'wangwu@example.com',
            phone: '13800138003'
        }
    ];

    const mockEmployeeSkills: EmployeeSkill[] = [
        {
            id: 1,
            employee_id: 1,
            skill_name: "React",
            skill_category: "technical",
            level: "A",
            assessment_date: "2025-01-15",
            assessor_name: "李经理",
            source: "jd",
            jd_id: 1
        },
        {
            id: 2,
            employee_id: 1,
            skill_name: "Python",
            skill_category: "technical",
            level: "B",
            assessment_date: "2025-01-10",
            assessor_name: "王总监",
            source: "jd",
            jd_id: 2
        },
        {
            id: 3,
            employee_id: 2,
            skill_name: "UI设计",
            skill_category: "design",
            level: "S",
            assessment_date: "2025-01-12",
            assessor_name: "设计总监",
            source: "jd",
            jd_id: 3
        },
        {
            id: 4,
            employee_id: 3,
            skill_name: "项目管理",
            skill_category: "management",
            level: "A",
            assessment_date: "2025-01-08",
            assessor_name: "HR经理",
            source: "manual"
        }
    ];

    useEffect(() => {
        // 模拟从后端获取数据
        const fetchData = async () => {
            try {
                setTimeout(() => {
                    setEmployees(mockEmployees);
                    setEmployeeSkills(mockEmployeeSkills);
                    setLoading(false);
                }, 1000);
            } catch (err) {
                setError('获取数据失败');
                setLoading(false);
            }
        };

        fetchData();
    }, []);

    const getCategoryText = (category: string) => {
        const texts = {
            technical: '技术技能',
            management: '管理技能',
            communication: '沟通技能',
            design: '设计技能',
            business: '业务技能',
            language: '语言技能',
            other: '其他技能'
        };
        return texts[category as keyof typeof texts] || category;
    };

    const getCategoryColor = (category: string) => {
        const colors = {
            technical: 'blue',
            management: 'purple',
            communication: 'green',
            design: 'pink',
            business: 'orange',
            language: 'cyan',
            other: 'default'
        };
        return colors[category as keyof typeof colors] || 'default';
    };

    const getLevelColor = (level: string) => {
        const colors = {
            S: 'red',
            A: 'orange',
            B: 'gold',
            C: 'blue',
            D: 'default'
        };
        return colors[level as keyof typeof colors] || 'default';
    };

    const getLevelText = (level: string) => {
        const texts = {
            S: 'S级 - 专家级',
            A: 'A级 - 高级',
            B: 'B级 - 熟练级',
            C: 'C级 - 入门级',
            D: 'D级 - 初学者'
        };
        return texts[level as keyof typeof texts] || level;
    };

    const getEmployeeSkills = (employeeId: number) => {
        return employeeSkills.filter(skill => skill.employee_id === employeeId);
    };

    const columns = [
        {
            title: 'ID',
            dataIndex: 'id',
            key: 'id',
        },
        {
            title: '姓名',
            dataIndex: 'name',
            key: 'name',
        },
        {
            title: '部门',
            dataIndex: 'department',
            key: 'department',
        },
        {
            title: '职位',
            dataIndex: 'position',
            key: 'position',
        },
        {
            title: '邮箱',
            dataIndex: 'email',
            key: 'email',
        },
        {
            title: '电话',
            dataIndex: 'phone',
            key: 'phone',
        },
        {
            title: '技能数量',
            key: 'skillCount',
            render: (record: Employee) => {
                const skillCount = getEmployeeSkills(record.id).length;
                return (
                    <Tag color={skillCount > 3 ? 'green' : skillCount > 1 ? 'orange' : 'default'}>
                        {skillCount} 个技能
                    </Tag>
                );
            },
        },
        {
            title: '操作',
            key: 'action',
            render: (_: any, record: Employee) => (
                <Space size="small">
                    <Button
                        type="link"
                        icon={<TrophyOutlined />}
                        onClick={() => {
                            setSelectedEmployee(record);
                            setShowSkillDrawer(true);
                        }}
                        className="text-primary-600 hover:text-primary-700 p-0 h-auto font-medium"
                    >
                        技能管理
                    </Button>
                    <Button
                        type="link"
                        className="text-primary-600 hover:text-primary-700 p-0 h-auto font-medium"
                    >
                        编辑
                    </Button>
                    <Button
                        type="link"
                        danger
                        className="p-0 h-auto font-medium"
                    >
                        删除
                    </Button>
                </Space>
            ),
        },
    ];

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="text-center">
                    <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mb-4"></div>
                    <p className="text-gray-600">加载中...</p>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="text-center">
                    <div className="text-red-500 text-xl mb-2">⚠️</div>
                    <p className="text-red-600">错误: {error}</p>
                </div>
            </div>
        );
    }

    return (
        <div className="animate-fade-in">
            <div className="mb-6">
                <Title level={5} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2 text-left">
                    员工管理
                </Title>
                <div className="w-24 h-1 bg-gradient-to-r from-primary-500 to-primary-600 rounded-full mb-4"></div>
            </div>

            <div className="flex justify-end mb-6">
                <Space size="middle">
                    <Button
                        type="primary"
                        icon={<PlusOutlined />}
                        className="bg-gradient-to-r from-primary-500 to-primary-600 border-none shadow-soft hover:shadow-medium hover:scale-105 transition-all duration-200 h-10 px-6 font-medium"
                    >
                        添加员工
                    </Button>
                    <Button
                        icon={<UploadOutlined />}
                        className="border-primary-300 text-primary-600 hover:bg-primary-50 hover:border-primary-400 transition-all duration-200 h-10 px-6 font-medium"
                    >
                        导入员工
                    </Button>
                </Space>
            </div>

            <Table
                dataSource={employees}
                columns={columns}
                loading={loading}
                rowKey="id"
                className="shadow-soft rounded-lg overflow-hidden"
                pagination={{
                    pageSize: 10,
                    showSizeChanger: true,
                    showQuickJumper: true,
                    showTotal: (total, range) => `第 ${range[0]}-${range[1]} 条，共 ${total} 条`,
                }}
            />

            {/* 员工技能管理抽屉 */}
            <Drawer
                title={`${selectedEmployee?.name} - 技能管理`}
                placement="right"
                onClose={() => setShowSkillDrawer(false)}
                open={showSkillDrawer}
                width={600}
            >
                {selectedEmployee && (
                    <div>
                        <div className="mb-6">
                            <Button
                                type="primary"
                                icon={<PlusOutlined />}
                                className="bg-gradient-to-r from-primary-500 to-primary-600 border-none"
                            >
                                评估技能
                            </Button>
                        </div>

                        <div className="space-y-4">
                            {getEmployeeSkills(selectedEmployee.id).map((skill) => (
                                <div key={skill.id} className="bg-gray-50 p-4 rounded-lg">
                                    <div className="flex items-center justify-between mb-2">
                                        <h4 className="font-medium text-gray-900">{skill.skill_name}</h4>
                                        <Tag color={getLevelColor(skill.level)}>
                                            {getLevelText(skill.level)}
                                        </Tag>
                                    </div>
                                    <div className="flex items-center justify-between text-sm text-gray-500">
                                        <Tag color={getCategoryColor(skill.skill_category)}>
                                            {getCategoryText(skill.skill_category)}
                                        </Tag>
                                        <span>评估人: {skill.assessor_name}</span>
                                    </div>
                                    {skill.assessment_date && (
                                        <div className="text-xs text-gray-400 mt-1">
                                            评估时间: {new Date(skill.assessment_date).toLocaleDateString('zh-CN')}
                                        </div>
                                    )}
                                    {skill.source && (
                                        <div className="mt-2">
                                            <Tag color={skill.source === 'jd' ? 'blue' : 'green'} >
                                                {skill.source === 'jd' ? `来源: JD (ID: ${skill.jd_id})` : '来源: 手动创建'}
                                            </Tag>
                                        </div>
                                    )}
                                    <div className="mt-2 flex justify-end">
                                        <Space size="small">
                                            <Button type="link" size="small" className="text-primary-600">
                                                重新评估
                                            </Button>
                                            <Button type="link" size="small" danger>
                                                删除
                                            </Button>
                                        </Space>
                                    </div>
                                </div>
                            ))}

                            {getEmployeeSkills(selectedEmployee.id).length === 0 && (
                                <div className="text-center py-8 text-gray-500">
                                    该员工暂无技能记录
                                </div>
                            )}
                        </div>
                    </div>
                )}
            </Drawer>
        </div>
    );
};

export default EmployeeManagement;