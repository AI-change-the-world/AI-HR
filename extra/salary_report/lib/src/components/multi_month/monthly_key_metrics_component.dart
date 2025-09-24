import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart';

class MonthlyKeyMetricsComponent extends ConsumerWidget {
  final DateRangeParams params;

  const MonthlyKeyMetricsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyMetricsState = ref.watch(keyMetricsProvider(params));

    return keyMetricsState.when(
      data: (keyMetrics) {
        logger.info('keyMetrics: ${keyMetrics.monthlyData?.length}');
        if (keyMetrics.monthlyData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序月度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(keyMetrics.monthlyData!)
              ..sort((a, b) {
                if (a.year != b.year) {
                  return a.year.compareTo(b.year);
                }
                return a.month.compareTo(b.month);
              });

        // 计算当前页的月份范围

        return Column(
          children: sortedMonthlyData.map((monthlyData) {
            return _buildMonthlyCard(monthlyData);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildMonthlyCard(MonthlyComparisonData monthlyData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${monthlyData.year}年${monthlyData.month}月',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                _buildStatCard(
                  '总人次',
                  monthlyData.employeeCount.toString(),
                  Icons.people,
                ),
                _buildStatCard(
                  '工资总额',
                  '${monthlyData.totalSalary.toStringAsFixed(2)}元',
                  Icons.account_balance_wallet,
                ),
                _buildStatCard(
                  '平均工资',
                  '${monthlyData.averageSalary.toStringAsFixed(2)}元',
                  Icons.trending_up,
                ),
                _buildStatCard(
                  '最高工资',
                  '${monthlyData.highestSalary.toStringAsFixed(2)}元',
                  Icons.arrow_upward,
                ),
                _buildStatCard(
                  '最低工资',
                  '${monthlyData.lowestSalary.toStringAsFixed(2)}元',
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
