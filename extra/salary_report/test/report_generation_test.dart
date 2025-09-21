import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_factory.dart';

void main() {
  group('Report Generation Tests', () {
    test('ReportType enum should have correct values', () {
      expect(ReportType.values.length, 6);
      expect(ReportType.singleMonth.index, 0);
      expect(ReportType.multiMonth.index, 1);
      expect(ReportType.singleQuarter.index, 2);
      expect(ReportType.multiQuarter.index, 3);
      expect(ReportType.singleYear.index, 4);
      expect(ReportType.multiYear.index, 5);
    });

    test('ReportGeneratorFactory should create correct generators', () {
      final monthlyGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.singleMonth,
      );
      expect(monthlyGenerator.runtimeType.toString(), 'MonthlyReportGenerator');

      final multiMonthGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.multiMonth,
      );
      expect(
        multiMonthGenerator.runtimeType.toString(),
        'MultiMonthReportGenerator',
      );

      final quarterlyGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.singleQuarter,
      );
      expect(
        quarterlyGenerator.runtimeType.toString(),
        'QuarterlyReportGenerator',
      );

      final multiQuarterlyGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.multiQuarter,
      );
      expect(
        multiQuarterlyGenerator.runtimeType.toString(),
        'MultiQuarterlyReportGenerator',
      );

      final annualGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.singleYear,
      );
      expect(annualGenerator.runtimeType.toString(), 'AnnualReportGenerator');

      final multiAnnualGenerator = ReportGeneratorFactory.createGenerator(
        ReportType.multiYear,
      );
      expect(
        multiAnnualGenerator.runtimeType.toString(),
        'MultiAnnualReportGenerator',
      );
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
