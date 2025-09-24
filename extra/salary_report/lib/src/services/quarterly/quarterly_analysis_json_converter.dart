import 'dart:convert';
import 'package:salary_report/src/common/logger.dart';
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
    logger.info("_generateKeyParam analysisData: ${analysisData.runtimeType}");

    if (analysisData['comparisonData'] == null ||
        analysisData['comparisonData'] is! MultiMonthComparisonData) {
      return "";
    }

    final comparisonData =
        analysisData['comparisonData'] as MultiMonthComparisonData;

    final totalMonths = comparisonData.monthlyComparisons.length;

    // 按时间排序月度数据
    final sortedMonthlyData =
        List<MonthlyComparisonData>.from(comparisonData.monthlyComparisons)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.month.compareTo(b.month);
          });

    final buffer = StringBuffer();
    buffer.write('本期共有$totalMonths 个月份：');

    // 详细列出每个月份的数据
    for (int i = 0; i < sortedMonthlyData.length; i++) {
      final monthlyData = sortedMonthlyData[i];
      buffer.write('${monthlyData.year}年${monthlyData.month}月');
      buffer.write('发放工资${monthlyData.employeeCount}人次，');
      buffer.write('工资总额为${monthlyData.totalSalary.toStringAsFixed(2)}元，');
      buffer.write('平均工资为${monthlyData.averageSalary.toStringAsFixed(2)}元');
      if (i < sortedMonthlyData.length - 1) {
        buffer.write('；');
      }
    }

    buffer.write('。');

    if (previousQuarterData != null) {
      final prevTotalEmployees = previousQuarterData['totalEmployees'] as int;
      final prevTotalUniqueEmployees =
          previousQuarterData['totalUniqueEmployees'] as int;
      buffer.write('上季度共发薪$prevTotalEmployees 人次，');
      buffer.write('员工$prevTotalUniqueEmployees 人。');
    }

    return buffer.toString();
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
    if (analysisData['comparisonData'] == null ||
        analysisData['comparisonData'] is! MultiMonthComparisonData) {
      return [];
    }

    final monthlyComparisonData =
        analysisData['comparisonData'] as MultiMonthComparisonData;

    final lastMonthData = monthlyComparisonData.monthlyComparisons.last;
    // 实际应用中应该从数据库获取部门薪资区间联合统计数据
    // 这里暂时返回空列表，或者可以使用最后一个月的数据作为示例
    return [];
  }

  /// 生成部门薪资区间联合统计图表数据
  static List<Map<String, dynamic>> _generateDepartmentSalaryRangesChartData(
    Map<String, dynamic> analysisData,
  ) {
    if (analysisData['comparisonData'] == null ||
        analysisData['comparisonData'] is! MultiMonthComparisonData) {
      return [];
    }
    final monthlyComparisonData =
        analysisData['comparisonData'] as MultiMonthComparisonData;
    final lastMonthData = monthlyComparisonData.monthlyComparisons.last;
    // 实际应用中应该从数据库获取部门薪资区间联合统计数据
    // 这里暂时返回空列表，或者可以使用最后一个月的数据作为示例
    return [];

    // final deptSalaryRanges =
    //     analysisData['departmentSalaryRangeStats']
    //         as List<DepartmentSalaryRangeStats>;
    // // 按部门分组
    // final Map<String, List<Map<String, dynamic>>> groupedData = {};
    // for (var deptRange in deptSalaryRanges) {
    //   if (!groupedData.containsKey(deptRange.department)) {
    //     groupedData[deptRange.department] = [];
    //   }
    //   groupedData[deptRange.department]!.add({
    //     'salary_range': deptRange.salaryRange,
    //     'employee_count': deptRange.employeeCount,
    //     'total_salary': deptRange.totalSalary,
    //   });
    // }

    // // 转换为图表数据格式
    // return groupedData.entries.map((entry) {
    //   return {'department': entry.key, 'salary_ranges': entry.value};
    // }).toList();
  }

  /// 转换月度分解数据
  static List<Map<String, dynamic>> _convertMonthlyBreakdown(
    Map<String, dynamic> analysisData,
  ) {
    if (analysisData['comparisonData'] == null ||
        analysisData['comparisonData'] is! MultiMonthComparisonData) {
      return [];
    }
    final monthlyComparisonData =
        analysisData['comparisonData'] as MultiMonthComparisonData;

    return monthlyComparisonData.monthlyComparisons.map((monthlyData) {
      return {
        'year': monthlyData.year,
        'month': monthlyData.month,
        'employee_count': monthlyData.employeeCount,
        'total_salary': monthlyData.totalSalary,
        'average_salary': monthlyData.averageSalary,
        'highest_salary': monthlyData.highestSalary,
        'lowest_salary': monthlyData.lowestSalary,
      };
    }).toList();
  }

  /// 生成月度分解图表数据
  static List<Map<String, dynamic>> _generateMonthlyBreakdownChartData(
    Map<String, dynamic> analysisData,
  ) {
    if (analysisData['comparisonData'] == null ||
        analysisData['comparisonData'] is! MultiMonthComparisonData) {
      return [];
    }
    final monthlyComparisonData =
        analysisData['comparisonData'] as MultiMonthComparisonData;

    return monthlyComparisonData.monthlyComparisons.map((monthlyData) {
      return {
        'year': monthlyData.year,
        'month': monthlyData.month,
        'employee_count': monthlyData.employeeCount,
        'total_salary': monthlyData.totalSalary,
        'average_salary': monthlyData.averageSalary,
        'highest_salary': monthlyData.highestSalary,
        'lowest_salary': monthlyData.lowestSalary,
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
