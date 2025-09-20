// src/report/salary_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/report_service.dart';

import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';
import 'package:salary_report/src/pages/visualization/report/chart_generation_service.dart';
import 'package:salary_report/src/pages/visualization/report/docx_writer_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_data_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/analysis_data.dart';

class SalaryReportGenerator {
  // Dependencies are provided, making the class easier to test
  final ReportDataService _dataService;
  final ChartGenerationService _chartService;
  final DocxWriterService _docxService;
  final DataAnalysisService _analysisService;
  final ReportService _reportService;

  // Use dependency injection for better testability
  SalaryReportGenerator({
    ReportDataService? dataService,
    ChartGenerationService? chartService,
    DocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
  }) : _dataService =
           dataService ??
           ReportDataService(
             aiService: AISummaryService(),
             dataService: DataAnalysisService(IsarDatabase()),
           ),
       _chartService = chartService ?? ChartGenerationService(),
       _docxService = docxService ?? DocxWriterService(),
       _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService();

  /// 生成报告的主方法，支持不同类型的报告
  /// 使用新的工厂模式重构
  Future<String> generateReport({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required Map<String, dynamic> analysisData,
    required int year,
    required int month,
    required bool isMultiMonth,
    required DateTime startTime,
    required DateTime endTime,
    ReportType reportType = ReportType.singleMonth, // 默认为单月报告
    // Note: other stats like attendance can be passed into _dataService if needed
  }) async {
    try {
      logger.info('Starting salary report generation using factory pattern...');

      // 使用工厂模式创建相应的报告生成器
      final generator = ReportGeneratorFactory.createGenerator(reportType);

      // 准备报告数据
      final reportData = ReportData(
        departmentStats: departmentStats,
        analysisData: analysisData,
        year: year,
        month: month,
        isMultiMonth: isMultiMonth,
        startTime: startTime,
        endTime: endTime,
      );

      // 准备报告选项
      final reportOptions = ReportOptions();

      // 生成报告
      final reportPath = await generator.generateReport(
        reportType: reportType,
        data: reportData,
        options: reportOptions,
      );

      logger.info('Report generation complete: $reportPath');
      await _reportService.addReportRecord(reportPath);

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe('Fatal error during report generation: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 原有的生成报告方法，保持向后兼容
  Future<String> generateReportOld({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required Map<String, dynamic> analysisData,
    required int year,
    required int month,
    required bool isMultiMonth,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      logger.info('Starting salary report generation...');

      // 1. Prepare all data and text content using the data service.
      // This step also handles AI summaries.
      final reportContent = await _dataService.prepareReportDataForSingleMonth(
        SingleMonthAnalysisData(
          year: year,
          month: month,
          departmentStats: departmentStats,
          analysisData: analysisData,
        ),
      );
      logger.info('Report data prepared.');

      // Calculate salary ranges once to pass to the chart generator
      final salaryRanges = _dataService.calculateSalaryRanges(departmentStats);

      // 2. Generate all chart images using the chart service.
      final chartImages = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: salaryRanges, // 取第一个薪资区间数据
        salaryStructureData: reportContent.salaryStructureData,
        // generateReportOld方法默认为单月报告，不传递多月数据
      );

      logger.info('Chart images generated.');

      // 3. Write the .docx file using the docx service.
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: chartImages,
        reportType: ReportType.singleMonth, // generateReportOld方法默认使用单月报告类型
      );

      // 添加报告记录到数据库
      await _reportService.addReportRecord(reportPath);

      logger.info('Report generation complete: $reportPath');

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe('Fatal error during report generation: $e', e, stackTrace);
      rethrow;
    }
  }
}
