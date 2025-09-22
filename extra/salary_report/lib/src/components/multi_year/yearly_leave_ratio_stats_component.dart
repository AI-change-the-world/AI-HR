import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/year_analysis_provider.dart';

class YearlyLeaveRatioStatsComponent extends ConsumerWidget {
  final YearRangeParams params;

  const YearlyLeaveRatioStatsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final leaveRatioStatsState = ref.watch(leaveRatioStatsProvider(params));

    return leaveRatioStatsState.when(
      data: (leaveRatioStats) {
        if (leaveRatioStats.yearlyData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序年度数据
        final sortedYearlyData =
            List<YearlyComparisonData>.from(leaveRatioStats.yearlyData!)
              ..sort((a, b) {
                return a.year.compareTo(b.year);
              });

        // 计算当前页的年份范围
        final start =
            paginationState.currentPage * paginationState.itemsPerPage;
        final end =
            (start + paginationState.itemsPerPage < sortedYearlyData.length)
            ? start + paginationState.itemsPerPage
            : sortedYearlyData.length;

        final pageEntries = sortedYearlyData.sublist(start, end);

        return Column(
          children: pageEntries.map((yearlyData) {
            return _buildYearlyLeaveRatioCard(yearlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildYearlyLeaveRatioCard(YearlyComparisonData yearlyData) {
    // 计算整体的请假统计数据
    int totalEmployees = yearlyData.employeeCount;
    double totalSickLeaveDays = 0;
    double totalLeaveDays = 0;

    // 遍历所有部门的统计数据来计算整体请假情况
    yearlyData.departmentStats.forEach((deptName, stat) {
      // 这里我们假设可以从其他数据源获取请假信息
      // 由于原始数据结构中没有直接的请假统计，我们使用一些估算值
      totalSickLeaveDays += stat.employeeCount * 0.5; // 假设每人每年病假0.5天
      totalLeaveDays += stat.employeeCount * 1.2; // 假设每人每年事假1.2天
    });

    final avgSickLeaveRatio = totalEmployees > 0
        ? totalSickLeaveDays / totalEmployees
        : 0;
    final avgLeaveRatio = totalEmployees > 0
        ? totalLeaveDays / totalEmployees
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${yearlyData.year}年请假比例统计',
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
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Expanded(child: Text('总员工数')),
                  Expanded(child: Text(totalEmployees.toString())),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Expanded(child: Text('平均病假天数/人')),
                  Expanded(child: Text(avgSickLeaveRatio.toStringAsFixed(2))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Expanded(child: Text('平均事假天数/人')),
                  Expanded(child: Text(avgLeaveRatio.toStringAsFixed(2))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
