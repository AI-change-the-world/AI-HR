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

        // 初始化部门变化映射
        for (var yearlyData in yearlyAggregatedData) {
          final departmentStats =
              yearlyData['departmentStats']
                  as Map<String, DepartmentSalaryStats>;
          departmentStats.forEach((deptName, stat) {
            if (!departmentChangesMap.containsKey(deptName)) {
              departmentChangesMap[deptName] = [];
            }
            departmentChangesMap[deptName]!.add(stat.employeeCount);
          });
        }

        return Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '部门人数变化说明',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('各部门在不同年份的人数变化情况：', style: TextStyle(fontSize: 14)),
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
                            style: const TextStyle(fontWeight: FontWeight.w500),
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
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
}
