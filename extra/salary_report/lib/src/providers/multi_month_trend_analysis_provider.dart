import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart'; // 导入现有的DateRangeParams

// 部门和岗位趋势分析状态模型
class TrendAnalysisState {
  final List<Map<String, dynamic>> departmentMonthOverMonthData;
  final List<Map<String, dynamic>> departmentYearOverYearData;
  final List<Map<String, dynamic>> positionMonthOverMonthData;
  final List<Map<String, dynamic>> positionYearOverYearData;
  final bool isLoading;
  final String? error;

  TrendAnalysisState({
    required this.departmentMonthOverMonthData,
    required this.departmentYearOverYearData,
    required this.positionMonthOverMonthData,
    required this.positionYearOverYearData,
    this.isLoading = false,
    this.error,
  });

  TrendAnalysisState copyWith({
    List<Map<String, dynamic>>? departmentMonthOverMonthData,
    List<Map<String, dynamic>>? departmentYearOverYearData,
    List<Map<String, dynamic>>? positionMonthOverMonthData,
    List<Map<String, dynamic>>? positionYearOverYearData,
    bool? isLoading,
    String? error,
  }) {
    return TrendAnalysisState(
      departmentMonthOverMonthData:
          departmentMonthOverMonthData ?? this.departmentMonthOverMonthData,
      departmentYearOverYearData:
          departmentYearOverYearData ?? this.departmentYearOverYearData,
      positionMonthOverMonthData:
          positionMonthOverMonthData ?? this.positionMonthOverMonthData,
      positionYearOverYearData:
          positionYearOverYearData ?? this.positionYearOverYearData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// DataAnalysisService提供商
final dataAnalysisServiceProvider = Provider<DataAnalysisService>((ref) {
  final database = IsarDatabase();
  return DataAnalysisService(database);
});

// 部门和岗位趋势分析提供商
final trendAnalysisProvider =
    FutureProvider.family<TrendAnalysisState, DateRangeParams>((
      ref,
      params,
    ) async {
      final dataAnalysisService = ref.read(dataAnalysisServiceProvider);

      try {
        // 获取最后一个月份作为当前月份进行同比环比分析
        final currentYear = params.endYear;
        final currentMonth = params.endMonth;

        // 获取所有部门列表
        final departmentStats = await dataAnalysisService
            .getDepartmentAggregation(currentYear, currentMonth);
        final departments = departmentStats
            .map((stat) => stat.department)
            .toList();

        // 获取所有岗位列表
        final positionStats = await dataAnalysisService.getPositionSalaryStats(
          year: currentYear,
          month: currentMonth,
        );
        final positions = positionStats
            .map((stat) => stat.position)
            .toSet()
            .toList(); // 使用Set去重

        // 获取部门环比数据
        final departmentMonthOverMonthData = <Map<String, dynamic>>[];
        for (var department in departments) {
          try {
            final result = await dataAnalysisService
                .getDepartmentMonthOverMonthChange(
                  year: currentYear,
                  month: currentMonth,
                  department: department,
                );

            if (result.isNotEmpty &&
                result['month_over_month_change'] != null) {
              final changeData =
                  result['month_over_month_change'] as Map<String, dynamic>;
              departmentMonthOverMonthData.add({
                'department': department,
                'employee_count_change':
                    changeData['employee_count_change'] as int,
                'employee_count_change_percent':
                    changeData['employee_count_change_percent'] as double,
                'total_salary_change':
                    changeData['total_salary_change'] as double,
                'total_salary_change_percent':
                    changeData['total_salary_change_percent'] as double,
                'average_salary_change':
                    changeData['average_salary_change'] as double,
                'average_salary_change_percent':
                    changeData['average_salary_change_percent'] as double,
              });
            }
          } catch (e) {
            // 忽略单个部门的错误
            continue;
          }
        }

        // 获取部门同比数据
        final departmentYearOverYearData = <Map<String, dynamic>>[];
        for (var department in departments) {
          try {
            final result = await dataAnalysisService
                .getDepartmentYearOverYearChange(
                  year: currentYear,
                  month: currentMonth,
                  department: department,
                );

            if (result.isNotEmpty && result['year_over_year_change'] != null) {
              final changeData =
                  result['year_over_year_change'] as Map<String, dynamic>;
              departmentYearOverYearData.add({
                'department': department,
                'employee_count_change':
                    changeData['employee_count_change'] as int,
                'employee_count_change_percent':
                    changeData['employee_count_change_percent'] as double,
                'total_salary_change':
                    changeData['total_salary_change'] as double,
                'total_salary_change_percent':
                    changeData['total_salary_change_percent'] as double,
                'average_salary_change':
                    changeData['average_salary_change'] as double,
                'average_salary_change_percent':
                    changeData['average_salary_change_percent'] as double,
              });
            }
          } catch (e) {
            // 忽略单个部门的错误
            continue;
          }
        }

        // 获取岗位环比数据
        final positionMonthOverMonthData = <Map<String, dynamic>>[];
        for (var position in positions) {
          try {
            final result = await dataAnalysisService
                .getPositionMonthOverMonthChange(
                  year: currentYear,
                  month: currentMonth,
                  position: position,
                );

            if (result.isNotEmpty &&
                result['month_over_month_change'] != null) {
              final changeData =
                  result['month_over_month_change'] as Map<String, dynamic>;
              positionMonthOverMonthData.add({
                'position': position,
                'employee_count_change':
                    changeData['employee_count_change'] as int,
                'employee_count_change_percent':
                    changeData['employee_count_change_percent'] as double,
                'total_salary_change':
                    changeData['total_salary_change'] as double,
                'total_salary_change_percent':
                    changeData['total_salary_change_percent'] as double,
                'average_salary_change':
                    changeData['average_salary_change'] as double,
                'average_salary_change_percent':
                    changeData['average_salary_change_percent'] as double,
              });
            }
          } catch (e) {
            // 忽略单个岗位的错误
            continue;
          }
        }

        // 获取岗位同比数据
        final positionYearOverYearData = <Map<String, dynamic>>[];
        for (var position in positions) {
          try {
            final result = await dataAnalysisService
                .getPositionYearOverYearChange(
                  year: currentYear,
                  month: currentMonth,
                  position: position,
                );

            if (result.isNotEmpty && result['year_over_year_change'] != null) {
              final changeData =
                  result['year_over_year_change'] as Map<String, dynamic>;
              positionYearOverYearData.add({
                'position': position,
                'employee_count_change':
                    changeData['employee_count_change'] as int,
                'employee_count_change_percent':
                    changeData['employee_count_change_percent'] as double,
                'total_salary_change':
                    changeData['total_salary_change'] as double,
                'total_salary_change_percent':
                    changeData['total_salary_change_percent'] as double,
                'average_salary_change':
                    changeData['average_salary_change'] as double,
                'average_salary_change_percent':
                    changeData['average_salary_change_percent'] as double,
              });
            }
          } catch (e) {
            // 忽略单个岗位的错误
            continue;
          }
        }

        return TrendAnalysisState(
          departmentMonthOverMonthData: departmentMonthOverMonthData,
          departmentYearOverYearData: departmentYearOverYearData,
          positionMonthOverMonthData: positionMonthOverMonthData,
          positionYearOverYearData: positionYearOverYearData,
        );
      } catch (e) {
        return TrendAnalysisState(
          departmentMonthOverMonthData: [],
          departmentYearOverYearData: [],
          positionMonthOverMonthData: [],
          positionYearOverYearData: [],
          error: e.toString(),
        );
      }
    });
