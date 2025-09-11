import React, { useState, useEffect } from 'react';
import { Modal, Form, Input, Button, message, Tabs, Space, Spin } from 'antd';
import { JobDescription, JDFullInfoUpdate } from '../types';
import { getJDFullInfo, updateJDFullInfo, extractJDKeywords } from '../api';

const { TextArea } = Input;

interface JDFullInfoModalProps {
    visible: boolean;
    jd: JobDescription | null;
    onCancel: () => void;
    onSuccess: (updatedJD: JobDescription) => void;
}

const JDFullInfoModal: React.FC<JDFullInfoModalProps> = ({
    visible,
    jd,
    onCancel,
    onSuccess
}) => {
    const [form] = Form.useForm();
    const [loading, setLoading] = useState(false);
    const [extracting, setExtracting] = useState(false);

    useEffect(() => {
        if (visible && jd) {
            loadJDFullInfo();
        }
    }, [visible, jd]);

    const loadJDFullInfo = async () => {
        if (!jd) return;

        try {
            setLoading(true);
            const data = await getJDFullInfo(jd.id);
            form.setFieldsValue({
                full_text: data.full_text || '',
                evaluation_criteria: data.evaluation_criteria ? JSON.stringify(data.evaluation_criteria, null, 2) : ''
            });
        } catch (error) {
            message.error('加载JD完整信息失败');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async () => {
        try {
            const values = await form.validateFields();
            setLoading(true);

            let evaluationCriteria;
            if (values.evaluation_criteria?.trim()) {
                try {
                    evaluationCriteria = JSON.parse(values.evaluation_criteria);
                } catch (error) {
                    message.error('评价标准格式不正确，请输入有效的JSON格式');
                    return;
                }
            }

            const updateData: JDFullInfoUpdate = {
                full_text: values.full_text,
                evaluation_criteria: evaluationCriteria
            };

            const updatedJD = await updateJDFullInfo(jd!.id, updateData);
            message.success('JD完整信息更新成功');
            onSuccess(updatedJD);
        } catch (error) {
            message.error('更新失败');
        } finally {
            setLoading(false);
        }
    };

    const handleExtractKeywords = async () => {
        try {
            const values = await form.validateFields(['full_text']);
            if (!values.full_text?.trim()) {
                message.warning('请先填写完整职位描述');
                return;
            }

            setExtracting(true);
            const updatedJD = await extractJDKeywords(jd!.id, values.full_text);
            message.success('关键字提取成功，JD字段已更新');
            onSuccess(updatedJD);
        } catch (error) {
            console.error('Extract keywords error:', error);
            message.error('提取关键字失败');
        } finally {
            setExtracting(false);
        }
    };

    // const exampleCriteria = {
    //     "学历": { "本科": 5, "研究生": 10, "博士及以上": 20 },
    //     "技能": { "Python": 10, "SQL": 5, "Java": 8, "JavaScript": 8 },
    //     "年限": { ">=3年": 10, "<3年": 5, "<1年": 0 },
    //     "真实性": { "AI生成嫌疑": -10, "具体案例丰富": 10 }
    // };
    const exampleCriteria = `简历打分标准
一、学历要求
  本科：5 分
  研究生：10 分
  博士及以上：20 分
二、技能要求
  Python：10 分
  SQL：5 分
  Java：8 分
  JavaScript：8 分
三、工作年限
  三年及以上：10 分
  不足三年：5 分
  不足一年：0 分
四、内容真实性
  存在 AI 生成嫌疑：扣 10 分
五、项目多样性
  具体案例丰富，技术多样且合理：加 10 分
六、总分说明
  本评分体系总分不设上限，候选人得分由学历、技能、年限、内容真实性以及项目多样性五个维度累计计算，若出现扣分情况，则按相应标准从总分中减去。
七、评级标准
  优秀：40 分及以上
  良好：30–39 分
  合格：20–29 分
  不合格：20 分以下`;

    const insertExample = () => {
        form.setFieldValue('evaluation_criteria', exampleCriteria);
    };

    const items = [
        {
            key: 'full_text',
            label: 'JD完整信息',
            children: (
                <div>
                    <Form.Item
                        name="full_text"
                        label="完整职位描述"
                        extra="填写详细的职位描述，这将用于AI评估时的参考。如果填写了此字段，系统将优先使用此内容而不是结构化的职位信息。"
                    >
                        <TextArea
                            rows={12}
                            placeholder="请输入完整的职位描述信息..."
                        />
                    </Form.Item>
                    <Space>
                        <Button
                            type="primary"
                            onClick={handleExtractKeywords}
                            loading={extracting}
                        >
                            提取关键字更新JD字段
                        </Button>
                        <span className="text-gray-500 text-sm">
                            使用AI从完整描述中提取并更新职位名称、部门、地点等结构化字段
                        </span>
                    </Space>
                </div>
            ),
        },
        {
            key: 'criteria',
            label: '评价标准',
            children: (
                <div>
                    <div style={{ marginBottom: 16 }}>
                        <Button type="link" onClick={insertExample}>
                            插入示例评价标准
                        </Button>
                        <span style={{ color: '#666', fontSize: '12px', marginLeft: 8 }}>
                            (点击可插入默认的评价标准模板)
                        </span>
                    </div>
                    <Form.Item
                        name="evaluation_criteria"
                        label="评价标准"
                        extra="定义简历评估的评分标准，支持多维度评估"
                    >
                        <TextArea
                            rows={12}
                            placeholder="请输入JSON格式的评价标准..."
                        />
                    </Form.Item>
                </div>
            ),
        },
    ];

    return (
        <Modal
            title={`编辑JD完整信息 - ${jd?.title || ''}`}
            open={visible}
            onCancel={onCancel}
            onOk={handleSubmit}
            confirmLoading={loading}
            width={800}
            destroyOnHidden
        >
            <Spin spinning={loading}>
                <Form form={form} layout="vertical">
                    <Tabs items={items} />
                </Form>
            </Spin>
        </Modal>
    );
};

export default JDFullInfoModal;