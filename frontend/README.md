# 前端模块化结构说明

## 目录结构

```
src/
├── modules/                    # 功能模块目录
│   ├── department/            # 部门管理模块
│   │   ├── api/              # API接口
│   │   │   └── index.ts
│   │   ├── components/       # 组件
│   │   │   ├── index.ts
│   │   │   └── DepartmentFormModal.tsx
│   │   ├── pages/           # 页面
│   │   │   └── DepartmentManagement.tsx
│   │   ├── types/           # 类型定义
│   │   │   └── index.ts
│   │   └── index.ts         # 模块入口
│   ├── employee/            # 员工管理模块
│   ├── jd/                  # JD管理模块
│   ├── okr/                 # OKR管理模块
│   ├── resume/              # 简历库模块
│   └── common/              # 通用模块（首页、错误页等）
├── layout/                  # 布局组件
├── router/                  # 路由配置
└── ...
```

## 模块结构说明

每个功能模块都包含以下子目录：

### `api/`
- 包含该模块相关的所有API调用函数
- 统一的错误处理
- 类型安全的接口定义

### `components/`
- 该模块专用的组件
- 可复用的UI组件
- 表单、弹窗、卡片等

### `pages/`
- 该模块的页面组件
- 路由对应的顶级组件

### `types/`
- 该模块的TypeScript类型定义
- 数据模型接口
- API请求/响应类型

### `index.ts`
- 模块的统一导出入口
- 便于其他模块引用

## 使用方式

### 1. 引用模块内容
```typescript
// 引用整个模块
import { Department, getDepartments, DepartmentManagement } from '@/modules/department';

// 或者引用特定内容
import { Department } from '@/modules/department/types';
import { getDepartments } from '@/modules/department/api';
```

### 2. 添加新组件
在对应模块的 `components/` 目录下添加新组件，并在 `components/index.ts` 中导出。

### 3. 添加新API
在对应模块的 `api/` 目录下添加新的API函数，遵循现有的模式。

### 4. 添加新类型
在对应模块的 `types/` 目录下添加新的类型定义。

## 优势

1. **模块化**: 每个功能模块独立，便于维护和开发
2. **类型安全**: 完整的TypeScript类型定义
3. **代码复用**: 组件和API可以在模块内复用
4. **清晰结构**: 代码组织清晰，易于理解和导航
5. **团队协作**: 不同开发者可以专注于不同模块，减少冲突

## 开发规范

1. 每个模块应该保持相对独立
2. 跨模块的通用功能应该放在 `common/` 目录下
3. 遵循统一的命名规范
4. 保持API接口的一致性
5. 及时更新类型定义