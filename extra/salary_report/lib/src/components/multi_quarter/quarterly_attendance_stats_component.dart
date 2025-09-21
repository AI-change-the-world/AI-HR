import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/providers/multi_quarter_analysis_provider.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';

class QuarterlyAttendanceStatsComponent extends ConsumerWidget {
  final QuarterRangeParams params;

  const QuarterlyAttendanceStatsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final attendanceStatsState = ref.watch(attendanceStatsProvider(params));

    return attendanceStatsState.when(
      data: (attendanceStats) {
        if (attendanceStats.attendanceData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 获取所有季度的考勤数据
        final allAttendanceData = attendanceStats.attendanceData!.values
            .expand((x) => x)
            .toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  '考勤统计',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AttendancePagination(attendanceStats: allAttendanceData),
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
