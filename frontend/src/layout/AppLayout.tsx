import { Layout, Menu, Button, Input, Typography, Avatar } from 'antd';
import { useState, useRef, useEffect } from 'react';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import defaultThumbnail from "../assets/react.svg";
import { AppstoreOutlined, ClusterOutlined, DashboardOutlined, MonitorOutlined, PythonOutlined, MessageOutlined } from '@ant-design/icons';

const { Header, Sider, Content } = Layout;
const { TextArea } = Input;
const { Title, Text } = Typography;

export default function AppLayout() {
    const [isChatOpen, setIsChatOpen] = useState(false);
    const [isChatVisible, setIsChatVisible] = useState(false);
    const [animationState, setAnimationState] = useState<'open' | 'close'>('close');
    const [messages, setMessages] = useState<Array<{ id: number, text: string, isUser: boolean }>>([
        { id: 1, text: "您好！我是AI人事助手，有什么可以帮助您的吗？", isUser: false }
    ]);
    const [inputValue, setInputValue] = useState('');
    const messagesEndRef = useRef<HTMLDivElement>(null);

    const navigate = useNavigate();
    const location = useLocation();

    // 根据当前路径确定选中的菜单项
    const getSelectedKey = () => {
        const path = location.pathname;
        if (path.includes('/dashboard')) return 'dashboard';
        if (path.includes('/employee-management')) return 'employee-management';
        if (path.includes('/department-management')) return 'department-management';
        if (path.includes('/resume-management')) return 'resume-management';
        if (path.includes('/jd-management')) return 'jd-management';
        if (path.includes('/okr')) return 'okr';
        return 'dashboard'; // 默认选中项
    };

    // 滚动到消息底部
    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    // 处理聊天面板打开/关闭的动画
    useEffect(() => {
        if (isChatOpen) {
            setIsChatVisible(true);
            setAnimationState('open');
        } else {
            setAnimationState('close');
            const timer = setTimeout(() => {
                setIsChatVisible(false);
            }, 300); // 动画持续时间
            return () => clearTimeout(timer);
        }
    }, [isChatOpen]);

    // 发送消息
    const handleSend = () => {
        if (inputValue.trim() === '') return;

        // 添加用户消息
        const newUserMessage = {
            id: messages.length + 1,
            text: inputValue,
            isUser: true
        };

        setMessages(prev => [...prev, newUserMessage]);
        setInputValue('');

        // 模拟AI回复
        setTimeout(() => {
            const aiResponse = {
                id: messages.length + 2,
                text: "感谢您的提问，我已经收到您的问题。作为AI人事助手，我会尽力为您提供帮助。",
                isUser: false
            };
            setMessages(prev => [...prev, aiResponse]);
        }, 1000);
    };

    // AI对话组件
    const AIChatPanel = () => (
        <div className="h-full flex flex-col">
            <div className="bg-gradient-to-r from-primary-50 to-blue-50 p-4 rounded-xl mb-4 border border-primary-100">
                <Title level={4} className="text-primary-700 m-0 mb-1">AI助手</Title>
                <Text className="text-primary-600 text-sm">您好！我是AI人事助手，有什么可以帮助您的吗？</Text>
            </div>
            <div className="flex-1 overflow-y-auto mb-4 p-2 space-y-4">
                {messages.map(message => (
                    <div
                        key={message.id}
                        className={`flex ${message.isUser ? 'justify-end' : 'justify-start'} mb-4`}
                    >
                        {!message.isUser && (
                            <Avatar
                                className="bg-primary-500 mr-2 flex-shrink-0"
                                icon={<MessageOutlined />}
                            />
                        )}
                        <div
                            className={`max-w-[80%] px-3 py-2 rounded-2xl break-words ${message.isUser
                                ? 'bg-gradient-to-r from-primary-500 to-primary-600 text-white'
                                : 'bg-gray-100 text-gray-800'
                                }`}
                        >
                            {message.text}
                        </div>
                        {message.isUser && (
                            <Avatar
                                className="bg-success-500 ml-2 flex-shrink-0"
                                icon={<span>U</span>}
                            />
                        )}
                    </div>
                ))}
                <div ref={messagesEndRef} />
            </div>
            <div className="relative">
                <TextArea
                    placeholder="请输入您的问题..."
                    autoSize={{ minRows: 2, maxRows: 4 }}
                    value={inputValue}
                    onChange={(e) => setInputValue(e.target.value)}
                    onPressEnter={(e) => {
                        if (e.shiftKey) return;
                        e.preventDefault();
                        handleSend();
                    }}
                    className="mb-2 border-gray-200 rounded-xl resize-none focus:border-primary-400 focus:shadow-soft transition-all duration-200"
                />
                <Button
                    type="primary"
                    onClick={handleSend}
                    block
                    className="bg-gradient-to-r from-primary-500 to-primary-600 border-none rounded-xl h-10 font-medium hover:shadow-medium transition-all duration-200"
                >
                    发送
                </Button>
            </div>
        </div>
    );

    return (
        <Layout className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
            <Header
                className="flex items-center px-4 md:px-6 bg-white/80 backdrop-blur-md border-b border-gray-200/50 h-16 fixed top-0 left-0 right-0 z-50 shadow-soft"
            >
                <div className="flex items-center">
                    <img
                        src={defaultThumbnail}
                        alt="Logo"
                        className="h-8 w-8 mr-3 animate-bounce-gentle"
                    />
                    <div className="hidden sm:block">
                        <span className="font-bold text-xl bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent">
                            AI人事干人事
                        </span>
                    </div>
                </div>
                <div className="flex-1"></div>
                <div className="flex items-center space-x-4">
                    <div className="hidden md:flex items-center space-x-2 bg-primary-50 px-3 py-1 rounded-full">
                        <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                        <span className="text-primary-700 text-sm font-medium">演示账户</span>
                    </div>
                </div>
            </Header>
            <Layout>
                <Sider
                    className="bg-white/90 backdrop-blur-md border-r border-gray-200/50 overflow-y-auto fixed left-0 h-screen z-40 shadow-soft"
                    style={{
                        top: '64px',
                        height: 'calc(100vh - 64px)',
                        width: '240px',
                    }}
                    width={240}
                >
                    <Menu
                        mode="inline"
                        selectedKeys={[getSelectedKey()]}
                        className="bg-transparent border-none pt-4"
                        items={[
                            {
                                key: 'dashboard',
                                label: <span className="font-medium">仪表盘</span>,
                                onClick: () => navigate('/dashboard'),
                                icon: <DashboardOutlined className="text-primary-600" />,
                                className: 'mx-2 mb-1 rounded-lg hover:bg-primary-50 transition-all duration-200'
                            },
                            {
                                key: 'employee-management',
                                label: <span className="font-medium">员工管理</span>,
                                onClick: () => navigate('/employee-management'),
                                icon: <MonitorOutlined className="text-primary-600" />,
                                className: 'mx-2 mb-1 rounded-lg hover:bg-primary-50 transition-all duration-200'
                            },
                            {
                                key: 'department-management',
                                label: <span className="font-medium">部门管理</span>,
                                onClick: () => navigate('/department-management'),
                                icon: <AppstoreOutlined className="text-primary-600" />,
                                className: 'mx-2 mb-1 rounded-lg hover:bg-primary-50 transition-all duration-200'
                            },
                            {
                                key: 'resume-management',
                                label: <span className="font-medium">简历库</span>,
                                onClick: () => navigate('/resume-management'),
                                icon: <PythonOutlined className="text-primary-600" />,
                                className: 'mx-2 mb-1 rounded-lg hover:bg-primary-50 transition-all duration-200'
                            },
                            {
                                key: 'jd-management',
                                label: <span className="font-medium">JD管理</span>,
                                onClick: () => navigate('/jd-management'),
                                icon: <ClusterOutlined className="text-primary-600" />,
                                className: 'mx-2 mb-1 rounded-lg hover:bg-primary-50 transition-all duration-200'
                            },
                            {
                                key: 'okr',
                                label: <span className="font-medium">OKR/KPI管理</span>,
                                onClick: () => navigate('/okr'),
                                icon: <ClusterOutlined className="text-primary-600" />,
                                className: 'mx-2 mb-1 rounded-lg hover:bg-primary-50 transition-all duration-200'
                            },
                        ]}
                    />
                </Sider>

                <Content
                    className="min-h-screen bg-transparent transition-all duration-300"
                    style={{
                        padding: '24px',
                        marginLeft: '240px',
                        marginTop: '64px',
                    }}
                >
                    <div className="bg-white/70 backdrop-blur-sm rounded-2xl shadow-soft border border-white/50 p-6 min-h-[calc(100vh-152px)] transition-all duration-300 hover:shadow-medium">
                        <Outlet />
                    </div>
                </Content>
            </Layout>

            {/* AI助手按钮 */}
            {!isChatOpen && (
                <Button
                    type="primary"
                    shape="circle"
                    size="large"
                    icon={<MessageOutlined />}
                    onClick={() => setIsChatOpen(true)}
                    style={{
                        position: 'fixed',
                        bottom: '30px',
                        right: '30px',
                        background: '#2196f3',
                        borderColor: '#2196f3',
                        zIndex: 1000,
                        width: '40px',
                        height: '40px',
                        transition: 'all 0.3s ease',
                    }}
                />
            )}

            {/* AI问答面板 */}
            {isChatVisible && (
                <div
                    className={`fixed bottom-6 right-6 w-96 h-[600px] bg-white/95 backdrop-blur-md rounded-2xl shadow-hard z-50 flex flex-col border border-white/50 transition-all duration-300 ${animationState === 'open' ? 'opacity-100 scale-100' : 'opacity-0 scale-90'
                        }`}
                >
                    <div className="flex justify-between items-center p-4 border-b border-gray-200/50 bg-gradient-to-r from-primary-50 to-primary-100 rounded-t-2xl">
                        <Title level={4} className="m-0 bg-gradient-to-r from-primary-600 to-primary-900 bg-clip-text text-transparent">
                            AI助手
                        </Title>
                        <Button
                            type="text"
                            icon={<span className="text-xl text-gray-400 hover:text-gray-600">×</span>}
                            onClick={() => setIsChatOpen(false)}
                            className="hover:bg-white/50 rounded-full transition-all duration-200"
                        />
                    </div>
                    <div className="flex-1 p-6 overflow-hidden">
                        <AIChatPanel />
                    </div>
                </div>
            )}

        </Layout>
    );
}