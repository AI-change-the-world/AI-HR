// src/report/report_generator_factory.dart

import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/report_data_service.dart';
import 'package:salary_report/src/pages/visualization/report/chart_generation_service.dart';
import 'package:salary_report/src/pages/visualization/report/docx_writer_service.dart';
import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_interface.dart';
import 'package:flutter/material.dart';
import 'package:salary_report/src/pages/visualization/report/monthly_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/multi_month_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/quarterly_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/annual_report_generator.dart';

/// 报告生成器工厂
class ReportGeneratorFactory {
  /// 根据报告类型创建相应的报告生成器
  static ReportGenerator createGenerator(ReportType type) {
    switch (type) {
      case ReportType.monthly:
        return MonthlyReportGenerator();
      case ReportType.multiMonth:
        return MultiMonthReportGenerator();
      case ReportType.quarterly:
        return QuarterlyReportGenerator();
      case ReportType.annual:
        return AnnualReportGenerator();
    }
  }
}

/// 单月报告生成器
class MonthlyReportGenerator implements ReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 实现单月报告生成逻辑
    // 使用 salary_report_template_monthly.docx 模板
    // 执行单月报告特有的业务逻辑

    // 创建所需的服务
    final analysisService = DataAnalysisService(IsarDatabase());
    final dataService = ReportDataService(
      aiService: AISummaryService(),
      dataService: analysisService, // 通过构造函数注入dataService
    );
    final chartService = ChartGenerationService();
    final docxService = DocxWriterService();

    // 准备报告数据
    final reportContent = await dataService.prepareReportData(
      departmentStats: data.departmentStats,
      analysisData: data.analysisData,
      year: data.year,
      month: data.month,
      isMultiMonth: false, // 单月报告
      startTime: data.startTime,
      endTime: data.endTime,
    );

    // 生成图表
    final salaryRanges = dataService.calculateSalaryRanges(
      data.departmentStats,
    );
    final chartImages = await chartService.generateAllCharts(
      previewContainerKey: GlobalKey(), // 这里应该从实际的预览容器获取
      departmentStats: data.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
    );

    // 生成报告文件
    final reportPath = await docxService.writeReport(
      data: reportContent,
      images: chartImages,
      reportType: ReportType.monthly,
    );

    return reportPath;
  }
}

/// 多月报告生成器
class MultiMonthReportGenerator implements ReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 实现多月报告生成逻辑
    // 使用 salary_report_template_multi_month.docx 模板
    // 执行多月报告特有的业务逻辑

    // 创建所需的服务
    final analysisService = DataAnalysisService(IsarDatabase());
    final dataService = ReportDataService(
      aiService: AISummaryService(),
      dataService: analysisService, // 通过构造函数注入dataService
    );
    final chartService = ChartGenerationService();
    final docxService = DocxWriterService();

    // 准备报告数据 - 多月报告需要特殊的处理
    final reportContent = await dataService.prepareReportData(
      departmentStats: data.departmentStats,
      analysisData: data.analysisData,
      year: data.year,
      month: data.month,
      isMultiMonth: true, // 明确设置为多月报告
      startTime: data.startTime,
      endTime: data.endTime,
    );

    // 生成图表 - 多月报告可能需要不同的图表类型
    final salaryRanges = dataService.calculateSalaryRanges(
      data.departmentStats,
    );
    final chartImages = await chartService.generateAllCharts(
      previewContainerKey: GlobalKey(), // 这里应该从实际的预览容器获取
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

    // 生成报告文件
    final reportPath = await docxService.writeReport(
      data: reportContent,
      images: chartImages,
      reportType: ReportType.multiMonth,
    );

    return reportPath;
  }
}

/// 季度报告生成器
class QuarterlyReportGenerator implements ReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 实现季度报告生成逻辑
    // 使用 salary_report_template_quarterly.docx 模板
    // 执行季度报告特有的业务逻辑

    // 创建所需的服务
    final analysisService = DataAnalysisService(IsarDatabase());
    final dataService = ReportDataService(
      aiService: AISummaryService(),
      dataService: analysisService, // 通过构造函数注入dataService
    );
    final chartService = ChartGenerationService();
    final docxService = DocxWriterService();

    // 准备报告数据 - 季度报告需要特殊的处理
    final reportContent = await dataService.prepareReportData(
      departmentStats: data.departmentStats,
      analysisData: data.analysisData,
      year: data.year,
      month: data.month,
      isMultiMonth: true, // 季度报告也是多月报告的一种
      startTime: data.startTime,
      endTime: data.endTime,
    );

    // 生成图表 - 季度报告可能需要不同的图表类型
    final salaryRanges = dataService.calculateSalaryRanges(
      data.departmentStats,
    );
    final chartImages = await chartService.generateAllCharts(
      previewContainerKey: GlobalKey(), // 这里应该从实际的预览容器获取
      departmentStats: data.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
      // 季度报告也可以使用多月报告的图表数据
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

    // 生成报告文件
    final reportPath = await docxService.writeReport(
      data: reportContent,
      images: chartImages,
      reportType: ReportType.quarterly,
    );

    return reportPath;
  }
}

/// 年度报告生成器
class AnnualReportGenerator implements ReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 实现年度报告生成逻辑
    // 使用 salary_report_template_annual.docx 模板
    // 执行年度报告特有的业务逻辑

    // 创建所需的服务
    final analysisService = DataAnalysisService(IsarDatabase());
    final dataService = ReportDataService(
      aiService: AISummaryService(),
      dataService: analysisService, // 通过构造函数注入dataService
    );
    final chartService = ChartGenerationService();
    final docxService = DocxWriterService();

    // 准备报告数据 - 年度报告需要特殊的处理
    final reportContent = await dataService.prepareReportData(
      departmentStats: data.departmentStats,
      analysisData: data.analysisData,
      year: data.year,
      month: data.month,
      isMultiMonth: true, // 年度报告也是多月报告的一种
      startTime: data.startTime,
      endTime: data.endTime,
    );

    // 生成图表 - 年度报告可能需要不同的图表类型
    final salaryRanges = dataService.calculateSalaryRanges(
      data.departmentStats,
    );
    final chartImages = await chartService.generateAllCharts(
      previewContainerKey: GlobalKey(), // 这里应该从实际的预览容器获取
      departmentStats: data.departmentStats,
      salaryRanges: salaryRanges,
      salaryStructureData: reportContent.salaryStructureData,
      // 年度报告也可以使用多月报告的图表数据
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

    // 生成报告文件
    final reportPath = await docxService.writeReport(
      data: reportContent,
      images: chartImages,
      reportType: ReportType.annual,
    );

    return reportPath;
  }
}
