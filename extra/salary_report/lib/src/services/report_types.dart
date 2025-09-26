// src/report/report_types.dart

import 'package:salary_report/src/services/global_analysis_models.dart';

/// 报告类型枚举
enum ReportType {
  /// 单月报告
  singleMonth,

  /// 多月报告
  multiMonth,

  /// 单季度报告
  singleQuarter,

  /// 多季度报告
  multiQuarter,

  /// 单年报告
  singleYear,

  /// 多年报告
  multiYear,
}

/// 报告数据模型
class ReportData {
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;
  final int year;
  final int month;
  final bool isMultiMonth;
  final DateTime startTime;
  final DateTime endTime;

  ReportData({
    required this.departmentStats,
    required this.analysisData,
    required this.year,
    required this.month,
    required this.isMultiMonth,
    required this.startTime,
    required this.endTime,
  });
}

/// 报告选项
class ReportOptions {
  final bool includeCharts;
  final bool includeAIAnalysis;
  final String companyName;
  final String reportTitle;
  // 其他选项...

  ReportOptions({
    this.includeCharts = true,
    this.includeAIAnalysis = true,
    this.companyName = '',
    this.reportTitle = '',
  });
}
