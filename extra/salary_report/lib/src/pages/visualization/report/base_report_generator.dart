// src/report/base_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/report_service.dart';

import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';
import 'package:salary_report/src/pages/visualization/report/chart_generation_service.dart';
import 'package:salary_report/src/pages/visualization/report/docx_writer_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:salary_report/src/pages/visualization/report/report_data_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/analysis_data.dart';
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
      late ReportContentModel reportContent;
      switch (reportType) {
        case ReportType.singleMonth:
          final singleMonthData = SingleMonthAnalysisData(
            year: data.year,
            month: data.month,
            departmentStats: data.departmentStats,
            analysisData: data.analysisData,
          );
          reportContent = await prepareReportDataForSingleMonth(
            singleMonthData,
          );
          break;
        case ReportType.multiMonth:
          // 对于多月报告，我们需要构造MultiMonthAnalysisData
          // 这里简化处理，实际应用中可能需要更复杂的逻辑
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
          reportContent = await prepareReportDataForMultiMonth(multiMonthData);
          break;
        case ReportType.singleQuarter:
          final singleQuarterData = SingleQuarterAnalysisData(
            year: data.year,
            quarter: ((data.month - 1) ~/ 3) + 1,
            departmentStats: data.departmentStats,
            analysisData: data.analysisData,
          );
          reportContent = await prepareReportDataForSingleQuarter(
            singleQuarterData,
          );
          break;
        case ReportType.multiQuarter:
          // 简化处理
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
          reportContent = await prepareReportDataForMultiQuarter(
            multiQuarterData,
          );
          break;
        case ReportType.singleYear:
          final singleYearData = SingleYearAnalysisData(
            year: data.year,
            departmentStats: data.departmentStats,
            analysisData: data.analysisData,
          );
          reportContent = await prepareReportDataForSingleYear(singleYearData);
          break;
        case ReportType.multiYear:
          // 简化处理
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
          reportContent = await prepareReportDataForMultiYear(multiYearData);
          break;
      }
      logger.info('Report data prepared.');

      // 2. 生成图表
      late ReportChartImages chartImages;
      switch (reportType) {
        case ReportType.singleMonth:
          final singleMonthData = SingleMonthAnalysisData(
            year: data.year,
            month: data.month,
            departmentStats: data.departmentStats,
            analysisData: data.analysisData,
          );
          chartImages = await generateCharts(singleMonthData, reportContent);
          break;
        case ReportType.multiMonth:
          // 对于多月报告，我们需要构造MultiMonthAnalysisData
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
          chartImages = await generateChartsForMultiMonth(
            multiMonthData,
            reportContent,
          );
          break;
        case ReportType.singleQuarter:
          final singleQuarterData = SingleQuarterAnalysisData(
            year: data.year,
            quarter: ((data.month - 1) ~/ 3) + 1,
            departmentStats: data.departmentStats,
            analysisData: data.analysisData,
          );
          chartImages = await generateChartsForSingleQuarter(
            singleQuarterData,
            reportContent,
          );
          break;
        case ReportType.multiQuarter:
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
          chartImages = await generateChartsForMultiQuarter(
            multiQuarterData,
            reportContent,
          );
          break;
        case ReportType.singleYear:
          final singleYearData = SingleYearAnalysisData(
            year: data.year,
            departmentStats: data.departmentStats,
            analysisData: data.analysisData,
          );
          chartImages = await generateChartsForSingleYear(
            singleYearData,
            reportContent,
          );
          break;
        case ReportType.multiYear:
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
          chartImages = await generateChartsForMultiYear(
            multiYearData,
            reportContent,
          );
          break;
      }
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

  /// 准备单月报告数据
  Future<ReportContentModel> prepareReportDataForSingleMonth(
    SingleMonthAnalysisData data,
  ) async {
    return await _dataService.prepareReportDataForSingleMonth(data);
  }

  /// 准备多月报告数据
  Future<ReportContentModel> prepareReportDataForMultiMonth(
    MultiMonthAnalysisData data,
  ) async {
    return await _dataService.prepareReportDataForMultiMonth(data);
  }

  /// 准备单季度报告数据
  Future<ReportContentModel> prepareReportDataForSingleQuarter(
    SingleQuarterAnalysisData data,
  ) async {
    return await _dataService.prepareReportDataForSingleQuarter(data);
  }

  /// 准备多季度报告数据
  Future<ReportContentModel> prepareReportDataForMultiQuarter(
    MultiQuarterAnalysisData data,
  ) async {
    return await _dataService.prepareReportDataForMultiQuarter(data);
  }

  /// 准备单年报告数据
  Future<ReportContentModel> prepareReportDataForSingleYear(
    SingleYearAnalysisData data,
  ) async {
    return await _dataService.prepareReportDataForSingleYear(data);
  }

  /// 准备多年报告数据
  Future<ReportContentModel> prepareReportDataForMultiYear(
    MultiYearAnalysisData data,
  ) async {
    return await _dataService.prepareReportDataForMultiYear(data);
  }

  /// 生成单月报告图表
  Future<ReportChartImages> generateCharts(
    SingleMonthAnalysisData data,
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

  /// 生成多月报告图表
  Future<ReportChartImages> generateChartsForMultiMonth(
    MultiMonthAnalysisData data,
    ReportContentModel reportContent,
  ) async {
    // 使用最后一个月的数据计算薪资区间
    final lastMonthData = data.monthlyData.last;
    final salaryRanges = _dataService.calculateSalaryRanges(
      lastMonthData.departmentStats,
    );

    // 生成多月报告专用图表
    return await _chartService.generateAllCharts(
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

  /// 生成单季度报告图表
  Future<ReportChartImages> generateChartsForSingleQuarter(
    SingleQuarterAnalysisData data,
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

  /// 生成多季度报告图表
  Future<ReportChartImages> generateChartsForMultiQuarter(
    MultiQuarterAnalysisData data,
    ReportContentModel reportContent,
  ) async {
    // 使用最后一个季度的数据计算薪资区间
    final lastQuarterData = data.quarterlyData.last;
    final salaryRanges = _dataService.calculateSalaryRanges(
      lastQuarterData.departmentStats,
    );

    return await _chartService.generateAllCharts(
      previewContainerKey: GlobalKey(),
      departmentStats: lastQuarterData.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
    );
  }

  /// 生成单年报告图表
  Future<ReportChartImages> generateChartsForSingleYear(
    SingleYearAnalysisData data,
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

  /// 生成多年报告图表
  Future<ReportChartImages> generateChartsForMultiYear(
    MultiYearAnalysisData data,
    ReportContentModel reportContent,
  ) async {
    // 使用最后一年的数据计算薪资区间
    final lastYearData = data.annualData.last;
    final salaryRanges = _dataService.calculateSalaryRanges(
      lastYearData.departmentStats,
    );

    return await _chartService.generateAllCharts(
      previewContainerKey: GlobalKey(),
      departmentStats: lastYearData.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
    );
  }

  /// 生成报告文档
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

  /// 获取报告类型名称
  String _getReportTypeName(ReportType type) {
    switch (type) {
      case ReportType.singleMonth:
        return '单月';
      case ReportType.multiMonth:
        return '多月';
      case ReportType.singleQuarter:
        return '单季度';
      case ReportType.multiQuarter:
        return '多季度';
      case ReportType.singleYear:
        return '单年';
      case ReportType.multiYear:
        return '多年';
    }
  }
}
