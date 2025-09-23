import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/providers/multi_month_trend_analysis_provider.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart';

void main() {
  group('TrendAnalysisState', () {
    test('should create TrendAnalysisState with empty data', () {
      final state = TrendAnalysisState(
        departmentMonthOverMonthData: [],
        departmentYearOverYearData: [],
        positionMonthOverMonthData: [],
        positionYearOverYearData: [],
      );

      expect(state.departmentMonthOverMonthData, isEmpty);
      expect(state.departmentYearOverYearData, isEmpty);
      expect(state.positionMonthOverMonthData, isEmpty);
      expect(state.positionYearOverYearData, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('should create TrendAnalysisState with error', () {
      final state = TrendAnalysisState(
        departmentMonthOverMonthData: [],
        departmentYearOverYearData: [],
        positionMonthOverMonthData: [],
        positionYearOverYearData: [],
        error: 'Test error',
      );

      expect(state.error, 'Test error');
    });

    test('should copy TrendAnalysisState with new data', () {
      final originalState = TrendAnalysisState(
        departmentMonthOverMonthData: [],
        departmentYearOverYearData: [],
        positionMonthOverMonthData: [],
        positionYearOverYearData: [],
      );

      final newState = originalState.copyWith(
        departmentMonthOverMonthData: [
          {'department': '技术部', 'employee_count_change': 5},
        ],
      );

      expect(newState.departmentMonthOverMonthData, isNot(isEmpty));
      expect(newState.departmentMonthOverMonthData.first['department'], '技术部');
      expect(
        newState.departmentYearOverYearData,
        isEmpty,
      ); // Should remain unchanged
    });
  });

  group('DateRangeParams', () {
    test('should create DateRangeParams correctly', () {
      final params = DateRangeParams(
        startYear: 2023,
        startMonth: 1,
        endYear: 2023,
        endMonth: 12,
      );

      expect(params.startYear, 2023);
      expect(params.startMonth, 1);
      expect(params.endYear, 2023);
      expect(params.endMonth, 12);
    });
  });
}
