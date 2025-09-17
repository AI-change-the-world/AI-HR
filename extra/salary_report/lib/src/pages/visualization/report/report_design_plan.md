# 薪资报告生成设计方案

## 1. 概述

当前系统已实现单月薪资报告生成功能，但需要扩展支持多月、季度和年度报告。不同时间维度的报告在数据层面相似，但在模板设计和业务逻辑上存在较大差异。

本方案旨在设计一个灵活的报告生成系统，根据不同时间维度调用不同的模板和执行不同的业务逻辑。

## 2. 报告类型分类

### 2.1 单月报告 (Monthly Report)
- **适用场景**: 分析某一个月的薪资数据
- **特点**: 
  - 数据粒度最细
  - 包含详细的部门和员工信息
  - 适合日常管理和月度总结

### 2.2 多月报告 (Multi-Month Report)
- **适用场景**: 分析连续几个月的薪资趋势
- **特点**: 
  - 包含时间序列分析
  - 重点关注薪资变化趋势
  - 适合季度初的回顾分析

### 2.3 季度报告 (Quarterly Report)
- **适用场景**: 分析一个季度的薪资情况
- **特点**: 
  - 包含季度对比分析
  - 重点关注季节性变化
  - 适合季度总结和规划

### 2.4 年度报告 (Annual Report)
- **适用场景**: 分析一整年的薪资情况
- **特点**: 
  - 包含年度总结和对比
  - 重点关注长期趋势和年度变化
  - 适合年度总结和下一年度规划

## 3. 模板设计规划

### 3.1 单月报告模板 (salary_report_template_monthly.docx)
- **结构**: 
  - 公司信息和报告基本信息
  - 当月薪资总览
  - 部门薪资详情
  - 员工薪资分布
  - 薪资结构分析
  - AI分析和建议
- **图表**: 
  - 部门人员分布饼图
  - 薪资区间柱状图
  - 薪资结构饼图
  - 主要图表（来自预览）

### 3.2 多月报告模板 (salary_report_template_multi_month.docx)
- **结构**: 
  - 公司信息和报告基本信息
  - 多月薪资趋势总览
  - 月度对比分析
  - 部门薪资变化趋势
  - 员工流动情况分析
  - 薪资增长率分析
  - AI分析和建议
- **图表**: 
  - 月度薪资趋势折线图
  - 部门薪资变化趋势图
  - 薪资增长率柱状图
  - 员工流动情况图表

### 3.3 季度报告模板 (salary_report_template_quarterly.docx)
- **结构**: 
  - 公司信息和报告基本信息
  - 季度薪资总览
  - 季度对比分析（与上季度/去年同期）
  - 部门季度表现
  - 季节性因素分析
  - 薪资预算执行情况
  - AI分析和建议
- **图表**: 
  - 季度薪资对比柱状图
  - 部门季度表现雷达图
  - 季节性因素影响图
  - 薪资预算执行情况图

### 3.4 年度报告模板 (salary_report_template_annual.docx)
- **结构**: 
  - 公司信息和报告基本信息
  - 年度薪资总览
  - 年度对比分析（与去年）
  - 部门年度表现
  - 员工薪资增长分析
  - 薪资预算执行情况
  - 年度总结和下一年度展望
  - AI分析和建议
- **图表**: 
  - 年度薪资趋势折线图
  - 部门年度表现对比图
  - 员工薪资增长分布图
  - 薪资预算执行情况图

## 4. 系统架构设计

### 4.1 报告生成器接口
```dart
abstract class ReportGenerator {
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  });
}
```

### 4.2 报告类型枚举
```dart
enum ReportType {
  monthly,
  multiMonth,
  quarterly,
  annual
}
```

### 4.3 报告数据模型
```dart
class ReportData {
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;
  final int year;
  final int month;
  final bool isMultiMonth;
  final DateTime startTime;
  final DateTime endTime;
  final List<MonthlyData> monthlyData; // 用于多月报告
  final List<QuarterlyData> quarterlyData; // 用于季度报告
  final AnnualData annualData; // 用于年度报告
}
```

### 4.4 报告选项
```dart
class ReportOptions {
  final bool includeCharts;
  final bool includeAIAnalysis;
  final String companyName;
  final String reportTitle;
  // 其他选项...
}
```

## 5. 具体实现方案

### 5.1 报告生成器工厂
```dart
class ReportGeneratorFactory {
  static ReportGenerator createGenerator(ReportType type) {
    switch (type) {
      case ReportType.monthly:
        return MonthlyReportGenerator();
      case ReportType.multiMonth:
        return MultiMonthReportGenerator();
      case ReportType.quarterly:
        return QuarterlyReportGenerator();
      case ReportType.annual:
        return AnnualReportGenerator();
      default:
        throw ArgumentError('Unsupported report type: $type');
    }
  }
}
```

### 5.2 各类报告生成器

#### 5.2.1 单月报告生成器
```dart
class MonthlyReportGenerator implements ReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 使用 salary_report_template_monthly.docx 模板
    // 执行单月报告特有的业务逻辑
    // 返回生成的报告路径
  }
}
```

#### 5.2.2 多月报告生成器
```dart
class MultiMonthReportGenerator implements ReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 使用 salary_report_template_multi_month.docx 模板
    // 执行多月报告特有的业务逻辑
    // 返回生成的报告路径
  }
}
```

#### 5.2.3 季度报告生成器
```dart
class QuarterlyReportGenerator implements ReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 使用 salary_report_template_quarterly.docx 模板
    // 执行季度报告特有的业务逻辑
    // 返回生成的报告路径
  }
}
```

#### 5.2.4 年度报告生成器
```dart
class AnnualReportGenerator implements ReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 使用 salary_report_template_annual.docx 模板
    // 执行年度报告特有的业务逻辑
    // 返回生成的报告路径
  }
}
```

## 6. 模板内容规划

### 6.1 单月报告模板内容
- 封面：公司名称、报告标题、日期
- 目录
- 报告摘要
- 当月薪资总览
- 部门薪资详情表
- 员工薪资分布图
- 薪资结构分析
- AI分析和建议
- 附录

### 6.2 多月报告模板内容
- 封面：公司名称、报告标题、日期范围
- 目录
- 报告摘要
- 多月薪资趋势分析
- 月度对比表
- 薪资变化趋势图
- 部门表现对比
- AI分析和建议
- 附录

### 6.3 季度报告模板内容
- 封面：公司名称、报告标题、季度信息
- 目录
- 报告摘要
- 季度薪资总览
- 季度对比分析
- 部门季度表现
- 季节性因素分析
- 薪资预算执行情况
- AI分析和建议
- 附录

### 6.4 年度报告模板内容
- 封面：公司名称、报告标题、年度信息
- 目录
- 报告摘要
- 年度薪资总览
- 年度对比分析
- 部门年度表现
- 员工薪资增长分析
- 薪资预算执行情况
- 年度总结和展望
- AI分析和建议
- 附录

## 7. 数据处理差异

### 7.1 单月报告数据处理
- 直接使用当月数据
- 详细到每个部门和员工
- 包含完整的薪资结构分析

### 7.2 多月报告数据处理
- 聚合多个月的数据
- 计算月度平均值和趋势
- 分析薪资变化情况

### 7.3 季度报告数据处理
- 聚合季度数据
- 与上季度和去年同期对比
- 分析季节性影响

### 7.4 年度报告数据处理
- 聚合年度数据
- 与去年对比
- 分析长期趋势

## 8. AI分析差异化

### 8.1 单月报告AI分析
- 当月薪资结构分析
- 部门间薪资差异分析
- 异常薪资情况识别

### 8.2 多月报告AI分析
- 薪资变化趋势分析
- 薪资增长率分析
- 异常波动识别

### 8.3 季度报告AI分析
- 季度表现评估
- 季节性因素影响分析
- 部门季度表现对比

### 8.4 年度报告AI分析
- 年度总结和评估
- 长期趋势分析
- 下一年度预测和建议

## 9. 实施步骤

1. **模板准备**: 创建四种不同的DOCX模板文件
2. **接口定义**: 定义报告生成器接口和相关数据模型
3. **工厂模式实现**: 实现报告生成器工厂
4. **各类生成器实现**: 分别实现四种报告生成器
5. **数据服务扩展**: 扩展数据服务以支持不同时间维度的数据处理
6. **AI服务扩展**: 扩展AI服务以支持不同时间维度的分析
7. **图表服务扩展**: 扩展图表服务以支持不同时间维度的图表生成
8. **集成测试**: 对四种报告类型进行集成测试
9. **文档编写**: 编写详细的使用文档

## 10. 预期效果

通过本方案的实施，系统将能够：
- 根据不同时间维度自动生成相应的报告
- 使用专门设计的模板，提高报告的专业性和可读性
- 执行针对性的业务逻辑，提供更准确的分析结果
- 满足不同管理层对薪资数据的多样化需求