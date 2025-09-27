// src/report/enhanced_report_generator_factory.dart

import 'package:salary_report/src/services/report_types.dart';
import 'package:salary_report/src/services/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/services/monthly/enhanced_monthly_report_generator.dart';
import 'package:salary_report/src/services/multi_month/enhanced_multi_month_report_generator.dart';
import 'package:salary_report/src/services/quarterly/enhanced_quarterly_report_generator.dart';
import 'package:salary_report/src/services/yearly/enhanced_yearly_report_generator.dart';

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
        return EnhancedMultiMonthReportGenerator(); // 多季度报告使用多月报告生成器
      case ReportType.singleYear:
        return EnhancedYearlyReportGenerator();
      case ReportType.multiYear:
        return EnhancedMultiMonthReportGenerator(); // 多年报告使用多月报告生成器
    }
  }
}
