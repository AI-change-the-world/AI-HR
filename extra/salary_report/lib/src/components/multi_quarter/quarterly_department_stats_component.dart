import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/multi_quarter_analysis_provider.dart';

class QuarterlyDepartmentStatsComponent extends ConsumerWidget {
  final QuarterRangeParams params;

  const QuarterlyDepartmentStatsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final departmentStatsState = ref.watch(departmentStatsProvider(params));

    return departmentStatsState.when(
      data: (departmentStats) {
        if (departmentStats.quarterlyData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序季度数据
        final sortedQuarterlyData =
            List<MonthlyComparisonData>.from(departmentStats.quarterlyData!)
              ..sort((a, b) {
                if (a.year != b.year) {
                  return a.year.compareTo(b.year);
                }
                return a.month.compareTo(b.month);
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
            return _buildDepartmentStatsCard(quarterlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildDepartmentStatsCard(MonthlyComparisonData quarterlyData) {
    final departmentStats = quarterlyData.departmentStats.values.toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${quarterlyData.year}年${quarterlyData.month}月部门统计',
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
                    '发薪人次',
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
                        '${stat.averageNetSalary.toStringAsFixed(2)}元',
                      ),
                    ),
                    Expanded(
                      child: Text('${stat.totalNetSalary.toStringAsFixed(2)}元'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
