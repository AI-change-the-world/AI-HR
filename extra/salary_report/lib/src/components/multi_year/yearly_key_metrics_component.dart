import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/year_analysis_provider.dart';

class YearlyKeyMetricsComponent extends ConsumerWidget {
  final YearRangeParams params;

  const YearlyKeyMetricsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final keyMetricsState = ref.watch(keyMetricsProvider(params));

    return keyMetricsState.when(
      data: (keyMetrics) {
        if (keyMetrics.yearlyData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序月度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(keyMetrics.yearlyData!)
              ..sort((a, b) {
                if (a.year != b.year) {
                  return a.year.compareTo(b.year);
                }
                return a.month.compareTo(b.month);
              });

        // 将月度数据聚合为年度数据
        final yearlyAggregatedData = _aggregateMonthlyToYearly(
          sortedMonthlyData,
        );

        // 计算当前页的年份范围
        final start =
            paginationState.currentPage * paginationState.itemsPerPage;
        final end =
            (start + paginationState.itemsPerPage < yearlyAggregatedData.length)
            ? start + paginationState.itemsPerPage
            : yearlyAggregatedData.length;

        final pageEntries = yearlyAggregatedData.sublist(
          start,
          yearlyAggregatedData.length < end ? yearlyAggregatedData.length : end,
        );

        return Column(
          children: pageEntries.map((yearlyData) {
            return _buildYearlyCard(yearlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildYearlyCard(Map<String, dynamic> yearlyData) {
    // 从聚合的年度数据中获取统计信息
    final year = yearlyData['year'] as int;
    final employeeCount = yearlyData['employeeCount'] as int;
    final totalEmployeeCount = yearlyData['totalEmployeeCount'] as int;
    final totalSalary = yearlyData['totalSalary'] as double;
    final averageSalary = yearlyData['averageSalary'] as double;
    final highestSalary = yearlyData['highestSalary'] as double;
    final lowestSalary = yearlyData['lowestSalary'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$year年',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                _buildStatCard('总人次', employeeCount.toString(), Icons.people),
                _buildStatCard(
                  '总人数',
                  totalEmployeeCount.toString(),
                  Icons.group,
                ),
                _buildStatCard(
                  '工资总额',
                  '${totalSalary.toStringAsFixed(2)}元',
                  Icons.account_balance_wallet,
                ),
                _buildStatCard(
                  '平均工资',
                  '${averageSalary.toStringAsFixed(2)}元',
                  Icons.trending_up,
                ),
                _buildStatCard(
                  '最高工资',
                  '${highestSalary.toStringAsFixed(2)}元',
                  Icons.arrow_upward,
                ),
                _buildStatCard(
                  '最低工资',
                  '${lowestSalary.toStringAsFixed(2)}元',
                  Icons.arrow_downward,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 将月度数据聚合为年度数据
  List<Map<String, dynamic>> _aggregateMonthlyToYearly(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<int, List<MonthlyComparisonData>> yearlyGroups = {};

    // 按年份分组月度数据
    for (var monthData in monthlyData) {
      final year = monthData.year;

      if (!yearlyGroups.containsKey(year)) {
        yearlyGroups[year] = [];
      }
      yearlyGroups[year]!.add(monthData);
    }

    // 将分组后的数据聚合为年度数据
    return yearlyGroups.entries
        .map((entry) {
          final year = entry.key;
          final months = entry.value;

          if (months.isEmpty) return null;

          // 聚合年度数据
          int totalEmployeeCount = 0; // 总人次（所有月份的人数累加）
          double totalSalary = 0.0; // 总工资
          double highestSalary = 0.0; // 最高工资
          double lowestSalary = double.infinity; // 最低工资

          // 收集所有月份的员工（去重）
          final Set<MinimalEmployeeInfo> allWorkers = {};

          for (var monthData in months) {
            // 累加人次
            totalEmployeeCount += monthData.employeeCount;

            // 累加年度数据
            monthData.departmentStats.forEach((deptName, stat) {
              totalSalary += stat.totalNetSalary;

              if (stat.maxSalary > highestSalary) {
                highestSalary = stat.maxSalary;
              }
              if (stat.minSalary < lowestSalary && stat.minSalary > 0) {
                lowestSalary = stat.minSalary;
              }
            });

            // 收集所有员工（去重）
            allWorkers.addAll(monthData.workers);
          }

          if (lowestSalary == double.infinity) {
            lowestSalary = 0;
          }

          // 真实人数（去重后）
          final totalemployeecountActual = allWorkers.length;

          // 平均工资
          final averageSalary = totalemployeecountActual > 0
              ? totalSalary / totalemployeecountActual
              : 0.0;

          return {
            'year': year,
            'employeeCount': totalEmployeeCount, // 总人次
            'totalEmployeeCount': totalemployeecountActual, // 总人数（去重）
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
            'highestSalary': highestSalary,
            'lowestSalary': lowestSalary,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));
  }
}
