import { useState, useEffect, useRef } from 'react';
import { Button, Input, Typography, Avatar } from 'antd';
import { MessageOutlined } from '@ant-design/icons';

const { TextArea } = Input;
const { Title, Text } = Typography;

interface Message {
    id: number;
    text: string;
    isUser: boolean;
}

export default function AIChatPanel() {
    const [messages, setMessages] = useState<Message[]>([
        { id: 1, text: "您好！我是AI人事助手，有什么可以帮助您的吗？", isUser: false }
    ]);
    const [inputValue, setInputValue] = useState('');
    const messagesEndRef = useRef<HTMLDivElement>(null);

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

    return (
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
}