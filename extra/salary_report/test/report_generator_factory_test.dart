import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';

void main() {
  group('ReportGeneratorFactory Tests', () {
    test('Should create MonthlyReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.monthly,
      );
      expect(generator, isA<MonthlyReportGenerator>());
    });

    test('Should create MultiMonthReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.multiMonth,
      );
      expect(generator, isA<MultiMonthReportGenerator>());
    });

    test('Should create QuarterlyReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.quarterly,
      );
      expect(generator, isA<QuarterlyReportGenerator>());
    });

    test('Should create AnnualReportGenerator', () {
      final generator = ReportGeneratorFactory.createGenerator(
        ReportType.annual,
      );
      expect(generator, isA<AnnualReportGenerator>());
    });
  });
}
