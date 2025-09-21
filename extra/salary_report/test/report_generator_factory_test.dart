import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';

void main() {
  group('ReportGeneratorFactory Tests', () {
    test('Should create MonthlyReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.singleMonth,
      );
      expect(generator.runtimeType.toString(), 'MonthlyReportGenerator');
    });

    test('Should create MultiMonthReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.multiMonth,
      );
      expect(generator.runtimeType.toString(), 'MultiMonthReportGenerator');
    });

    test('Should create QuarterlyReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.singleQuarter,
      );
      expect(generator.runtimeType.toString(), 'QuarterlyReportGenerator');
    });

    test('Should create MultiQuarterlyReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.multiQuarter,
      );
      expect(generator.runtimeType.toString(), 'MultiQuarterlyReportGenerator');
    });

    test('Should create AnnualReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.singleYear,
      );
      expect(generator.runtimeType.toString(), 'AnnualReportGenerator');
    });

    test('Should create MultiAnnualReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.multiYear,
      );
      expect(generator.runtimeType.toString(), 'MultiAnnualReportGenerator');
    });
  });
}
