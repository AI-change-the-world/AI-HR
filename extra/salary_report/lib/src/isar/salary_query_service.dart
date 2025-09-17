import 'package:isar_community/isar.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/salary_list.dart';

class SalaryQueryService {
  final IsarDatabase _database;

  SalaryQueryService(this._database);

  /// 查询某年某月某员工的工资详情
  Future<SalaryListRecord?> getEmployeeSalaryByYearMonth({
    required int year,
    required int month,
    required String employeeName,
  }) async {
    final isar = _database.isar!;

    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    if (salaryList != null) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          return record;
        }
      }
    }

    return null;
  }

  /// 查询某年某月某部门的工资详情
  Future<List<SalaryListRecord>> getDepartmentSalaryByYearMonth({
    required int year,
    required int month,
    required String department,
  }) async {
    final isar = _database.isar!;

    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    final results = <SalaryListRecord>[];

    if (salaryList != null) {
      for (var record in salaryList.records) {
        if (record.department == department) {
          results.add(record);
        }
      }
    }

    return results;
  }

  /// 查询某年某月工资最高的前N名员工
  Future<List<SalaryListRecord>> getTopSalaryEmployees({
    required int year,
    required int month,
    int limit = 10,
  }) async {
    final isar = _database.isar!;

    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    if (salaryList != null) {
      // 过滤掉没有姓名或工资的记录
      final validRecords = salaryList.records
          .where((record) => record.name != null && record.netSalary != null)
          .toList();

      // 按工资排序
      validRecords.sort((a, b) {
        final salaryA =
            double.tryParse(a.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ??
            0;
        final salaryB =
            double.tryParse(b.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ??
            0;
        return salaryB.compareTo(salaryA); // 降序排列
      });

      return validRecords.take(limit).toList();
    }

    return [];
  }

  /// 查询某年某月工资最低的前N名员工
  Future<List<SalaryListRecord>> getBottomSalaryEmployees({
    required int year,
    required int month,
    int limit = 10,
  }) async {
    final isar = _database.isar!;

    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    if (salaryList != null) {
      // 过滤掉没有姓名或工资的记录
      final validRecords = salaryList.records
          .where((record) => record.name != null && record.netSalary != null)
          .toList();

      // 按工资排序
      validRecords.sort((a, b) {
        final salaryA =
            double.tryParse(a.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ??
            0;
        final salaryB =
            double.tryParse(b.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ??
            0;
        return salaryA.compareTo(salaryB); // 升序排列
      });

      return validRecords.take(limit).toList();
    }

    return [];
  }

  /// 查询某年某月某员工的考勤情况
  Future<Map<String, String?>> getEmployeeAttendance({
    required int year,
    required int month,
    required String employeeName,
  }) async {
    final isar = _database.isar!;

    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    if (salaryList != null) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          return {
            'attendance': record.attendance,
            'payDays': record.payDays,
            'actualPayDays': record.actualPayDays,
            'sickLeave': record.sickLeave,
            'leave': record.leave,
            'absence': record.absence,
            'truancy': record.truancy,
          };
        }
      }
    }

    return {};
  }

  /// 查询某年某月所有员工的平均工资
  Future<double> getAverageSalary({
    required int year,
    required int month,
  }) async {
    final isar = _database.isar!;

    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    if (salaryList != null) {
      double totalSalary = 0;
      int count = 0;

      for (var record in salaryList.records) {
        if (record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;
          totalSalary += salary;
          count++;
        }
      }

      return count > 0 ? totalSalary / count : 0;
    }

    return 0;
  }

  /// 查询某年某月所有员工的工资总和
  Future<double> getTotalSalary({required int year, required int month}) async {
    final isar = _database.isar!;

    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    if (salaryList != null) {
      double totalSalary = 0;

      for (var record in salaryList.records) {
        if (record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;
          totalSalary += salary;
        }
      }

      return totalSalary;
    }

    return 0;
  }

  /// 查询某年某月各部门的平均工资
  Future<Map<String, double>> getAverageSalaryByDepartments({
    required int year,
    required int month,
  }) async {
    final isar = _database.isar!;

    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    if (salaryList != null) {
      final departmentSalaryMap = <String, List<double>>{};

      for (var record in salaryList.records) {
        if (record.department != null && record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;

          if (!departmentSalaryMap.containsKey(record.department)) {
            departmentSalaryMap[record.department!] = [];
          }
          departmentSalaryMap[record.department!]!.add(salary);
        }
      }

      final result = <String, double>{};
      departmentSalaryMap.forEach((department, salaries) {
        final total = salaries.reduce((a, b) => a + b);
        result[department] = salaries.isNotEmpty ? total / salaries.length : 0;
      });

      return result;
    }

    return {};
  }
}
