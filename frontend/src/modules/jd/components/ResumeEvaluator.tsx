import React, { useState } from 'react';
import { Button, Upload, message, Card, Spin, List, Typography, Modal } from 'antd';
import { UploadOutlined, FilePdfOutlined, FileTextOutlined } from '@ant-design/icons';
import type { UploadProps } from 'antd/es/upload/interface';
import { evaluateResume, getJDEvaluationCriteria } from '../api';
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

        try {
            // 获取该JD的评估标准
            const criteria = await getJDEvaluationCriteria(jdId);

            // 调用后端API进行评估
            const results = await evaluateResume(jdId, file, criteria);
            setEvaluationResults(results);
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
                    <div className="flex flex-col items-center justify-center py-8">
                        <Spin size="large" />
                        <Text className="mt-4 text-gray-600">正在分析简历与职位匹配度...</Text>
                    </div>
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
                                        title={
                                            <div className="flex items-center">
                                                <span className="font-medium text-gray-800">{item.name}</span>
                                                {item.score !== undefined && (
                                                    <span className="ml-3 bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-sm font-medium">
                                                        得分: {item.score}
                                                    </span>
                                                )}
                                            </div>
                                        }
                                        description={
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
                                        }
                                    />
                                </List.Item>
                            )}
                        />
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
                    </Card>
                )}
            </div>
        </Modal>
    );
};

export default ResumeEvaluator;