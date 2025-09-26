import React, { useState, useEffect } from 'react';
import { Button, Table, Space, Typography, Tabs, Tag, Modal, Form, Input, Select, Cascader } from 'antd';
import { PlusOutlined, SearchOutlined, BarChartOutlined, TrophyOutlined, LinkOutlined } from '@ant-design/icons';

const { Title } = Typography;
const { TabPane } = Tabs;
const { Option } = Select;

interface SkillDefinition {
  id: number;
  name: string;
  category: string;
  description?: string;
  source: 'jd' | 'manual';
  jd_id?: number;
  jd_title?: string; // JD标题，用于显示
  created_at: string;
}

interface JDOption {
  id: number;
  title: string;
  department: string;
}

interface EmployeeSkill {
  id: number;
  employee_id: number;
  employee_name: string;
  skill_name: string;
  skill_category: string;
  level: string;
  assessment_date?: string;
  assessor_name?: string;
}

const CapabilityManagement: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'skills' | 'analysis'>('skills');
  const [skills, setSkills] = useState<SkillDefinition[]>([]);
  const [employeeSkills, setEmployeeSkills] = useState<EmployeeSkill[]>([]);
  const [jdOptions, setJdOptions] = useState<JDOption[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');
  const [sourceFilter, setSourceFilter] = useState('');
  const [showCreateModal, setShowCreateModal] = useState(false);

  // Mock数据
  const mockSkills: SkillDefinition[] = [
    {
      id: 1,
      name: "React",
      category: "technical",
      description: "React前端框架开发",
      source: "jd",
      jd_id: 1,
      jd_title: "前端工程师",
      created_at: "2025-01-15T10:00:00"
    },
    {
      id: 2,
      name: "Python",
      category: "technical",
      description: "Python编程语言",
      source: "jd",
      jd_id: 2,
      jd_title: "后端工程师",
      created_at: "2025-01-14T14:30:00"
    },
    {
      id: 3,
      name: "项目管理",
      category: "management",
      description: "项目规划和执行管理",
      source: "manual",
      created_at: "2025-01-13T09:15:00"
    },
    {
      id: 4,
      name: "UI设计",
      category: "design",
      description: "用户界面设计",
      source: "jd",
      jd_id: 3,
      jd_title: "UI设计师",
      created_at: "2025-01-12T16:45:00"
    },
    {
      id: 5,
      name: "数据分析",
      category: "business",
      description: "数据分析和洞察",
      source: "manual",
      created_at: "2025-01-11T11:20:00"
    },
    {
      id: 6,
      name: "英语",
      category: "language",
      description: "英语沟通能力",
      source: "manual",
      created_at: "2025-01-10T08:30:00"
    }
  ];

  const mockJdOptions: JDOption[] = [
    { id: 1, title: "前端工程师", department: "技术部" },
    { id: 2, title: "后端工程师", department: "技术部" },
    { id: 3, title: "UI设计师", department: "设计部" },
    { id: 4, title: "产品经理", department: "产品部" },
    { id: 5, title: "数据分析师", department: "技术部" }
  ];

  const mockEmployeeSkills: EmployeeSkill[] = [
    {
      id: 1,
      employee_id: 1,
      employee_name: "张三",
      skill_name: "React",
      skill_category: "technical",
      level: "A",
      assessment_date: "2025-01-15",
      assessor_name: "李经理"
    },
    {
      id: 2,
      employee_id: 1,
      employee_name: "张三",
      skill_name: "Python",
      skill_category: "technical",
      level: "B",
      assessment_date: "2025-01-10",
      assessor_name: "王总监"
    },
    {
      id: 3,
      employee_id: 2,
      employee_name: "李四",
      skill_name: "UI设计",
      skill_category: "design",
      level: "S",
      assessment_date: "2025-01-12",
      assessor_name: "设计总监"
    },
    {
      id: 4,
      employee_id: 3,
      employee_name: "王五",
      skill_name: "项目管理",
      skill_category: "management",
      level: "A",
      assessment_date: "2025-01-08",
      assessor_name: "HR经理"
    }
  ];

  useEffect(() => {
    // 模拟API调用
    setTimeout(() => {
      setSkills(mockSkills);
      setEmployeeSkills(mockEmployeeSkills);
      setJdOptions(mockJdOptions);
      setLoading(false);
    }, 1000);
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

  const filteredSkills = skills.filter(skill => {
    const matchesSearch = skill.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (skill.description && skill.description.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesCategory = !categoryFilter || skill.category === categoryFilter;
    const matchesSource = !sourceFilter || skill.source === sourceFilter;

    return matchesSearch && matchesCategory && matchesSource;
  });

  const skillColumns = [
    {
      title: '技能名称',
      dataIndex: 'name',
      key: 'name',
      render: (text: string, record: SkillDefinition) => (
        <div>
          <div className="font-medium text-gray-900">{text}</div>
          {record.source === 'jd' && record.jd_title && (
            <div className="text-xs text-gray-500 flex items-center mt-1">
              <LinkOutlined className="mr-1" />
              关联JD: {record.jd_title}
            </div>
          )}
        </div>
      ),
    },
    {
      title: '分类',
      dataIndex: 'category',
      key: 'category',
      render: (category: string) => (
        <Tag color={getCategoryColor(category)}>
          {getCategoryText(category)}
        </Tag>
      ),
    },
    {
      title: '描述',
      dataIndex: 'description',
      key: 'description',
      render: (text: string) => text || '-',
    },
    {
      title: '来源',
      key: 'source',
      render: (record: SkillDefinition) => (
        <Tag color={record.source === 'jd' ? 'blue' : 'green'}>
          {record.source === 'jd' ? `JD关联 (ID: ${record.jd_id})` : '手动创建'}
        </Tag>
      ),
    },
    {
      title: '创建时间',
      dataIndex: 'created_at',
      key: 'created_at',
      render: (date: string) => new Date(date).toLocaleDateString('zh-CN'),
    },
    {
      title: '操作',
      key: 'action',
      render: (record: SkillDefinition) => (
        <Space size="small">
          <Button type="link" className="text-primary-600 hover:text-primary-700 p-0 h-auto font-medium">
            编辑
          </Button>
          <Button type="link" danger className="p-0 h-auto font-medium">
            删除
          </Button>
        </Space>
      ),
    },
  ];

  // 技能统计
  const skillStats = {
    totalSkills: skills.length,
    totalEmployeeSkills: employeeSkills.length,
    jdLinkedSkills: skills.filter(skill => skill.source === 'jd').length,
    manualSkills: skills.filter(skill => skill.source === 'manual').length,
    categoryDistribution: skills.reduce((acc, skill) => {
      acc[skill.category] = (acc[skill.category] || 0) + 1;
      return acc;
    }, {} as Record<string, number>),
    levelDistribution: employeeSkills.reduce((acc, empSkill) => {
      acc[empSkill.level] = (acc[empSkill.level] || 0) + 1;
      return acc;
    }, {} as Record<string, number>),
    sourceDistribution: skills.reduce((acc, skill) => {
      acc[skill.source] = (acc[skill.source] || 0) + 1;
      return acc;
    }, {} as Record<string, number>)
  };

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

  return (
    <div className="animate-fade-in">
      <div className="mb-6">
        <Title level={5} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2 text-left">
          能力管理
        </Title>
        <div className="w-24 h-1 bg-gradient-to-r from-primary-500 to-primary-600 rounded-full mb-4"></div>
      </div>

      <Tabs
        activeKey={activeTab}
        onChange={(key) => setActiveTab(key as 'skills' | 'analysis')}
        className="mb-6"
      >
        <TabPane tab={<span><TrophyOutlined /> 技能定义</span>} key="skills">
          {/* 操作栏 */}
          <div className="mb-6 flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <Input
                placeholder="搜索技能..."
                prefix={<SearchOutlined />}
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="h-10"
              />
            </div>

            <div className="flex gap-2">
              <Select
                placeholder="所有分类"
                value={categoryFilter}
                onChange={setCategoryFilter}
                className="w-32"
                allowClear
              >
                <Option value="technical">技术技能</Option>
                <Option value="management">管理技能</Option>
                <Option value="communication">沟通技能</Option>
                <Option value="design">设计技能</Option>
                <Option value="business">业务技能</Option>
                <Option value="language">语言技能</Option>
                <Option value="other">其他技能</Option>
              </Select>

              <Select
                placeholder="所有来源"
                value={sourceFilter}
                onChange={setSourceFilter}
                className="w-32"
                allowClear
              >
                <Option value="jd">JD关联</Option>
                <Option value="manual">手动创建</Option>
              </Select>

              <Button
                type="primary"
                icon={<PlusOutlined />}
                onClick={() => setShowCreateModal(true)}
                className="bg-gradient-to-r from-primary-500 to-primary-600 border-none shadow-soft hover:shadow-medium hover:scale-105 transition-all duration-200 h-10 px-6 font-medium"
              >
                添加技能
              </Button>
            </div>
          </div>

          {/* 技能列表 */}
          <Table
            columns={skillColumns}
            dataSource={filteredSkills}
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
        </TabPane>

        <TabPane tab={<span><BarChartOutlined /> 技能分析</span>} key="analysis">
          {/* 统计卡片 */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
            <div className="bg-white p-6 rounded-lg shadow-soft">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <BarChartOutlined className="h-8 w-8 text-primary-600" />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-500">总技能数</p>
                  <p className="text-2xl font-semibold text-gray-900">{skillStats.totalSkills}</p>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-soft">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <TrophyOutlined className="h-8 w-8 text-green-600" />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-500">员工技能记录</p>
                  <p className="text-2xl font-semibold text-gray-900">{skillStats.totalEmployeeSkills}</p>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-soft">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <LinkOutlined className="h-8 w-8 text-blue-600" />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-500">JD关联技能</p>
                  <p className="text-2xl font-semibold text-gray-900">{skillStats.jdLinkedSkills}</p>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-soft">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 bg-green-500 rounded-full flex items-center justify-center">
                    <span className="text-white font-bold text-sm">M</span>
                  </div>
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-500">手动创建技能</p>
                  <p className="text-2xl font-semibold text-gray-900">{skillStats.manualSkills}</p>
                </div>
              </div>
            </div>
          </div>

          {/* 技能来源分布 */}
          <div className="bg-white p-6 rounded-lg shadow-soft mb-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">技能来源分布</h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <Tag color="blue">JD关联</Tag>
                <span className="text-sm font-medium text-gray-900">{skillStats.sourceDistribution.jd || 0} 个技能</span>
              </div>
              <div className="flex items-center justify-between">
                <Tag color="green">手动创建</Tag>
                <span className="text-sm font-medium text-gray-900">{skillStats.sourceDistribution.manual || 0} 个技能</span>
              </div>
            </div>
          </div>

          {/* 分类分布 */}
          <div className="bg-white p-6 rounded-lg shadow-soft mb-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">技能分类分布</h3>
            <div className="space-y-3">
              {Object.entries(skillStats.categoryDistribution).map(([category, count]) => (
                <div key={category} className="flex items-center justify-between">
                  <Tag color={getCategoryColor(category)}>
                    {getCategoryText(category)}
                  </Tag>
                  <span className="text-sm font-medium text-gray-900">{count} 个技能</span>
                </div>
              ))}
            </div>
          </div>

          {/* 等级分布 */}
          <div className="bg-white p-6 rounded-lg shadow-soft">
            <h3 className="text-lg font-medium text-gray-900 mb-4">员工技能等级分布</h3>
            <div className="space-y-3">
              {Object.entries(skillStats.levelDistribution).map(([level, count]) => (
                <div key={level} className="flex items-center justify-between">
                  <Tag color={getLevelColor(level)}>
                    {getLevelText(level)}
                  </Tag>
                  <span className="text-sm font-medium text-gray-900">{count} 人次</span>
                </div>
              ))}
            </div>
          </div>
        </TabPane>
      </Tabs>

      {/* 添加技能模态框 */}
      <Modal
        title="添加新技能"
        open={showCreateModal}
        onCancel={() => setShowCreateModal(false)}
        footer={null}
        width={600}
      >
        <Form layout="vertical">
          <Form.Item label="技能名称" required>
            <Input placeholder="输入技能名称" />
          </Form.Item>
          <Form.Item label="技能分类" required>
            <Select placeholder="选择技能分类">
              <Option value="technical">技术技能</Option>
              <Option value="management">管理技能</Option>
              <Option value="communication">沟通技能</Option>
              <Option value="design">设计技能</Option>
              <Option value="business">业务技能</Option>
              <Option value="language">语言技能</Option>
              <Option value="other">其他技能</Option>
            </Select>
          </Form.Item>
          <Form.Item label="技能描述">
            <Input.TextArea rows={3} placeholder="输入技能描述" />
          </Form.Item>
          <Form.Item label="技能来源" required>
            <Select placeholder="选择技能来源">
              <Option value="manual">手动创建</Option>
              <Option value="jd">JD关联</Option>
            </Select>
          </Form.Item>
          <Form.Item label="关联JD" help="仅当选择'JD关联'时需要填写">
            <Select placeholder="选择关联的JD" disabled>
              {jdOptions.map(jd => (
                <Option key={jd.id} value={jd.id}>
                  {jd.title} ({jd.department})
                </Option>
              ))}
            </Select>
          </Form.Item>
          <div className="flex justify-end space-x-3 mt-6">
            <Button onClick={() => setShowCreateModal(false)}>
              取消
            </Button>
            <Button
              type="primary"
              className="bg-gradient-to-r from-primary-500 to-primary-600 border-none"
              onClick={() => setShowCreateModal(false)}
            >
              创建
            </Button>
          </div>
        </Form>
      </Modal>
    </div>
  );
};

export default CapabilityManagement;