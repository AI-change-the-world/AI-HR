// src/report/report_generator_factory.dart

import 'report_generator_interface.dart';
import 'report_types.dart';

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
    // TODO: 实现单月报告生成逻辑
    // 使用 salary_report_template_monthly.docx 模板
    // 执行单月报告特有的业务逻辑
    throw UnimplementedError('Monthly report generation not implemented');
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
    // TODO: 实现多月报告生成逻辑
    // 使用 salary_report_template_multi_month.docx 模板
    // 执行多月报告特有的业务逻辑
    throw UnimplementedError('Multi-month report generation not implemented');
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
    // TODO: 实现季度报告生成逻辑
    // 使用 salary_report_template_quarterly.docx 模板
    // 执行季度报告特有的业务逻辑
    throw UnimplementedError('Quarterly report generation not implemented');
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
    // TODO: 实现年度报告生成逻辑
    // 使用 salary_report_template_annual.docx 模板
    // 执行年度报告特有的业务逻辑
    throw UnimplementedError('Annual report generation not implemented');
  }
}
