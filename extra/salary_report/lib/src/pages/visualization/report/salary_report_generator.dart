// src/report/salary_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';
import 'package:salary_report/src/pages/visualization/report/chart_generation_service.dart';
import 'package:salary_report/src/pages/visualization/report/docx_writer_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_data_service.dart';

class SalaryReportGenerator {
  // Dependencies are provided, making the class easier to test
  final ReportDataService _dataService;
  final ChartGenerationService _chartService;
  final DocxWriterService _docxService;

  // Use dependency injection for better testability
  SalaryReportGenerator({
    ReportDataService? dataService,
    ChartGenerationService? chartService,
    DocxWriterService? docxService,
  }) : _dataService = dataService ?? ReportDataService(AISummaryService()),
       _chartService = chartService ?? ChartGenerationService(),
       _docxService = docxService ?? DocxWriterService();

  Future<String> generateReport({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required Map<String, dynamic> analysisData,
    required int year,
    required int month,
    required bool isMultiMonth,
    required DateTime startTime,
    required DateTime endTime,
    // Note: other stats like attendance can be passed into _dataService if needed
  }) async {
    try {
      logger.info('Starting salary report generation...');

      // 1. Prepare all data and text content using the data service.
      // This step also handles AI summaries.
      final reportContent = await _dataService.prepareReportData(
        departmentStats: departmentStats,
        analysisData: analysisData,
        year: year,
        month: month,
        isMultiMonth: isMultiMonth,
        startTime: startTime,
        endTime: endTime,
      );
      logger.info('Report data prepared.');

      // Calculate salary ranges once to pass to the chart generator
      final salaryRanges = _dataService.calculateSalaryRanges(departmentStats);

      // 2. Generate all chart images using the chart service.
      final chartImages = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: salaryRanges,
      );
      logger.info('Chart images generated.');

      // 3. Write the .docx file using the docx service.
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: chartImages,
      );
      logger.info('Report generation complete: $reportPath');

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe('Fatal error during report generation: $e', e, stackTrace);
      rethrow;
    }
  }
}
