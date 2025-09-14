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
