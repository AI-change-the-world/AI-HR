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

        // 按时间排序年度数据
        final sortedYearlyData =
            List<YearlyComparisonData>.from(keyMetrics.yearlyData!)
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
            return _buildYearlyCard(yearlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildYearlyCard(YearlyComparisonData yearlyData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${yearlyData.year}年',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                _buildStatCard(
                  '总人次',
                  yearlyData.employeeCount.toString(),
                  Icons.people,
                ),
                _buildStatCard(
                  '工资总额',
                  '¥${yearlyData.totalSalary.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                ),
                _buildStatCard(
                  '平均工资',
                  '¥${yearlyData.averageSalary.toStringAsFixed(2)}',
                  Icons.trending_up,
                ),
                _buildStatCard(
                  '最高工资',
                  '¥${yearlyData.highestSalary.toStringAsFixed(2)}',
                  Icons.arrow_upward,
                ),
                _buildStatCard(
                  '最低工资',
                  '¥${yearlyData.lowestSalary.toStringAsFixed(2)}',
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
}
