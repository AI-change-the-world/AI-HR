import 'package:flutter/material.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 时间单位员工变化组件
/// 用于展示员工数量变化、新入职和离职员工详情
/// 支持月度、季度和年度数据
class TimeUnitEmployeeChangesComponent extends StatelessWidget {
  /// 员工变化数据
  final List<Map<String, dynamic>> changes;
  
  /// 时间单位标签（如"月"、"季度"、"年"）
  final String timeUnitLabel;
  
  /// 时间单位格式化函数，用于将时间单位值格式化为显示文本
  final String Function(dynamic timeUnit)? timeUnitFormatter;

  const TimeUnitEmployeeChangesComponent({
    super.key,
    required this.changes,
    this.timeUnitLabel = '月',
    this.timeUnitFormatter,
  });

  @override
  Widget build(BuildContext context) {
    if (changes.isEmpty) {
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

    logger.info('员工变化数据：$changes');

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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      timeUnitLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '员工数',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '新入职',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '离职',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '净变化',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 每个时间单位的数据块
            ...changes.map<Widget>((data) {
              final timeUnit = data['month'] ?? data['quarter'] ?? data['year'];
              final employeeCount = data['employeeCount'] as int;
              final newEmployees =
                  data['newEmployees'] as List<MinimalEmployeeInfo>;
              final resignedEmployees =
                  data['resignedEmployees'] as List<MinimalEmployeeInfo>;
              final netChange = data['netChange'] as int;

              // 格式化时间单位显示
              String timeUnitDisplay;
              if (timeUnitFormatter != null) {
                timeUnitDisplay = timeUnitFormatter!(timeUnit);
              } else {
                timeUnitDisplay = '$timeUnit $timeUnitLabel';
              }

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
                    // 时间单位 + 数据行
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            timeUnitDisplay,
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

/// 月度员工变化组件
/// 用于展示每月员工数量变化、新入职和离职员工详情
class MonthlyTimeUnitEmployeeChangesComponent extends StatelessWidget {
  /// 月度员工变化数据
  final List<Map<String, dynamic>> monthlyChanges;

  const MonthlyTimeUnitEmployeeChangesComponent({
    super.key,
    required this.monthlyChanges,
  });

  @override
  Widget build(BuildContext context) {
    return TimeUnitEmployeeChangesComponent(
      changes: monthlyChanges,
      timeUnitLabel: '月份',
      timeUnitFormatter: (timeUnit) => '$timeUnit 月',
    );
  }
}

/// 季度员工变化组件
/// 用于展示每季度员工数量变化、新入职和离职员工详情
class QuarterlyTimeUnitEmployeeChangesComponent extends StatelessWidget {
  /// 季度员工变化数据
  final List<Map<String, dynamic>> quarterlyChanges;

  const QuarterlyTimeUnitEmployeeChangesComponent({
    super.key,
    required this.quarterlyChanges,
  });

  @override
  Widget build(BuildContext context) {
    return TimeUnitEmployeeChangesComponent(
      changes: quarterlyChanges,
      timeUnitLabel: '季度',
      timeUnitFormatter: (timeUnit) => '第$timeUnit 季度',
    );
  }
}

/// 年度员工变化组件
/// 用于展示每年员工数量变化、新入职和离职员工详情
class YearlyTimeUnitEmployeeChangesComponent extends StatelessWidget {
  /// 年度员工变化数据
  final List<Map<String, dynamic>> yearlyChanges;

  const YearlyTimeUnitEmployeeChangesComponent({
    super.key,
    required this.yearlyChanges,
  });

  @override
  Widget build(BuildContext context) {
    return TimeUnitEmployeeChangesComponent(
      changes: yearlyChanges,
      timeUnitLabel: '年份',
      timeUnitFormatter: (timeUnit) => '$timeUnit 年',
    );
  }
}