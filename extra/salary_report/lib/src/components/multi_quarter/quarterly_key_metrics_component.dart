import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/multi_quarter_analysis_provider.dart';

class QuarterlyKeyMetricsComponent extends ConsumerWidget {
  final QuarterRangeParams params;

  const QuarterlyKeyMetricsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final keyMetricsState = ref.watch(keyMetricsProvider(params));

    return keyMetricsState.when(
      data: (keyMetrics) {
        if (keyMetrics.quarterlyData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序季度数据
        final sortedQuarterlyData =
            List<QuarterlyComparisonData>.from(keyMetrics.quarterlyData!)
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
            return _buildQuarterlyCard(quarterlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildQuarterlyCard(QuarterlyComparisonData quarterlyData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${quarterlyData.year}年第${quarterlyData.quarter}季度',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                _buildStatCard(
                  '总人次',
                  quarterlyData.employeeCount.toString(),
                  Icons.people,
                ),
                _buildStatCard(
                  '总人数',
                  quarterlyData.totalEmployeeCount.toString(),
                  Icons.group,
                ),
                _buildStatCard(
                  '工资总额',
                  '¥${quarterlyData.totalSalary.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                ),
                _buildStatCard(
                  '平均工资',
                  '¥${quarterlyData.averageSalary.toStringAsFixed(2)}',
                  Icons.trending_up,
                ),
                _buildStatCard(
                  '最高工资',
                  '¥${quarterlyData.highestSalary.toStringAsFixed(2)}',
                  Icons.arrow_upward,
                ),
                _buildStatCard(
                  '最低工资',
                  '¥${quarterlyData.lowestSalary.toStringAsFixed(2)}',
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
    return Card(
      elevation: 2,
      child: SizedBox(
        width: 150,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
