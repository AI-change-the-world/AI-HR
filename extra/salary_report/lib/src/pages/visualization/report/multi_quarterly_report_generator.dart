// src/report/multi_quarterly_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';

import 'package:salary_report/src/pages/visualization/report/analysis_data.dart';
import 'package:salary_report/src/pages/visualization/report/base_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';

class MultiQuarterlyReportGenerator extends BaseReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 验证报告类型
    if (reportType != ReportType.multiQuarter) {
      throw ArgumentError('MultiQuarterlyReportGenerator 只支持多季度报告类型');
    }

    try {
      logger.info('Starting multi quarter report generation...');

      // 构造MultiQuarterAnalysisData对象
      final quarterlyData = [
        QuarterlyAnalysisData(
          year: data.year,
          quarter: ((data.month - 1) ~/ 3) + 1,
          departmentStats: data.departmentStats,
          analysisData: data.analysisData,
        ),
      ];

      final multiQuarterData = MultiQuarterAnalysisData(
        startTime: data.startTime,
        endTime: data.endTime,
        quarterlyData: quarterlyData,
      );

      // 1. 准备报告数据
      final reportContent = await prepareReportDataForMultiQuarter(
        multiQuarterData,
      );
      logger.info('Report data prepared.');

      // 2. 生成图表
      final chartImages = await generateChartsForMultiQuarter(
        multiQuarterData,
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
        'Error during multi quarter report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 多季度报告特定的数据准备逻辑
  @override
  Future<ReportContentModel> prepareReportDataForMultiQuarter(
    MultiQuarterAnalysisData data,
  ) async {
    // 调用父类方法准备基础数据
    return await super.prepareReportDataForMultiQuarter(data);
  }

  /// 多季度报告特定的图表生成逻辑
  @override
  Future<ReportChartImages> generateChartsForMultiQuarter(
    MultiQuarterAnalysisData data,
    ReportContentModel reportContent,
  ) async {
    // 使用最后一个季度的数据计算薪资区间
    final lastQuarterData = data.quarterlyData.last;
    final salaryRanges = dataService.calculateSalaryRanges(
      lastQuarterData.departmentStats,
    );

    return await chartService.generateAllCharts(
      previewContainerKey: GlobalKey(),
      departmentStats: lastQuarterData.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
    );
  }
}
