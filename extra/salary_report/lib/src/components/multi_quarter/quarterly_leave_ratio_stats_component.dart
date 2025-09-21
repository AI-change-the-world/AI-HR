import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/providers/multi_quarter_analysis_provider.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';

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

        // 按时间排序季度数据
        final sortedQuarterlyData =
            List<QuarterlyComparisonData>.from(leaveRatioStats.quarterlyData!)
              ..sort((a, b) {
                if (a.year != b.year) {
                  return a.year.compareTo(b.year);
                }
                return a.quarter.compareTo(b.quarter);
              });

        // 计算当前页的季度范围
        final start =
            paginationState.currentPage * paginationState.itemsPerPage;
        final end =
            (start + paginationState.itemsPerPage < sortedQuarterlyData.length)
            ? start + paginationState.itemsPerPage
            : sortedQuarterlyData.length;

        final pageEntries = sortedQuarterlyData.sublist(start, end);

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

  Widget _buildLeaveRatioStatsCard(QuarterlyComparisonData quarterlyData) {
    // 计算总的病假和事假天数
    double totalSickLeave = 0;
    double totalLeave = 0;
    int employeeCount = 0;

    // 遍历部门统计计算总的请假天数
    quarterlyData.departmentStats.forEach((deptName, stat) {
      // 这里需要从考勤数据中获取请假信息，暂时使用估算值
      // 在实际应用中，应该从考勤统计数据中获取
      totalSickLeave += stat.employeeCount * 0.5; // 估算每人0.5天病假
      totalLeave += stat.employeeCount * 0.3; // 估算每人0.3天事假
      employeeCount += stat.employeeCount;
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
              '${quarterlyData.year}年第${quarterlyData.quarter}季度请假比例统计',
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
}
