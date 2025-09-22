import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 月度员工变化组件
/// 用于展示每月员工数量变化、新入职和离职员工详情
class MonthlyEmployeeChangesComponent extends StatelessWidget {
  /// 月度员工变化数据
  final List<Map<String, dynamic>> monthlyChanges;

  const MonthlyEmployeeChangesComponent({
    super.key,
    required this.monthlyChanges,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyChanges.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '暂无员工变动数据',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    logger.info('月度员工变化数据：$monthlyChanges');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 表头
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      '月份',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '员工数',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '新入职',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '离职',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '净变化',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 每个月的数据块
            ...monthlyChanges.map<Widget>((data) {
              final month = data['month'] as int;
              final employeeCount = data['employeeCount'] as int;
              final newEmployees =
                  data['newEmployees'] as List<MinimalEmployeeInfo>;
              final resignedEmployees =
                  data['resignedEmployees'] as List<MinimalEmployeeInfo>;
              final netChange = data['netChange'] as int;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 月份 + 数据行
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$month 月',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(child: Text(employeeCount.toString())),
                        Expanded(child: Text(newEmployees.length.toString())),
                        Expanded(
                          child: Text(resignedEmployees.length.toString()),
                        ),
                        Expanded(
                          child: Text(
                            netChange.toString(),
                            style: TextStyle(
                              color: netChange > 0
                                  ? Colors.green
                                  : netChange < 0
                                  ? Colors.red
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),

                    // 详细变动信息
                    if (newEmployees.isNotEmpty ||
                        resignedEmployees.isNotEmpty) ...[
                      Text(
                        '详细变动情况：',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 新入职员工
                      if (newEmployees.isNotEmpty) ...[
                        const Text(
                          '新入职：',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: newEmployees.map((employee) {
                            return Chip(
                              avatar: const Icon(
                                Icons.person_add,
                                size: 16,
                                color: Colors.green,
                              ),
                              label: Text(
                                '${employee.name} (${employee.department})',
                              ),
                              backgroundColor: Colors.green.shade50,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 离职员工
                      if (resignedEmployees.isNotEmpty) ...[
                        const Text(
                          '离职：',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: resignedEmployees.map((employee) {
                            return Chip(
                              avatar: const Icon(
                                Icons.person_remove,
                                size: 16,
                                color: Colors.red,
                              ),
                              label: Text(
                                '${employee.name} (${employee.department})',
                              ),
                              backgroundColor: Colors.red.shade50,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
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
