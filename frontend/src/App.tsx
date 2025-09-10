// import { BrowserRouter as Router, Routes, Route, Link, useLocation } from 'react-router-dom';
// import { useState, useEffect } from 'react';
// import './App.css';

// // 导入各个模块的页面组件
// import EmployeeManagement from './pages/EmployeeManagement';
// import ResumeLibrary from './pages/ResumeLibrary';
// import DepartmentManagement from './pages/DepartmentManagement';
// import JDManagement from './pages/JDManagement';
// import OKRManagement from './pages/OKRManagement';
// import HomePage from './pages/HomePage';

// // 侧边栏菜单项组件
// interface SidebarItemProps {
//   to: string;
//   icon: string;
//   children: React.ReactNode;
// }

// const SidebarItem = ({ to, icon, children }: SidebarItemProps) => {
//   const location = useLocation();
//   const isActive = location.pathname === to;

//   return (
//     <li className="sidebar-menu-item">
//       <Link to={to} className={`sidebar-menu-link ${isActive ? 'active' : ''}`}>
//         <span className="sidebar-menu-icon">{icon}</span>
//         <span>{children}</span>
//       </Link>
//     </li>
//   );
// };

// // 侧边栏组件
// const Sidebar = () => {
//   return (
//     <aside className="sidebar">
//       <ul className="sidebar-menu">
//         <SidebarItem to="/" icon="🏠">
//           首页
//         </SidebarItem>
//         <SidebarItem to="/employees" icon="👥">
//           员工管理
//         </SidebarItem>
//         <SidebarItem to="/resumes" icon="📄">
//           简历库
//         </SidebarItem>
//         <SidebarItem to="/departments" icon="🏢">
//           部门管理
//         </SidebarItem>
//         <SidebarItem to="/jd" icon="📝">
//           JD管理
//         </SidebarItem>
//         <SidebarItem to="/okr" icon="🎯">
//           OKR/KPI管理
//         </SidebarItem>
//       </ul>
//     </aside>
//   );
// };

// // 顶部导航栏组件
// const AppBar = () => {
//   return (
//     <header className="appbar">
//       <div className="appbar-title">
//         <span>AI人事干人事</span>
//       </div>
//       <div className="appbar-actions">
//         <div className="user-info">
//           <span>演示账户</span>
//         </div>
//       </div>
//     </header>
//   );
// };

// // AI问答抽屉组件
// const AIChatDrawer = ({ isOpen, onClose }: { isOpen: boolean; onClose: () => void }) => {
//   return (
//     <div className={`ai-chat-drawer ${isOpen ? 'open' : ''}`}>
//       <div className="drawer-header">
//         <h3>AI助手</h3>
//         <button className="close-btn" onClick={onClose}>×</button>
//       </div>
//       <div className="drawer-content">
//         <div className="chat-messages">
//           <div className="message ai-message">
//             您好！我是AI人事助手，有什么可以帮助您的吗？
//           </div>
//         </div>
//         <div className="chat-input">
//           <input type="text" placeholder="请输入您的问题..." />
//           <button className="btn btn-primary">发送</button>
//         </div>
//       </div>
//     </div>
//   );
// };

// // 主应用组件
// function App() {
//   const [isChatOpen, setIsChatOpen] = useState(false);

//   return (
//     <Router>
//       <div className="App">
//         <AppBar />
//         <Sidebar />
//         <div className="main-content">
//           <Routes>
//             <Route path="/" element={<HomePage />} />
//             <Route path="/employees" element={<EmployeeManagement />} />
//             <Route path="/resumes" element={<ResumeLibrary />} />
//             <Route path="/departments" element={<DepartmentManagement />} />
//             <Route path="/jd" element={<JDManagement />} />
//             <Route path="/okr" element={<OKRManagement />} />
//           </Routes>
//         </div>
//         {/* 全局AI助手按钮 */}
//         <button className="ai-assistant-button" onClick={() => setIsChatOpen(true)}>
//           AI助手
//         </button>
//         {/* AI问答抽屉 */}
//         <AIChatDrawer isOpen={isChatOpen} onClose={() => setIsChatOpen(false)} />
//       </div>
//     </Router>
//   );
// }

import { RouterProvider } from "react-router-dom";
import { router } from "./router";
import { ToastContainer } from "react-toastify";

export default function App() {
  return (
    <>
      <RouterProvider router={router} />
      <ToastContainer />
    </>
  );
}
