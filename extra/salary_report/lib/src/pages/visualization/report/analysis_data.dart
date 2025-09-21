// src/pages/visualization/report/analysis_data.dart

import 'package:salary_report/src/services/global_analysis_models.dart';

/// 单月分析数据模型
class SingleMonthAnalysisData {
  final int year;
  final int month;
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;

  SingleMonthAnalysisData({
    required this.year,
    required this.month,
    required this.departmentStats,
    required this.analysisData,
  });
}

/// 多月分析数据模型
class MultiMonthAnalysisData {
  final DateTime startTime;
  final DateTime endTime;
  final List<MonthlyAnalysisData> monthlyData;

  MultiMonthAnalysisData({
    required this.startTime,
    required this.endTime,
    required this.monthlyData,
  });
}

/// 月度分析数据单元
class MonthlyAnalysisData {
  final int year;
  final int month;
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;

  MonthlyAnalysisData({
    required this.year,
    required this.month,
    required this.departmentStats,
    required this.analysisData,
  });
}

/// 单季度分析数据模型
class SingleQuarterAnalysisData {
  final int year;
  final int quarter; // 1-4
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;

  SingleQuarterAnalysisData({
    required this.year,
    required this.quarter,
    required this.departmentStats,
    required this.analysisData,
  });
}

/// 多季度分析数据模型
class MultiQuarterAnalysisData {
  final DateTime startTime;
  final DateTime endTime;
  final List<QuarterlyAnalysisData> quarterlyData;

  MultiQuarterAnalysisData({
    required this.startTime,
    required this.endTime,
    required this.quarterlyData,
  });
}

/// 季度分析数据单元
class QuarterlyAnalysisData {
  final int year;
  final int quarter; // 1-4
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;

  QuarterlyAnalysisData({
    required this.year,
    required this.quarter,
    required this.departmentStats,
    required this.analysisData,
  });
}

/// 单年分析数据模型
class SingleYearAnalysisData {
  final int year;
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;

  SingleYearAnalysisData({
    required this.year,
    required this.departmentStats,
    required this.analysisData,
  });
}

/// 多年分析数据模型
class MultiYearAnalysisData {
  final int startYear;
  final int endYear;
  final List<AnnualAnalysisData> annualData;

  MultiYearAnalysisData({
    required this.startYear,
    required this.endYear,
    required this.annualData,
  });
}

/// 年度分析数据单元
class AnnualAnalysisData {
  final int year;
  final List<DepartmentSalaryStats> departmentStats;
  final Map<String, dynamic> analysisData;

  AnnualAnalysisData({
    required this.year,
    required this.departmentStats,
    required this.analysisData,
  });
}
