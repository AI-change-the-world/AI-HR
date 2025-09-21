import 'package:isar_community/isar.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/global_analysis_models.dart';
import 'package:salary_report/src/isar/monthly_analysis_service.dart';
import 'package:salary_report/src/isar/quarterly_analysis_service.dart';
import 'package:salary_report/src/isar/yearly_analysis_service.dart';
import 'package:salary_report/src/isar/salary_list.dart';

class DataAnalysisService {
  final IsarDatabase _database;
  final MonthlyAnalysisService _monthlyService;
  final QuarterlyAnalysisService _quarterlyService;
  final YearlyAnalysisService _yearlyService;

  DataAnalysisService(this._database)
    : _monthlyService = MonthlyAnalysisService(_database),
      _quarterlyService = QuarterlyAnalysisService(_database),
      _yearlyService = YearlyAnalysisService(_database);

  // 月度分析委托给 MonthlyAnalysisService
  Future<MonthlySalaryData?> getMonthlySalaryData(int year, int month) async {
    return _monthlyService.getMonthlySalaryData(year, month);
  }

  Future<MultiMonthSalaryData?> getMultiMonthSalaryData(
    int startYear,
    int startMonth,
    int endYear,
    int endMonth,
  ) async {
    return _monthlyService.getMultiMonthSalaryData(
      startYear,
      startMonth,
      endYear,
      endMonth,
    );
  }

  Future<List<DepartmentSalaryStats>> getDepartmentAggregation(
    int year,
    int month, {
    String? department,
    String? name,
  }) async {
    return _monthlyService.getDepartmentAggregation(
      year,
      month,
      department: department,
      name: name,
    );
  }

  Future<List<SalaryRangeStats>> getSalaryRangeAggregation(
    int year,
    int month,
  ) async {
    return _monthlyService.getSalaryRangeAggregation(year, month);
  }

  Future<List<DepartmentSalaryRangeStats>> getDepartmentSalaryRangeAggregation(
    int year,
    int month,
  ) async {
    return _monthlyService.getDepartmentSalaryRangeAggregation(year, month);
  }

  Future<MultiMonthComparisonData?> getMultiMonthComparisonData(
    int startYear,
    int startMonth,
    int endYear,
    int endMonth,
  ) async {
    return _monthlyService.getMultiMonthComparisonData(
      startYear,
      startMonth,
      endYear,
      endMonth,
    );
  }

  // 季度分析委托给 QuarterlyAnalysisService
  Future<MultiQuarterComparisonData?> getMultiQuarterComparisonData(
    int startYear,
    int startQuarter,
    int endYear,
    int endQuarter,
  ) async {
    return _quarterlyService.getMultiQuarterComparisonData(
      startYear,
      startQuarter,
      endYear,
      endQuarter,
    );
  }

  // 年度分析委托给 YearlyAnalysisService
  Future<MultiYearComparisonData?> getMultiYearComparisonData(
    int startYear,
    int endYear,
  ) async {
    return _yearlyService.getMultiYearComparisonData(startYear, endYear);
  }

  // 保留一些直接访问数据库的方法，用于向后兼容
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
            'leave': record.personalLeave,
            'absence': record.absence,
            'truancy': record.truancy,
          };
        }
      }
    }

    return {};
  }

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
    return _monthlyService.getMonthlyAttendanceStats(
      year: year,
      startYear: startYear,
      endYear: endYear,
      month: month,
      startMonth: startMonth,
      endMonth: endMonth,
      department: department,
      name: name,
    );
  }

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
    return _monthlyService.getDepartmentSalaryStats(
      year: year,
      startYear: startYear,
      endYear: endYear,
      month: month,
      startMonth: startMonth,
      endMonth: endMonth,
      department: department,
      name: name,
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
    return _quarterlyService.getQuarterlyDepartmentSalaryStats(
      year: year,
      startYear: startYear,
      endYear: endYear,
      quarter: quarter,
      department: department,
      name: name,
    );
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
    return _monthlyService.getLeaveRatioStats(
      year: year,
      startYear: startYear,
      endYear: endYear,
      month: month,
      startMonth: startMonth,
      endMonth: endMonth,
      department: department,
      name: name,
    );
  }

  /// 查询某年某月工资最低的前N名员工
  Future<List<SalaryListRecord>> getBottomSalaryEmployees({
    required int year,
    required int month,
    int limit = 10,
  }) async {
    return _monthlyService.getBottomSalaryEmployees(
      year: year,
      month: month,
      limit: limit,
    );
  }

  /// 获取指定年月的工资汇总数据
  Future<Map<String, dynamic>?> getSalarySummaryData({
    required int year,
    required int month,
  }) async {
    return _monthlyService.getSalarySummaryData(year: year, month: month);
  }

  /// 查询某年某月工资最高的前N名员工
  Future<List<SalaryListRecord>> getTopSalaryEmployees({
    required int year,
    required int month,
    int limit = 10,
  }) async {
    return _monthlyService.getTopSalaryEmployees(
      year: year,
      month: month,
      limit: limit,
    );
  }

  Future<Map<String, double>> getAverageSalaryByDepartments({
    required int year,
    required int month,
  }) {
    return _monthlyService.getAverageSalaryByDepartments(
      year: year,
      month: month,
    );
  }

  /// 查询某年某月某部门的工资详情
  Future<List<SalaryListRecord>> getDepartmentSalaryByYearMonth({
    required int year,
    required int month,
    required String department,
  }) {
    return _monthlyService.getDepartmentSalaryByYearMonth(
      year: year,
      month: month,
      department: department,
    );
  }
}
