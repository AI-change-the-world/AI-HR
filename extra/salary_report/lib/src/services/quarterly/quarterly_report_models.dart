// src/services/quarterly/quarterly_report_models.dart

import 'dart:typed_data';
import 'package:salary_report/src/services/global_analysis_models.dart';

// 单季度报告图表图像容器
class QuarterlyReportChartImages {
  final Uint8List? mainChart;
  final Uint8List? departmentDetailsChart;
  final Uint8List? salaryRangeChart;
  final Uint8List? salaryStructureChart;

  QuarterlyReportChartImages({
    this.mainChart,
    this.departmentDetailsChart,
    this.salaryRangeChart,
    this.salaryStructureChart,
  });
}

// 单季度报告内容模型
class QuarterlyReportContentModel {
  final String reportTitle;
  final String reportDate;
  final String companyName;
  final String reportTime;
  final String startTime;
  final String endTime;
  final String compareLast;
  final int totalEmployees;
  final double totalSalary;
  final double averageSalary;
  final int departmentCount;
  final int employeeCount;
  final String employeeDetails;
  final String departmentDetails;
  final String salaryRangeDescription;
  final String salaryRangeFeatureSummary;
  final String departmentSalaryAnalysis;
  final String keySalaryPoint;
  final String salaryRankings;
  final double basicSalaryRate;
  final double performanceSalaryRate;
  final String salaryStructure;
  final String salaryStructureAdvice;
  final List<Map<String, dynamic>> salaryStructureData;
  final List<DepartmentSalaryStats> departmentStats;

  QuarterlyReportContentModel({
    required this.reportTitle,
    required this.reportDate,
    required this.companyName,
    required this.reportTime,
    required this.startTime,
    required this.endTime,
    required this.compareLast,
    required this.totalEmployees,
    required this.totalSalary,
    required this.averageSalary,
    required this.departmentCount,
    required this.employeeCount,
    required this.employeeDetails,
    required this.departmentDetails,
    required this.salaryRangeDescription,
    required this.salaryRangeFeatureSummary,
    required this.departmentSalaryAnalysis,
    required this.keySalaryPoint,
    required this.salaryRankings,
    required this.basicSalaryRate,
    required this.performanceSalaryRate,
    required this.salaryStructure,
    required this.salaryStructureAdvice,
    required this.salaryStructureData,
    required this.departmentStats,
  });
}
