// src/report/multi_annual_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';

import 'package:salary_report/src/pages/visualization/report/analysis_data.dart';
import 'package:salary_report/src/pages/visualization/report/base_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';

class MultiAnnualReportGenerator extends BaseReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 验证报告类型
    if (reportType != ReportType.multiYear) {
      throw ArgumentError('MultiAnnualReportGenerator 只支持多年报告类型');
    }

    try {
      logger.info('Starting multi year report generation...');

      // 构造MultiYearAnalysisData对象
      final annualData = [
        AnnualAnalysisData(
          year: data.year,
          departmentStats: data.departmentStats,
          analysisData: data.analysisData,
        ),
      ];

      final multiYearData = MultiYearAnalysisData(
        startYear: data.year,
        endYear: data.year,
        annualData: annualData,
      );

      // 1. 准备报告数据
      final reportContent = await prepareReportDataForMultiYear(multiYearData);
      logger.info('Report data prepared.');

      // 2. 生成图表
      final chartImages = await generateChartsForMultiYear(
        multiYearData,
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
        'Error during multi year report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 多年报告特定的数据准备逻辑
  @override
  Future<ReportContentModel> prepareReportDataForMultiYear(
    MultiYearAnalysisData data,
  ) async {
    // 调用父类方法准备基础数据
    return await super.prepareReportDataForMultiYear(data);
  }

  /// 多年报告特定的图表生成逻辑
  @override
  Future<ReportChartImages> generateChartsForMultiYear(
    MultiYearAnalysisData data,
    ReportContentModel reportContent,
  ) async {
    // 使用最后一年的数据计算薪资区间
    final lastYearData = data.annualData.last;
    final salaryRanges = dataService.calculateSalaryRanges(
      lastYearData.departmentStats,
    );

    return await chartService.generateAllCharts(
      previewContainerKey: GlobalKey(),
      departmentStats: lastYearData.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
    );
  }
}
