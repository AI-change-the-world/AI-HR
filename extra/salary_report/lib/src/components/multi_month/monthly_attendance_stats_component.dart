import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';

class MonthlyAttendanceStatsComponent extends ConsumerWidget {
  final DateRangeParams params;

  const MonthlyAttendanceStatsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceStatsState = ref.watch(attendanceStatsProvider(params));

    return attendanceStatsState.when(
      data: (attendanceStats) {
        if (attendanceStats.attendanceData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 获取当前页的月份键
        // 注意：这里需要根据分页状态获取对应的月份数据
        // 由于我们没有直接的月份列表，我们需要从attendanceData的键中提取并排序
        final sortedMonthKeys = attendanceStats.attendanceData!.keys.toList()
          ..sort((a, b) {
            final aParts = a.split('-');
            final bParts = b.split('-');
            final aYear = int.parse(aParts[0]);
            final aMonth = int.parse(aParts[1]);
            final bYear = int.parse(bParts[0]);
            final bMonth = int.parse(bParts[1]);

            if (aYear != bYear) {
              return aYear.compareTo(bYear);
            }
            return aMonth.compareTo(bMonth);
          });

        return Column(
          children: sortedMonthKeys.map((monthKey) {
            final attendanceStatsList =
                attendanceStats.attendanceData![monthKey] ?? [];

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
                      '$year年$month月考勤统计',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 这里使用AttendancePagination组件来显示考勤数据
                    AttendancePagination(attendanceStats: attendanceStatsList),
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
}
