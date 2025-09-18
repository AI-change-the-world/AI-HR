// src/report/base_report_generator.dart

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
import 'package:salary_report/src/pages/visualization/report/report_generator_interface.dart';

/// 抽象基类报告生成器
/// 定义通用接口和共享逻辑
abstract class BaseReportGenerator implements ReportGenerator {
  // 依赖服务
  late final ReportDataService _dataService;
  late final ChartGenerationService _chartService;
  late final DocxWriterService _docxService;
  late final DataAnalysisService _analysisService;
  late final ReportService _reportService;
  late final AISummaryService _aiService;

  // 受保护的getter方法，供子类访问
  ReportDataService get dataService => _dataService;
  ChartGenerationService get chartService => _chartService;
  DocxWriterService get docxService => _docxService;
  DataAnalysisService get analysisService => _analysisService;
  ReportService get reportService => _reportService;
  AISummaryService get aiService => _aiService;

  // 构造函数中初始化服务
  BaseReportGenerator() {
    _initializeServices();
  }

  /// 初始化所有服务
  void _initializeServices() {
    _aiService = AISummaryService();
    _analysisService = DataAnalysisService(IsarDatabase());
    _dataService = ReportDataService(
      aiService: _aiService,
      dataService: _analysisService,
    );
    _chartService = ChartGenerationService();
    _docxService = DocxWriterService();
    _reportService = ReportService();
  }

  /// 生成报告的主方法
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    try {
      logger.info(
        'Starting ${_getReportTypeName(reportType)} report generation...',
      );

      // 1. 准备报告数据
      final reportContent = await prepareReportData(data);
      logger.info('Report data prepared.');

      // 2. 生成图表
      final chartImages = await generateCharts(data, reportContent);
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
      logger.severe('Error during report generation: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 准备报告数据 - 子类可以重写以实现特定逻辑
  Future<ReportContentModel> prepareReportData(ReportData data) async {
    return await _dataService.prepareReportData(
      departmentStats: data.departmentStats,
      analysisData: data.analysisData,
      year: data.year,
      month: data.month,
      isMultiMonth: data.isMultiMonth,
      startTime: data.startTime,
      endTime: data.endTime,
    );
  }

  /// 生成图表 - 子类可以重写以实现特定逻辑
  Future<ReportChartImages> generateCharts(
    ReportData data,
    ReportContentModel reportContent,
  ) async {
    // 计算薪资区间
    final salaryRanges = _dataService.calculateSalaryRanges(
      data.departmentStats,
    );

    return await _chartService.generateAllCharts(
      previewContainerKey: GlobalKey(),
      departmentStats: data.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
    );
  }

  /// 生成文档
  Future<String> generateDocument(
    ReportContentModel reportContent,
    ReportChartImages chartImages,
    ReportType reportType,
  ) async {
    return await _docxService.writeReport(
      data: reportContent,
      images: chartImages,
      reportType: reportType,
    );
  }

  /// 保存报告记录
  Future<void> saveReportRecord(String reportPath) async {
    await _reportService.addReportRecord(reportPath);
  }

  /// 获取报告类型名称 - 用于日志记录
  String _getReportTypeName(ReportType type) {
    switch (type) {
      case ReportType.monthly:
        return 'Monthly';
      case ReportType.multiMonth:
        return 'Multi-Month';
      case ReportType.quarterly:
        return 'Quarterly';
      case ReportType.annual:
        return 'Annual';
    }
  }

  /// 生成报告标题 - 子类可以重写以实现特定逻辑
  String generateReportTitle(
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
}
