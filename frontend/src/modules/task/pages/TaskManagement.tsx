import React, { useState, useEffect } from 'react';
import { Button, Table, Space, Typography, Input, Select, Tag, Progress, Modal, Form, DatePicker, Tabs } from 'antd';
import { PlusOutlined, SearchOutlined, FilterOutlined, EyeOutlined, CalendarOutlined, TeamOutlined, BarChartOutlined } from '@ant-design/icons';

const { Title } = Typography;
const { Option } = Select;
const { TabPane } = Tabs;

interface Task {
  id: number;
  name: string;
  description?: string;
  difficulty: string;
  status: string;
  priority: string;
  assignee_name?: string;
  department_name?: string;
  due_date?: string;
  progress: number;
  created_at: string;
}

interface Employee {
  id: number;
  name: string;
  department: string;
  tasks: Task[];
}

const TaskManagement: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [priorityFilter, setPriorityFilter] = useState('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [activeTab, setActiveTab] = useState('list');

  // Mock数据
  const mockTasks: Task[] = [
    {
      id: 1,
      name: "开发用户登录功能",
      description: "实现用户登录、注册和密码重置功能",
      difficulty: "medium",
      status: "in_progress",
      priority: "high",
      assignee_name: "张三",
      department_name: "技术部",
      due_date: "2025-01-30",
      progress: 60,
      created_at: "2025-01-15T10:00:00"
    },
    {
      id: 2,
      name: "设计系统UI组件库",
      description: "创建可复用的UI组件库，包括按钮、表单、卡片等",
      difficulty: "hard",
      status: "assigned",
      priority: "medium",
      assignee_name: "李四",
      department_name: "设计部",
      due_date: "2025-02-15",
      progress: 0,
      created_at: "2025-01-14T14:30:00"
    },
    {
      id: 3,
      name: "数据库性能优化",
      description: "优化查询性能，添加索引，清理冗余数据",
      difficulty: "very_hard",
      status: "pending",
      priority: "urgent",
      assignee_name: undefined,
      department_name: "技术部",
      due_date: "2025-01-25",
      progress: 0,
      created_at: "2025-01-13T09:15:00"
    },
    {
      id: 4,
      name: "编写API文档",
      description: "为所有API接口编写详细的文档",
      difficulty: "easy",
      status: "completed",
      priority: "low",
      assignee_name: "王五",
      department_name: "技术部",
      due_date: "2025-01-20",
      progress: 100,
      created_at: "2025-01-10T16:45:00"
    }
  ];

  const mockEmployees: Employee[] = [
    {
      id: 1,
      name: "张三",
      department: "技术部",
      tasks: [mockTasks[0], mockTasks[3]]
    },
    {
      id: 2,
      name: "李四",
      department: "设计部",
      tasks: [mockTasks[1]]
    },
    {
      id: 3,
      name: "王五",
      department: "技术部",
      tasks: [mockTasks[3]]
    }
  ];

  useEffect(() => {
    // 模拟API调用
    setTimeout(() => {
      setTasks(mockTasks);
      setEmployees(mockEmployees);
      setLoading(false);
    }, 1000);
  }, []);

  const getDifficultyColor = (difficulty: string) => {
    const colors = {
      very_easy: 'green',
      easy: 'blue',
      medium: 'orange',
      hard: 'red',
      very_hard: 'purple'
    };
    return colors[difficulty as keyof typeof colors] || 'default';
  };

  const getStatusColor = (status: string) => {
    const colors = {
      pending: 'default',
      assigned: 'blue',
      in_progress: 'processing',
      completed: 'success',
      cancelled: 'error',
      overdue: 'error'
    };
    return colors[status as keyof typeof colors] || 'default';
  };

  const getPriorityColor = (priority: string) => {
    const colors = {
      low: 'default',
      medium: 'blue',
      high: 'orange',
      urgent: 'red'
    };
    return colors[priority as keyof typeof colors] || 'default';
  };

  const getDifficultyText = (difficulty: string) => {
    const texts = {
      very_easy: '非常简单',
      easy: '简单',
      medium: '中等',
      hard: '困难',
      very_hard: '非常困难'
    };
    return texts[difficulty as keyof typeof texts] || difficulty;
  };

  const getStatusText = (status: string) => {
    const texts = {
      pending: '待分配',
      assigned: '已分配',
      in_progress: '进行中',
      completed: '已完成',
      cancelled: '已取消',
      overdue: '已逾期'
    };
    return texts[status as keyof typeof texts] || status;
  };

  const getPriorityText = (priority: string) => {
    const texts = {
      low: '低',
      medium: '中',
      high: '高',
      urgent: '紧急'
    };
    return texts[priority as keyof typeof texts] || priority;
  };

  const filteredTasks = tasks.filter(task => {
    const matchesSearch = task.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (task.description && task.description.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesStatus = !statusFilter || task.status === statusFilter;
    const matchesPriority = !priorityFilter || task.priority === priorityFilter;
    
    return matchesSearch && matchesStatus && matchesPriority;
  });

  const columns = [
    {
      title: '任务信息',
      key: 'info',
      render: (record: Task) => (
        <div>
          <div className="font-medium text-gray-900">{record.name}</div>
          {record.description && (
            <div className="text-sm text-gray-500 mt-1">{record.description}</div>
          )}
          <div className="text-xs text-gray-400 mt-1">{record.department_name}</div>
        </div>
      ),
    },
    {
      title: '难度',
      dataIndex: 'difficulty',
      key: 'difficulty',
      render: (difficulty: string) => (
        <Tag color={getDifficultyColor(difficulty)}>
          {getDifficultyText(difficulty)}
        </Tag>
      ),
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => (
        <Tag color={getStatusColor(status)}>
          {getStatusText(status)}
        </Tag>
      ),
    },
    {
      title: '优先级',
      dataIndex: 'priority',
      key: 'priority',
      render: (priority: string) => (
        <Tag color={getPriorityColor(priority)}>
          {getPriorityText(priority)}
        </Tag>
      ),
    },
    {
      title: '指派人员',
      dataIndex: 'assignee_name',
      key: 'assignee_name',
      render: (name: string) => name || '未分配',
    },
    {
      title: '进度',
      dataIndex: 'progress',
      key: 'progress',
      render: (progress: number) => (
        <Progress percent={progress} size="small" />
      ),
    },
    {
      title: '截止时间',
      dataIndex: 'due_date',
      key: 'due_date',
      render: (date: string) => date ? new Date(date).toLocaleDateString('zh-CN') : '-',
    },
    {
      title: '操作',
      key: 'action',
      render: (record: Task) => (
        <Space size="small">
          <Button type="link" className="text-primary-600 hover:text-primary-700 p-0 h-auto font-medium">
            编辑
          </Button>
          <Button type="link" className="text-primary-600 hover:text-primary-700 p-0 h-auto font-medium">
            分配
          </Button>
          <Button type="link" danger className="p-0 h-auto font-medium">
            删除
          </Button>
        </Space>
      ),
    },
  ];

  // 甘特图组件
  const GanttChart = () => {
    const generateTimeAxis = () => {
      const today = new Date();
      const days = [];
      
      for (let i = -7; i <= 30; i++) {
        const date = new Date(today);
        date.setDate(today.getDate() + i);
        days.push(date);
      }
      
      return days;
    };

    const timeAxis = generateTimeAxis();

    const getTaskPosition = (task: Task) => {
      if (!task.due_date) return { left: '0%', width: '0%' };
      
      const startDate = new Date(task.created_at);
      const endDate = new Date(task.due_date);
      const firstDay = timeAxis[0];
      const lastDay = timeAxis[timeAxis.length - 1];
      
      const totalDays = (lastDay.getTime() - firstDay.getTime()) / (1000 * 60 * 60 * 24);
      const startOffset = (startDate.getTime() - firstDay.getTime()) / (1000 * 60 * 60 * 24);
      const duration = (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24);
      
      const left = (startOffset / totalDays) * 100;
      const width = (duration / totalDays) * 100;
      
      return { left: `${Math.max(0, left)}%`, width: `${Math.max(1, width)}%` };
    };

    return (
      <div className="bg-white rounded-lg shadow overflow-hidden">
        {/* 时间轴头部 */}
        <div className="border-b border-gray-200">
          <div className="flex">
            <div className="w-48 p-4 bg-gray-50 border-r border-gray-200">
              <h3 className="font-medium text-gray-900">员工</h3>
            </div>
            <div className="flex-1 p-2 bg-gray-50">
              <div className="flex">
                {timeAxis.map((date, index) => (
                  <div
                    key={index}
                    className="flex-1 text-center text-xs text-gray-600 border-r border-gray-200 last:border-r-0 p-1"
                  >
                    <div>{date.getMonth() + 1}/{date.getDate()}</div>
                    <div className="text-gray-400">
                      {['日', '一', '二', '三', '四', '五', '六'][date.getDay()]}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* 员工任务行 */}
        <div className="divide-y divide-gray-200">
          {employees.map((employee) => (
            <div key={employee.id} className="flex">
              {/* 员工信息 */}
              <div className="w-48 p-4 border-r border-gray-200">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="h-8 w-8 bg-primary-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-sm font-medium">
                        {employee.name.charAt(0)}
                      </span>
                    </div>
                  </div>
                  <div className="ml-3">
                    <div className="text-sm font-medium text-gray-900">{employee.name}</div>
                    <div className="text-xs text-gray-500">{employee.department}</div>
                  </div>
                </div>
                <div className="mt-2 text-xs text-gray-500">
                  {employee.tasks.length} 个任务
                </div>
              </div>

              {/* 任务甘特图 */}
              <div className="flex-1 relative" style={{ minHeight: '80px' }}>
                {/* 时间网格线 */}
                <div className="absolute inset-0 flex">
                  {timeAxis.map((_, index) => (
                    <div
                      key={index}
                      className="flex-1 border-r border-gray-100 last:border-r-0"
                    />
                  ))}
                </div>

                {/* 任务条 */}
                <div className="relative h-full p-2">
                  {employee.tasks.map((task, taskIndex) => {
                    const position = getTaskPosition(task);
                    return (
                      <div
                        key={task.id}
                        className="absolute h-6 rounded-md flex items-center px-2 text-white text-xs font-medium cursor-pointer hover:opacity-80 transition-opacity"
                        style={{
                          left: position.left,
                          width: position.width,
                          top: `${taskIndex * 28 + 8}px`,
                          backgroundColor: getStatusColor(task.status) === 'processing' ? '#1890ff' : 
                                          getStatusColor(task.status) === 'success' ? '#52c41a' :
                                          getStatusColor(task.status) === 'error' ? '#ff4d4f' : '#d9d9d9',
                          minWidth: '60px'
                        }}
                        title={`${task.name} (${task.progress}%)`}
                      >
                        <div className="truncate flex-1">{task.name}</div>
                        <div className="ml-1 text-xs">{task.progress}%</div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  };

  return (
    <div className="animate-fade-in">
      <div className="mb-6">
        <Title level={5} className="bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent mb-2 text-left">
          任务管理
        </Title>
        <div className="w-24 h-1 bg-gradient-to-r from-primary-500 to-primary-600 rounded-full mb-4"></div>
      </div>

      <Tabs activeKey={activeTab} onChange={setActiveTab} className="mb-6">
        <TabPane tab={<span><BarChartOutlined /> 任务列表</span>} key="list">
          {/* 操作栏 */}
          <div className="mb-6 flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <Input
                placeholder="搜索任务..."
                prefix={<SearchOutlined />}
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="h-10"
              />
            </div>
            
            <div className="flex gap-2">
              <Select
                placeholder="所有状态"
                value={statusFilter}
                onChange={setStatusFilter}
                className="w-32"
                allowClear
              >
                <Option value="pending">待分配</Option>
                <Option value="assigned">已分配</Option>
                <Option value="in_progress">进行中</Option>
                <Option value="completed">已完成</Option>
              </Select>
              
              <Select
                placeholder="所有优先级"
                value={priorityFilter}
                onChange={setPriorityFilter}
                className="w-32"
                allowClear
              >
                <Option value="low">低</Option>
                <Option value="medium">中</Option>
                <Option value="high">高</Option>
                <Option value="urgent">紧急</Option>
              </Select>
              
              <Button
                type="primary"
                icon={<PlusOutlined />}
                onClick={() => setShowCreateModal(true)}
                className="bg-gradient-to-r from-primary-500 to-primary-600 border-none shadow-soft hover:shadow-medium hover:scale-105 transition-all duration-200 h-10 px-6 font-medium"
              >
                创建任务
              </Button>
            </div>
          </div>

          {/* 任务列表 */}
          <Table
            columns={columns}
            dataSource={filteredTasks}
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

        <TabPane tab={<span><CalendarOutlined /> 工作安排</span>} key="gantt">
          {/* 工作负载统计 */}
          <div className="mb-6 grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="bg-white p-6 rounded-lg shadow-soft">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <BarChartOutlined className="h-8 w-8 text-primary-600" />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-500">总任务数</p>
                  <p className="text-2xl font-semibold text-gray-900">{tasks.length}</p>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-soft">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 bg-orange-500 rounded-full flex items-center justify-center">
                    <span className="text-white font-bold text-sm">!</span>
                  </div>
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-500">进行中任务</p>
                  <p className="text-2xl font-semibold text-gray-900">
                    {tasks.filter(task => task.status === 'in_progress').length}
                  </p>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-soft">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 bg-green-500 rounded-full flex items-center justify-center">
                    <span className="text-white font-bold text-sm">✓</span>
                  </div>
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-500">已完成任务</p>
                  <p className="text-2xl font-semibold text-gray-900">
                    {tasks.filter(task => task.status === 'completed').length}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* 甘特图 */}
          <GanttChart />
        </TabPane>
      </Tabs>

      {/* 创建任务模态框 */}
      <Modal
        title="创建新任务"
        open={showCreateModal}
        onCancel={() => setShowCreateModal(false)}
        footer={null}
        width={600}
      >
        <Form layout="vertical">
          <Form.Item label="任务名称" required>
            <Input placeholder="输入任务名称" />
          </Form.Item>
          <Form.Item label="任务描述">
            <Input.TextArea rows={3} placeholder="输入任务描述" />
          </Form.Item>
          <div className="grid grid-cols-2 gap-4">
            <Form.Item label="难度">
              <Select defaultValue="medium">
                <Option value="very_easy">非常简单</Option>
                <Option value="easy">简单</Option>
                <Option value="medium">中等</Option>
                <Option value="hard">困难</Option>
                <Option value="very_hard">非常困难</Option>
              </Select>
            </Form.Item>
            <Form.Item label="优先级">
              <Select defaultValue="medium">
                <Option value="low">低</Option>
                <Option value="medium">中</Option>
                <Option value="high">高</Option>
                <Option value="urgent">紧急</Option>
              </Select>
            </Form.Item>
          </div>
          <Form.Item label="截止时间">
            <DatePicker className="w-full" />
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

export default TaskManagement;