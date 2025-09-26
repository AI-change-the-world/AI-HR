// src/utils/multi_quarter_analysis_json_converter.dart

import 'dart:convert';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 多季度分析数据JSON转换器
class MultiQuarterAnalysisJsonConverter {
  /// 将多季度分析数据转换为JSON格式
  static String convertAnalysisDataToJson({
    required MultiQuarterComparisonData comparisonData,
    required List<AttendanceStats> attendanceStats,
    required DateTime startDate,
    required DateTime endDate,
    List<Map<String, dynamic>>? departmentQuarterOverQuarterData,
    List<Map<String, dynamic>>? departmentYearOverYearData,
  }) {
    try {
      // 按时间排序季度数据
      final sortedQuarterlyData =
          List<QuarterlyComparisonData>.from(
            comparisonData.quarterlyComparisons,
          )..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.quarter.compareTo(b.quarter);
          });

      // 计算关键指标
      int totalEmployees = 0;
      int averageEmployees = 0;
      double totalSalary = 0;
      double averageSalary = 0;
      double highestSalary = 0;
      double lowestSalary = double.infinity;

      for (var quarterlyData in sortedQuarterlyData) {
        totalEmployees += quarterlyData.employeeCount;
        totalSalary += quarterlyData.totalSalary;

        if (quarterlyData.highestSalary > highestSalary) {
          highestSalary = quarterlyData.highestSalary;
        }

        if (quarterlyData.lowestSalary < lowestSalary) {
          lowestSalary = quarterlyData.lowestSalary;
        }
      }

      // 计算平均值
      if (sortedQuarterlyData.isNotEmpty) {
        averageEmployees = totalEmployees ~/ sortedQuarterlyData.length;
        averageSalary = totalSalary / totalEmployees;
      }

      if (lowestSalary == double.infinity) {
        lowestSalary = 0;
      }

      // 构建季度趋势数据
      final quarterlyTrends = <Map<String, dynamic>>[];
      for (var quarterlyData in sortedQuarterlyData) {
        quarterlyTrends.add({
          'year': quarterlyData.year,
          'quarter': quarterlyData.quarter,
          'employee_count': quarterlyData.employeeCount,
          'total_salary': quarterlyData.totalSalary,
          'average_salary': quarterlyData.averageSalary,
          'highest_salary': quarterlyData.highestSalary,
          'lowest_salary': quarterlyData.lowestSalary,
        });
      }

      // 构建部门趋势数据
      final departmentTrends = <String, List<Map<String, dynamic>>>{};
      // 从季度数据中提取部门信息
      final departmentNames = <String>{};
      for (var quarterlyData in sortedQuarterlyData) {
        departmentNames.addAll(quarterlyData.departmentStats.keys);
      }

      for (var deptName in departmentNames) {
        final deptTrends = <Map<String, dynamic>>[];

        for (var quarterlyData in sortedQuarterlyData) {
          if (quarterlyData.departmentStats.containsKey(deptName)) {
            final deptStat = quarterlyData.departmentStats[deptName]!;
            deptTrends.add({
              'year': quarterlyData.year,
              'quarter': quarterlyData.quarter,
              'employee_count': deptStat.employeeCount,
              'total_salary': deptStat.totalNetSalary,
              'average_salary': deptStat.averageNetSalary,
            });
          }
        }

        departmentTrends[deptName] = deptTrends;
      }

      // 构建薪资区间趋势数据
      final salaryRangeTrends = <String, List<Map<String, dynamic>>>{};
      // 从季度数据中提取薪资区间信息
      final rangeNames = <String>{};
      for (var quarterlyData in sortedQuarterlyData) {
        rangeNames.addAll(quarterlyData.salaryRangeStats.keys);
      }

      for (var rangeName in rangeNames) {
        final rangeTrends = <Map<String, dynamic>>[];

        for (var quarterlyData in sortedQuarterlyData) {
          if (quarterlyData.salaryRangeStats.containsKey(rangeName)) {
            final rangeStat = quarterlyData.salaryRangeStats[rangeName]!;
            rangeTrends.add({
              'year': quarterlyData.year,
              'quarter': quarterlyData.quarter,
              'employee_count': rangeStat.employeeCount,
              'total_salary': rangeStat.totalSalary,
              'average_salary': rangeStat.averageSalary,
            });
          }
        }

        salaryRangeTrends[rangeName] = rangeTrends;
      }

      // 构建环比数据
      final quarterOverQuarterData = <Map<String, dynamic>>[];
      for (int i = 1; i < sortedQuarterlyData.length; i++) {
        final currentQuarter = sortedQuarterlyData[i];
        final previousQuarter = sortedQuarterlyData[i - 1];

        final employeeCountChange =
            currentQuarter.employeeCount - previousQuarter.employeeCount;
        final employeeCountChangeRate = previousQuarter.employeeCount > 0
            ? (employeeCountChange / previousQuarter.employeeCount) * 100
            : 0.0;

        final totalSalaryChange =
            currentQuarter.totalSalary - previousQuarter.totalSalary;
        final totalSalaryChangeRate = previousQuarter.totalSalary > 0
            ? (totalSalaryChange / previousQuarter.totalSalary) * 100
            : 0.0;

        final averageSalaryChange =
            currentQuarter.averageSalary - previousQuarter.averageSalary;
        final averageSalaryChangeRate = previousQuarter.averageSalary > 0
            ? (averageSalaryChange / previousQuarter.averageSalary) * 100
            : 0.0;

        quarterOverQuarterData.add({
          'current_year': currentQuarter.year,
          'current_quarter': currentQuarter.quarter,
          'previous_year': previousQuarter.year,
          'previous_quarter': previousQuarter.quarter,
          'employee_count_change': employeeCountChange,
          'employee_count_change_rate': employeeCountChangeRate,
          'total_salary_change': totalSalaryChange,
          'total_salary_change_rate': totalSalaryChangeRate,
          'average_salary_change': averageSalaryChange,
          'average_salary_change_rate': averageSalaryChangeRate,
        });
      }

      // 构建同比数据（去年同季度）
      final yearOverYearData = <Map<String, dynamic>>[];
      for (var currentQuarter in sortedQuarterlyData) {
        // 查找去年同季度数据
        final lastYearQuarter = sortedQuarterlyData.firstWhere(
          (q) =>
              q.year == currentQuarter.year - 1 &&
              q.quarter == currentQuarter.quarter,
          orElse: () => QuarterlyComparisonData(
            year: 0,
            quarter: 0,
            employeeCount: 0,
            totalSalary: 0,
            averageSalary: 0,
            highestSalary: 0,
            lowestSalary: 0,
            departmentStats: {},
            salaryRangeStats: {},
            uniqueEmployees: {},
            totalEmployeeCount: 0,
            workers: [],
            monthlyComparisons: [],
          ),
        );

        // 如果找到去年同季度数据
        if (lastYearQuarter.year > 0) {
          final employeeCountChange =
              currentQuarter.employeeCount - lastYearQuarter.employeeCount;
          final employeeCountChangeRate = lastYearQuarter.employeeCount > 0
              ? (employeeCountChange / lastYearQuarter.employeeCount) * 100
              : 0.0;

          final totalSalaryChange =
              currentQuarter.totalSalary - lastYearQuarter.totalSalary;
          final totalSalaryChangeRate = lastYearQuarter.totalSalary > 0
              ? (totalSalaryChange / lastYearQuarter.totalSalary) * 100
              : 0.0;

          final averageSalaryChange =
              currentQuarter.averageSalary - lastYearQuarter.averageSalary;
          final averageSalaryChangeRate = lastYearQuarter.averageSalary > 0
              ? (averageSalaryChange / lastYearQuarter.averageSalary) * 100
              : 0.0;

          yearOverYearData.add({
            'current_year': currentQuarter.year,
            'current_quarter': currentQuarter.quarter,
            'previous_year': lastYearQuarter.year,
            'previous_quarter': lastYearQuarter.quarter,
            'employee_count_change': employeeCountChange,
            'employee_count_change_rate': employeeCountChangeRate,
            'total_salary_change': totalSalaryChange,
            'total_salary_change_rate': totalSalaryChangeRate,
            'average_salary_change': averageSalaryChange,
            'average_salary_change_rate': averageSalaryChangeRate,
          });
        }
      }

      // 构建考勤数据
      final attendanceData = <Map<String, dynamic>>[];
      for (var stat in attendanceStats) {
        // 假设一个月工作日为22天
        const int workDaysPerMonth = 22;

        // 计算请假率、缺勤率和考勤率
        final leaveRate =
            (stat.leaveDays + stat.sickLeaveDays) / workDaysPerMonth * 100;
        final absenceRate =
            (stat.absenceCount + stat.truancyDays) / workDaysPerMonth * 100;
        final attendanceRate = 100 - leaveRate - absenceRate;

        attendanceData.add({
          'year': stat.year,
          'month': stat.month,
          'department': stat.department,
          'attendance_data': {
            'attendance_rate': attendanceRate < 0 ? 0 : attendanceRate,
            'leave_rate': leaveRate,
            'absence_rate': absenceRate,
          },
        });
      }

      // 构建最终JSON数据
      final jsonData = {
        'report_type': 'multi_quarter',
        'start_date':
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-01',
        'end_date':
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${DateTime(endDate.year, endDate.month + 1, 0).day}',
        'key_metrics': {
          'total_employees': totalEmployees,
          'average_employees': averageEmployees,
          'total_salary': totalSalary,
          'average_salary': averageSalary,
          'highest_salary': highestSalary,
          'lowest_salary': lowestSalary,
        },
        'quarterly_trends': quarterlyTrends,
        'department_trends': departmentTrends,
        'salary_range_trends': salaryRangeTrends,
        'quarter_over_quarter': quarterOverQuarterData,
        'year_over_year': yearOverYearData,
        'attendance_data': attendanceData,
        'department_qoq_data': departmentQuarterOverQuarterData ?? [],
        'department_yoy_data': departmentYearOverYearData ?? [],
      };

      return jsonEncode(jsonData);
    } catch (e, stackTrace) {
      logger.severe(
        'Error converting multi-quarter analysis data to JSON: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
