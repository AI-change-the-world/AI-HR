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
            departmentChanges.comparisonData!.yearlyComparisons;

        if (yearlyComparisons.isEmpty) {
          return const Center(child: Text('暂无数据'));
        }

        // 按年份排序
        final sortedYearlyData =
            List<YearlyComparisonData>.from(yearlyComparisons)..sort((a, b) {
              return a.year.compareTo(b.year);
            });

        // 计算部门变化情况
        final departmentChangesMap = <String, List<int>>{};

        // 初始化部门变化映射
        for (var yearlyData in sortedYearlyData) {
          yearlyData.departmentStats.forEach((deptName, stat) {
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
}
