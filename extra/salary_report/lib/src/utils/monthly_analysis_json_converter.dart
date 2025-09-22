import 'dart:convert';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/isar/salary_list.dart';

/// 月度分析数据转JSON工具类
class MonthlyAnalysisJsonConverter {
  /// 将月度分析数据转换为JSON格式
  static String convertAnalysisDataToJson({
    required Map<String, dynamic> analysisData,
    required List<DepartmentSalaryStats> departmentStats,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousMonthData,
    required int year,
    required int month,
  }) {
    final jsonData = {
      'report_info': {
        'type': 'monthly_analysis',
        'year': year,
        'month': month,
        'generated_at': DateTime.now().toIso8601String(),
      },
      'key_param': _generateKeyParam(analysisData, previousMonthData),
      'key_metrics': _convertKeyMetrics(analysisData, previousMonthData),
      'department_stats': _convertDepartmentStats(departmentStats),
      'department_stats_chart_data': _generateDepartmentStatsChartData(
        departmentStats,
      ),
      'salary_ranges': _convertSalaryRanges(analysisData),
      'salary_ranges_chart_data': _generateSalaryRangesChartData(analysisData),
      'department_salary_ranges': _convertDepartmentSalaryRanges(analysisData),
      'department_salary_ranges_chart_data':
          _generateDepartmentSalaryRangesChartData(analysisData),
      'top_employees': _convertTopEmployees(analysisData),
      'top_employees_chart_data': _generateTopEmployeesChartData(analysisData),
      'bottom_employees': _convertBottomEmployees(analysisData),
      'attendance_stats': _convertAttendanceStats(attendanceStats),
      'attendance_stats_chart_data': _generateAttendanceStatsChartData(
        attendanceStats,
      ),
      'employee_changes': _convertEmployeeChanges(
        analysisData,
        previousMonthData,
      ),
    };

    return JsonEncoder.withIndent('  ').convert(jsonData);
  }

  /// 生成关键参数描述
  static String _generateKeyParam(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousMonthData,
  ) {
    final totalEmployees = analysisData['totalEmployees'] as int;
    final totalUniqueEmployees = analysisData['totalUniqueEmployees'] as int;
    final totalSalary = analysisData['totalSalary'] as double;
    final averageSalary = analysisData['averageSalary'] as double;
    final highestSalary = analysisData['highestSalary'] as double;
    final lowestSalary = analysisData['lowestSalary'] as double;

    String keyParam =
        '本月共有$totalUniqueEmployees 名员工，发放工资$totalEmployees 人次，工资总额为¥${totalSalary.toStringAsFixed(2)}，平均工资为¥${averageSalary.toStringAsFixed(2)}，最高工资为¥${highestSalary.toStringAsFixed(2)}，最低工资为¥${lowestSalary.toStringAsFixed(2)}';

    if (previousMonthData != null) {
      final prevTotalEmployees = previousMonthData['totalEmployees'] as int;
      final prevTotalUniqueEmployees =
          previousMonthData['totalUniqueEmployees'] as int;
      final prevTotalSalary = previousMonthData['totalSalary'] as double;
      final prevAverageSalary = previousMonthData['averageSalary'] as double;
      final prevHighestSalary = previousMonthData['highestSalary'] as double;
      final prevLowestSalary = previousMonthData['lowestSalary'] as double;

      final employeeChange = totalUniqueEmployees - prevTotalUniqueEmployees;
      final salaryChange = totalSalary - prevTotalSalary;
      final avgSalaryChange = averageSalary - prevAverageSalary;
      final highestSalaryChange = highestSalary - prevHighestSalary;
      final lowestSalaryChange = lowestSalary - prevLowestSalary;

      keyParam +=
          '，相比上月（$prevTotalUniqueEmployees 名员工，发放工资$prevTotalEmployees 人次，工资总额为¥${prevTotalSalary.toStringAsFixed(2)}，平均工资为¥${prevAverageSalary.toStringAsFixed(2)}，最高工资为¥${prevHighestSalary.toStringAsFixed(2)}，最低工资为¥${prevLowestSalary.toStringAsFixed(2)}）';
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
    Map<String, dynamic>? previousMonthData,
  ) {
    final keyMetrics = {
      'current_month': {
        'total_employees': analysisData['totalEmployees'],
        'total_unique_employees': analysisData['totalUniqueEmployees'],
        'total_salary': analysisData['totalSalary'],
        'average_salary': analysisData['averageSalary'],
        'highest_salary': analysisData['highestSalary'],
        'lowest_salary': analysisData['lowestSalary'],
      },
    };

    if (previousMonthData != null) {
      keyMetrics['previous_month'] = {
        'year': previousMonthData['year'],
        'month': previousMonthData['month'],
        'total_employees': previousMonthData['totalEmployees'],
        'total_unique_employees': previousMonthData['totalUniqueEmployees'],
        'total_salary': previousMonthData['totalSalary'],
        'average_salary': previousMonthData['averageSalary'],
        'highest_salary': previousMonthData['highestSalary'],
        'lowest_salary': previousMonthData['lowestSalary'],
      };

      // 计算环比变化
      keyMetrics['month_over_month_change'] = {
        'total_employees_change':
            ((analysisData['totalEmployees'] -
                        previousMonthData['totalEmployees']) /
                    previousMonthData['totalEmployees'] *
                    100)
                .toStringAsFixed(2),
        'total_salary_change':
            ((analysisData['totalSalary'] - previousMonthData['totalSalary']) /
                    previousMonthData['totalSalary'] *
                    100)
                .toStringAsFixed(2),
        'average_salary_change':
            ((analysisData['averageSalary'] -
                        previousMonthData['averageSalary']) /
                    previousMonthData['averageSalary'] *
                    100)
                .toStringAsFixed(2),
        'highest_salary_change':
            ((analysisData['highestSalary'] -
                        previousMonthData['highestSalary']) /
                    previousMonthData['highestSalary'] *
                    100)
                .toStringAsFixed(2),
        'lowest_salary_change':
            ((analysisData['lowestSalary'] -
                        previousMonthData['lowestSalary']) /
                    previousMonthData['lowestSalary'] *
                    100)
                .toStringAsFixed(2),
      };
    }

    return keyMetrics;
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

  /// 转换工资最高员工数据
  static List<Map<String, dynamic>> _convertTopEmployees(
    Map<String, dynamic> analysisData,
  ) {
    final topEmployees = analysisData['topSalaryEmployees'] as List;
    return topEmployees
        .map<Map<String, dynamic>>((employee) {
          if (employee is SalaryListRecord) {
            return {
              'name': employee.name ?? '',
              'department': employee.department ?? '',
              'position': employee.position ?? '',
              'net_salary': employee.netSalary ?? '',
            };
          }
          return {};
        })
        .where((element) => element.isNotEmpty)
        .toList();
  }

  /// 生成工资最高员工图表数据
  static List<Map<String, dynamic>> _generateTopEmployeesChartData(
    Map<String, dynamic> analysisData,
  ) {
    final topEmployees = analysisData['topSalaryEmployees'] as List;
    return topEmployees
        .map<Map<String, dynamic>>((employee) {
          if (employee is SalaryListRecord) {
            final salaryStr =
                employee.netSalary?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0';
            final salary = double.tryParse(salaryStr) ?? 0;
            return {'name': employee.name ?? '', 'net_salary': salary};
          }
          return {};
        })
        .where((element) => element.isNotEmpty)
        .toList();
  }

  /// 转换工资最低员工数据
  static List<Map<String, dynamic>> _convertBottomEmployees(
    Map<String, dynamic> analysisData,
  ) {
    final bottomEmployees = analysisData['bottomSalaryEmployees'] as List;
    return bottomEmployees
        .map<Map<String, dynamic>>((employee) {
          if (employee is SalaryListRecord) {
            return {
              'name': employee.name ?? '',
              'department': employee.department ?? '',
              'position': employee.position ?? '',
              'net_salary': employee.netSalary ?? '',
            };
          }
          return {};
        })
        .where((element) => element.isNotEmpty)
        .toList();
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

  /// 转换员工变动数据
  static Map<String, dynamic> _convertEmployeeChanges(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousMonthData,
  ) {
    if (previousMonthData == null ||
        !analysisData.containsKey('currentEmployees') ||
        !previousMonthData.containsKey('previousEmployees')) {
      return {'description': '无人员变动数据'};
    }

    // 获取当前月和上月的员工列表
    final currentEmployees = analysisData['currentEmployees'] as List<dynamic>;
    final previousEmployees =
        previousMonthData['previousEmployees'] as List<dynamic>;

    // 创建员工标识集合（姓名+部门）
    final currentEmployeeSet = <String>{};
    final previousEmployeeSet = <String>{};

    // 构建当前月员工标识
    for (var emp in currentEmployees) {
      if (emp is MinimalEmployeeInfo) {
        currentEmployeeSet.add('${emp.name}_${emp.department}');
      }
    }

    // 构建上月员工标识
    for (var emp in previousEmployees) {
      if (emp is MinimalEmployeeInfo) {
        previousEmployeeSet.add('${emp.name}_${emp.department}');
      }
    }

    // 计算新增和离职员工
    final newEmployees = currentEmployeeSet.difference(previousEmployeeSet);
    final resignedEmployees = previousEmployeeSet.difference(
      currentEmployeeSet,
    );

    // 构建自然语言描述
    String description = '';

    if (newEmployees.isEmpty && resignedEmployees.isEmpty) {
      description = '本月无人员变动';
    } else {
      if (newEmployees.isNotEmpty) {
        description += '本月新增${newEmployees.length}名员工';
        if (newEmployees.length <= 5) {
          // 如果新增员工不多，列出具体员工和部门
          final employeeDetails = <String>[];
          for (var emp in newEmployees) {
            final parts = emp.split('_');
            if (parts.length >= 2) {
              employeeDetails.add('${parts[0]}(${parts[1]})');
            }
          }
          if (employeeDetails.isNotEmpty) {
            description += '，分别是：${employeeDetails.join('、')}';
          }
        }
      }

      if (resignedEmployees.isNotEmpty) {
        if (description.isNotEmpty) description += '；';
        description += '本月离职${resignedEmployees.length}名员工';
        if (resignedEmployees.length <= 5) {
          // 如果离职员工不多，列出具体员工和部门
          final employeeDetails = <String>[];
          for (var emp in resignedEmployees) {
            final parts = emp.split('_');
            if (parts.length >= 2) {
              employeeDetails.add('${parts[0]}(${parts[1]})');
            }
          }
          if (employeeDetails.isNotEmpty) {
            description += '，分别是：${employeeDetails.join('、')}';
          }
        }
      }

      description += '。';
    }

    return {
      'description': description,
      'new_employee_count': newEmployees.length,
      'resigned_employee_count': resignedEmployees.length,
      'net_change': newEmployees.length - resignedEmployees.length,
    };
  }
}
