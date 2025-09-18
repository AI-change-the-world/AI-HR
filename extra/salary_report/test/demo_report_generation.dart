// test/demo_report_generation.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';

void main() {
  group('Demo Report Generation Tests', () {
    test('Should create and verify all report generators', () {
      // 测试创建所有类型的报告生成器
      final monthlyGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.monthly,
      );
      expect(monthlyGenerator, isA<MonthlyReportGenerator>());

      final multiMonthGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.multiMonth,
      );
      expect(multiMonthGenerator, isA<MultiMonthReportGenerator>());

      final quarterlyGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.quarterly,
      );
      expect(quarterlyGenerator, isA<QuarterlyReportGenerator>());

      final annualGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.annual,
      );
      expect(annualGenerator, isA<AnnualReportGenerator>());
    });

    test('Should verify ReportType enum values', () {
      // 验证报告类型枚举值
      expect(ReportType.values.length, 4);
      expect(ReportType.monthly.index, 0);
      expect(ReportType.multiMonth.index, 1);
      expect(ReportType.quarterly.index, 2);
      expect(ReportType.annual.index, 3);
    });

    test('Should verify ReportOptions defaults', () {
      // 验证报告选项默认值
      final options = ReportOptions();
      expect(options.includeCharts, isTrue);
      expect(options.includeAIAnalysis, isTrue);
      expect(options.companyName, '');
      expect(options.reportTitle, '');
    });
  });
}
