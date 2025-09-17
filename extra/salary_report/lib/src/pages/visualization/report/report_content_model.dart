// src/report/models/report_content_model.dart

import 'dart:typed_data';
import 'package:salary_report/src/isar/data_analysis_service.dart';

// A container for the generated chart images
class ReportChartImages {
  final Uint8List? mainChart;
  final Uint8List? departmentDetailsChart;
  final Uint8List? salaryRangeChart;
  final Uint8List? salaryStructureChart; // 薪资结构饼图

  ReportChartImages({
    this.mainChart,
    this.departmentDetailsChart,
    this.salaryRangeChart,
    this.salaryStructureChart, // 薪资结构饼图
  });
}

// A strongly-typed model for all the data that will fill the report
class ReportContentModel {
  final String reportTitle;
  final String reportDate;
  final String companyName;
  final String reportTime;
  final String startTime;
  final String endTime;
  final String compareLast; // 改为非空String类型
  final int totalEmployees;
  final double totalSalary;
  final double averageSalary;
  final int departmentCount;
  final int employeeCount;
  final String employeeDetails;
  final String departmentDetails;
  final String salaryRangeDescription;
  final String salaryRangeFeatureSummary; // AI-generated
  final String departmentSalaryAnalysis; // AI-generated
  final String keySalaryPoint; // AI-generated
  final String salaryRankings;
  final double basicSalaryRate;
  final double performanceSalaryRate;
  final String salaryStructure; // 薪资结构分析
  final List<Map<String, dynamic>> salaryStructureData; // 薪资结构数据用于图表
  final List<DepartmentSalaryStats> departmentStats;
  // ... add any other fields you need

  ReportContentModel({
    required this.reportTitle,
    required this.reportDate,
    required this.companyName,
    required this.reportTime,
    required this.startTime,
    required this.endTime,
    required this.compareLast, // 改为required参数
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
    required this.salaryStructure, // 薪资结构分析
    required this.salaryStructureData, // 薪资结构数据用于图表
    required this.departmentStats,
  });
}
