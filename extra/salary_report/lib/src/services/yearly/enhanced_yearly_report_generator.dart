import 'package:flutter/material.dart';
import 'package:salary_report/src/services/base_multi_period_report_generator.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/yearly/yearly_report_models.dart';
import 'package:salary_report/src/services/yearly/chart_generation_service.dart';
import 'package:salary_report/src/services/yearly/docx_writer_service.dart';

/// 年度报告生成器，基于统一的多期间报告生成器框架
class EnhancedYearlyReportGenerator extends BaseMultiPeriodReportGenerator {
  @override
  PeriodType get periodType => PeriodType.yearly;

  @override
  dynamic get chartService => YearlyChartGenerationService();

  @override
  dynamic get docxService => YearlyDocxWriterService();

  @override
  Future<YearlyReportContentModel> createReportContentModel({
    required Map<String, dynamic> periodData,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // 从聚合数据中提取统计信息
    final summaryStats = periodData['summaryStats'] as Map<String, dynamic>;

    // 创建年度分析结果模型
    return YearlyReportContentModel(
      reportTitle: '年度薪资分析报告',
      reportDate: DateTime.now().toString().split(' ')[0],
      companyName: '公司名称',
      reportTime: '${startTime.year}年',
      startTime: '${startTime.year}年1月',
      endTime: '${endTime.year}年12月',
      compareLast: '上年同期',
      totalEmployees: summaryStats['totalEmployees'] ?? 0,
      totalSalary: summaryStats['totalSalary'] ?? 0.0,
      averageSalary: summaryStats['averageSalary'] ?? 0.0,
      departmentCount: summaryStats['departmentCount'] ?? 0,
      employeeCount: summaryStats['uniqueEmployeeCount'] ?? 0,
      employeeDetails: _generateEmployeeDetails(periodData).toString(),
      departmentDetails: _generateDepartmentDetails(periodData).toString(),
      salaryRangeDescription: '薪资区间分布',
      salaryRangeFeatureSummary: '薪资区间特征总结',
      departmentSalaryAnalysis: '部门薪资分析',
      keySalaryPoint: '关键薪资要点',
      salaryRankings: '薪资排名',
      salaryOrder: '薪资排序',
      basicSalaryRate: 0.7,
      performanceSalaryRate: 0.3,
      salaryStructure: '薪资结构分析',
      salaryStructureAdvice: '薪资结构建议',
      salaryStructureData: [_createSalaryStructureData(periodData)],
      departmentStats: summaryStats['departmentStats'] ?? [],
      monthCount: 12,
      totalSalaryGrowthRate: 0.0,
      averageSalaryGrowthRate: 0.0,
      trendAnalysisSummary: '趋势分析总结',
    );
  }

  @override
  Future<YearlyReportChartImages> generateCharts({
    required GlobalKey previewContainerKey,
    required Map<String, dynamic> periodData,
    required List<dynamic> departmentStats,
  }) async {
    // 年度图表生成逻辑
    return YearlyReportChartImages();
  }

  /// 创建薪资结构数据
  Map<String, dynamic> _createSalaryStructureData(
    Map<String, dynamic> periodData,
  ) {
    final salaryRanges =
        periodData['salaryRanges'] as List<SalaryRangeStats>? ?? [];

    return {
      'salaryRanges': salaryRanges
          .map(
            (range) => {
              'range': range.range,
              'employeeCount': range.employeeCount,
              'totalSalary': range.totalSalary,
              'averageSalary': range.averageSalary,
            },
          )
          .toList(),
    };
  }

  /// 生成员工详细信息
  List<Map<String, dynamic>> _generateEmployeeDetails(
    Map<String, dynamic> periodData,
  ) {
    // 从期间数据中提取员工详细信息
    return [];
  }

  /// 生成部门详细信息
  List<Map<String, dynamic>> _generateDepartmentDetails(
    Map<String, dynamic> periodData,
  ) {
    final departmentStats =
        periodData['departmentStats'] as List<DepartmentSalaryStats>? ?? [];

    return departmentStats
        .map(
          (dept) => {
            'department': dept.department,
            'employeeCount': dept.employeeCount,
            'totalNetSalary': dept.totalNetSalary,
            'averageNetSalary': dept.averageNetSalary,
            'maxSalary': dept.maxSalary,
            'minSalary': dept.minSalary,
          },
        )
        .toList();
  }
}
