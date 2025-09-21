// src/pages/visualization/report/quarterly_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';

import 'package:salary_report/src/pages/visualization/report/base_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/analysis_data.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';

/// 单季度报告生成器
class QuarterlyReportGenerator extends BaseReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 验证报告类型
    if (reportType != ReportType.singleQuarter) {
      throw ArgumentError('QuarterlyReportGenerator 只支持单季度报告类型');
    }

    try {
      logger.info('Starting single quarter report generation...');

      // 构造SingleQuarterAnalysisData对象
      final singleQuarterData = SingleQuarterAnalysisData(
        year: data.year,
        quarter: ((data.month - 1) ~/ 3) + 1,
        departmentStats: data.departmentStats,
        analysisData: data.analysisData,
      );

      // 1. 准备报告数据
      final reportContent = await prepareReportDataForSingleQuarter(
        singleQuarterData,
      );
      logger.info('Report data prepared.');

      // 2. 生成图表
      final chartImages = await generateChartsForSingleQuarter(
        singleQuarterData,
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
        'Error during single quarter report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 单季度报告特定的数据准备逻辑
  @override
  Future<ReportContentModel> prepareReportDataForSingleQuarter(
    SingleQuarterAnalysisData data,
  ) async {
    // 调用父类方法准备基础数据
    return await super.prepareReportDataForSingleQuarter(data);
  }

  /// 单季度报告特定的图表生成逻辑
  @override
  Future<ReportChartImages> generateChartsForSingleQuarter(
    SingleQuarterAnalysisData data,
    ReportContentModel reportContent,
  ) async {
    // 计算薪资区间
    final salaryRanges = dataService.calculateSalaryRanges(
      data.departmentStats,
    );

    return await chartService.generateAllCharts(
      previewContainerKey: GlobalKey(),
      departmentStats: data.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
    );
  }
}
