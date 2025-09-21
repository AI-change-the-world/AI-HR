import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart';

class DepartmentChangesComponent extends ConsumerWidget {
  final DateRangeParams params;

  const DepartmentChangesComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentChangesState = ref.watch(departmentChangesProvider(params));

    return departmentChangesState.when(
      data: (departmentChanges) {
        if (departmentChanges.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 计算部门人数变化情况
        final departmentChangesMap = _calculateDepartmentChanges(
          departmentChanges.comparisonData!,
          params, // 传递参数用于检查是否是时间范围的起始月
        );

        // 检查是否有任何变化
        bool hasChanges = false;
        departmentChangesMap.forEach((month, changes) {
          if (changes.isNotEmpty) {
            hasChanges = true;
          }
        });

        if (!hasChanges) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '各部门人数在统计期间内无变化',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: departmentChangesMap.entries.map((entry) {
            final monthKey = entry.key;
            final changes = entry.value;

            if (changes.isEmpty) {
              return const SizedBox.shrink();
            }

            // 解析月份信息
            final parts = monthKey.split('-');
            final year = parts[0];
            final month = parts[1];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$year年$month月部门人数变化',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...changes.map<Widget>((change) {
                      final department = change['department'] as String;
                      final countChange = change['change'] as int;
                      final type = change['type'] as String;
                      final currentCount = change['currentCount'] as int;
                      final previousCount = change['previousCount'] as int;

                      String changeText;
                      Color changeColor;

                      if (type == 'new') {
                        changeText = '新增部门，当前人数：$currentCount';
                        changeColor = Colors.green;
                      } else if (type == 'removed') {
                        changeText = '部门消失，原有人数：$previousCount';
                        changeColor = Colors.red;
                      } else {
                        if (countChange > 0) {
                          changeText =
                              '人数增加 $countChange 人，从 $previousCount 人增加到 $currentCount 人';
                          changeColor = Colors.green;
                        } else {
                          changeText =
                              '人数减少 ${-countChange} 人，从 $previousCount 人减少到 $currentCount 人';
                          changeColor = Colors.red;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              type == 'new'
                                  ? Icons.add_circle
                                  : type == 'removed'
                                  ? Icons.remove_circle
                                  : countChange > 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: changeColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$department: $changeText',
                                style: TextStyle(color: changeColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  /// 计算部门人数变化情况
  Map<String, List<Map<String, dynamic>>> _calculateDepartmentChanges(
    MultiMonthComparisonData comparisonData,
    DateRangeParams params, // 添加参数用于检查是否是时间范围的起始月
  ) {
    final Map<String, List<Map<String, dynamic>>> departmentChanges = {};

    // 按时间顺序排列月份数据
    final sortedMonths =
        List<MonthlyComparisonData>.from(comparisonData.monthlyComparisons)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.month.compareTo(b.month);
          });

    // 遍历每个月份，比较与前一个月的部门人数变化
    for (int i = 0; i < sortedMonths.length; i++) {
      final currentMonth = sortedMonths[i];
      final monthKey =
          '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';

      if (!departmentChanges.containsKey(monthKey)) {
        departmentChanges[monthKey] = [];
      }

      // 如果不是第一个月份，比较与前一个月的变化
      if (i > 0) {
        final previousMonth = sortedMonths[i - 1];
        final currentDepartments = currentMonth.departmentStats;
        final previousDepartments = previousMonth.departmentStats;

        // 检查现有部门的人数变化
        currentDepartments.forEach((deptName, currentStat) {
          if (previousDepartments.containsKey(deptName)) {
            final previousStat = previousDepartments[deptName]!;
            final countChange =
                currentStat.employeeCount - previousStat.employeeCount;

            if (countChange != 0) {
              departmentChanges[monthKey]!.add({
                'department': deptName,
                'change': countChange,
                'type': 'change', // 人数变化
                'currentCount': currentStat.employeeCount,
                'previousCount': previousStat.employeeCount,
              });
            }
          } else {
            // 新增部门
            departmentChanges[monthKey]!.add({
              'department': deptName,
              'change': currentStat.employeeCount,
              'type': 'new', // 新增部门
              'currentCount': currentStat.employeeCount,
              'previousCount': 0,
            });
          }
        });

        // 检查消失的部门
        previousDepartments.forEach((deptName, previousStat) {
          if (!currentDepartments.containsKey(deptName)) {
            // 部门消失
            departmentChanges[monthKey]!.add({
              'department': deptName,
              'change': -previousStat.employeeCount,
              'type': 'removed', // 部门消失
              'currentCount': 0,
              'previousCount': previousStat.employeeCount,
            });
          }
        });
      } else {
        // 第一个月，但只有当它不是用户指定的时间范围起始月时才记录变化
        // 检查当前月份是否是用户指定的时间范围起始月
        bool isUserSpecifiedStartMonth =
            currentMonth.year == params.startYear &&
            currentMonth.month == params.startMonth;

        // 如果是用户指定的时间范围起始月，则不标记为新增部门
        // 因为我们没有更早的数据来进行比较
        if (!isUserSpecifiedStartMonth) {
          currentMonth.departmentStats.forEach((deptName, stat) {
            departmentChanges[monthKey]!.add({
              'department': deptName,
              'change': stat.employeeCount,
              'type': 'new', // 新增部门
              'currentCount': stat.employeeCount,
              'previousCount': 0,
            });
          });
        }
        // 如果是用户指定的时间范围起始月，则不添加任何变化记录
      }
    }

    return departmentChanges;
  }
}
