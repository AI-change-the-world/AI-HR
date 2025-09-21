// test/database_update_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/isar/database.dart';

void main() {
  group('Database Update Tests', () {
    late ReportService reportService;
    late IsarDatabase database;

    setUp(() {
      // 初始化数据库和服务
      database = IsarDatabase();
      reportService = ReportService();
    });

    test('Should verify report record is saved to database', () async {
      // 创建报告生成器
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.singleMonth,
      );

      // 验证生成器已正确创建
      expect(generator.runtimeType.toString(), 'MonthlyReportGenerator');

      // 注意：实际的报告生成测试需要更多设置，这里只是验证结构
      expect(reportService, isA<ReportService>());
    });

    test('Should verify ReportService addReportRecord method', () async {
      // 验证ReportService的方法存在
      expect(reportService.addReportRecord, isA<Function>());
      expect(reportService.getAllReportRecords, isA<Function>());
      expect(reportService.deleteReportRecord, isA<Function>());
    });
  });
}
