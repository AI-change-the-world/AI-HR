import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_factory.dart';

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
      final monthlyGenerator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.singleMonth,
      );
      expect(
        monthlyGenerator.runtimeType.toString(),
        'EnhancedMonthlyReportGenerator',
      );

      final multiMonthGenerator =
          EnhancedReportGeneratorFactory.createGenerator(ReportType.multiMonth);
      expect(
        multiMonthGenerator.runtimeType.toString(),
        'EnhancedMultiMonthReportGenerator',
      );

      final quarterlyGenerator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.singleQuarter,
      );
      expect(
        quarterlyGenerator.runtimeType.toString(),
        'EnhancedQuarterlyReportGenerator',
      );

      final multiQuarterlyGenerator =
          EnhancedReportGeneratorFactory.createGenerator(
            ReportType.multiQuarter,
          );
      expect(
        multiQuarterlyGenerator.runtimeType.toString(),
        'EnhancedMultiMonthReportGenerator',
      );

      final annualGenerator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.singleYear,
      );
      expect(
        annualGenerator.runtimeType.toString(),
        'EnhancedAnnualReportGenerator',
      );

      final multiAnnualGenerator =
          EnhancedReportGeneratorFactory.createGenerator(ReportType.multiYear);
      expect(
        multiAnnualGenerator.runtimeType.toString(),
        'EnhancedMultiMonthReportGenerator',
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
