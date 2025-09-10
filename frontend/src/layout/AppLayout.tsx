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
        <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
            <div style={{
                background: '#e3f2fd',
                padding: '16px',
                borderRadius: '8px',
                marginBottom: '16px'
            }}>
                <Title level={4} style={{ color: '#0d47a1', margin: 0 }}>AI助手</Title>
                <Text style={{ color: '#0d47a1' }}>您好！我是AI人事助手，有什么可以帮助您的吗？</Text>
            </div>
            <div style={{
                flex: 1,
                overflowY: 'auto',
                marginBottom: '16px',
                padding: '8px'
            }}>
                {messages.map(message => (
                    <div
                        key={message.id}
                        style={{
                            display: 'flex',
                            justifyContent: message.isUser ? 'flex-end' : 'flex-start',
                            marginBottom: '16px'
                        }}
                    >
                        {!message.isUser && (
                            <Avatar
                                style={{ backgroundColor: '#2196f3', marginRight: '8px', flexShrink: 0 }}
                                icon={<MessageOutlined />}
                            />
                        )}
                        <div
                            style={{
                                maxWidth: '80%',
                                padding: '8px 12px',
                                borderRadius: '16px',
                                background: message.isUser ? '#2196f3' : '#f0f0f0',
                                color: message.isUser ? '#fff' : '#000',
                                wordBreak: 'break-word'
                            }}
                        >
                            {message.text}
                        </div>
                        {message.isUser && (
                            <Avatar
                                style={{ backgroundColor: '#4caf50', marginLeft: '8px', flexShrink: 0 }}
                                icon={<span>U</span>}
                            />
                        )}
                    </div>
                ))}
                <div ref={messagesEndRef} />
            </div>
            <div style={{
                position: 'relative'
            }}>
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
                    style={{ marginBottom: '8px' }}
                />
                <Button
                    type="primary"
                    style={{ background: '#2196f3', borderColor: '#2196f3' }}
                    onClick={handleSend}
                    block
                >
                    发送
                </Button>
            </div>
        </div>
    );

    return (
        <Layout style={{ minHeight: '100vh' }}>
            <Header
                style={{
                    display: 'flex',
                    alignItems: 'center',
                    padding: '0 16px',
                    background: '#e3f2fd', // 浅蓝色背景
                }}
            >
                <img
                    src={defaultThumbnail}
                    alt="Logo"
                    style={{ height: '32px', marginRight: '12px' }}
                />
                <div >
                    <span style={{ fontWeight: 'bold', fontSize: '20px', color: '#0d47a1' }}>AI人事干人事</span>
                </div>
                <div style={{ flex: 1 }}></div>
                <div>
                    <Text style={{ color: '#0d47a1' }}>演示账户</Text>
                </div>
            </Header>
            <Layout>
                <Sider
                    style={{
                        background: '#f5f9ff', // 浅蓝色背景
                    }}
                >
                    <Menu
                        mode="inline"
                        selectedKeys={[getSelectedKey()]}
                        style={{
                            background: '#f5f9ff', // 浅蓝色背景
                        }}
                        items={[
                            { key: 'dashboard', label: '仪表盘', onClick: () => navigate('/dashboard'), icon: <DashboardOutlined /> },
                            { key: 'employee-management', label: '员工管理', onClick: () => navigate('/employee-management'), icon: <MonitorOutlined /> },
                            { key: 'department-management', label: '部门管理', onClick: () => navigate('/department-management'), icon: <AppstoreOutlined /> },
                            { key: 'resume-management', label: '简历库', onClick: () => navigate('/resume-management'), icon: <PythonOutlined /> },
                            { key: 'jd-management', label: 'JD管理', onClick: () => navigate('/jd-management'), icon: <ClusterOutlined /> },
                            { key: 'okr', label: 'OKR/KPI管理', onClick: () => navigate('/okr'), icon: <ClusterOutlined /> },
                        ]}
                    />
                </Sider>

                <Content
                    style={{
                        padding: '24px',
                        minHeight: 'calc(100vh - 64px)',
                        background: '#fafafa', // 浅灰色背景
                    }}
                >
                    <div
                        style={{
                            background: '#fff',
                            padding: '24px',
                            minHeight: 'calc(100vh - 112px)',
                            position: 'relative'
                        }}
                    >
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
                    }}
                />
            )}

            {/* AI问答面板 */}
            {isChatOpen && (
                <div
                    style={{
                        position: 'fixed',
                        bottom: '30px',
                        right: '30px',
                        width: '400px',
                        height: '600px',
                        background: '#fff',
                        borderRadius: '8px',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                        zIndex: 1000,
                        display: 'flex',
                        flexDirection: 'column'
                    }}
                >
                    <div
                        style={{
                            padding: '12px 16px',
                            borderBottom: '1px solid #f0f0f0',
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center'
                        }}
                    >
                        <Title level={4} style={{ margin: 0, color: '#0d47a1' }}>AI助手</Title>
                        <Button
                            type="text"
                            icon={<span style={{ fontSize: '20px' }}>×</span>}
                            onClick={() => setIsChatOpen(false)}
                        />
                    </div>
                    <div style={{ flex: 1, padding: '24px', overflow: 'hidden' }}>
                        <AIChatPanel />
                    </div>
                </div>
            )}
        </Layout>
    );
}