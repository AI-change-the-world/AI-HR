import React, { useState, useEffect } from 'react';
import { Modal, Input, Button, message, Spin, Divider, Card, Typography, Space, Tabs, Progress, Select } from 'antd';
import { StarOutlined, EditOutlined, EyeOutlined, CopyOutlined, BankOutlined } from '@ant-design/icons';
import ReactMarkdown from 'react-markdown';
import { createJDFromText, polishJDTextStream, getDepartments } from '../api';
import { JobDescription, Department } from '../types';
import './JDCreateModal.css';

const { TextArea } = Input;
const { Title, Text, Paragraph } = Typography;
const { TabPane } = Tabs;

interface JDCreateModalProps {
    visible: boolean;
    onCancel: () => void;
    onSuccess: (jd: JobDescription) => void;
}

const JDCreateModal: React.FC<JDCreateModalProps> = ({ visible, onCancel, onSuccess }) => {
    const [originalText, setOriginalText] = useState('');
    const [polishedText, setPolishedText] = useState('');
    const [polishing, setPolishing] = useState(false);
    const [creating, setCreating] = useState(false);
    const [activeTab, setActiveTab] = useState('input');
    const [polishProgress, setPolishProgress] = useState(0);
    const [polishMessage, setPolishMessage] = useState('');
    const [departments, setDepartments] = useState<Department[]>([]);
    const [selectedDepartmentId, setSelectedDepartmentId] = useState<number | undefined>();
    const [loadingDepartments, setLoadingDepartments] = useState(false);

    // 重置状态
    useEffect(() => {
        if (visible) {
            setOriginalText('');
            setPolishedText('');
            setActiveTab('input');
            setPolishProgress(0);
            setPolishMessage('');
            setSelectedDepartmentId(undefined);
            loadDepartments();
        }
    }, [visible]);

    // 加载部门列表
    const loadDepartments = async () => {
        setLoadingDepartments(true);
        try {
            const deptList = await getDepartments();
            setDepartments(deptList);
        } catch (error) {
            console.error('加载部门列表失败:', error);
            message.error('加载部门列表失败');
        } finally {
            setLoadingDepartments(false);
        }
    };

    // AI润色功能 - 流式处理
    const handlePolish = async () => {
        if (!originalText.trim()) {
            message.warning('请先输入JD原文');
            return;
        }

        setPolishing(true);
        setPolishProgress(0);
        setPolishMessage('');

        try {
            await polishJDTextStream(
                originalText,
                // onProgress
                (data) => {
                    setPolishMessage(data.message);
                    if (data.progress !== undefined) {
                        setPolishProgress(data.progress);
                    }
                },
                // onComplete
                (polishedText) => {
                    setPolishedText(polishedText);
                    setActiveTab('polished');
                    message.success('AI润色完成');
                    setPolishProgress(100);
                },
                // onError
                (error) => {
                    message.error(`润色失败: ${error}`);
                    console.error('Polish error:', error);
                }
            );
        } catch (error) {
            message.error('润色失败，请重试');
            console.error('Polish error:', error);
        } finally {
            setPolishing(false);
            setPolishProgress(0);
            setPolishMessage('');
        }
    };

    // 创建JD
    const handleCreate = async () => {
        const textToUse = polishedText || originalText;
        if (!textToUse.trim()) {
            message.warning('请输入JD内容');
            return;
        }

        setCreating(true);
        try {
            // 先从文本创建JD
            const newJD = await createJDFromText(textToUse);

            // 如果选择了部门，则更新JD的部门信息
            if (selectedDepartmentId && newJD.id) {
                const { updateJD } = await import('../api');
                const updatedJD = await updateJD({
                    id: newJD.id,
                    department_id: selectedDepartmentId
                });
                message.success('JD创建成功');
                onSuccess(updatedJD);
            } else {
                message.success('JD创建成功');
                onSuccess(newJD);
            }
        } catch (error) {
            message.error('创建失败，请重试');
            console.error('Create error:', error);
        } finally {
            setCreating(false);
        }
    };

    // 复制到粘贴板
    const handleCopy = async (text: string) => {
        try {
            await navigator.clipboard.writeText(text);
            message.success('已复制到剪贴板');
        } catch (error) {
            message.error('复制失败');
        }
    };

    const renderInputTab = () => (
        <div className="space-y-4">
            {/* 部门选择 */}
            <div>
                <Text strong className="text-gray-700 block mb-2">
                    所属部门 <Text type="secondary">(可选，创建后可编辑)</Text>
                </Text>
                <Select
                    value={selectedDepartmentId}
                    onChange={setSelectedDepartmentId}
                    placeholder="请选择所属部门"
                    allowClear
                    loading={loadingDepartments}
                    className="w-full"
                    suffixIcon={<BankOutlined />}
                    showSearch
                    filterOption={(input, option) =>
                        (option?.label ?? '').toLowerCase().includes(input.toLowerCase())
                    }
                    options={departments.map(dept => ({
                        value: dept.id,
                        label: dept.name,
                        title: dept.description || dept.name
                    }))}
                />
            </div>

            <div>
                <Text strong className="text-gray-700 block mb-2">
                    JD原文 <Text type="secondary">(支持粘贴完整的职位描述)</Text>
                </Text>
                <TextArea
                    value={originalText}
                    onChange={(e) => setOriginalText(e.target.value)}
                    placeholder="请粘贴或输入完整的JD内容，包括职位名称、部门、工作地点、职位描述、任职要求等信息..."
                    rows={10}
                    className="resize-none"
                    style={{ fontSize: '14px', lineHeight: '1.6' }}
                />
            </div>
            <div className="flex justify-between items-center">
                <Text type="secondary" className="text-sm">
                    字数: {originalText.length}
                </Text>
                <Space>
                    <Button
                        icon={<StarOutlined />}
                        onClick={handlePolish}
                        loading={polishing}
                        disabled={!originalText.trim()}
                        className="bg-gradient-to-r from-purple-500 to-purple-600 border-none text-white hover:from-purple-600 hover:to-purple-700"
                    >
                        {polishing ? 'AI润色中...' : 'AI智能润色'}
                    </Button>
                </Space>
            </div>

            {/* 润色进度显示 */}
            {polishing && (
                <Card className="bg-purple-50 border-purple-200">
                    <div className="space-y-3">
                        <div className="flex items-center justify-between">
                            <Text strong className="text-purple-700">正在进行AI润色...</Text>
                            <Text className="text-purple-600 text-sm">{polishProgress}%</Text>
                        </div>
                        <Progress
                            percent={polishProgress}
                            strokeColor={{
                                '0%': '#a855f7',
                                '100%': '#7c3aed',
                            }}
                            trailColor="#e5e7eb"
                            strokeWidth={6}
                            showInfo={false}
                        />
                        {polishMessage && (
                            <Text type="secondary" className="text-sm">
                                {polishMessage}
                            </Text>
                        )}
                    </div>
                </Card>
            )}
        </div>
    );

    const renderPolishedTab = () => (
        <div className="space-y-4">
            <div className="flex items-center justify-between mb-3">
                <Text strong className="text-gray-700">
                    AI润色结果 <Text type="secondary">(支持Markdown格式)</Text>
                </Text>
                <Space>
                    <Button
                        icon={<CopyOutlined />}
                        size="small"
                        onClick={() => handleCopy(polishedText)}
                        className="text-gray-600"
                    >
                        复制
                    </Button>
                    <Button
                        icon={<EditOutlined />}
                        size="small"
                        onClick={() => setActiveTab('edit')}
                        className="text-blue-600"
                    >
                        编辑
                    </Button>
                </Space>
            </div>
            <Card className="bg-gray-50 border-gray-200">
                <div
                    className="prose prose-sm max-w-none"
                    style={{ maxHeight: '300px', overflowY: 'auto' }}
                >
                    <ReactMarkdown>{polishedText}</ReactMarkdown>
                </div>
            </Card>
        </div>
    );

    const renderEditTab = () => (
        <div className="space-y-4">
            <div className="flex items-center justify-between mb-3">
                <Text strong className="text-gray-700">
                    编辑润色结果 <Text type="secondary">(支持Markdown语法)</Text>
                </Text>
                <Button
                    icon={<EyeOutlined />}
                    size="small"
                    onClick={() => setActiveTab('polished')}
                    className="text-green-600"
                >
                    预览
                </Button>
            </div>
            <TextArea
                value={polishedText}
                onChange={(e) => setPolishedText(e.target.value)}
                placeholder="支持Markdown语法编辑..."
                rows={10}
                className="resize-none font-mono"
                style={{ fontSize: '13px', lineHeight: '1.6' }}
            />
            <Text type="secondary" className="text-sm block">
                支持Markdown语法：**粗体** *斜体* `代码` [链接](url) 等
            </Text>
        </div>
    );

    return (
        <Modal
            title={
                <div className="flex items-center space-x-3">
                    <div className="w-1 h-6 bg-gradient-to-b from-blue-500 to-purple-500 rounded-full"></div>
                    <div>
                        <div className="text-lg font-semibold text-gray-800">创建新JD</div>
                        <div className="text-sm text-gray-500">智能解析职位信息</div>
                    </div>
                </div>
            }
            open={visible}
            onCancel={onCancel}
            width={800}
            className="jd-create-modal"
            footer={
                <div className="flex justify-between items-center pt-4 border-t border-gray-100">
                    <Text type="secondary" className="text-sm">
                        {polishedText ? '将使用润色后的内容创建JD' : '将使用原始内容创建JD'}
                    </Text>
                    <Space>
                        <Button onClick={onCancel} className="border-gray-300 text-gray-600">
                            取消
                        </Button>
                        <Button
                            type="primary"
                            onClick={handleCreate}
                            loading={creating}
                            disabled={!originalText.trim()}
                            className="bg-gradient-to-r from-blue-500 to-blue-600 border-none shadow-lg hover:shadow-xl transition-all duration-300"
                        >
                            {creating ? '创建中...' : '创建JD'}
                        </Button>
                    </Space>
                </div>
            }
            styles={{
                body: { padding: '24px', maxHeight: '70vh', overflowY: 'auto' },
                header: { borderBottom: '1px solid #f0f0f0', paddingBottom: '16px' }
            }}
        >
            <div className="space-y-6">
                {/* 提示信息 */}
                <Card className="bg-blue-50 border-blue-200">
                    <div className="flex items-start space-x-3">
                        <StarOutlined className="text-blue-500 mt-1" />
                        <div className="text-sm text-blue-800">
                            <div className="font-medium mb-1">智能JD创建流程：</div>
                            <div className="space-y-1 text-blue-700">
                                <div>1. 选择所属部门（可选）</div>
                                <div>2. 粘贴或输入完整的JD原文</div>
                                <div>3. 使用AI智能润色功能优化格式和内容</div>
                                <div>4. 系统将自动解析并提取关键信息创建结构化JD</div>
                            </div>
                        </div>
                    </div>
                </Card>

                {/* 标签页 */}
                <Tabs
                    activeKey={activeTab}
                    onChange={setActiveTab}
                    className="jd-create-tabs"
                    items={[
                        {
                            key: 'input',
                            label: (
                                <span className="flex items-center space-x-1">
                                    <EditOutlined />
                                    <span>输入原文</span>
                                </span>
                            ),
                            children: renderInputTab()
                        },
                        ...(polishedText ? [
                            {
                                key: 'polished',
                                label: (
                                    <span className="flex items-center space-x-1">
                                        <EyeOutlined />
                                        <span>润色预览</span>
                                    </span>
                                ),
                                children: renderPolishedTab()
                            },
                            {
                                key: 'edit',
                                label: (
                                    <span className="flex items-center space-x-1">
                                        <StarOutlined />
                                        <span>编辑润色</span>
                                    </span>
                                ),
                                children: renderEditTab()
                            }
                        ] : [])
                    ]}
                />
            </div>
        </Modal>
    );
};

export default JDCreateModal;