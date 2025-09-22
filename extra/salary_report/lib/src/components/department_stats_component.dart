import 'package:flutter/material.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 通用部门统计组件（用于月度和年度分析）
class DepartmentStatsComponent extends StatelessWidget {
  final List<DepartmentSalaryStats> departmentStats;
  final String title;

  const DepartmentStatsComponent({
    super.key,
    required this.departmentStats,
    this.title = '部门工资对比',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                            '¥${stat.totalNetSalary.toStringAsFixed(2)}',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '¥${stat.averageNetSalary.toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
