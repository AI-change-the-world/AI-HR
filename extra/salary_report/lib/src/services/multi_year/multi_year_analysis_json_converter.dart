// src/utils/multi_year_analysis_json_converter.dart

import 'dart:convert';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 多年度分析数据JSON转换器
class MultiYearAnalysisJsonConverter {
  /// 将多年度分析数据转换为JSON格式
  static String convertAnalysisDataToJson({
    required MultiYearComparisonData comparisonData,
    required List<AttendanceStats> attendanceStats,
    required DateTime startDate,
    required DateTime endDate,
    List<Map<String, dynamic>>? departmentYearOverYearData,
  }) {
    try {
      // 按年份排序数据
      final sortedYearlyData = List<YearlyComparisonData>.from(
        comparisonData.yearlyComparisons,
      )..sort((a, b) => a.year.compareTo(b.year));

      // 计算关键指标
      int totalEmployees = 0;
      int averageEmployees = 0;
      double totalSalary = 0;
      double averageSalary = 0;
      double highestSalary = 0;
      double lowestSalary = double.infinity;

      for (var yearlyData in sortedYearlyData) {
        totalEmployees += yearlyData.employeeCount;
        totalSalary += yearlyData.totalSalary;
        
        if (yearlyData.highestSalary > highestSalary) {
          highestSalary = yearlyData.highestSalary;
        }
        
        if (yearlyData.lowestSalary < lowestSalary) {
          lowestSalary = yearlyData.lowestSalary;
        }
      }

      // 计算平均值
      if (sortedYearlyData.isNotEmpty) {
        averageEmployees = totalEmployees ~/ sortedYearlyData.length;
        averageSalary = totalSalary / totalEmployees;
      }

      if (lowestSalary == double.infinity) {
        lowestSalary = 0;
      }

      // 构建年度趋势数据
      final yearlyTrends = <Map<String, dynamic>>[];
      for (var yearlyData in sortedYearlyData) {
        yearlyTrends.add({
          'year': yearlyData.year,
          'employee_count': yearlyData.employeeCount,
          'total_salary': yearlyData.totalSalary,
          'average_salary': yearlyData.averageSalary,
          'highest_salary': yearlyData.highestSalary,
          'lowest_salary': yearlyData.lowestSalary,
        });
      }

      // 构建部门趋势数据
      final departmentTrends = <String, List<Map<String, dynamic>>>{};
      // 从年度数据中提取部门信息
      final departmentNames = <String>{};
      for (var yearlyData in sortedYearlyData) {
        departmentNames.addAll(yearlyData.departmentStats.keys);
      }
      
      for (var deptName in departmentNames) {
        final deptTrends = <Map<String, dynamic>>[];
        
        for (var yearlyData in sortedYearlyData) {
          if (yearlyData.departmentStats.containsKey(deptName)) {
            final deptStat = yearlyData.departmentStats[deptName]!;
            deptTrends.add({
              'year': yearlyData.year,
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
      // 从年度数据中提取薪资区间信息
      final rangeNames = <String>{};
      for (var yearlyData in sortedYearlyData) {
        rangeNames.addAll(yearlyData.salaryRangeStats.keys);
      }
      
      for (var rangeName in rangeNames) {
        final rangeTrends = <Map<String, dynamic>>[];
        
        for (var yearlyData in sortedYearlyData) {
          if (yearlyData.salaryRangeStats.containsKey(rangeName)) {
            final rangeStat = yearlyData.salaryRangeStats[rangeName]!;
            rangeTrends.add({
              'year': yearlyData.year,
              'employee_count': rangeStat.employeeCount,
              'total_salary': rangeStat.totalSalary,
              'average_salary': rangeStat.averageSalary,
            });
          }
        }
        
        salaryRangeTrends[rangeName] = rangeTrends;
      }

      // 构建同比数据
      final yearOverYearData = <Map<String, dynamic>>[];
      for (int i = 1; i < sortedYearlyData.length; i++) {
        final currentYear = sortedYearlyData[i];
        final previousYear = sortedYearlyData[i - 1];
        
        final employeeCountChange = currentYear.employeeCount - previousYear.employeeCount;
        final employeeCountChangeRate = previousYear.employeeCount > 0
            ? (employeeCountChange / previousYear.employeeCount) * 100
            : 0.0;
            
        final totalSalaryChange = currentYear.totalSalary - previousYear.totalSalary;
        final totalSalaryChangeRate = previousYear.totalSalary > 0
            ? (totalSalaryChange / previousYear.totalSalary) * 100
            : 0.0;
            
        final averageSalaryChange = currentYear.averageSalary - previousYear.averageSalary;
        final averageSalaryChangeRate = previousYear.averageSalary > 0
            ? (averageSalaryChange / previousYear.averageSalary) * 100
            : 0.0;
        
        yearOverYearData.add({
          'current_year': currentYear.year,
          'previous_year': previousYear.year,
          'employee_count_change': employeeCountChange,
          'employee_count_change_rate': employeeCountChangeRate,
          'total_salary_change': totalSalaryChange,
          'total_salary_change_rate': totalSalaryChangeRate,
          'average_salary_change': averageSalaryChange,
          'average_salary_change_rate': averageSalaryChangeRate,
        });
      }

      // 构建工资构成变化数据
      final salaryCompositionTrends = <Map<String, dynamic>>[];
      for (var yearlyData in sortedYearlyData) {
        // 假设我们有工资构成数据
        double basicSalaryRatio = 0.0;
        double bonusSalaryRatio = 0.0;
        double allowanceRatio = 0.0;
        
        // 如果有工资构成数据，可以从yearlyData中获取
        // 这里使用默认值作为示例
        basicSalaryRatio = 0.7;  // 基本工资占比
        bonusSalaryRatio = 0.2;  // 奖金占比
        allowanceRatio = 0.1;    // 补贴占比
        
        salaryCompositionTrends.add({
          'year': yearlyData.year,
          'basic_salary_ratio': basicSalaryRatio,
          'bonus_salary_ratio': bonusSalaryRatio,
          'allowance_ratio': allowanceRatio,
        });
      }

      // 构建考勤数据
      final attendanceData = <Map<String, dynamic>>[];
      for (var stat in attendanceStats) {
        // 假设一个月工作日为22天
        const int workDaysPerMonth = 22;
        
        // 计算请假率、缺勤率和考勤率
        final leaveRate = (stat.leaveDays + stat.sickLeaveDays) / workDaysPerMonth * 100;
        final absenceRate = (stat.absenceCount + stat.truancyDays) / workDaysPerMonth * 100;
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
        'report_type': 'multi_year',
        'start_date': '${startDate.year}-01-01',
        'end_date': '${endDate.year}-12-31',
        'key_metrics': {
          'total_employees': totalEmployees,
          'average_employees': averageEmployees,
          'total_salary': totalSalary,
          'average_salary': averageSalary,
          'highest_salary': highestSalary,
          'lowest_salary': lowestSalary,
        },
        'yearly_trends': yearlyTrends,
        'department_trends': departmentTrends,
        'salary_range_trends': salaryRangeTrends,
        'year_over_year': yearOverYearData,
        'salary_composition_trends': salaryCompositionTrends,
        'attendance_data': attendanceData,
        'department_yoy_data': departmentYearOverYearData ?? [],
      };

      return jsonEncode(jsonData);
    } catch (e, stackTrace) {
      logger.severe('Error converting multi-year analysis data to JSON: $e', e, stackTrace);
      rethrow;
    }
  }
}