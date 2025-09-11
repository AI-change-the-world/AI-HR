import { useState, useEffect, useRef } from 'react';
import { Button, Input, Typography, Avatar, Spin } from 'antd';
import { MessageOutlined } from '@ant-design/icons';
import { BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import apiClient from '../../../utils/api';

const { TextArea } = Input;
const { Title, Text } = Typography;

interface Message {
    id: number;
    text: string;
    isUser: boolean;
    chartData?: any; // 添加图表数据字段
}

interface ChatResponse {
    message: string;
    chart_data?: any;
    raw_data?: any;
}

interface ChatRequest {
    message: string;
}

// 颜色配置
const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d'];

export default function AIChatPanel() {
    const [messages, setMessages] = useState<Message[]>([
        { id: 1, text: "您好！我是AI人事助手，有什么可以帮助您的吗？", isUser: false }
    ]);
    const [inputValue, setInputValue] = useState('');
    const [loading, setLoading] = useState(false);
    const messagesEndRef = useRef<HTMLDivElement>(null);

    // 滚动到消息底部
    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    // 发送消息到后端API
    const sendToAI = async (message: string) => {
        try {
            setLoading(true);

            const request: ChatRequest = { message };
            const response: ChatResponse = await apiClient.post<ChatResponse>('/api/ai-qa/chat', request);

            return {
                text: response.message,
                chartData: response.chart_data,
                raw_data: response.raw_data
            };
        } catch (error) {
            console.error('AI助手请求失败:', error);
            return {
                text: "抱歉，AI助手暂时无法响应，请稍后再试。",
                chartData: null
            };
        } finally {
            setLoading(false);
        }
    };

    // 发送消息
    const handleSend = async () => {
        if (inputValue.trim() === '') return;

        // 添加用户消息
        const newUserMessage = {
            id: messages.length + 1,
            text: inputValue,
            isUser: true
        };

        setMessages(prev => [...prev, newUserMessage]);
        setInputValue('');

        // 获取AI回复
        const aiResponse = await sendToAI(inputValue);

        // 添加AI回复
        const newAiMessage = {
            id: messages.length + 2,
            text: aiResponse.text,
            isUser: false,
            chartData: aiResponse.chartData
        };

        setMessages(prev => [...prev, newAiMessage]);
    };

    // 渲染柱状图
    const renderBarChart = (chartData: any) => {
        if (!chartData || chartData.type !== 'bar') return null;

        const { data, title } = chartData;
        const { xAxis, yAxis, series } = data;

        // 转换数据格式以适应recharts
        const chartDataFormatted = xAxis.data.map((name: string, index: number) => ({
            name,
            value: series[0].data[index]
        }));

        return (
            <div className="mt-4 p-4 border rounded-lg bg-white shadow-sm">
                <h4 className="text-lg font-semibold mb-4 text-center text-gray-800">{title}</h4>
                <div className="h-64">
                    <ResponsiveContainer width="100%" height="100%">
                        <BarChart
                            data={chartDataFormatted}
                            margin={{ top: 20, right: 30, left: 20, bottom: 60 }}
                        >
                            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                            <XAxis
                                dataKey="name"
                                angle={-45}
                                textAnchor="end"
                                height={60}
                                tick={{ fontSize: 12 }}
                            />
                            <YAxis
                                tick={{ fontSize: 12 }}
                            />
                            <Tooltip
                                contentStyle={{
                                    backgroundColor: 'rgba(255, 255, 255, 0.9)',
                                    borderRadius: '8px',
                                    border: '1px solid #e5e7eb'
                                }}
                            />
                            <Legend />
                            <Bar
                                dataKey="value"
                                fill="#3b82f6"
                                name="员工数量"
                                radius={[4, 4, 0, 0]}
                            />
                        </BarChart>
                    </ResponsiveContainer>
                </div>
            </div>
        );
    };

    // 渲染饼图
    const renderPieChart = (chartData: any) => {
        if (!chartData || chartData.type !== 'pie') return null;

        const { data, title } = chartData;
        const chartDataFormatted = data.series[0].data;

        return (
            <div className="mt-4 p-4 border rounded-lg bg-white shadow-sm">
                <h4 className="text-lg font-semibold mb-4 text-center text-gray-800">{title}</h4>
                <div className="h-64">
                    <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                            <Pie
                                data={chartDataFormatted}
                                cx="50%"
                                cy="50%"
                                labelLine={true}
                                // label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                                outerRadius={80}
                                fill="#8884d8"
                                dataKey="value"
                            >
                                {chartDataFormatted.map((entry: any, index: number) => (
                                    <Cell
                                        key={`cell-${index}`}
                                        fill={COLORS[index % COLORS.length]}
                                    />
                                ))}
                            </Pie>
                            <Tooltip
                                formatter={(value) => [value, '人数']}
                                contentStyle={{
                                    backgroundColor: 'rgba(255, 255, 255, 0.9)',
                                    borderRadius: '8px',
                                    border: '1px solid #e5e7eb'
                                }}
                            />
                            <Legend />
                        </PieChart>
                    </ResponsiveContainer>
                </div>
            </div>
        );
    };

    // 渲染图表
    const renderChart = (chartData: any) => {
        if (!chartData) return null;

        switch (chartData.type) {
            case 'bar':
                return renderBarChart(chartData);
            case 'pie':
                return renderPieChart(chartData);
            default:
                return (
                    <div className="mt-2 p-3 bg-blue-50 rounded-lg border border-blue-100">
                        <div className="text-sm font-medium text-blue-800 mb-1">
                            {chartData.title}
                        </div>
                        <div className="text-xs text-blue-600">
                            图表数据已生成，可使用可视化工具展示
                        </div>
                    </div>
                );
        }
    };

    // 渲染消息内容，包括可能的图表
    const renderMessageContent = (message: Message) => {
        return (
            <div>
                <div className="whitespace-pre-wrap">{message.text}</div>
                {message.chartData && renderChart(message.chartData)}
            </div>
        );
    };

    return (
        <div className="h-full flex flex-col">
            <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-4 rounded-xl mb-4 border border-blue-100">
                <Title level={4} className="text-blue-800 m-0 mb-1">AI助手</Title>
                <Text className="text-blue-600 text-sm">您好！我是AI人事助手，有什么可以帮助您的吗？</Text>
            </div>

            {loading && (
                <div className="flex justify-center my-2">
                    <Spin size="small" />
                </div>
            )}

            <div className="flex-1 overflow-y-auto mb-4 p-2 space-y-4">
                {messages.map(message => (
                    <div
                        key={message.id}
                        className={`flex ${message.isUser ? 'justify-end' : 'justify-start'} mb-4`}
                    >
                        {!message.isUser && (
                            <Avatar
                                className="bg-blue-500 mr-2 flex-shrink-0"
                                icon={<MessageOutlined />}
                            />
                        )}
                        <div
                            className={`max-w-[80%] px-4 py-3 rounded-2xl break-words ${message.isUser
                                ? 'bg-gradient-to-r from-blue-500 to-indigo-600 text-white'
                                : 'bg-gray-100 text-gray-800'
                                }`}
                        >
                            {renderMessageContent(message)}
                        </div>
                        {message.isUser && (
                            <Avatar
                                className="bg-green-500 ml-2 flex-shrink-0"
                                icon={<span className="font-bold">U</span>}
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
                    className="mb-2 border-gray-200 rounded-xl resize-none focus:border-blue-400 focus:shadow-lg transition-all duration-200"
                    disabled={loading}
                />
                <Button
                    type="primary"
                    onClick={handleSend}
                    block
                    className="bg-gradient-to-r from-blue-500 to-indigo-600 border-none rounded-xl h-10 font-medium hover:shadow-lg transition-all duration-200"
                    loading={loading}
                >
                    发送
                </Button>
            </div>
        </div>
    );
}