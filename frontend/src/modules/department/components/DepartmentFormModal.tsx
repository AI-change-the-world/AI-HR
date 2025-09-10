import React from 'react';
import { Modal, Form, Input, Button } from 'antd';
import { Department, CreateDepartmentRequest } from '../types';

interface DepartmentFormModalProps {
    visible: boolean;
    onClose: () => void;
    onSubmit: (data: CreateDepartmentRequest) => void;
    initialData?: Department;
    loading?: boolean;
}

const DepartmentFormModal: React.FC<DepartmentFormModalProps> = ({
    visible,
    onClose,
    onSubmit,
    initialData,
    loading = false
}) => {
    const [form] = Form.useForm();

    const handleSubmit = async () => {
        try {
            const values = await form.validateFields();
            onSubmit(values);
        } catch (error) {
            console.error('表单验证失败:', error);
        }
    };

    return (
        <Modal
            title={initialData ? '编辑部门' : '添加部门'}
            open={visible}
            onCancel={onClose}
            footer={[
                <Button key="cancel" onClick={onClose}>
                    取消
                </Button>,
                <Button key="submit" type="primary" loading={loading} onClick={handleSubmit}>
                    {initialData ? '更新' : '创建'}
                </Button>
            ]}
        >
            <Form
                form={form}
                layout="vertical"
                initialValues={initialData}
            >
                <Form.Item
                    name="name"
                    label="部门名称"
                    rules={[{ required: true, message: '请输入部门名称' }]}
                >
                    <Input placeholder="请输入部门名称" />
                </Form.Item>

                <Form.Item
                    name="manager"
                    label="部门经理"
                    rules={[{ required: true, message: '请输入部门经理' }]}
                >
                    <Input placeholder="请输入部门经理" />
                </Form.Item>

                <Form.Item
                    name="description"
                    label="部门描述"
                    rules={[{ required: true, message: '请输入部门描述' }]}
                >
                    <Input.TextArea rows={4} placeholder="请输入部门描述" />
                </Form.Item>
            </Form>
        </Modal>
    );
};

export default DepartmentFormModal;