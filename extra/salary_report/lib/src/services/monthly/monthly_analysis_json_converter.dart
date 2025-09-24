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
      'key_metrics_description': _generateKeyMetricsDescription(
        analysisData,
        previousMonthData,
      ),
      'department_stats': _convertDepartmentStats(departmentStats),
      'department_stats_description': _generateDepartmentStatsDescription(
        departmentStats,
      ),
      'department_stats_chart_data': _generateDepartmentStatsChartData(
        departmentStats,
      ),
      'salary_ranges': _convertSalaryRanges(analysisData),
      'salary_ranges_description': _generateSalaryRangesDescription(
        analysisData,
      ),
      'salary_ranges_chart_data': _generateSalaryRangesChartData(analysisData),
      'department_salary_ranges': _convertDepartmentSalaryRanges(analysisData),
      'department_salary_ranges_description':
          _generateDepartmentSalaryRangesDescription(analysisData),
      'department_salary_ranges_chart_data':
          _generateDepartmentSalaryRangesChartData(analysisData),
      'top_employees': _convertTopEmployees(analysisData),
      'top_employees_description': _generateTopEmployeesDescription(
        analysisData,
      ),
      'bottom_employees': _convertBottomEmployees(analysisData),
      'bottom_employees_description': _generateBottomEmployeesDescription(
        analysisData,
      ),
      'top_employees_chart_data': _generateTopEmployeesChartData(analysisData),
      'attendance_stats': _convertAttendanceStats(attendanceStats),
      'attendance_stats_description': _generateAttendanceStatsDescription(
        attendanceStats,
      ),
      'attendance_stats_chart_data': _generateAttendanceStatsChartData(
        attendanceStats,
      ),
      'employee_changes': _convertEmployeeChanges(
        analysisData,
        previousMonthData,
      ),
    };

    // 添加薪资相关信息
    jsonData['salary_info'] = _generateSalaryInfo(
      analysisData,
      previousMonthData,
    );

    return JsonEncoder.withIndent('  ').convert(jsonData);
  }

  /// 生成完整的自然语言报告
  static String generateNaturalLanguageReport({
    required Map<String, dynamic> analysisData,
    required List<DepartmentSalaryStats> departmentStats,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousMonthData,
    required int year,
    required int month,
  }) {
    final buffer = StringBuffer();

    // 报告标题
    buffer.write('月度工资分析报告（$year年$month月）\n\n');

    // 关键参数
    buffer.write('一、基本情况\n');
    buffer.write(_generateKeyParam(analysisData, previousMonthData));
    buffer.write('\n\n');

    // 关键指标
    buffer.write('二、关键指标\n');
    buffer.write(
      _generateKeyMetricsDescription(analysisData, previousMonthData),
    );
    buffer.write('\n\n');

    // 部门统计
    buffer.write('三、部门统计\n');
    buffer.write(_generateDepartmentStatsDescription(departmentStats));
    buffer.write('\n\n');

    // 薪资区间分布
    buffer.write('四、薪资区间分布\n');
    buffer.write(_generateSalaryRangesDescription(analysisData));
    buffer.write('\n\n');

    // 部门薪资区间联合统计
    buffer.write('五、各部门薪资区间分布\n');
    buffer.write(_generateDepartmentSalaryRangesDescription(analysisData));
    buffer.write('\n\n');

    // 工资最高员工
    buffer.write('六、工资最高员工\n');
    buffer.write(_generateTopEmployeesDescription(analysisData));
    buffer.write('\n\n');

    // 工资最低员工
    buffer.write('七、工资最低员工\n');
    buffer.write(_generateBottomEmployeesDescription(analysisData));
    buffer.write('\n\n');

    // 考勤统计
    buffer.write('八、考勤统计\n');
    buffer.write(_generateAttendanceStatsDescription(attendanceStats));
    buffer.write('\n\n');

    // 员工变化情况
    buffer.write('九、人员变动情况\n');
    buffer.write(_convertEmployeeChanges(analysisData, previousMonthData));
    buffer.write('\n\n');

    // 薪资相关信息
    buffer.write('十、薪资变化情况\n');
    buffer.write(_generateSalaryInfo(analysisData, previousMonthData));
    buffer.write('。\n');

    return buffer.toString();
  }

  /// 生成关键参数描述
  static String _generateKeyParam(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousMonthData,
  ) {
    final totalEmployees = analysisData['totalEmployees'] as int;
    final totalUniqueEmployees = analysisData['totalUniqueEmployees'] as int;
    final List<DepartmentSalaryStats> departmentStats =
        _convertToDepartmentSalaryStatsList(
          analysisData['departmentStats'] as List<dynamic>,
        );

    // 构建部门信息描述
    final departmentInfo = StringBuffer();
    departmentInfo.write('其中，');

    for (int i = 0; i < departmentStats.length; i++) {
      final dept = departmentStats[i];
      departmentInfo.write('${dept.department}${dept.employeeCount}人');
      if (i < departmentStats.length - 1) {
        departmentInfo.write('、');
      }
    }

    String keyParam = departmentInfo.toString();

    // 添加员工变化情况
    if (previousMonthData != null) {
      final employeeChangesDescription = _convertEmployeeChanges(
        analysisData,
        previousMonthData,
      );
      keyParam += '，$employeeChangesDescription';
    }

    return keyParam;
  }

  /// 生成关键指标的自然语言描述
  static String _generateKeyMetricsDescription(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousMonthData,
  ) {
    final totalEmployees = analysisData['totalEmployees'] as int;
    final totalUniqueEmployees = analysisData['totalUniqueEmployees'] as int;
    final totalSalary = analysisData['totalSalary'] as double;
    final averageSalary = analysisData['averageSalary'] as double;
    final highestSalary = analysisData['highestSalary'] as double;
    final lowestSalary = analysisData['lowestSalary'] as double;

    final buffer = StringBuffer();
    buffer.write('本月共有员工$totalEmployees人，去重后实际员工数为$totalUniqueEmployees人。');
    buffer.write('工资总额为${totalSalary.toStringAsFixed(2)}元，');
    buffer.write('平均工资为${averageSalary.toStringAsFixed(2)}元，');
    buffer.write('最高工资为${highestSalary.toStringAsFixed(2)}元，');
    buffer.write('最低工资为${lowestSalary.toStringAsFixed(2)}元。');

    if (previousMonthData != null) {
      final prevTotalSalary = previousMonthData['totalSalary'] as double;
      final prevAverageSalary = previousMonthData['averageSalary'] as double;
      final prevHighestSalary = previousMonthData['highestSalary'] as double;
      final prevLowestSalary = previousMonthData['lowestSalary'] as double;

      final totalSalaryChange = totalSalary - prevTotalSalary;
      final averageSalaryChange = averageSalary - prevAverageSalary;
      final highestSalaryChange = highestSalary - prevHighestSalary;
      final lowestSalaryChange = lowestSalary - prevLowestSalary;

      final totalSalaryChangePercent =
          (totalSalaryChange / prevTotalSalary * 100).toStringAsFixed(2);
      final averageSalaryChangePercent =
          (averageSalaryChange / prevAverageSalary * 100).toStringAsFixed(2);
      final highestSalaryChangePercent =
          (highestSalaryChange / prevHighestSalary * 100).toStringAsFixed(2);
      final lowestSalaryChangePercent =
          (lowestSalaryChange / prevLowestSalary * 100).toStringAsFixed(2);

      buffer.write(
        '与上月相比，工资总额${totalSalaryChange >= 0 ? "增加" : "减少"}${totalSalaryChange.abs().toStringAsFixed(2)}元($totalSalaryChangePercent%)，',
      );
      buffer.write(
        '平均工资${averageSalaryChange >= 0 ? "上升" : "下降"}${averageSalaryChange.abs().toStringAsFixed(2)}元($averageSalaryChangePercent%)，',
      );
      buffer.write(
        '最高工资${highestSalaryChange >= 0 ? "上升" : "下降"}${highestSalaryChange.abs().toStringAsFixed(2)}元($highestSalaryChangePercent%)，',
      );
      buffer.write(
        '最低工资${lowestSalaryChange >= 0 ? "上升" : "下降"}${lowestSalaryChange.abs().toStringAsFixed(2)}元($lowestSalaryChangePercent%)。',
      );
    }

    return buffer.toString();
  }

  /// 转换关键指标数据（保持原方法以兼容现有代码）
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

  /// 生成部门统计数据的自然语言描述
  static String _generateDepartmentStatsDescription(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    if (departmentStats.isEmpty) {
      return '暂无部门统计数据。';
    }

    final buffer = StringBuffer();
    buffer.write('各部门员工分布情况如下：');

    for (int i = 0; i < departmentStats.length; i++) {
      final dept = departmentStats[i];
      buffer.write('${dept.department}有${dept.employeeCount}名员工，');
      buffer.write('工资总额为${dept.totalNetSalary.toStringAsFixed(2)}元，');
      buffer.write('平均工资为${dept.averageNetSalary.toStringAsFixed(2)}元');
      if (i < departmentStats.length - 1) {
        buffer.write('；');
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 转换部门统计数据（保持原方法以兼容现有代码）
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

  /// 将动态列表转换为DepartmentSalaryStats列表
  static List<DepartmentSalaryStats> _convertToDepartmentSalaryStatsList(
    List<dynamic> departmentStats,
  ) {
    return departmentStats.map((dept) {
      if (dept is DepartmentSalaryStats) {
        return dept;
      } else if (dept is Map<String, dynamic>) {
        return DepartmentSalaryStats(
          department: dept['department'] as String? ?? '未知部门',
          employeeCount:
              dept['count'] as int? ?? dept['employee_count'] as int? ?? 0,
          averageNetSalary:
              (dept['average'] as num? ?? dept['average_salary'] as num? ?? 0)
                  .toDouble(),
          totalNetSalary:
              (dept['total'] as num? ?? dept['total_salary'] as num? ?? 0)
                  .toDouble(),
          year: dept['year'] as int? ?? DateTime.now().year,
          month: dept['month'] as int? ?? DateTime.now().month,
          maxSalary: (dept['max'] as num? ?? dept['max_salary'] as num? ?? 0)
              .toDouble(), // 添加最高工资
          minSalary: (dept['min'] as num? ?? dept['min_salary'] as num? ?? 0)
              .toDouble(), // 添加最低工资
        );
      } else {
        return DepartmentSalaryStats(
          department: '未知部门',
          employeeCount: 0,
          averageNetSalary: 0.0,
          totalNetSalary: 0.0,
          year: DateTime.now().year,
          month: DateTime.now().month,
          maxSalary: 0.0, // 添加最高工资
          minSalary: 0.0, // 添加最低工资
        );
      }
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

  /// 生成薪资区间分布的自然语言描述
  static String _generateSalaryRangesDescription(
    Map<String, dynamic> analysisData,
  ) {
    final salaryRanges = analysisData['salaryRanges'] as List<SalaryRangeStats>;

    if (salaryRanges.isEmpty) {
      return '暂无薪资区间分布数据。';
    }

    final buffer = StringBuffer();
    buffer.write('薪资区间分布情况如下：');

    for (int i = 0; i < salaryRanges.length; i++) {
      final range = salaryRanges[i];
      buffer.write('${range.range}区间有${range.employeeCount}名员工，');
      buffer.write('工资总额为${range.totalSalary.toStringAsFixed(2)}元，');
      buffer.write('平均工资为${range.averageSalary.toStringAsFixed(2)}元');
      if (i < salaryRanges.length - 1) {
        buffer.write('；');
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 转换薪资区间分布数据（保持原方法以兼容现有代码）
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

  /// 生成部门薪资区间联合统计的自然语言描述
  static String _generateDepartmentSalaryRangesDescription(
    Map<String, dynamic> analysisData,
  ) {
    final deptSalaryRanges =
        analysisData['departmentSalaryRangeStats']
            as List<DepartmentSalaryRangeStats>;

    if (deptSalaryRanges.isEmpty) {
      return '暂无部门薪资区间联合统计数据。';
    }

    // 按部门分组
    final Map<String, List<DepartmentSalaryRangeStats>> groupedData = {};
    for (var deptRange in deptSalaryRanges) {
      if (!groupedData.containsKey(deptRange.department)) {
        groupedData[deptRange.department] = [];
      }
      groupedData[deptRange.department]!.add(deptRange);
    }

    final buffer = StringBuffer();
    buffer.write('各部门薪资区间分布情况如下：');

    int deptIndex = 0;
    for (var entry in groupedData.entries) {
      final department = entry.key;
      final ranges = entry.value;

      buffer.write('$department：');

      for (int i = 0; i < ranges.length; i++) {
        final range = ranges[i];
        buffer.write('${range.salaryRange}区间有${range.employeeCount}名员工，');
        buffer.write('工资总额为${range.totalSalary.toStringAsFixed(2)}元，');
        buffer.write('平均工资为${range.averageSalary.toStringAsFixed(2)}元');
        if (i < ranges.length - 1) {
          buffer.write('；');
        }
      }

      if (deptIndex < groupedData.length - 1) {
        buffer.write('。');
      }
      deptIndex++;
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 转换部门薪资区间联合统计数据（保持原方法以兼容现有代码）
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

  /// 生成工资最高员工的自然语言描述
  static String _generateTopEmployeesDescription(
    Map<String, dynamic> analysisData,
  ) {
    final topEmployees = analysisData['topSalaryEmployees'] as List;

    if (topEmployees.isEmpty) {
      return '暂无工资最高员工数据。';
    }

    final buffer = StringBuffer();
    buffer.write('工资最高的员工有：');

    for (int i = 0; i < topEmployees.length && i < 5; i++) {
      final employee = topEmployees[i];
      if (employee is SalaryListRecord) {
        final salaryStr =
            employee.netSalary?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0';
        final salary = double.tryParse(salaryStr) ?? 0;
        buffer.write(
          '${employee.name}(${employee.department})，工资为${salary.toStringAsFixed(2)}元',
        );
        if (i < topEmployees.length - 1 && i < 4) {
          buffer.write('；');
        }
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 生成工资最低员工的自然语言描述
  static String _generateBottomEmployeesDescription(
    Map<String, dynamic> analysisData,
  ) {
    final bottomEmployees = analysisData['bottomSalaryEmployees'] as List;

    if (bottomEmployees.isEmpty) {
      return '暂无工资最低员工数据。';
    }

    final buffer = StringBuffer();
    buffer.write('工资最低的员工有：');

    for (int i = 0; i < bottomEmployees.length && i < 5; i++) {
      final employee = bottomEmployees[i];
      if (employee is SalaryListRecord) {
        final salaryStr =
            employee.netSalary?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0';
        final salary = double.tryParse(salaryStr) ?? 0;
        buffer.write(
          '${employee.name}(${employee.department})，工资为${salary.toStringAsFixed(2)}元',
        );
        if (i < bottomEmployees.length - 1 && i < 4) {
          buffer.write('；');
        }
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 转换工资最高员工数据（保持原方法以兼容现有代码）
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

  /// 生成考勤统计数据的自然语言描述
  static String _generateAttendanceStatsDescription(
    List<AttendanceStats> attendanceStats,
  ) {
    if (attendanceStats.isEmpty) {
      return '暂无考勤统计数据。';
    }

    final buffer = StringBuffer();
    buffer.write('考勤情况统计如下：');

    for (int i = 0; i < attendanceStats.length && i < 10; i++) {
      final stat = attendanceStats[i];
      buffer.write('${stat.name}(${stat.department})，');
      buffer.write('病假${stat.sickLeaveDays}天，');
      buffer.write('事假${stat.leaveDays}天，');
      buffer.write('缺勤${stat.absenceCount}次，');
      buffer.write('旷工${stat.truancyDays}天');
      if (i < attendanceStats.length - 1 && i < 9) {
        buffer.write('；');
      }
    }

    if (attendanceStats.length > 10) {
      buffer.write('；还有${attendanceStats.length - 10}条记录未显示');
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 转换考勤统计数据（保持原方法以兼容现有代码）
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

  /// 生成员工变动情况的自然语言描述
  static String _convertEmployeeChanges(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousMonthData,
  ) {
    if (previousMonthData == null ||
        !analysisData.containsKey('currentEmployees') ||
        !previousMonthData.containsKey('previousEmployees')) {
      return '无人员变动数据';
    }

    // 获取当前月和上月的员工列表
    final currentEmployees =
        analysisData['currentEmployees'] as List<MinimalEmployeeInfo>;
    final previousEmployees =
        previousMonthData['previousEmployees'] as List<MinimalEmployeeInfo>;

    // 创建员工标识集合（姓名+部门）
    final currentEmployeeSet = <String>{};
    final previousEmployeeSet = <String>{};

    // 构建当前月员工标识
    for (var emp in currentEmployees) {
      currentEmployeeSet.add('${emp.name}_${emp.department}');
    }

    // 构建上月员工标识
    for (var emp in previousEmployees) {
      previousEmployeeSet.add('${emp.name}_${emp.department}');
    }

    // 计算新增和离职员工
    final newEmployees = currentEmployeeSet.difference(previousEmployeeSet);
    final resignedEmployees = previousEmployeeSet.difference(
      currentEmployeeSet,
    );

    // 构建自然语言描述
    final buffer = StringBuffer();

    if (newEmployees.isEmpty && resignedEmployees.isEmpty) {
      buffer.write('本月无人员变动');
    } else {
      if (newEmployees.isNotEmpty) {
        buffer.write('本月新增${newEmployees.length}名员工');
        // 列出新增员工的姓名和部门
        final newEmployeeDetails = <String>[];
        for (var emp in currentEmployees) {
          final identifier = '${emp.name}_${emp.department}';
          if (newEmployees.contains(identifier) &&
              newEmployeeDetails.length < 5) {
            newEmployeeDetails.add('${emp.name}(${emp.department})');
          }
        }
        if (newEmployeeDetails.isNotEmpty) {
          buffer.write('，分别为${newEmployeeDetails.join('、')}');
        }
      }

      if (resignedEmployees.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write('；');
        buffer.write('本月离职${resignedEmployees.length}名员工');
        // 列出离职员工的姓名和部门
        final resignedEmployeeDetails = <String>[];
        for (var emp in previousEmployees) {
          final identifier = '${emp.name}_${emp.department}';
          if (resignedEmployees.contains(identifier) &&
              resignedEmployeeDetails.length < 5) {
            resignedEmployeeDetails.add('${emp.name}(${emp.department})');
          }
        }
        if (resignedEmployeeDetails.isNotEmpty) {
          buffer.write('，分别为${resignedEmployeeDetails.join('、')}');
        }
      }
    }

    return buffer.toString();
  }

  /// 生成用于图表的部门统计数据
  static List<Map<String, dynamic>> generateDepartmentChartDataSet(
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

  /// 生成用于图表的薪资区间数据
  static List<Map<String, dynamic>> generateSalaryRangeChartDataSet(
    List<SalaryRangeStats> salaryRanges,
  ) {
    return salaryRanges.map((range) {
      return {
        'range': range.range,
        'count': range.employeeCount,
        'total': range.totalSalary,
      };
    }).toList();
  }

  /// 生成用于图表的员工Top榜单数据
  static List<Map<String, dynamic>> generateTopEmployeesChartDataSet(
    List<dynamic> topEmployees,
  ) {
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

  /// 生成用于图表的考勤统计数据
  static List<Map<String, dynamic>> generateAttendanceChartDataSet(
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

  /// 生成用于图表的部门薪资区间联合统计数据
  static List<Map<String, dynamic>> generateDepartmentSalaryRangeChartDataSet(
    List<DepartmentSalaryRangeStats> deptSalaryRanges,
  ) {
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

  /// 生成薪资相关信息描述
  static String _generateSalaryInfo(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousMonthData,
  ) {
    final totalSalary = analysisData['totalSalary'] as double;
    final averageSalary = analysisData['averageSalary'] as double;
    final highestSalary = analysisData['highestSalary'] as double;
    final lowestSalary = analysisData['lowestSalary'] as double;

    final buffer = StringBuffer();
    buffer.write('工资总额为${totalSalary.toStringAsFixed(2)}元，');
    buffer.write('平均工资为${averageSalary.toStringAsFixed(2)}元，');
    buffer.write('最高工资为${highestSalary.toStringAsFixed(2)}元，');
    buffer.write('最低工资为${lowestSalary.toStringAsFixed(2)}元');

    if (previousMonthData != null) {
      final prevTotalSalary = previousMonthData['totalSalary'] as double;
      final prevAverageSalary = previousMonthData['averageSalary'] as double;
      final prevHighestSalary = previousMonthData['highestSalary'] as double;
      final prevLowestSalary = previousMonthData['lowestSalary'] as double;

      final salaryChange = totalSalary - prevTotalSalary;
      final avgSalaryChange = averageSalary - prevAverageSalary;
      final highestSalaryChange = highestSalary - prevHighestSalary;
      final lowestSalaryChange = lowestSalary - prevLowestSalary;

      final totalSalaryChangePercent = (salaryChange / prevTotalSalary * 100)
          .toStringAsFixed(2);
      final averageSalaryChangePercent =
          (avgSalaryChange / prevAverageSalary * 100).toStringAsFixed(2);
      final highestSalaryChangePercent =
          (highestSalaryChange / prevHighestSalary * 100).toStringAsFixed(2);
      final lowestSalaryChangePercent =
          (lowestSalaryChange / prevLowestSalary * 100).toStringAsFixed(2);

      buffer.write(
        '，与上月相比，工资总额${salaryChange >= 0 ? "增加" : "减少"}${salaryChange.abs().toStringAsFixed(2)}元($totalSalaryChangePercent%)',
      );
      buffer.write(
        '，平均工资${avgSalaryChange >= 0 ? "上升" : "下降"}${avgSalaryChange.abs().toStringAsFixed(2)}元($averageSalaryChangePercent%)',
      );
      buffer.write(
        '，最高工资${highestSalaryChange >= 0 ? "上升" : "下降"}${highestSalaryChange.abs().toStringAsFixed(2)}元($highestSalaryChangePercent%)',
      );
      buffer.write(
        '，最低工资${lowestSalaryChange >= 0 ? "上升" : "下降"}${lowestSalaryChange.abs().toStringAsFixed(2)}元($lowestSalaryChangePercent%)',
      );
    }

    return buffer.toString();
  }
}
