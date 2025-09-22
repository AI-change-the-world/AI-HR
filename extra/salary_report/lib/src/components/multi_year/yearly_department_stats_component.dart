import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/year_analysis_provider.dart';

class YearlyDepartmentStatsComponent extends ConsumerWidget {
  final YearRangeParams params;

  const YearlyDepartmentStatsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final departmentStatsState = ref.watch(departmentStatsProvider(params));

    return departmentStatsState.when(
      data: (departmentStats) {
        if (departmentStats.yearlyData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序年度数据
        final sortedYearlyData =
            List<YearlyComparisonData>.from(departmentStats.yearlyData!)
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
            return _buildYearlyDepartmentCard(yearlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildYearlyDepartmentCard(YearlyComparisonData yearlyData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${yearlyData.year}年部门统计',
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
                    '工资总额',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '平均工资',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...yearlyData.departmentStats.entries.map((entry) {
              final stat = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: Text(stat.department)),
                    Expanded(child: Text(stat.employeeCount.toString())),
                    Expanded(
                      child: Text('¥${stat.totalNetSalary.toStringAsFixed(2)}'),
                    ),
                    Expanded(
                      child: Text(
                        '¥${stat.averageNetSalary.toStringAsFixed(2)}',
                      ),
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
