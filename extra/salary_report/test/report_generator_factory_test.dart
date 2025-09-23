import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';

void main() {
  group('ReportGeneratorFactory Tests', () {
    test('Should create MonthlyReportGenerator', () {
      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.singleMonth,
      );
      expect(
        generator.runtimeType.toString(),
        'EnhancedMonthlyReportGenerator',
      );
    });

    test('Should create MultiMonthReportGenerator', () {
      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.multiMonth,
      );
      expect(
        generator.runtimeType.toString(),
        'EnhancedMultiMonthReportGenerator',
      );
    });

    test('Should create QuarterlyReportGenerator', () {
      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.singleQuarter,
      );
      expect(
        generator.runtimeType.toString(),
        'EnhancedQuarterlyReportGenerator',
      );
    });

    test('Should create MultiQuarterlyReportGenerator', () {
      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.multiQuarter,
      );
      expect(
        generator.runtimeType.toString(),
        'EnhancedMultiMonthReportGenerator',
      );
    });

    test('Should create AnnualReportGenerator', () {
      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.singleYear,
      );
      expect(generator.runtimeType.toString(), 'EnhancedAnnualReportGenerator');
    });

    test('Should create MultiAnnualReportGenerator', () {
      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.multiYear,
      );
      expect(
        generator.runtimeType.toString(),
        'EnhancedMultiMonthReportGenerator',
      );
    });
  });
}
