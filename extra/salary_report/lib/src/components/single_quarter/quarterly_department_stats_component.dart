import 'package:flutter/material.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 单季度部门统计卡片组件
class QuarterlyDepartmentStatsCard extends StatelessWidget {
  final int year;
  final int quarter;
  final List<DepartmentSalaryStats> departmentStats;

  const QuarterlyDepartmentStatsCard({
    super.key,
    required this.year,
    required this.quarter,
    required this.departmentStats,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> departmentStatsMap = {};

    for (DepartmentSalaryStats stat in departmentStats) {
      // departmentStatsMap[stat.department] = stat;
      if (departmentStatsMap.containsKey(stat.department)) {
        DepartmentSalaryStats existingStat =
            departmentStatsMap[stat.department];
        final newState = DepartmentSalaryStats(
          department: stat.department,
          employeeCount: existingStat.employeeCount + stat.employeeCount,
          totalNetSalary: existingStat.totalNetSalary + stat.totalNetSalary,
          averageNetSalary:
              (existingStat.totalNetSalary + stat.totalNetSalary) /
              (existingStat.employeeCount + stat.employeeCount),
          year: existingStat.year,
          month: existingStat.month,
        );

        departmentStatsMap[stat.department] = newState;
      } else {
        departmentStatsMap[stat.department] = stat;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$year年第$quarter季度部门统计',
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
            ...departmentStatsMap.values.map<Widget>((stat) {
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
            }),
          ],
        ),
      ),
    );
  }
}
