import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/isar/global_analysis_models.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart';

class MonthlyLeaveRatioStatsComponent extends ConsumerWidget {
  final DateRangeParams params;

  const MonthlyLeaveRatioStatsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final leaveRatioStatsState = ref.watch(leaveRatioStatsProvider(params));

    return leaveRatioStatsState.when(
      data: (leaveRatioStats) {
        if (leaveRatioStats.monthlyData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序月度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(leaveRatioStats.monthlyData!)
              ..sort((a, b) {
                if (a.year != b.year) {
                  return a.year.compareTo(b.year);
                }
                return a.month.compareTo(b.month);
              });

        // 计算当前页的月份范围
        final start =
            paginationState.currentPage * paginationState.itemsPerPage;
        final end =
            (start + paginationState.itemsPerPage < sortedMonthlyData.length)
            ? start + paginationState.itemsPerPage
            : sortedMonthlyData.length;

        final pageEntries = sortedMonthlyData.sublist(start, end);

        return Column(
          children: pageEntries.map((monthlyData) {
            return _buildLeaveRatioStatsCard(monthlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildLeaveRatioStatsCard(MonthlyComparisonData monthlyData) {
    // 创建LeaveRatioStats对象
    final leaveRatioStats = LeaveRatioStats(
      totalEmployees: monthlyData.employeeCount,
      sickLeaveRatio: 0.0, // 这些值需要从实际数据中获取
      leaveRatio: 0.0, // 这些值需要从实际数据中获取
      year: monthlyData.year,
      month: monthlyData.month,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${monthlyData.year}年${monthlyData.month}月请假比例统计',
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
                  Expanded(
                    child: Text(leaveRatioStats.totalEmployees.toString()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Expanded(child: Text('平均病假天数/人')),
                  Expanded(
                    child: Text(
                      leaveRatioStats.sickLeaveRatio.toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Expanded(child: Text('平均事假天数/人')),
                  Expanded(
                    child: Text(leaveRatioStats.leaveRatio.toStringAsFixed(2)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
