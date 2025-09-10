import { createBrowserRouter } from 'react-router-dom';
import AppLayout from '../layout/AppLayout';
import HomePage from '../pages/HomePage';
import EmployeeManagement from '../pages/EmployeeManagement';
import DepartmentManagement from '../pages/DepartmentManagement';
import ResumeLibrary from '../pages/ResumeLibrary';
import JDManagement from '../pages/JDManagement';
import OKRManagement from '../pages/OKRManagement';
import Error from '../pages/Error';


export const router = createBrowserRouter([

    {
        element: <AppLayout />,
        children: [
            { index: true, element: <HomePage /> },  // 默认路由，匹配 "/"
            { path: '/dashboard', element: <HomePage /> },
            { path: '/employee-management', element: <EmployeeManagement /> },
            { path: '/department-management', element: <DepartmentManagement /> },
            { path: '/resume-management', element: <ResumeLibrary /> },
            { path: '/jd-management', element: <JDManagement /> },
            { path: '/okr', element: <OKRManagement /> },
        ],
    },
    { path: '*', element: <Error /> },
]);