// test/demo_report_generation.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/monthly_report_generator.dart'
    as monthly_gen;
import 'package:salary_report/src/pages/visualization/report/multi_month_report_generator.dart'
    as multi_month_gen;
import 'package:salary_report/src/pages/visualization/report/quarterly_report_generator.dart'
    as quarterly_gen;
import 'package:salary_report/src/pages/visualization/report/multi_quarterly_report_generator.dart'
    as multi_quarterly_gen;
import 'package:salary_report/src/pages/visualization/report/annual_report_generator.dart'
    as annual_gen;
import 'package:salary_report/src/pages/visualization/report/multi_annual_report_generator.dart'
    as multi_annual_gen;

void main() {
  group('Demo Report Generation Tests', () {
    test('Should create and verify all report generators', () {
      // 测试创建所有类型的报告生成器
      final monthlyGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.singleMonth,
      );
      expect(monthlyGenerator, isA<monthly_gen.MonthlyReportGenerator>());

      final multiMonthGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.multiMonth,
      );
      expect(
        multiMonthGenerator,
        isA<multi_month_gen.MultiMonthReportGenerator>(),
      );

      final quarterlyGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.singleQuarter,
      );
      expect(quarterlyGenerator, isA<quarterly_gen.QuarterlyReportGenerator>());

      final multiQuarterlyGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.multiQuarter,
      );
      expect(
        multiQuarterlyGenerator,
        isA<multi_quarterly_gen.MultiQuarterlyReportGenerator>(),
      );

      final annualGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.singleYear,
      );
      expect(annualGenerator, isA<annual_gen.AnnualReportGenerator>());

      final multiAnnualGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.multiYear,
      );
      expect(
        multiAnnualGenerator,
        isA<multi_annual_gen.MultiAnnualReportGenerator>(),
      );
    });

    test('Should verify ReportType enum values', () {
      // 验证报告类型枚举值
      expect(ReportType.values.length, 6);
      expect(ReportType.singleMonth.index, 0);
      expect(ReportType.multiMonth.index, 1);
      expect(ReportType.singleQuarter.index, 2);
      expect(ReportType.multiQuarter.index, 3);
      expect(ReportType.singleYear.index, 4);
      expect(ReportType.multiYear.index, 5);
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
