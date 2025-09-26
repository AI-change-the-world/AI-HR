// src/services/monthly/monthly_report_models.dart

import 'dart:typed_data';
import 'package:salary_report/src/services/global_analysis_models.dart';

// 单月报告图表图像容器
class MonthlyReportChartImages {
  final Uint8List? mainChart;
  final Uint8List? departmentDetailsChart;
  final Uint8List? salaryRangeChart;
  final Uint8List? salaryStructureChart;
  final Uint8List? attendanceChart;
  final Uint8List? topEmployeesChart;
  final Uint8List? departmentSalaryRangeChart;

  MonthlyReportChartImages({
    this.mainChart,
    this.departmentDetailsChart,
    this.salaryRangeChart,
    this.salaryStructureChart,
    this.attendanceChart,
    this.topEmployeesChart,
    this.departmentSalaryRangeChart,
  });
}

// 单月报告内容模型
class MonthlyReportContentModel {
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
  final String salaryStructure;
  final String salaryStructureAdvice;
  final List<Map<String, dynamic>> salaryStructureData;
  final List<DepartmentSalaryStats> departmentStats;

  MonthlyReportContentModel({
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
    required this.salaryStructure,
    required this.salaryStructureAdvice,
    required this.salaryStructureData,
    required this.departmentStats,
  });
}
