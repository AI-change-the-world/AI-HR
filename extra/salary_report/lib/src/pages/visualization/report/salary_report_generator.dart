// src/report/salary_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/report_service.dart';
import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';
import 'package:salary_report/src/pages/visualization/report/chart_generation_service.dart';
import 'package:salary_report/src/pages/visualization/report/docx_writer_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:salary_report/src/pages/visualization/report/report_data_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_factory.dart';

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
           dataService ?? ReportDataService(aiService: AISummaryService()),
       _chartService = chartService ?? ChartGenerationService(),
       _docxService = docxService ?? DocxWriterService(),
       _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService();

  /// 生成报告的主方法，支持不同类型的报告
  Future<String> generateReport({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required Map<String, dynamic> analysisData,
    required int year,
    required int month,
    required bool isMultiMonth,
    required DateTime startTime,
    required DateTime endTime,
    ReportType reportType = ReportType.monthly, // 默认为单月报告
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
      // 根据是否为多月报告传递不同的参数
      ReportChartImages chartImages;
      if (isMultiMonth) {
        chartImages = await _chartService.generateAllCharts(
          previewContainerKey: previewContainerKey,
          departmentStats: departmentStats,
          salaryRanges: salaryRanges,
          salaryStructureData: reportContent.salaryStructureData,
          // 多月报告专用图表数据 - 从analysisData中获取
          employeeCountPerMonth:
              analysisData.containsKey('monthlyEmployeeCount')
              ? List<Map<String, dynamic>>.from(
                  analysisData['monthlyEmployeeCount'] as List,
                )
              : null,
          averageSalaryPerMonth:
              analysisData.containsKey('monthlyAverageSalary')
              ? List<Map<String, dynamic>>.from(
                  analysisData['monthlyAverageSalary'] as List,
                )
              : null,
          totalSalaryPerMonth: analysisData.containsKey('monthlyTotalSalary')
              ? List<Map<String, dynamic>>.from(
                  analysisData['monthlyTotalSalary'] as List,
                )
              : null,
          departmentDetailsPerMonth:
              analysisData.containsKey('monthlyDepartmentDetails')
              ? List<Map<String, dynamic>>.from(
                  analysisData['monthlyDepartmentDetails'] as List,
                )
              : null,
          // 传递最后一个月的部门统计数据用于图表生成
          lastMonthDepartmentStats:
              analysisData.containsKey('lastMonthDepartmentStats')
              ? List<Map<String, dynamic>>.from(
                  analysisData['lastMonthDepartmentStats'] as List,
                )
              : null,
        );
      } else {
        chartImages = await _chartService.generateAllCharts(
          previewContainerKey: previewContainerKey,
          departmentStats: departmentStats,
          salaryRanges: salaryRanges,
          salaryStructureData: reportContent.salaryStructureData,
        );
      }
      logger.info('Chart images generated.');

      // 3. Write the .docx file using the docx service.
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: chartImages,
        reportType: reportType, // 使用传入的reportType参数，而不是硬编码为monthly
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

  /// 根据报告类型生成报告标题
  String _getReportTitle(
    ReportType type,
    int year,
    int month,
    bool isMultiMonth,
    DateTime startTime,
    DateTime endTime,
  ) {
    switch (type) {
      case ReportType.monthly:
        return '$year年$month月工资分析报告';
      case ReportType.multiMonth:
        return '${startTime.year}年${startTime.month}月至${endTime.year}年${endTime.month}月工资分析报告';
      case ReportType.quarterly:
        // 根据开始时间计算季度
        final startQuarter = ((startTime.month - 1) ~/ 3) + 1;
        // 根据结束时间计算季度
        final endQuarter = ((endTime.month - 1) ~/ 3) + 1;

        // 如果是同一季度
        if (startTime.year == endTime.year && startQuarter == endQuarter) {
          return '${startTime.year}年第${startQuarter}季度工资分析报告';
        } else {
          // 跨季度情况
          return '${startTime.year}年第${startQuarter}季度-${endTime.year}年第${endQuarter}季度工资分析报告';
        }
      case ReportType.annual:
        // 如果是同一年度
        if (startTime.year == endTime.year) {
          return '$year年度工资分析报告';
        } else {
          // 跨年度情况
          return '${startTime.year}-${endTime.year}年度工资分析报告';
        }
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
        salaryStructureData: reportContent.salaryStructureData,
        // generateReportOld方法默认为单月报告，不传递多月数据
      );

      logger.info('Chart images generated.');

      // 3. Write the .docx file using the docx service.
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: chartImages,
        reportType: ReportType.monthly, // generateReportOld方法默认使用单月报告类型
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
