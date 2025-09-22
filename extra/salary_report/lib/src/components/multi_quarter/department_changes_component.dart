import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/multi_quarter_analysis_provider.dart';

class DepartmentChangesComponent extends ConsumerWidget {
  final QuarterRangeParams params;

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
          params, // 传递参数用于检查是否是时间范围的起始季度
        );

        // 计算员工入职和离职情况
        final employeeChangesMap = _calculateEmployeeChanges(
          departmentChanges.comparisonData!,
          params,
        );

        // 计算按部门分组的员工变化情况
        final departmentEmployeeChangesMap =
            _calculateDepartmentEmployeeChanges(
              departmentChanges.comparisonData!,
              params,
            );

        // 检查是否有任何变化
        bool hasChanges = false;
        departmentChangesMap.forEach((quarter, changes) {
          if (changes.isNotEmpty) {
            hasChanges = true;
          }
        });
        employeeChangesMap.forEach((quarter, changes) {
          if (changes['newEmployees']!.isNotEmpty ||
              changes['resignedEmployees']!.isNotEmpty) {
            hasChanges = true;
          }
        });
        departmentEmployeeChangesMap.forEach((quarter, deptChanges) {
          deptChanges.forEach((dept, changes) {
            if (changes['newEmployees']!.isNotEmpty ||
                changes['resignedEmployees']!.isNotEmpty) {
              hasChanges = true;
            }
          });
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
          children: [
            // 部门变化
            ...departmentChangesMap.entries.map((entry) {
              final quarterKey = entry.key;
              final changes = entry.value;

              if (changes.isEmpty) {
                return const SizedBox.shrink();
              }

              // 解析季度信息
              final parts = quarterKey.split('-');
              final year = parts[0];
              final quarter = parts[1];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$year年第$quarter季度部门人数变化',
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

            // 员工入职和离职详情（总体）
            ...employeeChangesMap.entries.map((entry) {
              final quarterKey = entry.key;
              final changes = entry.value;
              final newEmployees =
                  changes['newEmployees'] as List<MinimalEmployeeInfo>;
              final resignedEmployees =
                  changes['resignedEmployees'] as List<MinimalEmployeeInfo>;

              if (newEmployees.isEmpty && resignedEmployees.isEmpty) {
                return const SizedBox.shrink();
              }

              // 解析季度信息
              final parts = quarterKey.split('-');
              final year = parts[0];
              final quarter = parts[1];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$year年第$quarter季度员工变动详情（总体）',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 新入职员工
                      if (newEmployees.isNotEmpty) ...[
                        const Text(
                          '新入职员工',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...newEmployees.map((employee) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_add,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${employee.name} (${employee.department})',
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                      ],

                      // 离职员工
                      if (resignedEmployees.isNotEmpty) ...[
                        const Text(
                          '离职员工',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...resignedEmployees.map((employee) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_remove,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${employee.name} (${employee.department})',
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),

            // 按部门分组的员工变化详情
            ...departmentEmployeeChangesMap.entries.map((entry) {
              final quarterKey = entry.key;
              final deptChanges = entry.value;

              bool hasDeptChanges = false;
              deptChanges.forEach((dept, changes) {
                if (changes['newEmployees']!.isNotEmpty ||
                    changes['resignedEmployees']!.isNotEmpty) {
                  hasDeptChanges = true;
                }
              });

              if (!hasDeptChanges) {
                return const SizedBox.shrink();
              }

              // 解析季度信息
              final parts = quarterKey.split('-');
              final year = parts[0];
              final quarter = parts[1];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$year年第$quarter季度员工变动详情（按部门）',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 按部门显示员工变化
                      ...deptChanges.entries.map((deptEntry) {
                        final department = deptEntry.key;
                        final changes = deptEntry.value;
                        final newEmployees =
                            changes['newEmployees']
                                as List<MinimalEmployeeInfo>;
                        final resignedEmployees =
                            changes['resignedEmployees']
                                as List<MinimalEmployeeInfo>;

                        if (newEmployees.isEmpty && resignedEmployees.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Text(
                                '部门：$department',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // 新入职员工
                            if (newEmployees.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.only(left: 16.0),
                                child: Text(
                                  '新入职：',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              ...newEmployees.map((employee) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 32.0,
                                    top: 2.0,
                                    bottom: 2.0,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person_add,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${employee.name}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],

                            // 离职员工
                            if (resignedEmployees.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.only(left: 16.0),
                                child: Text(
                                  '离职：',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              ...resignedEmployees.map((employee) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 32.0,
                                    top: 2.0,
                                    bottom: 2.0,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person_remove,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${employee.name}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 4),
                            ],
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  /// 计算部门人数变化情况
  Map<String, List<Map<String, dynamic>>> _calculateDepartmentChanges(
    MultiQuarterComparisonData comparisonData,
    QuarterRangeParams params, // 添加参数用于检查是否是时间范围的起始季度
  ) {
    final Map<String, List<Map<String, dynamic>>> departmentChanges = {};

    // 按时间顺序排列季度数据
    final sortedQuarters =
        List<QuarterlyComparisonData>.from(comparisonData.quarterlyComparisons)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.quarter.compareTo(b.quarter);
          });

    // 遍历每个季度，比较与前一个季度的部门人数变化
    for (int i = 0; i < sortedQuarters.length; i++) {
      final currentQuarter = sortedQuarters[i];
      final quarterKey = '${currentQuarter.year}-Q${currentQuarter.quarter}';

      if (!departmentChanges.containsKey(quarterKey)) {
        departmentChanges[quarterKey] = [];
      }

      // 如果不是第一个季度，比较与前一个季度的变化
      if (i > 0) {
        final previousQuarter = sortedQuarters[i - 1];
        final currentDepartments = currentQuarter.departmentStats;
        final previousDepartments = previousQuarter.departmentStats;

        // 检查现有部门的人数变化
        currentDepartments.forEach((deptName, currentStat) {
          if (previousDepartments.containsKey(deptName)) {
            final previousStat = previousDepartments[deptName]!;
            final countChange =
                currentStat.employeeCount - previousStat.employeeCount;

            if (countChange != 0) {
              departmentChanges[quarterKey]!.add({
                'department': deptName,
                'change': countChange,
                'type': 'change', // 人数变化
                'currentCount': currentStat.employeeCount,
                'previousCount': previousStat.employeeCount,
              });
            }
          } else {
            // 新增部门
            departmentChanges[quarterKey]!.add({
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
            departmentChanges[quarterKey]!.add({
              'department': deptName,
              'change': -previousStat.employeeCount,
              'type': 'removed', // 部门消失
              'currentCount': 0,
              'previousCount': previousStat.employeeCount,
            });
          }
        });
      } else {
        // 第一个季度，但只有当它不是用户指定的时间范围起始季度时才记录变化
        // 检查当前季度是否是用户指定的时间范围起始季度
        bool isUserSpecifiedStartQuarter =
            currentQuarter.year == params.startYear &&
            currentQuarter.quarter == params.startQuarter;

        // 如果是用户指定的时间范围起始季度，则不标记为新增部门
        // 因为我们没有更早的数据来进行比较
        if (!isUserSpecifiedStartQuarter) {
          currentQuarter.departmentStats.forEach((deptName, stat) {
            departmentChanges[quarterKey]!.add({
              'department': deptName,
              'change': stat.employeeCount,
              'type': 'new', // 新增部门
              'currentCount': stat.employeeCount,
              'previousCount': 0,
            });
          });
        }
        // 如果是用户指定的时间范围起始季度，则不添加任何变化记录
      }
    }

    return departmentChanges;
  }

  /// 计算员工入职和离职情况（总体）
  Map<String, Map<String, List<MinimalEmployeeInfo>>> _calculateEmployeeChanges(
    MultiQuarterComparisonData comparisonData,
    QuarterRangeParams params,
  ) {
    final Map<String, Map<String, List<MinimalEmployeeInfo>>> employeeChanges =
        {};

    // 按时间顺序排列季度数据
    final sortedQuarters =
        List<QuarterlyComparisonData>.from(comparisonData.quarterlyComparisons)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.quarter.compareTo(b.quarter);
          });

    // 遍历每个季度，比较与前一个季度的员工变化
    for (int i = 0; i < sortedQuarters.length; i++) {
      final currentQuarter = sortedQuarters[i];
      final quarterKey = '${currentQuarter.year}-Q${currentQuarter.quarter}';

      if (!employeeChanges.containsKey(quarterKey)) {
        employeeChanges[quarterKey] = {
          'newEmployees': <MinimalEmployeeInfo>[],
          'resignedEmployees': <MinimalEmployeeInfo>[],
        };
      }

      // 如果不是第一个季度，比较与前一个季度的员工变化
      if (i > 0) {
        final previousQuarter = sortedQuarters[i - 1];
        final currentWorkers = currentQuarter.workers;
        final previousWorkers = previousQuarter.workers;

        // 将员工列表转换为Set以提高查找效率
        final currentWorkerSet = currentWorkers.toSet();
        final previousWorkerSet = previousWorkers.toSet();

        // 找出新入职的员工
        final newEmployees = currentWorkerSet
            .difference(previousWorkerSet)
            .toList();

        // 找出离职的员工
        final resignedEmployees = previousWorkerSet
            .difference(currentWorkerSet)
            .toList();

        employeeChanges[quarterKey]!['newEmployees'] = newEmployees;
        employeeChanges[quarterKey]!['resignedEmployees'] = resignedEmployees;
      }
    }

    return employeeChanges;
  }

  /// 计算按部门分组的员工变化情况（精细化到部门）
  Map<String, Map<String, Map<String, List<MinimalEmployeeInfo>>>>
  _calculateDepartmentEmployeeChanges(
    MultiQuarterComparisonData comparisonData,
    QuarterRangeParams params,
  ) {
    final Map<String, Map<String, Map<String, List<MinimalEmployeeInfo>>>>
    departmentEmployeeChanges = {};

    // 按时间顺序排列季度数据
    final sortedQuarters =
        List<QuarterlyComparisonData>.from(comparisonData.quarterlyComparisons)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.quarter.compareTo(b.quarter);
          });

    // 遍历每个季度，比较与前一个季度的员工变化（按部门分组）
    for (int i = 0; i < sortedQuarters.length; i++) {
      final currentQuarter = sortedQuarters[i];
      final quarterKey = '${currentQuarter.year}-Q${currentQuarter.quarter}';

      if (!departmentEmployeeChanges.containsKey(quarterKey)) {
        departmentEmployeeChanges[quarterKey] = {};
      }

      // 如果不是第一个季度，比较与前一个季度的员工变化
      if (i > 0) {
        final previousQuarter = sortedQuarters[i - 1];

        // 按部门分组当前季度和前一个季度的员工
        final currentWorkersByDept = <String, Set<MinimalEmployeeInfo>>{};
        final previousWorkersByDept = <String, Set<MinimalEmployeeInfo>>{};

        // 分组当前季度员工
        for (var worker in currentQuarter.workers) {
          if (!currentWorkersByDept.containsKey(worker.department)) {
            currentWorkersByDept[worker.department] = <MinimalEmployeeInfo>{};
          }
          currentWorkersByDept[worker.department]!.add(worker);
        }

        // 分组前一个季度员工
        for (var worker in previousQuarter.workers) {
          if (!previousWorkersByDept.containsKey(worker.department)) {
            previousWorkersByDept[worker.department] = <MinimalEmployeeInfo>{};
          }
          previousWorkersByDept[worker.department]!.add(worker);
        }

        // 计算每个部门的员工变化
        final allDepartments = <String>{
          ...currentWorkersByDept.keys,
          ...previousWorkersByDept.keys,
        };

        for (var department in allDepartments) {
          if (!departmentEmployeeChanges[quarterKey]!.containsKey(department)) {
            departmentEmployeeChanges[quarterKey]![department] = {
              'newEmployees': <MinimalEmployeeInfo>[],
              'resignedEmployees': <MinimalEmployeeInfo>[],
            };
          }

          final currentDeptWorkers =
              currentWorkersByDept[department] ?? <MinimalEmployeeInfo>{};
          final previousDeptWorkers =
              previousWorkersByDept[department] ?? <MinimalEmployeeInfo>{};

          // 找出该部门新入职的员工
          final newEmployees = currentDeptWorkers
              .difference(previousDeptWorkers)
              .toList();

          // 找出该部门离职的员工
          final resignedEmployees = previousDeptWorkers
              .difference(currentDeptWorkers)
              .toList();

          departmentEmployeeChanges[quarterKey]![department]!['newEmployees'] =
              newEmployees;
          departmentEmployeeChanges[quarterKey]![department]!['resignedEmployees'] =
              resignedEmployees;
        }
      }
    }

    return departmentEmployeeChanges;
  }
}
