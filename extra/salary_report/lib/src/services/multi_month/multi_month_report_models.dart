import 'dart:typed_data';
import 'package:salary_report/src/services/global_analysis_models.dart';

// 多月报告图表图像容器
class MultiMonthReportChartImages {
  final Uint8List? mainChart;
  final Uint8List? departmentDetailsChart;
  final Uint8List? salaryRangeChart;
  final Uint8List? salaryStructureChart;
  // 多月报告专用图表
  final Uint8List? employeeCountPerMonthChart;
  final Uint8List? averageSalaryPerMonthChart;
  final Uint8List? totalSalaryPerMonthChart;
  final Uint8List? departmentDetailsPerMonthChart;
  // 新增同比环比对比图表
  final Uint8List? departmentMonthOverMonthChart;
  final Uint8List? departmentYearOverYearChart;
  final Uint8List? positionMonthOverMonthChart;
  final Uint8List? positionYearOverYearChart;

  MultiMonthReportChartImages({
    this.mainChart,
    this.departmentDetailsChart,
    this.salaryRangeChart,
    this.salaryStructureChart,
    this.employeeCountPerMonthChart,
    this.averageSalaryPerMonthChart,
    this.totalSalaryPerMonthChart,
    this.departmentDetailsPerMonthChart,
    this.departmentMonthOverMonthChart,
    this.departmentYearOverYearChart,
    this.positionMonthOverMonthChart,
    this.positionYearOverYearChart,
  });
}

// 多月报告内容模型 - 专门为多月分析设计
class MultiMonthReportContentModel {
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
  final String payrollInfo;
  final String departmentDetails;
  final String salaryRangeDescription;
  final String salaryRangeFeatureSummary;
  final String departmentSalaryAnalysis;
  final String keySalaryPoint;
  @Deprecated("弃用")
  final String salaryRankings;
  final String salaryOrder; // 部门平均薪资排名
  @Deprecated("弃用")
  final double basicSalaryRate;
  @Deprecated("弃用")
  final double performanceSalaryRate;
  final String salaryStructure;
  final String salaryStructureAdvice;
  final List<Map<String, dynamic>> salaryStructureData;
  final List<DepartmentSalaryStats> departmentStats;

  // 多月报告专用字段 - 时间序列数据
  final List<Map<String, dynamic>>? employeeCountPerMonth;
  final List<Map<String, dynamic>>? averageSalaryPerMonth;
  final List<Map<String, dynamic>>? totalSalaryPerMonth;
  final List<Map<String, dynamic>>? departmentDetailsPerMonth;

  // 多月趋势分析专用字段 - 同比环比对比数据
  final List<Map<String, dynamic>>? departmentMonthOverMonthData;
  final List<Map<String, dynamic>>? departmentYearOverYearData;
  final List<Map<String, dynamic>>? positionMonthOverMonthData;
  final List<Map<String, dynamic>>? positionYearOverYearData;

  // 多月报告特有字段
  final int monthCount; // 报告涵盖的月份数量
  final double totalSalaryGrowthRate; // 总工资增长率
  final double averageSalaryGrowthRate; // 平均工资增长率
  final String trendAnalysisSummary; // 趋势分析总结

  MultiMonthReportContentModel({
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
    required this.payrollInfo,
    required this.departmentDetails,
    required this.salaryRangeDescription,
    required this.salaryRangeFeatureSummary,
    required this.departmentSalaryAnalysis,
    required this.keySalaryPoint,
    @Deprecated("弃用") required this.salaryRankings,
    required this.salaryOrder,
    @Deprecated("弃用") required this.basicSalaryRate,
    @Deprecated("弃用") required this.performanceSalaryRate,
    required this.salaryStructure,
    required this.salaryStructureAdvice,
    required this.salaryStructureData,
    required this.departmentStats,
    // 多月报告专用字段
    this.employeeCountPerMonth,
    this.averageSalaryPerMonth,
    this.totalSalaryPerMonth,
    this.departmentDetailsPerMonth,
    // 多月趋势分析专用字段
    this.departmentMonthOverMonthData,
    this.departmentYearOverYearData,
    this.positionMonthOverMonthData,
    this.positionYearOverYearData,
    // 多月报告特有字段
    this.monthCount = 0,
    this.totalSalaryGrowthRate = 0.0,
    this.averageSalaryGrowthRate = 0.0,
    this.trendAnalysisSummary = '',
  });
}
