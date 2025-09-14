# 数据可视化模块

## 模块结构

```
visualization/
├── chart/                 # 图表展示页面
│   └── chart_page.dart    # 图表展示主页面
├── report/                # 报告生成页面
│   ├── report_page.dart   # 报告生成页面
│   └── comprehensive_report_page.dart  # 综合可视化报告页面
└── README.md              # 本文件
```

## 功能说明

### 综合可视化报告 (Comprehensive Report)
- **路径**: `/visualization` (默认页面)
- **文件**: `comprehensive_report_page.dart`
- **功能**: 
  - 展示公司工资数据的综合分析
  - 包含各部门工资占比饼图
  - 月度工资趋势折线图
  - 各部门月度工资趋势图
  - 季度工资趋势图
  - 考勤统计表
  - 关键指标概览

### 图表展示 (Chart Display)
- **路径**: `/visualization/chart`
- **文件**: `chart_page.dart`
- **功能**: 
  - 简单的图表展示页面
  - 重定向到综合报告页面

### 报告生成 (Report Generation)
- **路径**: `/visualization/report`
- **文件**: `report_page.dart`
- **功能**: 
  - 报告生成页面
  - 重定向到综合报告页面

## 使用说明

1. 用户通过侧边栏"可视化展示"菜单项进入综合可视化报告页面
2. 页面会自动加载当前年份的数据并生成图表
3. 用户可以通过右上角的刷新按钮手动刷新数据
4. 如果没有数据，页面会显示提示信息，指导用户先上传工资表数据

## 数据来源

所有图表数据均来自Isar数据库中存储的工资表数据，通过`DataAnalysisService`服务进行聚合和分析。