# salary_report

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 增强版报告生成功能

本项目实现了增强版的工资报告生成功能，包括：

### 主要特性

1. **JSON数据转换器** - 将分析数据转换为结构化的JSON格式，便于存储和传输
2. **图表生成服务** - 从JSON数据生成图表图像
3. **增强版报告生成器** - 结合描述性文本和图表生成综合报告

### 核心组件

- `MonthlyAnalysisJsonConverter` - 月度分析数据转JSON工具类
- `ChartGenerationFromJsonService` - 从JSON数据生成图表的服务
- `EnhancedSalaryReportGenerator` - 增强版工资报告生成器

### 使用方法

1. 在月度分析页面中，系统会自动生成包含描述和图表的综合报告
2. 报告包含关键指标、部门统计、薪资区间分布等信息
3. 报告以DOCX格式保存，包含文本描述和对应的图表图像

### 新增功能

1. **图表数据生成方法** - MonthlyAnalysisJsonConverter中添加了多个生成图表数据集的方法：
   - `generateDepartmentChartDataSet()` - 生成部门统计图表数据
   - `generateSalaryRangeChartDataSet()` - 生成薪资区间图表数据
   - `generateTopEmployeesChartDataSet()` - 生成员工Top榜单图表数据
   - `generateAttendanceChartDataSet()` - 生成考勤统计图表数据
   - `generateDepartmentSalaryRangeChartDataSet()` - 生成部门薪资区间联合统计图表数据

2. **从JSON生成图表** - ChartGenerationFromJsonService可以从JSON数据直接生成图表图像

3. **增强版报告生成** - EnhancedSalaryReportGenerator结合了描述性文本和图表生成综合报告

### 文件结构

- `lib/src/utils/monthly_analysis_json_converter.dart` - JSON转换器
- `lib/src/services/*/chart_generation_from_json_service.dart` - 图表生成服务（按场景分类）
- `lib/src/services/*/docx_writer_service.dart` - DOCX报告写入服务（按场景分类）
- `lib/src/pages/visualization/report/enhanced_salary_report_generator.dart` - 增强版报告生成器
- `lib/src/pages/data_analysis/monthly/monthly_analysis_page.dart` - 月度分析页面（已集成增强功能）
- `example/json_to_chart_example.dart` - JSON到图表转换示例
- `example/enhanced_report_example.dart` - 增强版报告生成示例