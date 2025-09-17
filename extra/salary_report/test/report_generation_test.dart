import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_factory.dart';

void main() {
  group('Report Generation Tests', () {
    test('ReportType enum should have correct values', () {
      expect(ReportType.values.length, 4);
      expect(ReportType.monthly.index, 0);
      expect(ReportType.multiMonth.index, 1);
      expect(ReportType.quarterly.index, 2);
      expect(ReportType.annual.index, 3);
    });

    test('ReportGeneratorFactory should create correct generators', () {
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

    test('ReportOptions should be instantiated correctly', () {
      final options = ReportOptions();
      expect(options.includeCharts, isTrue);
      expect(options.includeAIAnalysis, isTrue);
      expect(options.companyName, '');
      expect(options.reportTitle, '');
    });
  });
}
