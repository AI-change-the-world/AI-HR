import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/year_analysis_provider.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';

class YearlyLeaveRatioStatsComponent extends ConsumerWidget {
  final YearRangeParams params;

  const YearlyLeaveRatioStatsComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final attendanceStatsState = ref.watch(attendanceStatsProvider(params));

    return attendanceStatsState.when(
      data: (attendanceStats) {
        if (attendanceStats.attendanceData == null ||
            attendanceStats.attendanceData!.isEmpty) {
          return const Center(child: Text('暂无数据'));
        }

        // 获取年份列表并排序
        final yearKeys = attendanceStats.attendanceData!.keys.toList()
          ..sort((a, b) {
            // 提取年份进行排序
            final yearA = int.tryParse(a.replaceAll('年', '')) ?? 0;
            final yearB = int.tryParse(b.replaceAll('年', '')) ?? 0;
            return yearA.compareTo(yearB);
          });

        // 计算当前页的年份范围
        final start =
            paginationState.currentPage * paginationState.itemsPerPage;
        final end = (start + paginationState.itemsPerPage < yearKeys.length)
            ? start + paginationState.itemsPerPage
            : yearKeys.length;

        final pageEntries = yearKeys.sublist(start, end);

        return Column(
          children: pageEntries.map((yearKey) {
            final stats = attendanceStats.attendanceData![yearKey] ?? [];
            // 过滤出有请假、缺勤或旷工记录的员工
            final leaveStats = stats.where((stat) {
              return stat.sickLeaveDays > 0 ||
                  stat.leaveDays > 0 ||
                  stat.absenceCount > 0 ||
                  stat.truancyDays > 0;
            }).toList();
            return _buildYearlyLeaveDetailsCard(yearKey, leaveStats);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildYearlyLeaveDetailsCard(
    String yearKey,
    List<AttendanceStats> leaveStats,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$yearKey请假详情',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (leaveStats.isEmpty)
              const Text('本年度无请假、缺勤或旷工记录')
            else
              // 使用分页组件展示详细请假数据
              AttendancePagination(attendanceStats: leaveStats),
          ],
        ),
      ),
    );
  }
}
