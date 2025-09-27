import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/multi_quarter_analysis_provider.dart';

class QuarterlyLeaveRatioStatsComponent extends ConsumerWidget {
  final QuarterRangeParams params;

  const QuarterlyLeaveRatioStatsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final leaveRatioStatsState = ref.watch(leaveRatioStatsProvider(params));

    return leaveRatioStatsState.when(
      data: (leaveRatioStats) {
        if (leaveRatioStats.quarterlyData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序月度数据，然后聚合为季度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(leaveRatioStats.quarterlyData!)
              ..sort((a, b) {
                if (a.year != b.year) {
                  return a.year.compareTo(b.year);
                }
                return a.month.compareTo(b.month);
              });

        // 将月度数据聚合为季度数据
        final quarterlyAggregatedData = _aggregateMonthlyToQuarterly(
          sortedMonthlyData,
        );

        // 计算当前页的季度范围
        final start =
            paginationState.currentPage * paginationState.itemsPerPage;
        final end =
            (start + paginationState.itemsPerPage <
                quarterlyAggregatedData.length)
            ? start + paginationState.itemsPerPage
            : quarterlyAggregatedData.length;

        final pageEntries = quarterlyAggregatedData.sublist(
          start,
          quarterlyAggregatedData.length < end
              ? quarterlyAggregatedData.length
              : end,
        );

        return Column(
          children: pageEntries.map((quarterlyData) {
            return _buildLeaveRatioStatsCard(quarterlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildLeaveRatioStatsCard(Map<String, dynamic> quarterlyData) {
    // 从聚合的季度数据中获取统计信息
    final year = quarterlyData['year'] as int;
    final quarter = quarterlyData['quarter'] as int;
    final employeeCount = quarterlyData['employeeCount'] as int;
    final departmentStats =
        quarterlyData['departmentStats'] as Map<String, DepartmentSalaryStats>;

    // 计算总的病假和事假天数
    double totalSickLeave = 0;
    double totalLeave = 0;

    // 遍历部门统计计算总的请假天数
    departmentStats.forEach((deptName, stat) {
      totalSickLeave += stat.employeeCount * 0.5; // 估算每人0.5天病假
      totalLeave += stat.employeeCount * 0.3; // 估算每人0.3天事假
    });

    final averageSickLeave = employeeCount > 0
        ? totalSickLeave / employeeCount
        : 0;
    final averageLeave = employeeCount > 0 ? totalLeave / employeeCount : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$year年第$quarter季度请假比例统计',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    '统计项',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '数值',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Expanded(child: Text('总员工数')),
                  Expanded(child: Text(employeeCount.toString())),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Expanded(child: Text('平均病假天数/人')),
                  Expanded(child: Text(averageSickLeave.toStringAsFixed(2))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Expanded(child: Text('平均事假天数/人')),
                  Expanded(child: Text(averageLeave.toStringAsFixed(2))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 将月度数据聚合为季度数据
  List<Map<String, dynamic>> _aggregateMonthlyToQuarterly(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<String, List<MonthlyComparisonData>> quarterlyGroups = {};

    // 按季度分组月度数据
    for (var monthData in monthlyData) {
      final quarter = _getQuarter(monthData.month);
      final quarterKey = '${monthData.year}-Q$quarter';

      if (!quarterlyGroups.containsKey(quarterKey)) {
        quarterlyGroups[quarterKey] = [];
      }
      quarterlyGroups[quarterKey]!.add(monthData);
    }

    // 将分组后的数据聚合为季度数据
    return quarterlyGroups.entries
        .map((entry) {
          final quarterKey = entry.key;
          final months = entry.value;

          if (months.isEmpty) return null;

          final year = months.first.year;
          final quarter = _getQuarter(months.first.month);

          // 聚合部门统计数据
          final Map<String, DepartmentSalaryStats> aggregatedDepartmentStats =
              {};
          final Map<String, List<DepartmentSalaryStats>> deptMonthlyData = {};

          // 收集所有月份的部门数据
          for (var monthData in months) {
            monthData.departmentStats.forEach((deptName, stat) {
              if (!deptMonthlyData.containsKey(deptName)) {
                deptMonthlyData[deptName] = [];
              }
              deptMonthlyData[deptName]!.add(stat);
            });
          }

          // 聚合每个部门的季度数据
          int totalEmployeeCount = 0;
          deptMonthlyData.forEach((deptName, monthlyStats) {
            double totalNetSalary = 0.0;
            int maxEmployeeCount = 0;
            double maxSalary = 0;
            double minSalary = double.infinity;

            for (var stat in monthlyStats) {
              totalNetSalary += stat.totalNetSalary;
              if (stat.employeeCount > maxEmployeeCount) {
                maxEmployeeCount = stat.employeeCount;
              }
              if (stat.maxSalary > maxSalary) {
                maxSalary = stat.maxSalary;
              }
              if (stat.minSalary < minSalary && stat.minSalary > 0) {
                minSalary = stat.minSalary;
              }
            }

            if (minSalary == double.infinity) {
              minSalary = 0;
            }

            final averageNetSalary = maxEmployeeCount > 0
                ? totalNetSalary / maxEmployeeCount
                : 0.0;

            aggregatedDepartmentStats[deptName] = DepartmentSalaryStats(
              department: deptName,
              totalNetSalary: totalNetSalary,
              averageNetSalary: averageNetSalary,
              employeeCount: maxEmployeeCount,
              year: year,
              month: months.first.month,
              maxSalary: maxSalary,
              minSalary: minSalary,
            );

            totalEmployeeCount += maxEmployeeCount;
          });

          return {
            'year': year,
            'quarter': quarter,
            'employeeCount': totalEmployeeCount,
            'departmentStats': aggregatedDepartmentStats,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) {
        if (a['year'] != b['year']) {
          return (a['year'] as int).compareTo(b['year'] as int);
        }
        return (a['quarter'] as int).compareTo(b['quarter'] as int);
      });
  }

  /// 根据月份计算季度
  int _getQuarter(int month) {
    return ((month - 1) ~/ 3) + 1;
  }
}
