import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/providers/year_analysis_provider.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';

class YearlyAttendanceStatsComponent extends ConsumerWidget {
  final YearRangeParams params;

  const YearlyAttendanceStatsComponent({super.key, required this.params});

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
            return _buildYearlyAttendanceCard(yearKey, stats);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  Widget _buildYearlyAttendanceCard(
    String yearKey,
    List<AttendanceStats> stats,
  ) {
    // 计算统计数据
    double totalSickLeaveDays = 0;
    double totalLeaveDays = 0;
    int totalAbsenceCount = 0;
    int totalTruancyDays = 0;

    for (var stat in stats) {
      totalSickLeaveDays += stat.sickLeaveDays;
      totalLeaveDays += stat.leaveDays;
      totalAbsenceCount += stat.absenceCount;
      totalTruancyDays += stat.truancyDays;
    }

    final avgSickLeaveDays = stats.isNotEmpty
        ? totalSickLeaveDays / stats.length
        : 0;
    final avgLeaveDays = stats.isNotEmpty ? totalLeaveDays / stats.length : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$yearKey考勤统计',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 使用分页组件展示详细考勤数据
            AttendancePagination(attendanceStats: stats),
            const SizedBox(height: 16),
            // 汇总统计信息
            Wrap(
              children: [
                _buildStatCard(
                  '总病假天数',
                  totalSickLeaveDays.toStringAsFixed(1),
                  Icons.local_hospital,
                ),
                _buildStatCard(
                  '总事假天数',
                  totalLeaveDays.toStringAsFixed(1),
                  Icons.event_busy,
                ),
                _buildStatCard(
                  '总缺勤次数',
                  totalAbsenceCount.toString(),
                  Icons.cancel,
                ),
                _buildStatCard(
                  '总旷工天数',
                  totalTruancyDays.toString(),
                  Icons.warning,
                ),
                _buildStatCard(
                  '平均病假天数/人',
                  avgSickLeaveDays.toStringAsFixed(2),
                  Icons.local_hospital,
                ),
                _buildStatCard(
                  '平均事假天数/人',
                  avgLeaveDays.toStringAsFixed(2),
                  Icons.event_busy,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
