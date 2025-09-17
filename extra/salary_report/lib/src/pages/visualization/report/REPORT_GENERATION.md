# 报告生成功能说明

## 功能概述

报告生成功能支持生成四种不同类型的薪资分析报告：单月报告、多月报告、季度报告和年度报告。每种报告类型使用不同的模板并执行相应的业务逻辑。

## 报告类型

### 1. 单月报告 (Monthly Report)
- **模板文件**: `salary_report_template_monthly.docx`
- **适用场景**: 分析特定月份的薪资数据
- **特点**: 提供该月的详细薪资分析

### 2. 多月报告 (Multi-Month Report)
- **模板文件**: `salary_report_template_multi_month.docx`
- **适用场景**: 分析连续多个月份的薪资数据趋势
- **特点**: 提供月份间对比分析

### 3. 季度报告 (Quarterly Report)
- **模板文件**: `salary_report_template_quarterly.docx`
- **适用场景**: 分析整个季度的薪资数据
- **特点**: 提供季度性薪资趋势分析

### 4. 年度报告 (Annual Report)
- **模板文件**: `salary_report_template_annual.docx`
- **适用场景**: 分析整年的薪资数据
- **特点**: 提供年度综合薪资分析

## 核心组件

### ReportGeneratorFactory
报告生成器工厂类，根据报告类型创建相应的报告生成器。

### ReportGenerator (接口)
所有报告生成器的接口，定义了生成报告的方法。

### 具体报告生成器
1. `MonthlyReportGenerator` - 单月报告生成器
2. `MultiMonthReportGenerator` - 多月报告生成器
3. `QuarterlyReportGenerator` - 季度报告生成器
4. `AnnualReportGenerator` - 年度报告生成器

## 实现逻辑

每种报告生成器都实现了以下逻辑：

1. **数据准备**: 使用`ReportDataService`准备报告数据
2. **图表生成**: 使用`ChartGenerationService`生成图表
3. **报告生成**: 使用`DocxWriterService`根据报告类型选择相应模板生成报告

## 使用流程

1. 选择报告类型
2. 工厂创建相应的报告生成器
3. 调用生成器的`generateReport`方法
4. 返回生成的报告文件路径

## 模板文件

所有模板文件都位于`assets`目录下：
- `salary_report_template_monthly.docx`
- `salary_report_template_multi_month.docx`
- `salary_report_template_quarterly.docx`
- `salary_report_template_annual.docx`

## 扩展性

通过工厂模式和接口设计，可以轻松添加新的报告类型：
1. 创建新的报告类型枚举
2. 实现新的报告生成器类
3. 在工厂中注册新的生成器