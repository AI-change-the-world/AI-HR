import React, { useState } from 'react';
import { Button, Upload, message, Card, Spin, Typography, Modal, Progress, Collapse, Badge, Space } from 'antd';
import { UploadOutlined, CheckCircleOutlined, ClockCircleOutlined, PlayCircleOutlined } from '@ant-design/icons';
import type { UploadProps } from 'antd/es/upload/interface';
import { evaluateResumeStream } from '../api';
import { EvaluationStep } from '../types';

const { Title, Text, Paragraph } = Typography;
const { Panel } = Collapse;

interface ResumeEvaluatorProps {
    jdId: number;
    jdTitle: string;
    onCancel: () => void;
    onEvaluate: () => void;
}

interface TaskState {
    id: number;
    title: string;
    description?: string;
    status: 'pending' | 'running' | 'completed' | 'error';
    result?: EvaluationStep;
    startTime?: number;
    endTime?: number;
}

const ResumeEvaluator: React.FC<ResumeEvaluatorProps> = ({ jdId, jdTitle, onCancel, onEvaluate }) => {
    const [file, setFile] = useState<File | null>(null);
    const [evaluating, setEvaluating] = useState(false);
    const [tasks, setTasks] = useState<TaskState[]>([]);
    const [currentTaskId, setCurrentTaskId] = useState<number | null>(null);
    const [overallProgress, setOverallProgress] = useState(0);
    const [activeKey, setActiveKey] = useState<string | string[]>([]);

    const handleFileUpload: UploadProps['beforeUpload'] = (file) => {
        const isPDF = file.type === 'application/pdf' || file.name.endsWith('.pdf');
        const isDOC = file.type === 'application/msword' ||
            file.type === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
            file.name.endsWith('.doc') || file.name.endsWith('.docx');
        const isTXT = file.type === 'text/plain' || file.name.endsWith('.txt');

        if (!isPDF && !isDOC && !isTXT) {
            message.error('只能上传 PDF、DOC/DOCX 或 TXT 文件!');
            return false;
        }

        setFile(file);
        return false;
    };

    const handleEvaluate = async () => {
        if (!file) {
            message.error('请先选择简历文件');
            return;
        }

        setEvaluating(true);
        setTasks([]);
        setCurrentTaskId(null);
        setOverallProgress(0);
        setActiveKey([]);

        try {
            await evaluateResumeStream(
                jdId,
                file,
                (step: EvaluationStep) => {
                    if (step.step === 0 && step.steps) {
                        // 初始化任务列表
                        const initialTasks: TaskState[] = step.steps.map((s, index) => ({
                            id: index + 1,
                            title: s.name,
                            description: s.desc,
                            status: 'pending'
                        }));
                        setTasks(initialTasks);
                    } else if (step.step > 0) {
                        // 更新任务状态
                        setTasks(prev => prev.map(task => {
                            if (task.id === step.step) {
                                return {
                                    ...task,
                                    status: step.score !== undefined ? 'completed' : 'running',
                                    result: step,
                                    startTime: task.startTime || Date.now(),
                                    endTime: step.score !== undefined ? Date.now() : undefined
                                };
                            } else if (task.id < step.step) {
                                return { ...task, status: 'completed' };
                            }
                            return task;
                        }));

                        setCurrentTaskId(step.step);
                        setOverallProgress((step.step / (tasks.length || 1)) * 100);

                        // 自动展开当前正在执行的任务
                        if (step.score !== undefined) {
                            setActiveKey(prev => [...(Array.isArray(prev) ? prev : [prev]), step.step.toString()]);
                        }
                    }
                },
                (error: string) => {
                    message.error(`评估出错: ${error}`);
                    if (currentTaskId) {
                        setTasks(prev => prev.map(task =>
                            task.id === currentTaskId ? { ...task, status: 'error' } : task
                        ));
                    }
                }
            );

            setTasks(prev => prev.map(task => ({ ...task, status: 'completed' })));
            setOverallProgress(100);
            message.success('评估完成');
            onEvaluate();
        } catch (error) {
            message.error('评估失败');
        } finally {
            setEvaluating(false);
            setCurrentTaskId(null);
        }
    };

    const getTaskIcon = (status: TaskState['status']) => {
        switch (status) {
            case 'completed':
                return <CheckCircleOutlined className="text-green-500" />;
            case 'running':
                return <Spin size="small" />;
            case 'error':
                return <ClockCircleOutlined className="text-red-500" />;
            default:
                return <PlayCircleOutlined className="text-gray-400" />;
        }
    };

    const getTaskBadgeStatus = (status: TaskState['status']): 'success' | 'processing' | 'error' | 'default' => {
        switch (status) {
            case 'completed': return 'success';
            case 'running': return 'processing';
            case 'error': return 'error';
            default: return 'default';
        }
    };

    const formatDuration = (startTime?: number, endTime?: number) => {
        if (!startTime) return '';
        const duration = (endTime || Date.now()) - startTime;
        return `${(duration / 1000).toFixed(1)}s`;
    };

    const getTotalScore = () => {
        return tasks
            .filter(task => task.result?.score !== undefined && typeof task.result.score === 'number')
            .reduce((sum, task) => sum + (task.result?.score || 0), 0);
    };

    return (
        <Modal
            title={
                <div className="flex items-center space-x-3">
                    <div className="w-1 h-6 bg-blue-500 rounded-full"></div>
                    <div>
                        <div className="text-lg font-semibold text-gray-800">简历智能评估</div>
                        <div className="text-sm text-gray-500">{jdTitle}</div>
                    </div>
                </div>
            }
            open={true}
            onCancel={onCancel}
            footer={null}
            width={900}
            className="resume-evaluator-modal"
            styles={{
                body: { maxHeight: '70vh', overflowY: 'auto', padding: '24px' },
                header: { borderBottom: '1px solid #f0f0f0', paddingBottom: '16px' }
            }}
        >
            <div className="space-y-6">
                {/* 文件上传区域 */}
                <Card className="border-dashed border-2 border-blue-200 bg-blue-50/30 hover:border-blue-300 transition-colors">
                    <div className="text-center py-6">
                        <Upload
                            beforeUpload={handleFileUpload}
                            fileList={file ? [{
                                uid: '1',
                                name: file.name,
                                status: 'done',
                                size: file.size,
                                type: file.type
                            }] : []}
                            onRemove={() => {
                                setFile(null);
                                return true;
                            }}
                            maxCount={1}
                            showUploadList={{ showRemoveIcon: true }}
                        >
                            <Button
                                icon={<UploadOutlined />}
                                size="large"
                                className="border-blue-300 text-blue-600 hover:border-blue-400 hover:text-blue-700"
                            >
                                选择简历文件
                            </Button>
                        </Upload>
                        <Text type="secondary" className="text-sm mt-2 block">
                            支持 PDF、DOC/DOCX 和 TXT 格式，文件大小不超过 10MB
                        </Text>
                    </div>
                </Card>

                {/* 操作按钮 */}
                <div className="flex justify-center">
                    <Button
                        type="primary"
                        size="large"
                        onClick={handleEvaluate}
                        loading={evaluating}
                        disabled={!file}
                        className="bg-gradient-to-r from-blue-500 to-blue-600 border-none shadow-lg hover:shadow-xl transition-all duration-300 px-8 h-12 text-base font-medium"
                    >
                        {evaluating ? '正在评估...' : '开始智能评估'}
                    </Button>
                </div>

                {/* 整体进度 */}
                {evaluating && tasks.length > 0 && (
                    <Card className="bg-gradient-to-r from-blue-50 to-indigo-50 border-blue-100">
                        <div className="flex items-center justify-between mb-3">
                            <Title level={5} className="text-blue-800 mb-0">评估进度</Title>
                            <Text className="text-blue-600 font-medium">
                                {tasks.filter(t => t.status === 'completed').length}/{tasks.length} 已完成
                            </Text>
                        </div>
                        <Progress
                            percent={Math.round(overallProgress)}
                            strokeColor={{
                                '0%': '#3b82f6',
                                '100%': '#10b981',
                            }}
                            trailColor="#e5e7eb"
                            strokeWidth={8}
                            format={(percent) => `${percent}%`}
                        />
                    </Card>
                )}

                {/* 任务列表 */}
                {tasks.length > 0 && (
                    <Card className="bg-white shadow-sm">
                        <div className="flex items-center justify-between mb-4">
                            <Title level={5} className="text-gray-800 mb-0">评估任务</Title>
                            {tasks.some(t => t.result?.score !== undefined) && (
                                <Badge
                                    count={`总分: ${getTotalScore()}`}
                                    className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full font-medium"
                                />
                            )}
                        </div>

                        <Collapse
                            activeKey={activeKey}
                            onChange={setActiveKey}
                            className="task-collapse"
                            ghost
                        >
                            {tasks.map((task) => (
                                <Panel
                                    key={task.id}
                                    header={
                                        <div className="flex items-center justify-between w-full pr-4">
                                            <div className="flex items-center space-x-3">
                                                {getTaskIcon(task.status)}
                                                <div className={`transition-colors duration-200 ${task.status === 'completed'
                                                    ? 'text-gray-600'
                                                    : task.status === 'running'
                                                        ? 'text-blue-600 font-medium'
                                                        : 'text-gray-400'
                                                    }`}>
                                                    <div className="font-medium">{task.title}</div>
                                                    {task.description && (
                                                        <div className="text-sm text-gray-500 mt-1">
                                                            {task.description}
                                                        </div>
                                                    )}
                                                </div>
                                            </div>
                                            <div className="flex items-center space-x-2">
                                                {task.result?.score !== undefined && (
                                                    <Badge
                                                        count={`${task.result.score}分`}
                                                        status={getTaskBadgeStatus(task.status)}
                                                        className="text-xs"
                                                    />
                                                )}
                                                {task.startTime && (
                                                    <Text type="secondary" className="text-xs">
                                                        {formatDuration(task.startTime, task.endTime)}
                                                    </Text>
                                                )}
                                            </div>
                                        </div>
                                    }
                                    className={`task-panel transition-all duration-200 ${task.status === 'completed' ? 'task-completed' : ''
                                        }`}
                                >
                                    {task.result && (
                                        <div className="pl-8 pb-4">
                                            <div className="bg-gray-50 rounded-lg p-4 border-l-4 border-blue-500">
                                                {task.result.reason && (
                                                    <Paragraph className="mb-2 text-gray-700">
                                                        <Text strong>评估结果: </Text>
                                                        {task.result.reason}
                                                    </Paragraph>
                                                )}
                                                {task.result.score !== undefined && (
                                                    <div className="flex items-center space-x-4 mt-3">
                                                        <Badge
                                                            count={`得分: ${task.result.score}`}
                                                            className="bg-blue-500 text-white px-3 py-1 rounded-full font-medium"
                                                        />
                                                        <Text type="secondary" className="text-sm">
                                                            评估完成时间: {task.endTime ? new Date(task.endTime).toLocaleTimeString() : '--'}
                                                        </Text>
                                                    </div>
                                                )}
                                            </div>
                                        </div>
                                    )}
                                </Panel>
                            ))}
                        </Collapse>
                    </Card>
                )}

                {/* 评估完成总结 */}
                {!evaluating && tasks.length > 0 && tasks.every(t => t.status === 'completed') && (
                    <Card className="bg-gradient-to-r from-green-50 to-blue-50 border-green-200">
                        <div className="text-center py-4">
                            <CheckCircleOutlined className="text-green-500 text-3xl mb-2" />
                            <Title level={4} className="text-green-700 mb-2">评估完成</Title>
                            <Space direction="vertical" className="text-center">
                                <Text className="text-lg">
                                    <Text strong>总体匹配度: </Text>
                                    <Text className="text-green-600 font-bold text-xl">{getTotalScore()}分</Text>
                                </Text>
                                <Text type="secondary">
                                    评估完成时间: {new Date().toLocaleString()}
                                </Text>
                            </Space>
                        </div>
                    </Card>
                )}
            </div>

        </Modal>
    );
};

export default ResumeEvaluator;