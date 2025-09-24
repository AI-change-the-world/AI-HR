// 考勤统计结果
import 'package:salary_report/src/isar/salary_list.dart';

class AttendanceStats {
  final String name;
  final String department;
  final double sickLeaveDays;
  final double leaveDays;
  final int absenceCount;
  final int truancyDays;
  final int? year; // 添加年份字段
  final int? month; // 添加月份字段

  AttendanceStats({
    required this.name,
    required this.department,
    required this.sickLeaveDays,
    required this.leaveDays,
    required this.absenceCount,
    required this.truancyDays,
    this.year,
    this.month,
  });
}

// 病假事假比例统计
class LeaveRatioStats {
  final double sickLeaveRatio;
  final double leaveRatio;
  final int totalEmployees;
  final int? year; // 添加年份字段
  final int? month; // 添加月份字段

  LeaveRatioStats({
    required this.sickLeaveRatio,
    required this.leaveRatio,
    required this.totalEmployees,
    this.year,
    this.month,
  });
}

// 月度工资数据模型
class MonthlySalaryData {
  final int year;
  final int month;
  final List<SalaryListRecord> records;
  final Map<String, dynamic> summaryData;

  MonthlySalaryData({
    required this.year,
    required this.month,
    required this.records,
    required this.summaryData,
  });
}

// 多月工资数据模型
class MultiMonthSalaryData {
  final List<MonthlySalaryData> monthlyData;
  final DateTime startDate;
  final DateTime endDate;

  MultiMonthSalaryData({
    required this.monthlyData,
    required this.startDate,
    required this.endDate,
  });
}

// 部门工资统计结果
class DepartmentSalaryStats {
  final String department;
  final double totalNetSalary;
  final double averageNetSalary;
  final int employeeCount;
  final int year;
  final int month;
  final double maxSalary; // 添加最高工资字段
  final double minSalary; // 添加最低工资字段

  DepartmentSalaryStats({
    required this.department,
    required this.totalNetSalary,
    required this.averageNetSalary,
    required this.employeeCount,
    required this.year,
    required this.month,
    this.maxSalary = 0, // 默认值为0
    this.minSalary = 0, // 默认值为0
  });
}

// 岗位工资统计结果
class PositionSalaryStats {
  final String position;
  final double totalNetSalary;
  final double averageNetSalary;
  final int employeeCount;
  final int year;
  final int month;
  final double maxSalary; // 添加最高工资字段
  final double minSalary; // 添加最低工资字段

  PositionSalaryStats({
    required this.position,
    required this.totalNetSalary,
    required this.averageNetSalary,
    required this.employeeCount,
    required this.year,
    required this.month,
    this.maxSalary = 0, // 默认值为0
    this.minSalary = 0, // 默认值为0
  });
}

// 薪资范围统计结果
class SalaryRangeStats {
  final String range;
  final int employeeCount;
  final double totalSalary;
  final double averageSalary;
  final int year;
  final int month;

  SalaryRangeStats({
    required this.range,
    required this.employeeCount,
    required this.totalSalary,
    required this.averageSalary,
    required this.year,
    required this.month,
  });
}

// 部门和薪资范围联合统计结果
class DepartmentSalaryRangeStats {
  final String department;
  final String salaryRange;
  final int employeeCount;
  final double totalSalary;
  final double averageSalary;
  final int year;
  final int month;

  DepartmentSalaryRangeStats({
    required this.department,
    required this.salaryRange,
    required this.employeeCount,
    required this.totalSalary,
    required this.averageSalary,
    required this.year,
    required this.month,
  });
}

// 最小化的人员信息类
class MinimalEmployeeInfo {
  final String name;
  final String department;

  MinimalEmployeeInfo({required this.name, required this.department});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MinimalEmployeeInfo &&
        other.name == name &&
        other.department == department;
  }

  @override
  int get hashCode => Object.hash(name, department);
}

// 月度对比数据模型
class MonthlyComparisonData {
  final int year;
  final int month;
  final int employeeCount;
  final double totalSalary;
  final double averageSalary;
  final double highestSalary; // 添加最高工资字段
  final double lowestSalary; // 添加最低工资字段
  final Map<String, DepartmentSalaryStats> departmentStats;
  final Map<String, SalaryRangeStats> salaryRangeStats;
  final List<MinimalEmployeeInfo> workers; // 添加员工列表字段

  MonthlyComparisonData({
    required this.year,
    required this.month,
    required this.employeeCount,
    required this.totalSalary,
    required this.averageSalary,
    required this.highestSalary, // 添加最高工资字段
    required this.lowestSalary, // 添加最低工资字段
    required this.departmentStats,
    required this.salaryRangeStats,
    required this.workers,
  });
}

// 多月对比数据模型
class MultiMonthComparisonData {
  final List<MonthlyComparisonData> monthlyComparisons;
  final DateTime startDate;
  final DateTime endDate;
  Map<String, String?> monthlySummary;

  MultiMonthComparisonData({
    required this.monthlyComparisons,
    required this.startDate,
    required this.endDate,
    this.monthlySummary = const {},
  });
}

/*=============================================================================*/

// 季度对比数据模型
@Deprecated("use `MultiMonthComparisonData` instead")
class QuarterlyComparisonData {
  final List<MonthlyComparisonData> monthlyComparisons;
  final int year;
  final int quarter;
  final int employeeCount;
  final double totalSalary;
  final double averageSalary;
  final double highestSalary;
  final double lowestSalary;
  final Map<String, DepartmentSalaryStats> departmentStats;
  final Map<String, SalaryRangeStats> salaryRangeStats;
  final Map<String, List<MinimalEmployeeInfo>> uniqueEmployees; // 每个月的员工姓名
  final int totalEmployeeCount; // 季度去重后的员工总数
  final List<MinimalEmployeeInfo> workers; // 添加员工列表字段

  QuarterlyComparisonData({
    required this.year,
    required this.quarter,
    required this.employeeCount,
    required this.totalSalary,
    required this.averageSalary,
    required this.highestSalary,
    required this.lowestSalary,
    required this.departmentStats,
    required this.salaryRangeStats,
    required this.uniqueEmployees,
    required this.totalEmployeeCount,
    required this.workers,
    required this.monthlyComparisons,
  });
}

// 多季度对比数据模型
@Deprecated("use `MultiMonthComparisonData` instead")
class MultiQuarterComparisonData {
  final List<QuarterlyComparisonData> quarterlyComparisons;
  final DateTime startDate;
  final DateTime endDate;
  Map<String, String?> monthlySummary;

  MultiQuarterComparisonData({
    required this.quarterlyComparisons,
    required this.startDate,
    required this.endDate,
    this.monthlySummary = const {},
  });
}

/*=============================================================================*/

// 年度对比数据模型
@Deprecated("use `MultiMonthComparisonData` instead")
class YearlyComparisonData {
  final int year;
  final int employeeCount;
  final double totalSalary;
  final double averageSalary;
  final double highestSalary;
  final double lowestSalary;
  final Map<String, DepartmentSalaryStats> departmentStats;
  final Map<String, SalaryRangeStats> salaryRangeStats;
  final Map<String, List<MinimalEmployeeInfo>> uniqueEmployees; // 每个月的员工姓名
  final int totalEmployeeCount; // 全年去重后的员工总数
  final List<MinimalEmployeeInfo> workers; // 添加员工列表字段

  YearlyComparisonData({
    required this.year,
    required this.employeeCount,
    required this.totalSalary,
    required this.averageSalary,
    required this.highestSalary,
    required this.lowestSalary,
    required this.departmentStats,
    required this.salaryRangeStats,
    required this.uniqueEmployees,
    required this.totalEmployeeCount,
    required this.workers,
  });
}

// 多年对比数据模型
@Deprecated("use `MultiMonthComparisonData` instead")
class MultiYearComparisonData {
  final List<YearlyComparisonData> yearlyComparisons;
  final DateTime startDate;
  final DateTime endDate;
  Map<String, String?> monthlySummary;

  MultiYearComparisonData({
    required this.yearlyComparisons,
    required this.startDate,
    required this.endDate,
    this.monthlySummary = const {},
  });
}
