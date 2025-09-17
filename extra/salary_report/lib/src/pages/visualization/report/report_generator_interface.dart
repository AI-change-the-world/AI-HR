// src/report/report_generator_interface.dart

import 'report_types.dart';

/// 报告生成器接口
abstract class ReportGenerator {
  /// 生成报告
  ///
  /// [reportType] 报告类型
  /// [data] 报告数据
  /// [options] 报告选项
  /// 返回生成的报告文件路径
  Future<String> generateReport({
    required ReportType reportType,
    required ReportData data,
    required ReportOptions options,
  });
}
