import 'package:flutter/material.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';

/// 通用的月度详细数据展示组件
class MonthlyDetailContainer extends StatelessWidget {
  final String title;
  final Map<String, dynamic> monthlyData;
  final Widget Function(String month, dynamic data) builder;

  const MonthlyDetailContainer({
    super.key,
    required this.title,
    required this.monthlyData,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...monthlyData.entries.map<Widget>((entry) {
          final month = entry.key;
          final data = entry.value;

          if (_isDataEmpty(data)) {
            return const SizedBox.shrink();
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    month,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  builder(month, data),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 检查数据是否为空
  bool _isDataEmpty(dynamic data) {
    if (data == null) return true;

    if (data is List) {
      return data.isEmpty;
    }

    if (data is LeaveRatioStats) {
      return data.totalEmployees == 0;
    }

    return false;
  }
}

/// 部门工资详细信息组件
class MonthlyDepartmentDetail extends StatelessWidget {
  final List<DepartmentSalaryStats> departmentStats;

  const MonthlyDepartmentDetail({super.key, required this.departmentStats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('部门', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text(
                '工资总额',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                '平均工资',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const Divider(),
        ...departmentStats.map<Widget>((stat) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(flex: 2, child: Text(stat.department)),
                Expanded(
                  child: Text('${stat.totalNetSalary.toStringAsFixed(2)}元'),
                ),
                Expanded(
                  child: Text('${stat.averageNetSalary.toStringAsFixed(2)}元'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// 考勤详细信息组件
class MonthlyAttendanceDetail extends StatelessWidget {
  final List<AttendanceStats> attendanceStats;

  const MonthlyAttendanceDetail({super.key, required this.attendanceStats});

  @override
  Widget build(BuildContext context) {
    return AttendancePagination(attendanceStats: attendanceStats);
  }
}

/// 请假详细信息组件
class MonthlyLeaveDetail extends StatelessWidget {
  final LeaveRatioStats leaveStats;
  final int year;
  final int month;

  const MonthlyLeaveDetail({
    super.key,
    required this.leaveStats,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: Text('统计项', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text('数值', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              const Expanded(child: Text('总员工数')),
              Expanded(child: Text(leaveStats.totalEmployees.toString())),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '具体请假情况请查看下方详细数据',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

/// 构建请假详情组件（包含缺勤和旷工信息）
class LeaveDetailBuilder {
  static Widget buildLeaveDetails(List<AttendanceStats> leaveDetails) {
    if (leaveDetails.isEmpty) {
      return const Text('本月无请假、缺勤或旷工记录');
    }

    return AttendancePagination(attendanceStats: leaveDetails);
  }
}
