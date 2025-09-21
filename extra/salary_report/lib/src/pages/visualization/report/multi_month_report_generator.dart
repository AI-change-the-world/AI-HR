// src/report/multi_month_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';

import 'package:salary_report/src/pages/visualization/report/analysis_data.dart';
import 'package:salary_report/src/pages/visualization/report/base_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/chart_generation_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';

class MultiMonthReportGenerator extends BaseReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 验证报告类型
    if (reportType != ReportType.multiMonth) {
      throw ArgumentError('MultiMonthReportGenerator 只支持多月报告类型');
    }

    try {
      logger.info('Starting multi month report generation...');

      // 构造MultiMonthAnalysisData对象
      final monthlyData = [
        MonthlyAnalysisData(
          year: data.year,
          month: data.month,
          departmentStats: data.departmentStats,
          analysisData: data.analysisData,
        ),
      ];

      final multiMonthData = MultiMonthAnalysisData(
        startTime: data.startTime,
        endTime: data.endTime,
        monthlyData: monthlyData,
      );

      // 1. 准备报告数据
      final reportContent = await prepareReportDataForMultiMonth(
        multiMonthData,
      );
      logger.info('Report data prepared.');

      // 2. 生成图表
      final chartImages = await generateChartsForMultiMonth(
        multiMonthData,
        reportContent,
      );
      logger.info('Chart images generated.');

      // 3. 生成报告文件
      final reportPath = await generateDocument(
        reportContent,
        chartImages,
        reportType,
      );
      logger.info('Document generated at: $reportPath');

      // 4. 保存报告记录
      await saveReportRecord(reportPath);
      logger.info('Report record saved.');

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe(
        'Error during multi month report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 多月报告特定的数据准备逻辑
  @override
  Future<ReportContentModel> prepareReportDataForMultiMonth(
    MultiMonthAnalysisData data,
  ) async {
    // 调用父类方法准备基础数据
    return await super.prepareReportDataForMultiMonth(data);
  }

  /// 多月报告特定的图表生成逻辑
  @override
  Future<ReportChartImages> generateChartsForMultiMonth(
    MultiMonthAnalysisData data,
    ReportContentModel reportContent,
  ) async {
    // 使用最后一个月的数据计算薪资区间
    final lastMonthData = data.monthlyData.last;
    final salaryRanges = dataService.calculateSalaryRanges(
      lastMonthData.departmentStats,
    );

    // 生成多月报告专用图表
    return await chartService.generateAllCharts(
      previewContainerKey: GlobalKey(),
      departmentStats: lastMonthData.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
      // 多月报告专用图表数据
      employeeCountPerMonth: reportContent.employeeCountPerMonth,
      averageSalaryPerMonth: reportContent.averageSalaryPerMonth,
      totalSalaryPerMonth: reportContent.totalSalaryPerMonth,
      departmentDetailsPerMonth: reportContent.departmentDetailsPerMonth,
      // 传递最后一个月的部门统计数据用于图表生成
      lastMonthDepartmentStats:
          lastMonthData.analysisData.containsKey('lastMonthDepartmentStats')
          ? List<Map<String, dynamic>>.from(
              lastMonthData.analysisData['lastMonthDepartmentStats'] as List,
            )
          : null,
    );
  }
}
