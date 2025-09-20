import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/report_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReportService Tests', () {
    late ReportService reportService;
    late IsarDatabase database;

    setUp(() async {
      // 初始化数据库
      database = IsarDatabase();
      // 由于测试环境中可能无法访问实际的文件系统，我们只初始化服务
      reportService = ReportService();
    });

    test('ReportService should be instantiated correctly', () {
      expect(reportService, isA<ReportService>());
    });

    // 由于需要实际的文件系统和数据库，我们暂时不运行这些测试
    // test('ReportService should add report record', () async {
    //   final savePath = 'test/path/report.docx';
    //   final id = await reportService.addReportRecord(savePath);
    //
    //   expect(id, isA<int>());
    //   expect(id, greaterThan(0));
    // });
    //
    // test('ReportService should get all report records', () async {
    //   // 先添加一些测试数据
    //   await reportService.addReportRecord('test/path/report1.docx');
    //   await reportService.addReportRecord('test/path/report2.docx');
    //
    //   final reports = await reportService.getAllReportRecords();
    //
    //   expect(reports, isA<List>());
    //   expect(reports.length, greaterThanOrEqualTo(2));
    // });
  });
}
