import { Layout, Menu } from 'antd';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import defaultThumbnail from "../assets/react.svg";
import { AppstoreOutlined, ClusterOutlined, DashboardOutlined, MonitorOutlined, PythonOutlined } from '@ant-design/icons';

const { Header, Sider, Content } = Layout;

export default function AppLayout() {

    const appbarHeight = '40px';


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
                    background: '#fff',
                    padding: '0 16px',
                    height: appbarHeight,
                    lineHeight: appbarHeight,
                    fontSize: '20px',
                    display: 'flex',         // 使用 flex 布局
                    alignItems: 'center',    // 垂直居中
                }}
            >
                <img
                    src={defaultThumbnail}  // 图片路径，可以是本地 public 文件夹下的路径或网络图片
                    alt="Logo"
                    style={{ height: '20px', marginRight: '8px' }} // 高度控制，右边留点空隙
                />
                <div>
                    <span style={{ fontWeight: 'bold' }}>AI人事干人事</span>
                </div>
            </Header>
            <Layout>
                <Sider
                    width={200}
                    style={{
                        background: '#fff',
                        height: 'calc(100vh -' + appbarHeight + ')', // 减去 Header 高度
                        position: 'sticky',           // 侧边固定
                        top: 30,                       // 从 Header 底部开始
                        overflowY: 'auto',            // 超出显示滚动条
                    }}
                >
                    <Menu
                        mode="inline"
                        // defaultSelectedKeys={['org']}
                        selectedKeys={[getSelectedKey()]}
                        style={{ height: '100%' }}
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
                        background: '#f5f5f5',
                        padding: 16,
                        flex: 1,
                        height: 'calc(100vh -' + appbarHeight + ')',
                        overflowY: 'auto',          // 内容独立滚动
                    }}
                >
                    <Outlet />
                </Content>
            </Layout>
        </Layout>

    );
}