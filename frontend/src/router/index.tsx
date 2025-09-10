import { createBrowserRouter } from 'react-router-dom';
import AppLayout from '../layout/AppLayout';
import HomePage from '../modules/common/pages/HomePage';
import EmployeeManagement from '../modules/employee/pages/EmployeeManagement';
import DepartmentManagement from '../modules/department/pages/DepartmentManagement';
import ResumeLibrary from '../modules/resume/pages/ResumeLibrary';
import JDManagement from '../modules/jd/pages/JDManagement';
import OKRManagement from '../modules/okr/pages/OKRManagement';
import Error from '../modules/common/pages/Error';


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