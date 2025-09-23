import 'dart:convert';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 多月分析数据转JSON工具类
class MultiMonthAnalysisJsonConverter {
  /// 将多月分析数据转换为JSON格式
  static String convertAnalysisDataToJson({
    required MultiMonthComparisonData comparisonData,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousPeriodData,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final jsonData = {
      'report_info': {
        'type': 'multi_month_analysis',
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'generated_at': DateTime.now().toIso8601String(),
      },
      'key_param': _generateKeyParam(comparisonData, previousPeriodData),
      'key_metrics': _convertKeyMetrics(comparisonData, previousPeriodData),
      'monthly_breakdown': _convertMonthlyBreakdown(comparisonData),
      'monthly_breakdown_chart_data': _generateMonthlyBreakdownChartData(
        comparisonData,
      ),
      'department_stats': _convertDepartmentStats(comparisonData),
      'department_stats_chart_data': _generateDepartmentStatsChartData(
        comparisonData,
      ),
      'salary_ranges': _convertSalaryRanges(comparisonData),
      'salary_ranges_chart_data': _generateSalaryRangesChartData(
        comparisonData,
      ),
      'department_salary_ranges': _convertDepartmentSalaryRanges(
        comparisonData,
      ),
      'department_salary_ranges_chart_data':
          _generateDepartmentSalaryRangesChartData(comparisonData),
      'attendance_stats': _convertAttendanceStats(attendanceStats),
      'attendance_stats_chart_data': _generateAttendanceStatsChartData(
        attendanceStats,
      ),
    };

    return JsonEncoder.withIndent('  ').convert(jsonData);
  }

  /// 生成关键指标的自然语言描述
  static String _generateKeyMetricsDescription(
    MultiMonthComparisonData comparisonData,
    Map<String, dynamic>? previousPeriodData,
  ) {
    final totalEmployees = comparisonData.monthlyComparisons.fold<int>(
      0,
      (sum, data) => sum + data.employeeCount,
    );

    double totalSalary = 0.0;
    double highestSalary = 0.0;
    double lowestSalary = double.infinity;

    for (var monthlyData in comparisonData.monthlyComparisons) {
      totalSalary += monthlyData.totalSalary;
      if (monthlyData.highestSalary > highestSalary) {
        highestSalary = monthlyData.highestSalary;
      }
      if (monthlyData.lowestSalary < lowestSalary &&
          monthlyData.lowestSalary > 0) {
        lowestSalary = monthlyData.lowestSalary;
      }
    }

    // 确保最低工资有合理的默认值
    if (lowestSalary == double.infinity) {
      lowestSalary = 0.0;
    }

    final averageSalary = totalEmployees > 0
        ? totalSalary / totalEmployees
        : 0.0;

    final buffer = StringBuffer();
    buffer.write('本期共有${comparisonData.monthlyComparisons.length}个月份，');
    buffer.write('总发放工资$totalEmployees人次，');
    buffer.write('工资总额为${totalSalary.toStringAsFixed(2)}元，');
    buffer.write('平均工资为${averageSalary.toStringAsFixed(2)}元，');
    buffer.write('最高工资为${highestSalary.toStringAsFixed(2)}元，');
    buffer.write('最低工资为${lowestSalary.toStringAsFixed(2)}元。');

    if (previousPeriodData != null) {
      final prevTotalSalary = previousPeriodData['totalSalary'] as double;
      final prevAverageSalary = previousPeriodData['averageSalary'] as double;
      final prevHighestSalary = previousPeriodData['highestSalary'] as double;
      final prevLowestSalary = previousPeriodData['lowestSalary'] as double;

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
        '与上期相比，工资总额${totalSalaryChange >= 0 ? "增加" : "减少"}${totalSalaryChange.abs().toStringAsFixed(2)}元($totalSalaryChangePercent%)，',
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

  /// 生成月度分解的自然语言描述
  static String _generateMonthlyBreakdownDescription(
    MultiMonthComparisonData comparisonData,
  ) {
    if (comparisonData.monthlyComparisons.isEmpty) {
      return '暂无月度分解数据。';
    }

    final buffer = StringBuffer();
    buffer.write('各月份工资情况如下：');

    for (int i = 0; i < comparisonData.monthlyComparisons.length; i++) {
      final monthlyData = comparisonData.monthlyComparisons[i];
      buffer.write('${monthlyData.year}年${monthlyData.month}月');
      buffer.write('发放工资${monthlyData.employeeCount}人次，');
      buffer.write('工资总额为${monthlyData.totalSalary.toStringAsFixed(2)}元，');
      buffer.write('平均工资为${monthlyData.averageSalary.toStringAsFixed(2)}元');
      if (i < comparisonData.monthlyComparisons.length - 1) {
        buffer.write('；');
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 生成部门统计数据的自然语言描述
  static String _generateDepartmentStatsDescription(
    MultiMonthComparisonData comparisonData,
  ) {
    // 合并所有月份的部门统计数据
    final departmentStatsMap = <String, DepartmentSalaryStats>{};

    for (var monthlyData in comparisonData.monthlyComparisons) {
      monthlyData.departmentStats.forEach((deptName, stat) {
        if (departmentStatsMap.containsKey(deptName)) {
          final existingStat = departmentStatsMap[deptName]!;
          departmentStatsMap[deptName] = DepartmentSalaryStats(
            department: deptName,
            employeeCount: existingStat.employeeCount + stat.employeeCount,
            totalNetSalary: existingStat.totalNetSalary + stat.totalNetSalary,
            averageNetSalary:
                (existingStat.totalNetSalary + stat.totalNetSalary) /
                (existingStat.employeeCount + stat.employeeCount),
            year: stat.year,
            month: stat.month,
            maxSalary: stat.maxSalary > existingStat.maxSalary
                ? stat.maxSalary
                : existingStat.maxSalary,
            minSalary: stat.minSalary < existingStat.minSalary
                ? stat.minSalary
                : existingStat.minSalary,
          );
        } else {
          departmentStatsMap[deptName] = stat;
        }
      });
    }

    if (departmentStatsMap.isEmpty) {
      return '暂无部门统计数据。';
    }

    final buffer = StringBuffer();
    buffer.write('各部门员工分布情况如下：');

    int index = 0;
    for (var entry in departmentStatsMap.entries) {
      final dept = entry.value;
      buffer.write('${dept.department}有${dept.employeeCount}名员工，');
      buffer.write('工资总额为${dept.totalNetSalary.toStringAsFixed(2)}元，');
      buffer.write('平均工资为${dept.averageNetSalary.toStringAsFixed(2)}元');
      if (index < departmentStatsMap.length - 1) {
        buffer.write('；');
      }
      index++;
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 生成薪资区间分布的自然语言描述
  static String _generateSalaryRangesDescription(
    MultiMonthComparisonData comparisonData,
  ) {
    // 合并所有月份的薪资区间统计数据
    final salaryRangeStatsMap = <String, SalaryRangeStats>{};

    for (var monthlyData in comparisonData.monthlyComparisons) {
      monthlyData.salaryRangeStats.forEach((rangeName, stat) {
        if (salaryRangeStatsMap.containsKey(rangeName)) {
          final existingStat = salaryRangeStatsMap[rangeName]!;
          salaryRangeStatsMap[rangeName] = SalaryRangeStats(
            range: rangeName,
            employeeCount: existingStat.employeeCount + stat.employeeCount,
            totalSalary: existingStat.totalSalary + stat.totalSalary,
            averageSalary:
                (existingStat.totalSalary + stat.totalSalary) /
                (existingStat.employeeCount + stat.employeeCount),
            year: stat.year,
            month: stat.month,
          );
        } else {
          salaryRangeStatsMap[rangeName] = stat;
        }
      });
    }

    if (salaryRangeStatsMap.isEmpty) {
      return '暂无薪资区间分布数据。';
    }

    final buffer = StringBuffer();
    buffer.write('薪资区间分布情况如下：');

    int index = 0;
    for (var entry in salaryRangeStatsMap.entries) {
      final range = entry.value;
      buffer.write('${range.range}区间有${range.employeeCount}名员工，');
      buffer.write('工资总额为${range.totalSalary.toStringAsFixed(2)}元，');
      buffer.write('平均工资为${range.averageSalary.toStringAsFixed(2)}元');
      if (index < salaryRangeStatsMap.length - 1) {
        buffer.write('；');
      }
      index++;
    }

    buffer.write('。');
    return buffer.toString();
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

  /// 生成完整的自然语言报告
  static String generateMultiMonthNaturalLanguageReport({
    required MultiMonthComparisonData comparisonData,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousPeriodData,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final buffer = StringBuffer();

    // 报告标题
    buffer.write(
      '多月工资分析报告（${startDate.year}年${startDate.month}月至${endDate.year}年${endDate.month}月）\n\n',
    );

    // 关键参数
    buffer.write('一、基本情况\n');
    buffer.write(_generateKeyParam(comparisonData, previousPeriodData));
    buffer.write('\n\n');

    // 关键指标
    buffer.write('二、关键指标\n');
    buffer.write(
      _generateKeyMetricsDescription(comparisonData, previousPeriodData),
    );
    buffer.write('\n\n');

    // 月度分解
    buffer.write('三、月度工资情况\n');
    buffer.write(_generateMonthlyBreakdownDescription(comparisonData));
    buffer.write('\n\n');

    // 部门统计
    buffer.write('四、部门统计\n');
    buffer.write(_generateDepartmentStatsDescription(comparisonData));
    buffer.write('\n\n');

    // 薪资区间分布
    buffer.write('五、薪资区间分布\n');
    buffer.write(_generateSalaryRangesDescription(comparisonData));
    buffer.write('\n\n');

    // 考勤统计
    buffer.write('六、考勤统计\n');
    buffer.write(_generateAttendanceStatsDescription(attendanceStats));
    buffer.write('\n\n');

    return buffer.toString();
  }

  /// 生成关键参数描述
  static String _generateKeyParam(
    MultiMonthComparisonData comparisonData,
    Map<String, dynamic>? previousPeriodData,
  ) {
    final totalMonths = comparisonData.monthlyComparisons.length;
    int totalEmployees = 0;
    int totalUniqueEmployees = 0;
    double totalSalary = 0.0;
    double averageSalary = 0.0;
    double highestSalary = 0.0;
    double lowestSalary = double.infinity;

    // 计算总体统计数据
    // 使用Set来跟踪唯一员工
    final uniqueEmployees = <String>{};

    for (var monthlyData in comparisonData.monthlyComparisons) {
      totalEmployees += monthlyData.employeeCount;
      totalSalary += monthlyData.totalSalary;
      if (monthlyData.highestSalary > highestSalary) {
        highestSalary = monthlyData.highestSalary;
      }
      if (monthlyData.lowestSalary < lowestSalary &&
          monthlyData.lowestSalary > 0) {
        lowestSalary = monthlyData.lowestSalary;
      }

      // 添加员工到唯一员工集合
      for (var worker in monthlyData.workers) {
        uniqueEmployees.add('${worker.name}_${worker.department}');
      }
    }

    totalUniqueEmployees = uniqueEmployees.length;

    // 计算平均工资
    if (totalEmployees > 0) {
      averageSalary = totalSalary / totalEmployees;
    }

    // 确保最低工资有合理的默认值
    if (lowestSalary == double.infinity) {
      lowestSalary = 0.0;
    }

    String keyParam =
        '本期共有$totalMonths 个月份，总发放工资$totalEmployees 人次，去重后实际员工数为$totalUniqueEmployees 人，工资总额为¥${totalSalary.toStringAsFixed(2)}，平均工资为¥${averageSalary.toStringAsFixed(2)}，最高工资为¥${highestSalary.toStringAsFixed(2)}，最低工资为¥${lowestSalary.toStringAsFixed(2)}';

    if (previousPeriodData != null) {
      final prevTotalEmployees = previousPeriodData['totalEmployees'] as int;
      final prevTotalSalary = previousPeriodData['totalSalary'] as double;
      final prevAverageSalary = previousPeriodData['averageSalary'] as double;
      final prevHighestSalary = previousPeriodData['highestSalary'] as double;
      final prevLowestSalary = previousPeriodData['lowestSalary'] as double;

      final employeeChange = totalEmployees - prevTotalEmployees;
      final salaryChange = totalSalary - prevTotalSalary;
      final avgSalaryChange = averageSalary - prevAverageSalary;
      final highestSalaryChange = highestSalary - prevHighestSalary;
      final lowestSalaryChange = lowestSalary - prevLowestSalary;

      keyParam +=
          '，相比上期（发放工资$prevTotalEmployees 人次，工资总额为¥${prevTotalSalary.toStringAsFixed(2)}，平均工资为¥${prevAverageSalary.toStringAsFixed(2)}，最高工资为¥${prevHighestSalary.toStringAsFixed(2)}，最低工资为¥${prevLowestSalary.toStringAsFixed(2)}）';
      keyParam +=
          '，工资人次${employeeChange >= 0 ? "增加" : "减少"}${employeeChange.abs()}人';
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
    MultiMonthComparisonData comparisonData,
    Map<String, dynamic>? previousPeriodData,
  ) {
    final totalEmployees = comparisonData.monthlyComparisons.fold<int>(
      0,
      (sum, data) => sum + data.employeeCount,
    );

    double totalSalary = 0.0;
    double highestSalary = 0.0;
    double lowestSalary = double.infinity;

    for (var monthlyData in comparisonData.monthlyComparisons) {
      totalSalary += monthlyData.totalSalary;
      if (monthlyData.highestSalary > highestSalary) {
        highestSalary = monthlyData.highestSalary;
      }
      if (monthlyData.lowestSalary < lowestSalary &&
          monthlyData.lowestSalary > 0) {
        lowestSalary = monthlyData.lowestSalary;
      }
    }

    // 确保最低工资有合理的默认值
    if (lowestSalary == double.infinity) {
      lowestSalary = 0.0;
    }

    final averageSalary = totalEmployees > 0
        ? totalSalary / totalEmployees
        : 0.0;

    final keyMetrics = {
      'current_period': {
        'total_months': comparisonData.monthlyComparisons.length,
        'total_employees': totalEmployees,
        'total_salary': totalSalary,
        'average_salary': averageSalary,
        'highest_salary': highestSalary,
        'lowest_salary': lowestSalary,
      },
    };

    if (previousPeriodData != null) {
      keyMetrics['previous_period'] = {
        'total_employees': previousPeriodData['totalEmployees'],
        'total_salary': previousPeriodData['totalSalary'],
        'average_salary': previousPeriodData['averageSalary'],
        'highest_salary': previousPeriodData['highestSalary'],
        'lowest_salary': previousPeriodData['lowestSalary'],
      };

      // 计算环比变化
      keyMetrics['period_over_period_change'] = {
        'total_employees_change': double.parse(
          ((totalEmployees - previousPeriodData['totalEmployees']) /
                  previousPeriodData['totalEmployees'] *
                  100)
              .toStringAsFixed(2),
        ),
        'total_salary_change': double.parse(
          ((totalSalary - previousPeriodData['totalSalary']) /
                  previousPeriodData['totalSalary'] *
                  100)
              .toStringAsFixed(2),
        ),
        'average_salary_change': double.parse(
          ((averageSalary - previousPeriodData['averageSalary']) /
                  previousPeriodData['averageSalary'] *
                  100)
              .toStringAsFixed(2),
        ),
        'highest_salary_change': double.parse(
          ((highestSalary - previousPeriodData['highestSalary']) /
                  previousPeriodData['highestSalary'] *
                  100)
              .toStringAsFixed(2),
        ),
        'lowest_salary_change': double.parse(
          ((lowestSalary - previousPeriodData['lowestSalary']) /
                  previousPeriodData['lowestSalary'] *
                  100)
              .toStringAsFixed(2),
        ),
      };
    }

    return keyMetrics;
  }

  /// 转换月度分解数据
  static List<Map<String, dynamic>> _convertMonthlyBreakdown(
    MultiMonthComparisonData comparisonData,
  ) {
    return comparisonData.monthlyComparisons.map((monthlyData) {
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
    MultiMonthComparisonData comparisonData,
  ) {
    return comparisonData.monthlyComparisons.map((monthlyData) {
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

  /// 转换部门统计数据
  static List<Map<String, dynamic>> _convertDepartmentStats(
    MultiMonthComparisonData comparisonData,
  ) {
    // 合并所有月份的部门统计数据
    final departmentStatsMap = <String, DepartmentSalaryStats>{};

    for (var monthlyData in comparisonData.monthlyComparisons) {
      monthlyData.departmentStats.forEach((deptName, stat) {
        if (departmentStatsMap.containsKey(deptName)) {
          final existingStat = departmentStatsMap[deptName]!;
          departmentStatsMap[deptName] = DepartmentSalaryStats(
            department: deptName,
            employeeCount: existingStat.employeeCount + stat.employeeCount,
            totalNetSalary: existingStat.totalNetSalary + stat.totalNetSalary,
            averageNetSalary:
                (existingStat.totalNetSalary + stat.totalNetSalary) /
                (existingStat.employeeCount + stat.employeeCount),
            year: stat.year,
            month: stat.month,
            maxSalary: stat.maxSalary > existingStat.maxSalary
                ? stat.maxSalary
                : existingStat.maxSalary,
            minSalary: stat.minSalary < existingStat.minSalary
                ? stat.minSalary
                : existingStat.minSalary,
          );
        } else {
          departmentStatsMap[deptName] = stat;
        }
      });
    }

    return departmentStatsMap.values.map((stat) {
      return {
        'department': stat.department,
        'employee_count': stat.employeeCount,
        'total_salary': stat.totalNetSalary,
        'average_salary': stat.averageNetSalary,
        'max_salary': stat.maxSalary,
        'min_salary': stat.minSalary,
      };
    }).toList();
  }

  /// 生成部门统计图表数据
  static List<Map<String, dynamic>> _generateDepartmentStatsChartData(
    MultiMonthComparisonData comparisonData,
  ) {
    // 合并所有月份的部门统计数据
    final departmentStatsMap = <String, DepartmentSalaryStats>{};

    for (var monthlyData in comparisonData.monthlyComparisons) {
      monthlyData.departmentStats.forEach((deptName, stat) {
        if (departmentStatsMap.containsKey(deptName)) {
          final existingStat = departmentStatsMap[deptName]!;
          departmentStatsMap[deptName] = DepartmentSalaryStats(
            department: deptName,
            employeeCount: existingStat.employeeCount + stat.employeeCount,
            totalNetSalary: existingStat.totalNetSalary + stat.totalNetSalary,
            averageNetSalary:
                (existingStat.totalNetSalary + stat.totalNetSalary) /
                (existingStat.employeeCount + stat.employeeCount),
            year: stat.year,
            month: stat.month,
            maxSalary: stat.maxSalary > existingStat.maxSalary
                ? stat.maxSalary
                : existingStat.maxSalary,
            minSalary: stat.minSalary < existingStat.minSalary
                ? stat.minSalary
                : existingStat.minSalary,
          );
        } else {
          departmentStatsMap[deptName] = stat;
        }
      });
    }

    return departmentStatsMap.values.map((stat) {
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
    MultiMonthComparisonData comparisonData,
  ) {
    // 合并所有月份的薪资区间统计数据
    final salaryRangeStatsMap = <String, SalaryRangeStats>{};

    for (var monthlyData in comparisonData.monthlyComparisons) {
      monthlyData.salaryRangeStats.forEach((rangeName, stat) {
        if (salaryRangeStatsMap.containsKey(rangeName)) {
          final existingStat = salaryRangeStatsMap[rangeName]!;
          salaryRangeStatsMap[rangeName] = SalaryRangeStats(
            range: rangeName,
            employeeCount: existingStat.employeeCount + stat.employeeCount,
            totalSalary: existingStat.totalSalary + stat.totalSalary,
            averageSalary:
                (existingStat.totalSalary + stat.totalSalary) /
                (existingStat.employeeCount + stat.employeeCount),
            year: stat.year,
            month: stat.month,
          );
        } else {
          salaryRangeStatsMap[rangeName] = stat;
        }
      });
    }

    return salaryRangeStatsMap.values.map((range) {
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
    MultiMonthComparisonData comparisonData,
  ) {
    // 合并所有月份的薪资区间统计数据
    final salaryRangeStatsMap = <String, SalaryRangeStats>{};

    for (var monthlyData in comparisonData.monthlyComparisons) {
      monthlyData.salaryRangeStats.forEach((rangeName, stat) {
        if (salaryRangeStatsMap.containsKey(rangeName)) {
          final existingStat = salaryRangeStatsMap[rangeName]!;
          salaryRangeStatsMap[rangeName] = SalaryRangeStats(
            range: rangeName,
            employeeCount: existingStat.employeeCount + stat.employeeCount,
            totalSalary: existingStat.totalSalary + stat.totalSalary,
            averageSalary:
                (existingStat.totalSalary + stat.totalSalary) /
                (existingStat.employeeCount + stat.employeeCount),
            year: stat.year,
            month: stat.month,
          );
        } else {
          salaryRangeStatsMap[rangeName] = stat;
        }
      });
    }

    return salaryRangeStatsMap.values.map((range) {
      return {
        'range': range.range,
        'count': range.employeeCount,
        'total': range.totalSalary,
      };
    }).toList();
  }

  /// 转换部门薪资区间联合统计数据
  static List<Map<String, dynamic>> _convertDepartmentSalaryRanges(
    MultiMonthComparisonData comparisonData,
  ) {
    // 这里简化处理，使用最后一个月的数据
    if (comparisonData.monthlyComparisons.isEmpty) {
      return [];
    }

    final lastMonthData = comparisonData.monthlyComparisons.last;
    // 实际应用中应该从数据库获取部门薪资区间联合统计数据
    // 这里暂时返回空列表，或者可以使用最后一个月的数据作为示例
    return [];
  }

  /// 生成部门薪资区间联合统计图表数据
  static List<Map<String, dynamic>> _generateDepartmentSalaryRangesChartData(
    MultiMonthComparisonData comparisonData,
  ) {
    // 这里简化处理，使用最后一个月的数据
    if (comparisonData.monthlyComparisons.isEmpty) {
      return [];
    }

    final lastMonthData = comparisonData.monthlyComparisons.last;
    // 实际应用中应该从数据库获取部门薪资区间联合统计数据
    // 这里暂时返回空列表，或者可以使用最后一个月的数据作为示例
    return [];
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
