import 'dart:convert';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 季度分析数据转JSON工具类
class QuarterlyAnalysisJsonConverter {
  /// 将季度分析数据转换为JSON格式
  static String convertAnalysisDataToJson({
    required Map<String, dynamic> analysisData,
    required List<DepartmentSalaryStats> departmentStats,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousQuarterData,
    required int year,
    required int quarter,
  }) {
    final jsonData = {
      'report_info': {
        'type': 'quarterly_analysis',
        'year': year,
        'quarter': quarter,
        'generated_at': DateTime.now().toIso8601String(),
      },
      'key_param': _generateKeyParam(analysisData, previousQuarterData),
      'key_metrics': _convertKeyMetrics(analysisData, previousQuarterData),
      'department_stats': _convertDepartmentStats(departmentStats),
      'department_stats_chart_data': _generateDepartmentStatsChartData(
        departmentStats,
      ),
      'salary_ranges': _convertSalaryRanges(analysisData),
      'salary_ranges_chart_data': _generateSalaryRangesChartData(analysisData),
      'department_salary_ranges': _convertDepartmentSalaryRanges(analysisData),
      'department_salary_ranges_chart_data':
          _generateDepartmentSalaryRangesChartData(analysisData),
      'monthly_breakdown': _convertMonthlyBreakdown(analysisData),
      'monthly_breakdown_chart_data': _generateMonthlyBreakdownChartData(
        analysisData,
      ),
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
    Map<String, dynamic>? previousQuarterData,
  ) {
    final totalEmployees = analysisData['totalEmployees'] as int;
    final totalUniqueEmployees = analysisData['totalUniqueEmployees'] as int;
    final totalSalary = analysisData['totalSalary'] as double;
    final averageSalary = analysisData['averageSalary'] as double;
    final highestSalary = analysisData['highestSalary'] as double;
    final lowestSalary = analysisData['lowestSalary'] as double;

    String keyParam =
        '本季度共有$totalUniqueEmployees 名员工，发放工资$totalEmployees 人次，工资总额为¥${totalSalary.toStringAsFixed(2)}，平均工资为¥${averageSalary.toStringAsFixed(2)}，最高工资为¥${highestSalary.toStringAsFixed(2)}，最低工资为¥${lowestSalary.toStringAsFixed(2)}';

    if (previousQuarterData != null) {
      final prevTotalEmployees = previousQuarterData['totalEmployees'] as int;
      final prevTotalUniqueEmployees =
          previousQuarterData['totalUniqueEmployees'] as int;
      final prevTotalSalary = previousQuarterData['totalSalary'] as double;
      final prevAverageSalary = previousQuarterData['averageSalary'] as double;
      final prevHighestSalary = previousQuarterData['highestSalary'] as double;
      final prevLowestSalary = previousQuarterData['lowestSalary'] as double;

      final employeeChange = totalUniqueEmployees - prevTotalUniqueEmployees;
      final salaryChange = totalSalary - prevTotalSalary;
      final avgSalaryChange = averageSalary - prevAverageSalary;
      final highestSalaryChange = highestSalary - prevHighestSalary;
      final lowestSalaryChange = lowestSalary - prevLowestSalary;

      keyParam +=
          '，相比上季度（$prevTotalUniqueEmployees 名员工，发放工资$prevTotalEmployees 人次，工资总额为¥${prevTotalSalary.toStringAsFixed(2)}，平均工资为¥${prevAverageSalary.toStringAsFixed(2)}，最高工资为¥${prevHighestSalary.toStringAsFixed(2)}，最低工资为¥${prevLowestSalary.toStringAsFixed(2)}）';
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
    Map<String, dynamic>? previousQuarterData,
  ) {
    final keyMetrics = {
      'current_quarter': {
        'total_employees': analysisData['totalEmployees'],
        'total_unique_employees': analysisData['totalUniqueEmployees'],
        'total_salary': analysisData['totalSalary'],
        'average_salary': analysisData['averageSalary'],
        'highest_salary': analysisData['highestSalary'],
        'lowest_salary': analysisData['lowestSalary'],
      },
    };

    if (previousQuarterData != null) {
      keyMetrics['previous_quarter'] = {
        'year': previousQuarterData['year'],
        'quarter': previousQuarterData['quarter'],
        'total_employees': previousQuarterData['totalEmployees'],
        'total_unique_employees': previousQuarterData['totalUniqueEmployees'],
        'total_salary': previousQuarterData['totalSalary'],
        'average_salary': previousQuarterData['averageSalary'],
        'highest_salary': previousQuarterData['highestSalary'],
        'lowest_salary': previousQuarterData['lowestSalary'],
      };

      // 计算环比变化
      keyMetrics['quarter_over_quarter_change'] = {
        'total_employees_change':
            ((analysisData['totalEmployees'] -
                        previousQuarterData['totalEmployees']) /
                    previousQuarterData['totalEmployees'] *
                    100)
                .toStringAsFixed(2),
        'total_salary_change':
            ((analysisData['totalSalary'] -
                        previousQuarterData['totalSalary']) /
                    previousQuarterData['totalSalary'] *
                    100)
                .toStringAsFixed(2),
        'average_salary_change':
            ((analysisData['averageSalary'] -
                        previousQuarterData['averageSalary']) /
                    previousQuarterData['averageSalary'] *
                    100)
                .toStringAsFixed(2),
        'highest_salary_change':
            ((analysisData['highestSalary'] -
                        previousQuarterData['highestSalary']) /
                    previousQuarterData['highestSalary'] *
                    100)
                .toStringAsFixed(2),
        'lowest_salary_change':
            ((analysisData['lowestSalary'] -
                        previousQuarterData['lowestSalary']) /
                    previousQuarterData['lowestSalary'] *
                    100)
                .toStringAsFixed(2),
      };
    }

    return keyMetrics;
  }

  /// 转换员工变动数据
  static Map<String, dynamic> _convertEmployeeChanges(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousQuarterData,
  ) {
    // 季度分析中暂不处理员工变动详细信息
    return {'description': '季度员工变动详情请参考月度分析数据'};
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
        'max_salary': stat.maxSalary, // 添加最高工资
        'min_salary': stat.minSalary, // 添加最低工资
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

  /// 转换薪资区间分布数据
  static List<Map<String, dynamic>> _convertSalaryRanges(
    Map<String, dynamic> analysisData,
  ) {
    final salaryRanges = analysisData['salaryRanges'] as List<SalaryRangeStats>;
    return salaryRanges.map((range) {
      return {
        'range': range.range,
        'employee_count': range.employeeCount,
        'total_salary': range.totalSalary,
        'average_salary': range.averageSalary,
      };
    }).toList();
  }

  /// 生成薪资区间分布图表数据
  static List<Map<String, dynamic>> _generateSalaryRangesChartData(
    Map<String, dynamic> analysisData,
  ) {
    final salaryRanges = analysisData['salaryRanges'] as List<SalaryRangeStats>;
    return salaryRanges.map((range) {
      return {
        'range': range.range,
        'count': range.employeeCount,
        'total': range.totalSalary,
      };
    }).toList();
  }

  /// 转换部门薪资区间联合统计数据
  static List<Map<String, dynamic>> _convertDepartmentSalaryRanges(
    Map<String, dynamic> analysisData,
  ) {
    final deptSalaryRanges =
        analysisData['departmentSalaryRangeStats']
            as List<DepartmentSalaryRangeStats>;
    return deptSalaryRanges.map((deptRange) {
      return {
        'department': deptRange.department,
        'salary_range': deptRange.salaryRange,
        'employee_count': deptRange.employeeCount,
        'total_salary': deptRange.totalSalary,
        'average_salary': deptRange.averageSalary,
      };
    }).toList();
  }

  /// 生成部门薪资区间联合统计图表数据
  static List<Map<String, dynamic>> _generateDepartmentSalaryRangesChartData(
    Map<String, dynamic> analysisData,
  ) {
    final deptSalaryRanges =
        analysisData['departmentSalaryRangeStats']
            as List<DepartmentSalaryRangeStats>;
    // 按部门分组
    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var deptRange in deptSalaryRanges) {
      if (!groupedData.containsKey(deptRange.department)) {
        groupedData[deptRange.department] = [];
      }
      groupedData[deptRange.department]!.add({
        'salary_range': deptRange.salaryRange,
        'employee_count': deptRange.employeeCount,
        'total_salary': deptRange.totalSalary,
      });
    }

    // 转换为图表数据格式
    return groupedData.entries.map((entry) {
      return {'department': entry.key, 'salary_ranges': entry.value};
    }).toList();
  }

  /// 转换月度分解数据
  static List<Map<String, dynamic>> _convertMonthlyBreakdown(
    Map<String, dynamic> analysisData,
  ) {
    final monthlyBreakdown =
        analysisData['monthlyBreakdown'] as List<Map<String, dynamic>>;
    return monthlyBreakdown.map((monthData) {
      return {
        'month': monthData['month'],
        'total_salary': monthData['totalSalary'],
        'average_salary': monthData['averageSalary'],
        'employee_count': monthData['employeeCount'],
        'highest_salary': monthData['highestSalary'],
        'lowest_salary': monthData['lowestSalary'],
      };
    }).toList();
  }

  /// 生成月度分解图表数据
  static List<Map<String, dynamic>> _generateMonthlyBreakdownChartData(
    Map<String, dynamic> analysisData,
  ) {
    final monthlyBreakdown =
        analysisData['monthlyBreakdown'] as List<Map<String, dynamic>>;
    return monthlyBreakdown.map((monthData) {
      return {
        'month': monthData['month'],
        'total_salary': monthData['totalSalary'],
        'average_salary': monthData['averageSalary'],
        'employee_count': monthData['employeeCount'],
        'highest_salary': monthData['highestSalary'],
        'lowest_salary': monthData['lowestSalary'],
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
