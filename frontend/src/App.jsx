import { BrowserRouter as Router, Routes, Route, Link, useLocation } from 'react-router-dom';
import './App.css';

// 导入各个模块的页面组件
import EmployeeManagement from './pages/EmployeeManagement';
import ResumeLibrary from './pages/ResumeLibrary';
import DepartmentManagement from './pages/DepartmentManagement';
import JDManagement from './pages/JDManagement';
import OKRManagement from './pages/OKRManagement';
import HomePage from './pages/HomePage';

// 侧边栏菜单项组件
const SidebarItem = ({ to, icon, children }) => {
  const location = useLocation();
  const isActive = location.pathname === to;

  return (
    <li className="sidebar-menu-item">
      <Link to={to} className={`sidebar-menu-link ${isActive ? 'active' : ''}`}>
        <span className="sidebar-menu-icon">{icon}</span>
        <span>{children}</span>
      </Link>
    </li>
  );
};

// 侧边栏组件
const Sidebar = () => {
  return (
    <aside className="sidebar">
      <ul className="sidebar-menu">
        <SidebarItem to="/" icon="🏠">
          首页
        </SidebarItem>
        <SidebarItem to="/employees" icon="👥">
          员工管理
        </SidebarItem>
        <SidebarItem to="/resumes" icon="📄">
          简历库
        </SidebarItem>
        <SidebarItem to="/departments" icon="🏢">
          部门管理
        </SidebarItem>
        <SidebarItem to="/jd" icon="📝">
          JD管理
        </SidebarItem>
        <SidebarItem to="/okr" icon="🎯">
          OKR/KPI管理
        </SidebarItem>
      </ul>
    </aside>
  );
};

// 顶部导航栏组件
const AppBar = () => {
  return (
    <header className="appbar">
      <div className="appbar-title">
        <span>AI HR 管理系统</span>
      </div>
      <div className="appbar-actions">
        <div className="user-info">
          <span>管理员</span>
        </div>
      </div>
    </header>
  );
};

// 主应用组件
function App() {
  return (
    <Router>
      <div className="App">
        <AppBar />
        <Sidebar />
        <div className="main-content">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/employees" element={<EmployeeManagement />} />
            <Route path="/resumes" element={<ResumeLibrary />} />
            <Route path="/departments" element={<DepartmentManagement />} />
            <Route path="/jd" element={<JDManagement />} />
            <Route path="/okr" element={<OKRManagement />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;