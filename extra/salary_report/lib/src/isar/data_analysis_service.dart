import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/salary_list.dart';

// 部门工资统计结果
class DepartmentSalaryStats {
  final String department;
  final double totalNetSalary;
  final double averageNetSalary;
  final int employeeCount;

  DepartmentSalaryStats({
    required this.department,
    required this.totalNetSalary,
    required this.averageNetSalary,
    required this.employeeCount,
  });
}

// 考勤统计结果
class AttendanceStats {
  final String name;
  final String department;
  final double sickLeaveDays;
  final double leaveDays;
  final int absenceCount;
  final int truancyDays;

  AttendanceStats({
    required this.name,
    required this.department,
    required this.sickLeaveDays,
    required this.leaveDays,
    required this.absenceCount,
    required this.truancyDays,
  });
}

// 病假事假比例统计
class LeaveRatioStats {
  final double sickLeaveRatio;
  final double leaveRatio;
  final int totalEmployees;

  LeaveRatioStats({
    required this.sickLeaveRatio,
    required this.leaveRatio,
    required this.totalEmployees,
  });
}

class DataAnalysisService {
  final IsarDatabase _database;

  DataAnalysisService(this._database);

  /// 按部门聚合实发工资和人均实发工资
  Future<List<DepartmentSalaryStats>> getDepartmentSalaryStats({
    int? year,
    int? startYear,
    int? endYear,
    int? month,
    int? startMonth,
    int? endMonth,
    String? department,
    String? name,
  }) async {
    final isar = _database.isar!;

    // 构建查询
    var queryBuilder = isar.salaryLists.where();

    // 获取所有数据，然后在内存中过滤
    final salaryLists = await queryBuilder.findAll();

    // 在内存中过滤年份和月份
    final filteredSalaryLists = <SalaryList>[];
    for (var salaryList in salaryLists) {
      bool yearMatch = true;
      bool monthMatch = true;

      // 年份过滤
      if (year != null) {
        yearMatch = salaryList.year == year;
      } else if (startYear != null && endYear != null) {
        yearMatch = salaryList.year >= startYear && salaryList.year <= endYear;
      }

      // 月份过滤
      if (month != null) {
        monthMatch = salaryList.month == month;
      } else if (startMonth != null && endMonth != null) {
        monthMatch =
            salaryList.month >= startMonth && salaryList.month <= endMonth;
      }

      if (yearMatch && monthMatch) {
        filteredSalaryLists.add(salaryList);
      }
    }

    // 按部门聚合数据
    final departmentMap = <String, List<SalaryListRecord>>{};

    for (var salaryList in filteredSalaryLists) {
      for (var record in salaryList.records) {
        // 过滤条件
        if (department != null && record.department != department) continue;
        if (name != null && record.name != name) continue;
        if (record.department == null || record.netSalary == null) continue;

        final dept = record.department!;
        if (!departmentMap.containsKey(dept)) {
          departmentMap[dept] = [];
        }
        departmentMap[dept]!.add(record);
      }
    }

    // 计算统计数据
    final stats = <DepartmentSalaryStats>[];
    departmentMap.forEach((dept, records) {
      double totalSalary = 0;
      int validRecordCount = 0;

      for (var record in records) {
        if (record.netSalary != null) {
          // 尝试解析实发工资字符串
          final salaryStr = record.netSalary!.replaceAll(
            RegExp(r'[^\d.-]'),
            '',
          );
          if (double.tryParse(salaryStr) != null) {
            totalSalary += double.parse(salaryStr);
            validRecordCount++;
          }
        }
      }

      if (validRecordCount > 0) {
        stats.add(
          DepartmentSalaryStats(
            department: dept,
            totalNetSalary: totalSalary,
            averageNetSalary: totalSalary / validRecordCount,
            employeeCount: validRecordCount,
          ),
        );
      }
    });

    return stats;
  }

  /// 按月关注缺勤情况
  Future<List<AttendanceStats>> getMonthlyAttendanceStats({
    int? year,
    int? startYear,
    int? endYear,
    int? month,
    int? startMonth,
    int? endMonth,
    String? department,
    String? name,
  }) async {
    final isar = _database.isar!;

    // 构建查询
    var queryBuilder = isar.salaryLists.where();

    // 获取所有数据，然后在内存中过滤
    final salaryLists = await queryBuilder.findAll();

    // 在内存中过滤年份和月份
    final filteredSalaryLists = <SalaryList>[];
    for (var salaryList in salaryLists) {
      bool yearMatch = true;
      bool monthMatch = true;

      // 年份过滤
      if (year != null) {
        yearMatch = salaryList.year == year;
      } else if (startYear != null && endYear != null) {
        yearMatch = salaryList.year >= startYear && salaryList.year <= endYear;
      }

      // 月份过滤
      if (month != null) {
        monthMatch = salaryList.month == month;
      } else if (startMonth != null && endMonth != null) {
        monthMatch =
            salaryList.month >= startMonth && salaryList.month <= endMonth;
      }

      if (yearMatch && monthMatch) {
        filteredSalaryLists.add(salaryList);
      }
    }

    // 收集考勤数据
    final attendanceStats = <AttendanceStats>[];

    for (var salaryList in filteredSalaryLists) {
      for (var record in salaryList.records) {
        // 过滤条件
        if (department != null && record.department != department) continue;
        if (name != null && record.name != name) continue;
        if (record.name == null || record.department == null) continue;

        // 解析考勤数据
        double sickLeave = 0;
        double leave = 0;
        int absence = 0;
        int truancy = 0;

        if (record.sickLeave != null) {
          final sickLeaveStr = record.sickLeave!.replaceAll(
            RegExp(r'[^\d.-]'),
            '',
          );
          sickLeave = double.tryParse(sickLeaveStr) ?? 0;
        }

        if (record.leave != null) {
          final leaveStr = record.leave!.replaceAll(RegExp(r'[^\d.-]'), '');
          leave = double.tryParse(leaveStr) ?? 0;
        }

        if (record.absence != null) {
          final absenceStr = record.absence!.replaceAll(RegExp(r'[^\d.-]'), '');
          absence = int.tryParse(absenceStr) ?? 0;
        }

        if (record.truancy != null) {
          final truancyStr = record.truancy!.replaceAll(RegExp(r'[^\d.-]'), '');
          truancy = int.tryParse(truancyStr) ?? 0;
        }

        attendanceStats.add(
          AttendanceStats(
            name: record.name!,
            department: record.department!,
            sickLeaveDays: sickLeave,
            leaveDays: leave,
            absenceCount: absence,
            truancyDays: truancy,
          ),
        );
      }
    }

    return attendanceStats;
  }

  /// 获取病假和事假的比例统计
  Future<LeaveRatioStats> getLeaveRatioStats({
    int? year,
    int? startYear,
    int? endYear,
    int? month,
    int? startMonth,
    int? endMonth,
    String? department,
    String? name,
  }) async {
    final isar = _database.isar!;

    // 构建查询
    var queryBuilder = isar.salaryLists.where();

    // 获取所有数据，然后在内存中过滤
    final salaryLists = await queryBuilder.findAll();

    // 在内存中过滤年份和月份
    final filteredSalaryLists = <SalaryList>[];
    for (var salaryList in salaryLists) {
      bool yearMatch = true;
      bool monthMatch = true;

      // 年份过滤
      if (year != null) {
        yearMatch = salaryList.year == year;
      } else if (startYear != null && endYear != null) {
        yearMatch = salaryList.year >= startYear && salaryList.year <= endYear;
      }

      // 月份过滤
      if (month != null) {
        monthMatch = salaryList.month == month;
      } else if (startMonth != null && endMonth != null) {
        monthMatch =
            salaryList.month >= startMonth && salaryList.month <= endMonth;
      }

      if (yearMatch && monthMatch) {
        filteredSalaryLists.add(salaryList);
      }
    }

    // 统计病假和事假数据
    double totalSickLeave = 0;
    double totalLeave = 0;
    int employeeCount = 0;

    for (var salaryList in filteredSalaryLists) {
      for (var record in salaryList.records) {
        // 过滤条件
        if (department != null && record.department != department) continue;
        if (name != null && record.name != name) continue;

        employeeCount++;

        if (record.sickLeave != null) {
          final sickLeaveStr = record.sickLeave!.replaceAll(
            RegExp(r'[^\d.-]'),
            '',
          );
          totalSickLeave += double.tryParse(sickLeaveStr) ?? 0;
        }

        if (record.leave != null) {
          final leaveStr = record.leave!.replaceAll(RegExp(r'[^\d.-]'), '');
          totalLeave += double.tryParse(leaveStr) ?? 0;
        }
      }
    }

    // 计算比例
    final totalLeaveDays = totalSickLeave + totalLeave;
    final sickLeaveRatio = employeeCount > 0
        ? totalSickLeave / employeeCount
        : 0.0;
    final leaveRatio = employeeCount > 0 ? totalLeave / employeeCount : 0.0;

    return LeaveRatioStats(
      sickLeaveRatio: sickLeaveRatio,
      leaveRatio: leaveRatio,
      totalEmployees: employeeCount,
    );
  }

  /// 获取指定年月的工资汇总数据
  Future<Map<String, dynamic>?> getSalarySummaryData({
    required int year,
    required int month,
  }) async {
    final isar = _database.isar!;

    // 查询指定年月的工资数据
    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    if (salaryList != null && salaryList.extraInfo.isNotEmpty) {
      try {
        // 解析存储的汇总数据
        final summaryData = jsonDecode(salaryList.extraInfo);
        return summaryData is Map<String, dynamic> ? summaryData : null;
      } catch (e) {
        // 解析失败，返回null
        return null;
      }
    }

    return null;
  }

  /// 获取上月的工资汇总数据
  Future<Map<String, dynamic>?> getLastMonthSalarySummaryData({
    required int year,
    required int month,
  }) async {
    // 计算上月的年份和月份
    int lastYear = year;
    int lastMonth = month - 1;

    if (lastMonth == 0) {
      // 如果是1月，上月就是去年的12月
      lastYear = year - 1;
      lastMonth = 12;
    }

    return await getSalarySummaryData(year: lastYear, month: lastMonth);
  }

  /// 获取上月的部门工资统计数据
  Future<DepartmentSalaryStats?> getLastMonthDepartmentStats({
    required int year,
    required int month,
    required String department,
  }) async {
    // 计算上月的年份和月份
    int lastYear = year;
    int lastMonth = month - 1;

    if (lastMonth == 0) {
      // 如果是1月，上月就是去年的12月
      lastYear = year - 1;
      lastMonth = 12;
    }

    // 获取上月该部门的统计数据
    final stats = await getDepartmentSalaryStats(
      year: lastYear,
      month: lastMonth,
      department: department,
    );

    // 返回匹配的部门统计数据
    for (var stat in stats) {
      if (stat.department == department) {
        return stat;
      }
    }

    return null;
  }

  /// 获取上月的总员工数和平均薪资
  Future<Map<String, dynamic>?> getLastMonthEmployeeAndSalaryStats({
    required int year,
    required int month,
  }) async {
    // 计算上月的年份和月份
    int lastYear = year;
    int lastMonth = month - 1;

    if (lastMonth == 0) {
      // 如果是1月，上月就是去年的12月
      lastYear = year - 1;
      lastMonth = 12;
    }

    // 获取上月的部门统计数据
    final stats = await getDepartmentSalaryStats(
      year: lastYear,
      month: lastMonth,
    );

    if (stats.isEmpty) {
      return null;
    }

    // 计算总员工数和平均薪资
    int totalEmployees = 0;
    double totalSalary = 0;
    int validDepartments = 0;

    for (var stat in stats) {
      totalEmployees += stat.employeeCount;
      totalSalary += stat.totalNetSalary;
      validDepartments++;
    }

    final averageSalary = validDepartments > 0
        ? totalSalary / totalEmployees
        : 0;

    return {'totalEmployees': totalEmployees, 'averageSalary': averageSalary};
  }

  /// 获取指定年份范围的工资汇总数据
  Future<Map<String, dynamic>?> getMultiMonthSalarySummaryData({
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
  }) async {
    final isar = _database.isar!;

    // 查询指定年份范围的工资数据
    final salaryLists = await isar.salaryLists
        .filter()
        .yearBetween(startYear, endYear)
        .findAll();

    // 合并所有月份的汇总数据
    final mergedSummaryData = <String, dynamic>{};

    for (var salaryList in salaryLists) {
      // 检查月份是否在范围内
      bool monthInRange = false;
      if (salaryList.year == startYear) {
        monthInRange = salaryList.month >= startMonth;
      } else if (salaryList.year == endYear) {
        monthInRange = salaryList.month <= endMonth;
      } else {
        monthInRange = salaryList.year > startYear && salaryList.year < endYear;
      }

      if (monthInRange && salaryList.extraInfo.isNotEmpty) {
        try {
          // 解析存储的汇总数据
          final summaryData = jsonDecode(salaryList.extraInfo);
          if (summaryData is Map<String, dynamic>) {
            // 合并数据
            summaryData.forEach((key, value) {
              // 如果是数值类型，进行累加
              if (value is num) {
                if (mergedSummaryData.containsKey(key)) {
                  mergedSummaryData[key] =
                      (mergedSummaryData[key] as num) + value;
                } else {
                  mergedSummaryData[key] = value;
                }
              } else {
                // 非数值类型，直接覆盖（以最后一个为准）
                mergedSummaryData[key] = value;
              }
            });
          }
        } catch (e) {
          // 解析失败，跳过该条数据
          continue;
        }
      }
    }

    return mergedSummaryData.isEmpty ? null : mergedSummaryData;
  }

  /// 按季度统计部门工资
  Future<List<DepartmentSalaryStats>> getQuarterlyDepartmentSalaryStats({
    int? year,
    int? startYear,
    int? endYear,
    int? quarter,
    String? department,
    String? name,
  }) async {
    final isar = _database.isar!;

    // 计算季度的月份范围
    int? startMonth, endMonth;
    if (quarter != null) {
      startMonth = (quarter - 1) * 3 + 1;
      endMonth = quarter * 3;
    }

    // 构建查询
    var queryBuilder = isar.salaryLists.where();

    // 获取所有数据，然后在内存中过滤
    final salaryLists = await queryBuilder.findAll();

    // 在内存中过滤年份和月份
    final filteredSalaryLists = <SalaryList>[];
    for (var salaryList in salaryLists) {
      bool yearMatch = true;
      bool monthMatch = true;

      // 年份过滤
      if (year != null) {
        yearMatch = salaryList.year == year;
      } else if (startYear != null && endYear != null) {
        yearMatch = salaryList.year >= startYear && salaryList.year <= endYear;
      }

      // 季度月份过滤
      if (startMonth != null && endMonth != null) {
        monthMatch =
            salaryList.month >= startMonth && salaryList.month <= endMonth;
      }

      if (yearMatch && monthMatch) {
        filteredSalaryLists.add(salaryList);
      }
    }

    // 按部门聚合数据
    final departmentMap = <String, List<SalaryListRecord>>{};

    for (var salaryList in filteredSalaryLists) {
      for (var record in salaryList.records) {
        // 过滤条件
        if (department != null && record.department != department) continue;
        if (name != null && record.name != name) continue;
        if (record.department == null || record.netSalary == null) continue;

        final dept = record.department!;
        if (!departmentMap.containsKey(dept)) {
          departmentMap[dept] = [];
        }
        departmentMap[dept]!.add(record);
      }
    }

    // 计算统计数据
    final stats = <DepartmentSalaryStats>[];
    departmentMap.forEach((dept, records) {
      double totalSalary = 0;
      int validRecordCount = 0;

      for (var record in records) {
        if (record.netSalary != null) {
          // 尝试解析实发工资字符串
          final salaryStr = record.netSalary!.replaceAll(
            RegExp(r'[^\d.-]'),
            '',
          );
          if (double.tryParse(salaryStr) != null) {
            totalSalary += double.parse(salaryStr);
            validRecordCount++;
          }
        }
      }

      if (validRecordCount > 0) {
        stats.add(
          DepartmentSalaryStats(
            department: dept,
            totalNetSalary: totalSalary,
            averageNetSalary: totalSalary / validRecordCount,
            employeeCount: validRecordCount,
          ),
        );
      }
    });

    return stats;
  }
}
