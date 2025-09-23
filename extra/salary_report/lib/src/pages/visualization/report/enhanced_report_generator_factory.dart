// src/report/enhanced_report_generator_factory.dart

import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_monthly_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_multi_month_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_quarterly_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_annual_report_generator.dart';

/// 增强版报告生成器工厂
class EnhancedReportGeneratorFactory {
  /// 根据报告类型创建相应的增强版报告生成器
  static EnhancedReportGenerator createGenerator(ReportType type) {
    switch (type) {
      case ReportType.singleMonth:
        return EnhancedMonthlyReportGenerator();
      case ReportType.multiMonth:
        return EnhancedMultiMonthReportGenerator();
      case ReportType.singleQuarter:
        return EnhancedQuarterlyReportGenerator();
      case ReportType.multiQuarter:
        return EnhancedQuarterlyReportGenerator(); // 多季度报告可以复用季度报告生成器
      case ReportType.singleYear:
        return EnhancedAnnualReportGenerator();
      case ReportType.multiYear:
        return EnhancedAnnualReportGenerator(); // 多年报告可以复用年度报告生成器
    }
  }
}
