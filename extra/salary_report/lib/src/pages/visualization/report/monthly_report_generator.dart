// src/report/monthly_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/pages/visualization/report/base_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';

/// 单月报告生成器
class MonthlyReportGenerator extends BaseReportGenerator {
  @override
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  }) async {
    // 调用父类的生成报告方法
    return super.generateReport(
      reportType: reportType,
      data: data,
      options: options,
    );
  }

  /// 单月报告特定的数据准备逻辑
  @override
  Future<ReportContentModel> prepareReportData(ReportData data) async {
    // 调用父类方法准备基础数据
    final reportContent = await super.prepareReportData(data);

    // 单月报告不需要额外的数据处理
    return reportContent;
  }

  /// 单月报告特定的图表生成逻辑
  @override
  Future<ReportChartImages> generateCharts(
    ReportData data,
    ReportContentModel reportContent,
  ) async {
    // 调用父类方法生成基础图表
    final chartImages = await super.generateCharts(data, reportContent);

    // 单月报告使用基础图表生成逻辑
    return chartImages;
  }
}
