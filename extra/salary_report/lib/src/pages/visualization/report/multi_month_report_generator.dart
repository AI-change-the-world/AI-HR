// src/report/multi_month_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/pages/visualization/report/base_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';

/// 多月报告生成器
class MultiMonthReportGenerator extends BaseReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 调用父类的生成报告方法
    return super.generateReport(
      reportType: reportType,
      data: data,
      options: options,
    );
  }

  /// 多月报告特定的数据准备逻辑
  @override
  Future<ReportContentModel> prepareReportData(ReportData data) async {
    // 调用父类方法准备基础数据，但明确指定为多月报告
    final reportContent = await super.prepareReportData(data);

    return reportContent;
  }

  /// 多月报告特定的图表生成逻辑
  @override
  Future<ReportChartImages> generateCharts(
    ReportData data,
    ReportContentModel reportContent,
  ) async {
    // 计算薪资区间
    final salaryRanges = dataService.calculateSalaryRanges(
      data.departmentStats,
    );

    // 生成多月报告专用图表
    return await chartService.generateAllCharts(
      previewContainerKey: GlobalKey(),
      departmentStats: data.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
      // 多月报告专用图表数据
      employeeCountPerMonth: reportContent.employeeCountPerMonth,
      averageSalaryPerMonth: reportContent.averageSalaryPerMonth,
      totalSalaryPerMonth: reportContent.totalSalaryPerMonth,
      departmentDetailsPerMonth: reportContent.departmentDetailsPerMonth,
      // 传递最后一个月的部门统计数据用于图表生成
      lastMonthDepartmentStats:
          data.analysisData.containsKey('lastMonthDepartmentStats')
          ? List<Map<String, dynamic>>.from(
              data.analysisData['lastMonthDepartmentStats'] as List,
            )
          : null,
    );
  }
}
