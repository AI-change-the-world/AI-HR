import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/year_analysis_provider.dart';

class YearlyDepartmentChangesComponent extends ConsumerWidget {
  final YearRangeParams params;

  const YearlyDepartmentChangesComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentChangesState = ref.watch(departmentChangesProvider(params));

    return departmentChangesState.when(
      data: (departmentChanges) {
        if (departmentChanges.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        final yearlyComparisons =
            departmentChanges.comparisonData!.monthlyComparisons;

        if (yearlyComparisons.isEmpty) {
          return const Center(child: Text('暂无数据'));
        }

        // 按时间排序月度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(yearlyComparisons)..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        // 将月度数据聚合为年度数据
        final yearlyAggregatedData = _aggregateMonthlyToYearly(
          sortedMonthlyData,
        );

        // 计算部门变化情况
        final departmentChangesMap = <String, List<int>>{};

        // 初始化部门变化映射（使用聚合后的年度数据）
        for (var yearlyData in yearlyAggregatedData) {
          final departmentStats =
              yearlyData['departmentStats']
                  as Map<String, DepartmentSalaryStats>;
          departmentStats.forEach((deptName, stat) {
            if (!departmentChangesMap.containsKey(deptName)) {
              departmentChangesMap[deptName] = [];
            }
            // 现在employeeCount已经是去重后的真实人数
            departmentChangesMap[deptName]!.add(stat.employeeCount);
          });
        }

        // 计算员工入职和离职情况
        final employeeChangesMap = _calculateEmployeeChanges(
          departmentChanges.comparisonData!,
        );

        // 计算按部门分组的员工变化情况
        final departmentEmployeeChangesMap =
            _calculateDepartmentEmployeeChanges(
              departmentChanges.comparisonData!,
            );

        // 检查是否有任何变化
        bool hasChanges = false;
        for (var entry in departmentChangesMap.entries) {
          final employeeCounts = entry.value;
          if (employeeCounts.length > 1) {
            hasChanges = true;
          }
        }
        employeeChangesMap.forEach((year, changes) {
          if (changes['newEmployees']!.isNotEmpty ||
              changes['resignedEmployees']!.isNotEmpty) {
            hasChanges = true;
          }
        });
        departmentEmployeeChangesMap.forEach((year, deptChanges) {
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
            // 部门人数变化说明
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '部门人数变化说明',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '各部门在不同年份的人数变化情况：',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ...departmentChangesMap.entries.map((entry) {
                      final deptName = entry.key;
                      final employeeCounts = entry.value;

                      // 计算变化趋势
                      String trend = '';
                      if (employeeCounts.length > 1) {
                        final firstCount = employeeCounts.first;
                        final lastCount = employeeCounts.last;
                        if (lastCount > firstCount) {
                          trend = '↑ 增长';
                        } else if (lastCount < firstCount) {
                          trend = '↓ 减少';
                        } else {
                          trend = '→ 稳定';
                        }
                      } else {
                        trend = '→ 稳定';
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                deptName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text('${employeeCounts.join(' → ')} 人'),
                            ),
                            Expanded(
                              child: Text(
                                trend,
                                style: TextStyle(
                                  color: trend.contains('↑')
                                      ? Colors.green
                                      : trend.contains('↓')
                                      ? Colors.red
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
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

            // 员工入职和离职详情（总体）
            ...employeeChangesMap.entries.map((entry) {
              final yearKey = entry.key;
              final changes = entry.value;
              final newEmployees =
                  changes['newEmployees'] as List<MinimalEmployeeInfo>;
              final resignedEmployees =
                  changes['resignedEmployees'] as List<MinimalEmployeeInfo>;

              if (newEmployees.isEmpty && resignedEmployees.isEmpty) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$yearKey年员工变动详情（总体）',
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
                        }),
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
                        }),
                      ],
                    ],
                  ),
                ),
              );
            }),

            // 按部门分组的员工变化详情
            ...departmentEmployeeChangesMap.entries.map((entry) {
              final yearKey = entry.key;
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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$yearKey年员工变动详情（按部门）',
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
                                        employee.name,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }),
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
                                        employee.name,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  /// 计算员工入职和离职情况（总体）
  Map<String, Map<String, List<MinimalEmployeeInfo>>> _calculateEmployeeChanges(
    MultiMonthComparisonData comparisonData,
  ) {
    final Map<String, Map<String, List<MinimalEmployeeInfo>>> employeeChanges =
        {};

    // 按时间排序月度数据
    final sortedMonthly =
        List<MonthlyComparisonData>.from(comparisonData.monthlyComparisons)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.month.compareTo(b.month);
          });

    // 将月度数据聚合为年度数据，包含员工信息
    final yearlyAggregatedData = _aggregateMonthlyToYearlyWithWorkers(
      sortedMonthly,
    );

    // 遍历每个年份，比较与前一个年份的员工变化
    for (int i = 0; i < yearlyAggregatedData.length; i++) {
      final currentYear = yearlyAggregatedData[i];
      final yearKey = '${currentYear['year']}';

      if (!employeeChanges.containsKey(yearKey)) {
        employeeChanges[yearKey] = {
          'newEmployees': <MinimalEmployeeInfo>[],
          'resignedEmployees': <MinimalEmployeeInfo>[],
        };
      }

      // 如果不是第一个年份，比较与前一个年份的员工变化
      if (i > 0) {
        final previousYear = yearlyAggregatedData[i - 1];
        final currentWorkers =
            currentYear['workers'] as List<MinimalEmployeeInfo>;
        final previousWorkers =
            previousYear['workers'] as List<MinimalEmployeeInfo>;

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

        employeeChanges[yearKey]!['newEmployees'] = newEmployees;
        employeeChanges[yearKey]!['resignedEmployees'] = resignedEmployees;
      }
    }

    return employeeChanges;
  }

  /// 计算按部门分组的员工变化情况（精细化到部门）
  Map<String, Map<String, Map<String, List<MinimalEmployeeInfo>>>>
  _calculateDepartmentEmployeeChanges(MultiMonthComparisonData comparisonData) {
    final Map<String, Map<String, Map<String, List<MinimalEmployeeInfo>>>>
    departmentEmployeeChanges = {};

    // 按时间排序月度数据
    final sortedMonthly =
        List<MonthlyComparisonData>.from(comparisonData.monthlyComparisons)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.month.compareTo(b.month);
          });

    // 将月度数据聚合为年度数据，包含员工信息
    final yearlyAggregatedData = _aggregateMonthlyToYearlyWithWorkers(
      sortedMonthly,
    );

    // 遍历每个年份，比较与前一个年份的员工变化（按部门分组）
    for (int i = 0; i < yearlyAggregatedData.length; i++) {
      final currentYear = yearlyAggregatedData[i];
      final yearKey = '${currentYear['year']}';

      if (!departmentEmployeeChanges.containsKey(yearKey)) {
        departmentEmployeeChanges[yearKey] = {};
      }

      // 如果不是第一个年份，比较与前一个年份的员工变化
      if (i > 0) {
        final previousYear = yearlyAggregatedData[i - 1];

        // 按部门分组当前年份和前一个年份的员工
        final currentWorkersByDept = <String, Set<MinimalEmployeeInfo>>{};
        final previousWorkersByDept = <String, Set<MinimalEmployeeInfo>>{};

        // 分组当前年份员工
        final currentWorkers =
            currentYear['workers'] as List<MinimalEmployeeInfo>;
        for (var worker in currentWorkers) {
          if (!currentWorkersByDept.containsKey(worker.department)) {
            currentWorkersByDept[worker.department] = <MinimalEmployeeInfo>{};
          }
          currentWorkersByDept[worker.department]!.add(worker);
        }

        // 分组前一个年份员工
        final previousWorkers =
            previousYear['workers'] as List<MinimalEmployeeInfo>;
        for (var worker in previousWorkers) {
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
          if (!departmentEmployeeChanges[yearKey]!.containsKey(department)) {
            departmentEmployeeChanges[yearKey]![department] = {
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

          departmentEmployeeChanges[yearKey]![department]!['newEmployees'] =
              newEmployees;
          departmentEmployeeChanges[yearKey]![department]!['resignedEmployees'] =
              resignedEmployees;
        }
      }
    }

    return departmentEmployeeChanges;
  }

  /// 将月度数据聚合为年度数据
  List<Map<String, dynamic>> _aggregateMonthlyToYearly(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<int, List<MonthlyComparisonData>> yearlyGroups = {};

    // 按年份分组月度数据
    for (var monthData in monthlyData) {
      final year = monthData.year;

      if (!yearlyGroups.containsKey(year)) {
        yearlyGroups[year] = [];
      }
      yearlyGroups[year]!.add(monthData);
    }

    // 将分组后的数据聚合为年度数据
    return yearlyGroups.entries
        .map((entry) {
          final year = entry.key;
          final months = entry.value;

          if (months.isEmpty) return null;

          // 聚合部门统计数据
          final Map<String, DepartmentSalaryStats> aggregatedDepartmentStats =
              {};
          final Map<String, List<DepartmentSalaryStats>> deptMonthlyData = {};

          // 收集所有月份的部门数据
          for (var monthData in months) {
            monthData.departmentStats.forEach((deptName, stat) {
              if (!deptMonthlyData.containsKey(deptName)) {
                deptMonthlyData[deptName] = [];
              }
              deptMonthlyData[deptName]!.add(stat);
            });
          }

          // 聚合每个部门的年度数据
          deptMonthlyData.forEach((deptName, monthlyStats) {
            double totalNetSalary = 0.0;
            int maxEmployeeCount = 0;
            double maxSalary = 0;
            double minSalary = double.infinity;

            for (var stat in monthlyStats) {
              totalNetSalary += stat.totalNetSalary;
              if (stat.employeeCount > maxEmployeeCount) {
                maxEmployeeCount = stat.employeeCount;
              }
              if (stat.maxSalary > maxSalary) {
                maxSalary = stat.maxSalary;
              }
              if (stat.minSalary < minSalary && stat.minSalary > 0) {
                minSalary = stat.minSalary;
              }
            }

            if (minSalary == double.infinity) {
              minSalary = 0;
            }

            final averageNetSalary = maxEmployeeCount > 0
                ? totalNetSalary / maxEmployeeCount
                : 0.0;

            aggregatedDepartmentStats[deptName] = DepartmentSalaryStats(
              department: deptName,
              totalNetSalary: totalNetSalary,
              averageNetSalary: averageNetSalary,
              employeeCount: maxEmployeeCount,
              year: year,
              month: months.first.month,
              maxSalary: maxSalary,
              minSalary: minSalary,
            );
          });

          return {'year': year, 'departmentStats': aggregatedDepartmentStats};
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));
  }

  /// 将月度数据聚合为年度数据（包含员工信息）
  List<Map<String, dynamic>> _aggregateMonthlyToYearlyWithWorkers(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<int, List<MonthlyComparisonData>> yearlyGroups = {};

    // 按年份分组月度数据
    for (var monthData in monthlyData) {
      final year = monthData.year;

      if (!yearlyGroups.containsKey(year)) {
        yearlyGroups[year] = [];
      }
      yearlyGroups[year]!.add(monthData);
    }

    // 将分组后的数据聚合为年度数据
    return yearlyGroups.entries
        .map((entry) {
          final year = entry.key;
          final months = entry.value;

          if (months.isEmpty) return null;

          // 聚合员工信息（去重）
          final Set<MinimalEmployeeInfo> allWorkers = {};
          for (var monthData in months) {
            allWorkers.addAll(monthData.workers);
          }

          // 聚合部门统计数据
          final Map<String, DepartmentSalaryStats> aggregatedDepartmentStats =
              {};
          final Map<String, List<DepartmentSalaryStats>> deptMonthlyData = {};

          // 收集所有月份的部门数据
          for (var monthData in months) {
            monthData.departmentStats.forEach((deptName, stat) {
              if (!deptMonthlyData.containsKey(deptName)) {
                deptMonthlyData[deptName] = [];
              }
              deptMonthlyData[deptName]!.add(stat);
            });
          }

          // 聚合每个部门的年度数据
          deptMonthlyData.forEach((deptName, monthlyStats) {
            double totalNetSalary = 0.0;
            int maxEmployeeCount = 0;
            double maxSalary = 0;
            double minSalary = double.infinity;

            for (var stat in monthlyStats) {
              totalNetSalary += stat.totalNetSalary;
              if (stat.employeeCount > maxEmployeeCount) {
                maxEmployeeCount = stat.employeeCount;
              }
              if (stat.maxSalary > maxSalary) {
                maxSalary = stat.maxSalary;
              }
              if (stat.minSalary < minSalary && stat.minSalary > 0) {
                minSalary = stat.minSalary;
              }
            }

            if (minSalary == double.infinity) {
              minSalary = 0;
            }

            final averageNetSalary = maxEmployeeCount > 0
                ? totalNetSalary / maxEmployeeCount
                : 0.0;

            aggregatedDepartmentStats[deptName] = DepartmentSalaryStats(
              department: deptName,
              totalNetSalary: totalNetSalary,
              averageNetSalary: averageNetSalary,
              employeeCount: maxEmployeeCount,
              year: year,
              month: months.first.month,
              maxSalary: maxSalary,
              minSalary: minSalary,
            );
          });

          return {
            'year': year,
            'departmentStats': aggregatedDepartmentStats,
            'workers': allWorkers.toList(),
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));
  }
}
