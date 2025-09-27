import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/monthly_analysis_service.dart';

class YearlyAnalysisService {
  final IsarDatabase _database;
  final MonthlyAnalysisService _monthlyService;

  YearlyAnalysisService(this._database)
    : _monthlyService = MonthlyAnalysisService(_database);

  /// 多年数据对比功能
  Future<MultiMonthComparisonData?> getMultiYearComparisonData(
    int startYear,
    int endYear,
  ) async {
    try {
      // 验证日期范围
      if (startYear > endYear) {
        logger.warning('Start year is after end year');
        return null;
      }

      final monthlyComparisons = <MonthlyComparisonData>[];

      // 遍历年份列表获取数据
      for (int year = startYear; year <= endYear; year++) {
        // 获取该年所有月份的数据
        for (int month = 1; month <= 12; month++) {
          final monthlyData = await _monthlyService.getMultiMonthComparisonData(
            year,
            month,
            year,
            month,
          );

          if (monthlyData != null &&
              monthlyData.monthlyComparisons.isNotEmpty) {
            monthlyComparisons.addAll(monthlyData.monthlyComparisons);
          }
        }
      }

      return MultiMonthComparisonData(
        monthlyComparisons: monthlyComparisons,
        startDate: DateTime(startYear),
        endDate: DateTime(endYear),
      );
    } catch (e) {
      logger.severe('Error getting multi-year comparison data: $e');
      rethrow;
    }
  }
}
