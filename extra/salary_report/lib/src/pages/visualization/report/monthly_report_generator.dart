// src/report/monthly_report_generator.dart

import 'package:salary_report/src/pages/visualization/report/base_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/analysis_data.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/common/logger.dart';

/// 单月报告生成器
class MonthlyReportGenerator extends BaseReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 验证报告类型
    if (reportType != ReportType.singleMonth) {
      throw ArgumentError('MonthlyReportGenerator 只支持单月报告类型');
    }

    try {
      logger.info('Starting single month report generation...');

      // 构造SingleMonthAnalysisData对象
      final singleMonthData = SingleMonthAnalysisData(
        year: data.year,
        month: data.month,
        departmentStats: data.departmentStats,
        analysisData: data.analysisData,
      );

      // 1. 准备报告数据
      final reportContent = await prepareReportDataForSingleMonth(
        singleMonthData,
      );
      logger.info('Report data prepared.');

      // 2. 生成图表
      final chartImages = await generateCharts(singleMonthData, reportContent);
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
        'Error during single month report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 单月报告特定的数据准备逻辑
  @override
  Future<ReportContentModel> prepareReportDataForSingleMonth(
    SingleMonthAnalysisData data,
  ) async {
    // 调用父类方法准备基础数据
    return await super.prepareReportDataForSingleMonth(data);
  }

  /// 单月报告特定的图表生成逻辑
  @override
  Future<ReportChartImages> generateCharts(
    SingleMonthAnalysisData data,
    ReportContentModel reportContent,
  ) async {
    // 调用父类方法生成基础图表
    return await super.generateCharts(data, reportContent);
  }
}
