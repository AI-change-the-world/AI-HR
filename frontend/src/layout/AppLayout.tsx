import { Layout, Menu } from 'antd';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import defaultThumbnail from "../assets/react.svg";
import { AppstoreOutlined, ClusterOutlined, DashboardOutlined, MonitorOutlined, PythonOutlined } from '@ant-design/icons';

const { Header, Sider, Content } = Layout;

export default function AppLayout() {
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
                <div>
                    <span style={{ fontWeight: 'bold', fontSize: '20px', color: '#0d47a1' }}>AI人事干人事</span>
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
                        }}
                    >
                        <Outlet />
                    </div>
                </Content>
            </Layout>
        </Layout>
    );
}