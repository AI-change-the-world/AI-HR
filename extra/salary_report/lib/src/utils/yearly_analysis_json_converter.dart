import 'dart:convert';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 年度分析数据转JSON工具类
class YearlyAnalysisJsonConverter {
  /// 将年度分析数据转换为JSON格式
  static String convertAnalysisDataToJson({
    required Map<String, dynamic> analysisData,
    required List<DepartmentSalaryStats> departmentStats,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousYearData,
    required int year,
  }) {
    final jsonData = {
      'report_info': {
        'type': 'yearly_analysis',
        'year': year,
        'generated_at': DateTime.now().toIso8601String(),
      },
      'key_param': _generateKeyParam(analysisData, previousYearData),
      'key_metrics': _convertKeyMetrics(analysisData, previousYearData),
      'department_stats': _convertDepartmentStats(departmentStats),
      'department_stats_chart_data': _generateDepartmentStatsChartData(
        departmentStats,
      ),
      'monthly_trend': _convertMonthlyTrend(analysisData),
      'monthly_trend_chart_data': _generateMonthlyTrendChartData(analysisData),
      'attendance_stats': _convertAttendanceStats(attendanceStats),
      'attendance_stats_chart_data': _generateAttendanceStatsChartData(
        attendanceStats,
      ),
    };

    return JsonEncoder.withIndent('  ').convert(jsonData);
  }

  /// 生成关键参数描述
  static String _generateKeyParam(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousYearData,
  ) {
    final totalEmployees = analysisData['totalEmployees'] as int;
    final totalUniqueEmployees = analysisData['totalUniqueEmployees'] as int;
    final totalSalary = analysisData['totalSalary'] as double;
    final averageSalary = analysisData['averageSalary'] as double;
    final highestSalary = analysisData['highestSalary'] as double;
    final lowestSalary = analysisData['lowestSalary'] as double;

    String keyParam =
        '本年度共有$totalUniqueEmployees 名员工，发放工资$totalEmployees 人次，工资总额为¥${totalSalary.toStringAsFixed(2)}，平均工资为¥${averageSalary.toStringAsFixed(2)}，最高工资为¥${highestSalary.toStringAsFixed(2)}，最低工资为¥${lowestSalary.toStringAsFixed(2)}';

    if (previousYearData != null) {
      final prevTotalEmployees = previousYearData['totalEmployees'] as int;
      final prevTotalUniqueEmployees =
          previousYearData['totalUniqueEmployees'] as int;
      final prevTotalSalary = previousYearData['totalSalary'] as double;
      final prevAverageSalary = previousYearData['averageSalary'] as double;
      final prevHighestSalary = previousYearData['highestSalary'] as double;
      final prevLowestSalary = previousYearData['lowestSalary'] as double;

      final employeeChange = totalUniqueEmployees - prevTotalUniqueEmployees;
      final salaryChange = totalSalary - prevTotalSalary;
      final avgSalaryChange = averageSalary - prevAverageSalary;
      final highestSalaryChange = highestSalary - prevHighestSalary;
      final lowestSalaryChange = lowestSalary - prevLowestSalary;

      keyParam +=
          '，相比上年度（$prevTotalUniqueEmployees 名员工，发放工资$prevTotalEmployees 人次，工资总额为¥${prevTotalSalary.toStringAsFixed(2)}，平均工资为¥${prevAverageSalary.toStringAsFixed(2)}，最高工资为¥${prevHighestSalary.toStringAsFixed(2)}，最低工资为¥${prevLowestSalary.toStringAsFixed(2)}）';
      keyParam +=
          '，员工人数${employeeChange >= 0 ? "增加" : "减少"}${employeeChange.abs()}人';
      keyParam +=
          '，工资总额${salaryChange >= 0 ? "增加" : "减少"}¥${salaryChange.abs().toStringAsFixed(2)}';
      keyParam +=
          '，平均工资${avgSalaryChange >= 0 ? "上升" : "下降"}¥${avgSalaryChange.abs().toStringAsFixed(2)}';
      keyParam +=
          '，最高工资${highestSalaryChange >= 0 ? "上升" : "下降"}¥${highestSalaryChange.abs().toStringAsFixed(2)}';
      keyParam +=
          '，最低工资${lowestSalaryChange >= 0 ? "上升" : "下降"}¥${lowestSalaryChange.abs().toStringAsFixed(2)}';
    }

    return keyParam;
  }

  /// 转换关键指标数据
  static Map<String, dynamic> _convertKeyMetrics(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousYearData,
  ) {
    final keyMetrics = {
      'current_year': {
        'total_employees': analysisData['totalEmployees'],
        'total_unique_employees': analysisData['totalUniqueEmployees'],
        'total_salary': analysisData['totalSalary'],
        'average_salary': analysisData['averageSalary'],
        'highest_salary': analysisData['highestSalary'],
        'lowest_salary': analysisData['lowestSalary'],
      },
    };

    if (previousYearData != null) {
      keyMetrics['previous_year'] = {
        'year': previousYearData['year'],
        'total_employees': previousYearData['totalEmployees'],
        'total_unique_employees': previousYearData['totalUniqueEmployees'],
        'total_salary': previousYearData['totalSalary'],
        'average_salary': previousYearData['averageSalary'],
        'highest_salary': previousYearData['highestSalary'],
        'lowest_salary': previousYearData['lowestSalary'],
      };

      // 计算同比变化
      keyMetrics['year_over_year_change'] = {
        'total_employees_change':
            ((analysisData['totalEmployees'] -
                        previousYearData['totalEmployees']) /
                    previousYearData['totalEmployees'] *
                    100)
                .toStringAsFixed(2),
        'total_salary_change':
            ((analysisData['totalSalary'] - previousYearData['totalSalary']) /
                    previousYearData['totalSalary'] *
                    100)
                .toStringAsFixed(2),
        'average_salary_change':
            ((analysisData['averageSalary'] -
                        previousYearData['averageSalary']) /
                    previousYearData['averageSalary'] *
                    100)
                .toStringAsFixed(2),
        'highest_salary_change':
            ((analysisData['highestSalary'] -
                        previousYearData['highestSalary']) /
                    previousYearData['highestSalary'] *
                    100)
                .toStringAsFixed(2),
        'lowest_salary_change':
            ((analysisData['lowestSalary'] - previousYearData['lowestSalary']) /
                    previousYearData['lowestSalary'] *
                    100)
                .toStringAsFixed(2),
      };
    }

    return keyMetrics;
  }

  /// 转换员工变动数据
  static Map<String, dynamic> _convertEmployeeChanges(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousYearData,
  ) {
    // 年度分析中暂不处理员工变动详细信息
    return {'description': '年度员工变动详情请参考月度分析数据'};
  }

  /// 转换部门统计数据
  static List<Map<String, dynamic>> _convertDepartmentStats(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    return departmentStats.map((stat) {
      return {
        'department': stat.department,
        'employee_count': stat.employeeCount,
        'total_salary': stat.totalNetSalary,
        'average_salary': stat.averageNetSalary,
      };
    }).toList();
  }

  /// 生成部门统计图表数据
  static List<Map<String, dynamic>> _generateDepartmentStatsChartData(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    return departmentStats.map((stat) {
      return {
        'department': stat.department,
        'employee_count': stat.employeeCount,
        'total_salary': stat.totalNetSalary,
        'average_salary': stat.averageNetSalary,
      };
    }).toList();
  }

  /// 转换月度趋势数据
  static List<Map<String, dynamic>> _convertMonthlyTrend(
    Map<String, dynamic> analysisData,
  ) {
    final monthlyTrend =
        analysisData['monthlyTrend'] as List<Map<String, dynamic>>;
    return monthlyTrend.map((monthData) {
      return {
        'month': monthData['month'],
        'total_salary': monthData['totalSalary'],
      };
    }).toList();
  }

  /// 生成月度趋势图表数据
  static List<Map<String, dynamic>> _generateMonthlyTrendChartData(
    Map<String, dynamic> analysisData,
  ) {
    final monthlyTrend =
        analysisData['monthlyTrend'] as List<Map<String, dynamic>>;
    return monthlyTrend.map((monthData) {
      return {
        'month': monthData['month'],
        'total_salary': monthData['totalSalary'],
      };
    }).toList();
  }

  /// 转换考勤统计数据
  static List<Map<String, dynamic>> _convertAttendanceStats(
    List<AttendanceStats> attendanceStats,
  ) {
    return attendanceStats.map((stat) {
      return {
        'name': stat.name,
        'department': stat.department,
        'sick_leave_days': stat.sickLeaveDays,
        'leave_days': stat.leaveDays,
        'absence_count': stat.absenceCount,
        'truancy_days': stat.truancyDays,
        'year': stat.year,
        'month': stat.month,
      };
    }).toList();
  }

  /// 生成考勤统计图表数据
  static List<Map<String, dynamic>> _generateAttendanceStatsChartData(
    List<AttendanceStats> attendanceStats,
  ) {
    return attendanceStats.map((stat) {
      return {
        'name': stat.name,
        'department': stat.department,
        'sick_leave_days': stat.sickLeaveDays,
        'leave_days': stat.leaveDays,
        'absence_count': stat.absenceCount,
        'truancy_days': stat.truancyDays,
      };
    }).toList();
  }
}
