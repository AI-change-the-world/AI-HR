import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';

class MonthlyDepartmentStatsComponent extends ConsumerWidget {
  final DateRangeParams params;

  const MonthlyDepartmentStatsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final departmentStatsState = ref.watch(departmentStatsProvider(params));

    return departmentStatsState.when(
      data: (departmentStats) {
        if (departmentStats.monthlyData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序月度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(departmentStats.monthlyData!)
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
            return _buildDepartmentStatsCard(monthlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildDepartmentStatsCard(MonthlyComparisonData monthlyData) {
    final departmentStats = monthlyData.departmentStats.values.toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${monthlyData.year}年${monthlyData.month}月部门统计',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '部门',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '人数',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '平均工资',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '工资总额',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...departmentStats.map<Widget>((stat) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: Text(stat.department)),
                    Expanded(child: Text(stat.employeeCount.toString())),
                    Expanded(
                      child: Text(
                        '¥${stat.averageNetSalary.toStringAsFixed(2)}',
                      ),
                    ),
                    Expanded(
                      child: Text('¥${stat.totalNetSalary.toStringAsFixed(2)}'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
