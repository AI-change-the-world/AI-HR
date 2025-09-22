import 'package:flutter/material.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';

/// 构建多年度请假详情组件（包含缺勤和旷工信息）
class YearlyLeaveDetailBuilder {
  static Widget buildLeaveDetails(List<AttendanceStats> leaveDetails) {
    if (leaveDetails.isEmpty) {
      return const Text('本年度无请假、缺勤或旷工记录');
    }

    return AttendancePagination(attendanceStats: leaveDetails);
  }
}
