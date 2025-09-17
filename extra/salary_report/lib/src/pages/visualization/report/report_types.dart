// src/report/report_types.dart

import 'package:salary_report/src/isar/data_analysis_service.dart';

/// 报告类型枚举
enum ReportType {
  /// 单月报告
  monthly,

  /// 多月报告
  multiMonth,

  /// 季度报告
  quarterly,

  /// 年度报告
  annual,
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
  final List<MonthlyData>? monthlyData; // 用于多月报告
  final List<QuarterlyData>? quarterlyData; // 用于季度报告
  final AnnualData? annualData; // 用于年度报告

  ReportData({
    required this.departmentStats,
    required this.analysisData,
    required this.year,
    required this.month,
    required this.isMultiMonth,
    required this.startTime,
    required this.endTime,
    this.monthlyData,
    this.quarterlyData,
    this.annualData,
  });
}

/// 月度数据模型
class MonthlyData {
  final int year;
  final int month;
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;

  MonthlyData({
    required this.year,
    required this.month,
    required this.departmentStats,
    required this.analysisData,
  });
}

/// 季度数据模型
class QuarterlyData {
  final int year;
  final int quarter;
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;

  QuarterlyData({
    required this.year,
    required this.quarter,
    required this.departmentStats,
    required this.analysisData,
  });
}

/// 年度数据模型
class AnnualData {
  final int year;
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;

  AnnualData({
    required this.year,
    required this.departmentStats,
    required this.analysisData,
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
