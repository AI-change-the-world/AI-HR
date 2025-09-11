import React, { useState } from 'react';
import { Button, Upload, message, Card, Spin, List, Typography, Modal, Progress } from 'antd';
import { UploadOutlined } from '@ant-design/icons';
import type { UploadProps } from 'antd/es/upload/interface';
import { evaluateResumeStream } from '../api';
import { EvaluationStep } from '../types';
const { Title, Text } = Typography;

interface ResumeEvaluatorProps {
    jdId: number;
    jdTitle: string;
    onCancel: () => void;
    onEvaluate: () => void;
}

const ResumeEvaluator: React.FC<ResumeEvaluatorProps> = ({ jdId, jdTitle, onCancel, onEvaluate }) => {
    const [file, setFile] = useState<File | null>(null);
    const [uploading, setUploading] = useState(false);
    const [evaluationResults, setEvaluationResults] = useState<EvaluationStep[]>([]);
    const [evaluating, setEvaluating] = useState(false);
    const [currentStep, setCurrentStep] = useState<string>('');
    const [progress, setProgress] = useState<number>(0);
    const [totalSteps, setTotalSteps] = useState<number>(0);

    const props: UploadProps = {
        beforeUpload: (file) => {
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
        },
        fileList: file ? [{ uid: '1', name: file.name, status: 'done', size: file.size, type: file.type }] : [],
        onRemove: () => {
            setFile(null);
            return true;
        },
        maxCount: 1,
    };

    const handleEvaluate = async () => {
        if (!file) {
            message.error('请先选择简历文件');
            return;
        }

        setUploading(true);
        setEvaluating(true);
        setEvaluationResults([]);
        setCurrentStep('正在初始化评估...');
        setProgress(0);
        setTotalSteps(0);

        try {
            // 使用流式接口进行评估
            const results = await evaluateResumeStream(
                jdId,
                file,
                // 实时进度回调
                (step: EvaluationStep) => {
                    console.log('收到流式数据:', step);

                    if (step.step === 0 && step.steps) {
                        // 第一步：任务拆解
                        setTotalSteps(step.steps.length + 1); // +1 for the task breakdown step
                        setCurrentStep('任务拆解完成');
                        setProgress(1);
                    } else {
                        // 后续步骤：具体评估
                        setCurrentStep(`正在执行: ${step.name}`);
                        if (totalSteps > 0) {
                            setProgress(step.step + 1);
                        }
                    }

                    // 实时更新结果列表
                    setEvaluationResults(prev => {
                        const existing = prev.find(r => r.step === step.step);
                        if (existing) {
                            return prev.map(r => r.step === step.step ? step : r);
                        } else {
                            return [...prev, step];
                        }
                    });
                },
                // 错误回调
                (error: string) => {
                    message.error(`评估出错: ${error}`);
                }
            );

            setCurrentStep('评估完成');
            message.success('评估完成');
            onEvaluate();
        } catch (error) {
            console.error('评估失败:', error);
            message.error(`评估失败：${error instanceof Error ? error.message : '请重试'}`);
        } finally {
            setUploading(false);
            setEvaluating(false);
        }
    };

    const getIconForStep = (step: number) => {
        if (step === 0) return '📋';
        if (step <= 3) return '🔍';
        return '📊';
    };

    return (
        <Modal
            title={`评估简历 - ${jdTitle}`}
            open={true}
            onCancel={onCancel}
            footer={null}
            width={800}
        >
            <div className="space-y-6">
                <Card className="bg-gradient-to-br from-blue-50 to-indigo-50 border-blue-100">
                    <Title level={5} className="text-blue-800">上传简历</Title>
                    <Upload {...props} className="mb-4">
                        <Button icon={<UploadOutlined />}>选择简历文件</Button>
                    </Upload>
                    <Text type="secondary" className="text-sm">
                        支持 PDF、DOC/DOCX 和 TXT 格式
                    </Text>
                </Card>

                <div className="flex justify-center">
                    <Button
                        type="primary"
                        size="large"
                        onClick={handleEvaluate}
                        loading={uploading || evaluating}
                        disabled={!file || uploading || evaluating}
                        className="bg-gradient-to-r from-blue-500 to-indigo-600 border-none shadow-lg hover:shadow-xl transition-all duration-300 px-8"
                    >
                        {evaluating ? '评估中...' : '开始评估'}
                    </Button>
                </div>

                {evaluating && (
                    <Card className="bg-gradient-to-br from-blue-50 to-indigo-50 border-blue-100">
                        <div className="flex flex-col items-center justify-center py-6">
                            <Spin size="large" />
                            <Text className="mt-4 text-gray-600 text-center">{currentStep}</Text>
                            {totalSteps > 0 && (
                                <div className="w-full max-w-md mt-4">
                                    <Progress
                                        percent={Math.round((progress / totalSteps) * 100)}
                                        format={(percent) => `${progress}/${totalSteps} 步骤`}
                                        strokeColor={{
                                            '0%': '#1890ff',
                                            '100%': '#52c41a',
                                        }}
                                    />
                                </div>
                            )}
                        </div>
                    </Card>
                )}

                {evaluationResults.length > 0 && (
                    <Card className="bg-white border-gray-200 shadow-sm">
                        <Title level={5} className="text-gray-800 border-b pb-2 mb-4">评估结果</Title>
                        <List
                            dataSource={evaluationResults}
                            renderItem={(item) => (
                                <List.Item className="py-3 border-b border-gray-100">
                                    <List.Item.Meta
                                        avatar={
                                            <div className="text-2xl">
                                                {getIconForStep(item.step)}
                                            </div>
                                        }
                                        title={(
                                            <div className="flex items-center justify-between">
                                                <span className="font-medium text-gray-800">{item.name}</span>
                                                <div className="flex items-center space-x-2">
                                                    {evaluating && !item.score && item.step > 0 && (
                                                        <Spin size="small" />
                                                    )}
                                                    {item.score !== undefined && (
                                                        <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-sm font-medium">
                                                            得分: {item.score}
                                                        </span>
                                                    )}
                                                </div>
                                            </div>
                                        )}
                                        description={(
                                            <div className="mt-1">
                                                {item.reason && <Text>{item.reason}</Text>}
                                                {item.steps && (
                                                    <div className="mt-2">
                                                        <Text strong>评估步骤:</Text>
                                                        <List
                                                            size="small"
                                                            dataSource={item.steps}
                                                            renderItem={(step) => (
                                                                <List.Item className="py-1 border-none">
                                                                    <Text type="secondary">• {step.name}: {step.desc}</Text>
                                                                </List.Item>
                                                            )}
                                                        />
                                                    </div>
                                                )}
                                            </div>
                                        )}
                                    />
                                </List.Item>
                            )}
                        />
                        {evaluationResults.filter(r => r.score !== undefined).length > 0 && (
                            <div className="mt-4 pt-4 border-t border-gray-200">
                                <Text strong className="text-lg">
                                    总体匹配度:{" "}
                                    <span className="text-blue-600">
                                        {evaluationResults
                                            .filter(r => r.score !== undefined)
                                            .reduce((sum, r) => sum + (r.score || 0), 0)}分
                                    </span>
                                </Text>
                            </div>
                        )}
                    </Card>
                )}
            </div>
        </Modal>
    );
};

export default ResumeEvaluator;