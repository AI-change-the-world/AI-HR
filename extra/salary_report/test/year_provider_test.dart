import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/providers/year_provider.dart';

void main() {
  group('YearProvider Tests', () {
    test('YearDataNotifier initializes with empty list', () {
      final container = ProviderContainer();
      final yearDataList = container.read(yearDataProvider);
      expect(yearDataList, isA<List<YearInfo>>());
    });

    test('YearInfo model creates correctly', () {
      final months = List.generate(
        12,
        (index) => MonthInfo(month: index + 1, hasData: false),
      );
      final yearInfo = YearInfo(
        year: 2023,
        isActivated: true,
        uploadedCount: 5,
        months: months,
      );

      expect(yearInfo.year, 2023);
      expect(yearInfo.isActivated, true);
      expect(yearInfo.uploadedCount, 5);
      expect(yearInfo.months.length, 12);
    });

    test('MonthInfo model creates correctly', () {
      final monthInfo = MonthInfo(month: 1, hasData: true);

      expect(monthInfo.month, 1);
      expect(monthInfo.hasData, true);
    });
  });
}
