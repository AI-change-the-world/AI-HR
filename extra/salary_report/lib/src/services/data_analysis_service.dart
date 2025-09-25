import 'package:isar_community/isar.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/monthly_analysis_service.dart';
import 'package:salary_report/src/services/quarterly_analysis_service.dart';
import 'package:salary_report/src/services/yearly_analysis_service.dart';
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

  Future<(double, String)> getMonthlyGinicoef(int year, int month) async {
    return await _monthlyService.caculateGiniCoefficient(
      year: year,
      month: month,
    );
  }

  Future<String> getMonthlyDepartmentEmployeeCountDescription(
    int year,
    int month,
  ) async {
    return await _monthlyService.getMonthlyDepartmentEmployeeCountDescription(
      year: year,
      month: month,
    );
  }

  Future<String?> getMonthlySummary(int year, int month) async {
    return (await _database.isar!.salaryLists
            .filter()
            .yearEqualTo(year)
            .monthEqualTo(month)
            .findFirst())
        ?.extraInfo;
  }

  Future<Map<String, String?>> getMonthlySummaryMap(
    int startYear,
    int startMonth,
    int endYear,
    int endMonth,
  ) async {
    final range = _monthlyService.generateMonthList(
      startYear,
      startMonth,
      endYear,
      endMonth,
    );

    var result = <String, String?>{};

    for (var month in range) {
      final summary = await getMonthlySummary(month['year']!, month['month']!);

      result["${month['year']!}-${month['month']!}"] = summary;
    }

    return result;
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

  /// 按岗位聚合实发工资和人均实发工资
  Future<List<PositionSalaryStats>> getPositionSalaryStats({
    int? year,
    int? startYear,
    int? endYear,
    int? month,
    int? startMonth,
    int? endMonth,
    String? position,
    String? name,
  }) async {
    final isar = _database.isar!;

    // 获取符合时间范围的数据
    List<SalaryList> salaryLists = [];

    // 如果指定了具体的年月，直接查询
    if (year != null && month != null) {
      final salaryList = await isar.salaryLists
          .filter()
          .yearEqualTo(year)
          .monthEqualTo(month)
          .findFirst();

      if (salaryList != null) {
        salaryLists = [salaryList];
      }
    }
    // 如果指定了年份范围和月份范围
    else if (startYear != null &&
        endYear != null &&
        startMonth != null &&
        endMonth != null) {
      // 生成需要查询的月份列表
      final monthList = _monthlyService.generateMonthList(
        startYear,
        startMonth,
        endYear,
        endMonth,
      );

      // 遍历月份列表获取数据
      for (var monthInfo in monthList) {
        final salaryList = await isar.salaryLists
            .filter()
            .yearEqualTo(monthInfo['year']!)
            .monthEqualTo(monthInfo['month']!)
            .findFirst();

        if (salaryList != null) {
          salaryLists.add(salaryList);
        }
      }
    }
    // 如果只指定了年份
    else if (year != null) {
      salaryLists = await isar.salaryLists.filter().yearEqualTo(year).findAll();
    }
    // 如果只指定了月份
    else if (month != null) {
      salaryLists = await isar.salaryLists
          .filter()
          .monthEqualTo(month)
          .findAll();
    }
    // 如果指定了年份范围
    else if (startYear != null && endYear != null) {
      salaryLists = await isar.salaryLists
          .filter()
          .yearBetween(startYear, endYear)
          .findAll();
    }
    // 如果指定了月份范围
    else if (startMonth != null && endMonth != null) {
      // 由于 Isar 的 monthBetween 可能无法正确处理跨年的月份查询
      // 我们获取所有数据然后在内存中过滤
      final allSalaryLists = await isar.salaryLists.where().findAll();

      for (var salaryList in allSalaryLists) {
        if (salaryList.month >= startMonth && salaryList.month <= endMonth) {
          salaryLists.add(salaryList);
        }
      }
    }
    // 如果没有指定时间范围，获取所有数据
    else {
      salaryLists = await isar.salaryLists.where().findAll();
    }

    // 按岗位聚合数据
    final positionMap = <String, List<SalaryListRecord>>{};

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        // 过滤条件
        if (position != null && record.position != position) continue;
        if (name != null && record.name != name) continue;
        if (record.position == null || record.netSalary == null) continue;

        final pos = record.position!;
        if (!positionMap.containsKey(pos)) {
          positionMap[pos] = [];
        }
        positionMap[pos]!.add(record);
      }
    }

    // 计算统计数据
    final stats = <PositionSalaryStats>[];
    positionMap.forEach((pos, records) {
      double totalSalary = 0;
      int validRecordCount = 0;
      double maxSalary = 0; // 添加最高工资变量
      double minSalary = double.infinity; // 添加最低工资变量

      for (var record in records) {
        if (record.netSalary != null) {
          // 尝试解析实发工资字符串
          final salaryStr = record.netSalary!.replaceAll(
            RegExp(r'[^\d.-]'),
            '',
          );
          if (double.tryParse(salaryStr) != null) {
            final salary = double.parse(salaryStr);
            totalSalary += salary;
            validRecordCount++;

            // 更新最高和最低工资
            if (salary > maxSalary) {
              maxSalary = salary;
            }
            if (salary < minSalary) {
              minSalary = salary;
            }
          }
        }
      }

      // 如果没有有效记录，将minSalary设为0
      if (minSalary == double.infinity) {
        minSalary = 0;
      }

      if (validRecordCount > 0) {
        // 确定年份和月份信息
        int statYear = 0;
        int statMonth = 0;

        // 如果是单月查询，使用查询参数
        if (year != null && month != null) {
          statYear = year;
          statMonth = month;
        }
        // 如果是多月查询，从第一条记录中获取年月信息
        else if (salaryLists.isNotEmpty) {
          statYear = salaryLists[0].year;
          statMonth = salaryLists[0].month;
        }

        stats.add(
          PositionSalaryStats(
            position: pos,
            totalNetSalary: totalSalary,
            averageNetSalary: totalSalary / validRecordCount,
            employeeCount: validRecordCount,
            year: statYear,
            month: statMonth,
            maxSalary: maxSalary, // 添加最高工资
            minSalary: minSalary, // 添加最低工资
          ),
        );
      }
    });

    // 如果是多月查询，需要为每个月份分别计算统计数据
    if (startYear != null &&
        endYear != null &&
        startMonth != null &&
        endMonth != null) {
      // 清空之前的统计数据
      stats.clear();

      // 按月份分组计算
      final monthlyData = <String, List<SalaryListRecord>>{};

      for (var salaryList in salaryLists) {
        final monthKey = '${salaryList.year}-${salaryList.month}';
        if (!monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = [];
        }

        for (var record in salaryList.records) {
          // 过滤条件
          if (position != null && record.position != position) continue;
          if (name != null && record.name != name) continue;
          if (record.position == null || record.netSalary == null) continue;

          monthlyData[monthKey]!.add(record);
        }
      }

      // 为每个月份计算岗位统计数据
      monthlyData.forEach((monthKey, records) {
        // 按岗位分组
        final posMap = <String, List<SalaryListRecord>>{};
        for (var record in records) {
          final pos = record.position!;
          if (!posMap.containsKey(pos)) {
            posMap[pos] = [];
          }
          posMap[pos]!.add(record);
        }

        // 计算每个岗位的统计数据
        posMap.forEach((pos, posRecords) {
          double totalSalary = 0;
          int validRecordCount = 0;
          double maxSalary = 0; // 添加最高工资变量
          double minSalary = double.infinity; // 添加最低工资变量

          for (var record in posRecords) {
            if (record.netSalary != null) {
              // 尝试解析实发工资字符串
              final salaryStr = record.netSalary!.replaceAll(
                RegExp(r'[^\d.-]'),
                '',
              );
              if (double.tryParse(salaryStr) != null) {
                final salary = double.parse(salaryStr);
                totalSalary += salary;
                validRecordCount++;

                // 更新最高和最低工资
                if (salary > maxSalary) {
                  maxSalary = salary;
                }
                if (salary < minSalary) {
                  minSalary = salary;
                }
              }
            }
          }

          // 如果没有有效记录，将minSalary设为0
          if (minSalary == double.infinity) {
            minSalary = 0;
          }

          if (validRecordCount > 0) {
            // 解析月份键
            final parts = monthKey.split('-');
            final statYear = int.parse(parts[0]);
            final statMonth = int.parse(parts[1]);

            stats.add(
              PositionSalaryStats(
                position: pos,
                totalNetSalary: totalSalary,
                averageNetSalary: totalSalary / validRecordCount,
                employeeCount: validRecordCount,
                year: statYear,
                month: statMonth,
                maxSalary: maxSalary, // 添加最高工资
                minSalary: minSalary, // 添加最低工资
              ),
            );
          }
        });
      });
    }

    return stats;
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
  @Deprecated("工资排名会有攀比心理，而且泄露出去不好")
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
  @Deprecated("工资排名会有攀比心理，而且泄露出去不好")
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

  /// 获取部门环比变化数据
  Future<Map<String, dynamic>> getDepartmentMonthOverMonthChange({
    required int year,
    required int month,
    required String department,
  }) async {
    // 获取当前月数据
    final currentStatsList = await getDepartmentSalaryStats(
      year: year,
      month: month,
      department: department,
    );

    if (currentStatsList.isEmpty) {
      return {};
    }

    final currentStats = currentStatsList.first;

    // 计算上月的年份和月份
    int lastYear = year;
    int lastMonth = month - 1;

    if (lastMonth == 0) {
      // 如果是1月，上月就是去年的12月
      lastYear = year - 1;
      lastMonth = 12;
    }

    // 获取上月数据
    final lastStatsList = await getDepartmentSalaryStats(
      year: lastYear,
      month: lastMonth,
      department: department,
    );

    if (lastStatsList.isEmpty) {
      return {
        'current': currentStats,
        'previous': null,
        'month_over_month_change': null,
      };
    }

    final lastStats = lastStatsList.first;

    // 计算环比变化
    final employeeCountChange =
        currentStats.employeeCount - lastStats.employeeCount;
    final totalSalaryChange =
        currentStats.totalNetSalary - lastStats.totalNetSalary;
    final averageSalaryChange =
        currentStats.averageNetSalary - lastStats.averageNetSalary;

    final employeeCountChangePercent = lastStats.employeeCount > 0
        ? (employeeCountChange / lastStats.employeeCount) * 100
        : 0.0;
    final totalSalaryChangePercent = lastStats.totalNetSalary > 0
        ? (totalSalaryChange / lastStats.totalNetSalary) * 100
        : 0.0;
    final averageSalaryChangePercent = lastStats.averageNetSalary > 0
        ? (averageSalaryChange / lastStats.averageNetSalary) * 100
        : 0.0;

    return {
      'current': currentStats,
      'previous': lastStats,
      'month_over_month_change': {
        'employee_count_change': employeeCountChange,
        'employee_count_change_percent': employeeCountChangePercent,
        'total_salary_change': totalSalaryChange,
        'total_salary_change_percent': totalSalaryChangePercent,
        'average_salary_change': averageSalaryChange,
        'average_salary_change_percent': averageSalaryChangePercent,
      },
    };
  }

  /// 获取部门同比变化数据（与去年同期对比）
  Future<Map<String, dynamic>> getDepartmentYearOverYearChange({
    required int year,
    required int month,
    required String department,
  }) async {
    // 获取当前月数据
    final currentStatsList = await getDepartmentSalaryStats(
      year: year,
      month: month,
      department: department,
    );

    if (currentStatsList.isEmpty) {
      return {};
    }

    final currentStats = currentStatsList.first;

    // 获取去年同期数据
    final lastYearStatsList = await getDepartmentSalaryStats(
      year: year - 1,
      month: month,
      department: department,
    );

    if (lastYearStatsList.isEmpty) {
      return {
        'current': currentStats,
        'previous': null,
        'year_over_year_change': null,
      };
    }

    final lastYearStats = lastYearStatsList.first;

    // 计算同比变化
    final employeeCountChange =
        currentStats.employeeCount - lastYearStats.employeeCount;
    final totalSalaryChange =
        currentStats.totalNetSalary - lastYearStats.totalNetSalary;
    final averageSalaryChange =
        currentStats.averageNetSalary - lastYearStats.averageNetSalary;

    final employeeCountChangePercent = lastYearStats.employeeCount > 0
        ? (employeeCountChange / lastYearStats.employeeCount) * 100
        : 0.0;
    final totalSalaryChangePercent = lastYearStats.totalNetSalary > 0
        ? (totalSalaryChange / lastYearStats.totalNetSalary) * 100
        : 0.0;
    final averageSalaryChangePercent = lastYearStats.averageNetSalary > 0
        ? (averageSalaryChange / lastYearStats.averageNetSalary) * 100
        : 0.0;

    return {
      'current': currentStats,
      'previous': lastYearStats,
      'year_over_year_change': {
        'employee_count_change': employeeCountChange,
        'employee_count_change_percent': employeeCountChangePercent,
        'total_salary_change': totalSalaryChange,
        'total_salary_change_percent': totalSalaryChangePercent,
        'average_salary_change': averageSalaryChange,
        'average_salary_change_percent': averageSalaryChangePercent,
      },
    };
  }

  /// 获取岗位环比变化数据
  Future<Map<String, dynamic>> getPositionMonthOverMonthChange({
    required int year,
    required int month,
    required String position,
  }) async {
    // 获取当前月数据
    final currentStatsList = await getPositionSalaryStats(
      year: year,
      month: month,
      position: position,
    );

    if (currentStatsList.isEmpty) {
      return {};
    }

    final currentStats = currentStatsList.first;

    // 计算上月的年份和月份
    int lastYear = year;
    int lastMonth = month - 1;

    if (lastMonth == 0) {
      // 如果是1月，上月就是去年的12月
      lastYear = year - 1;
      lastMonth = 12;
    }

    // 获取上月数据
    final lastStatsList = await getPositionSalaryStats(
      year: lastYear,
      month: lastMonth,
      position: position,
    );

    if (lastStatsList.isEmpty) {
      return {
        'current': currentStats,
        'previous': null,
        'month_over_month_change': null,
      };
    }

    final lastStats = lastStatsList.first;

    // 计算环比变化
    final employeeCountChange =
        currentStats.employeeCount - lastStats.employeeCount;
    final totalSalaryChange =
        currentStats.totalNetSalary - lastStats.totalNetSalary;
    final averageSalaryChange =
        currentStats.averageNetSalary - lastStats.averageNetSalary;

    final employeeCountChangePercent = lastStats.employeeCount > 0
        ? (employeeCountChange / lastStats.employeeCount) * 100
        : 0.0;
    final totalSalaryChangePercent = lastStats.totalNetSalary > 0
        ? (totalSalaryChange / lastStats.totalNetSalary) * 100
        : 0.0;
    final averageSalaryChangePercent = lastStats.averageNetSalary > 0
        ? (averageSalaryChange / lastStats.averageNetSalary) * 100
        : 0.0;

    return {
      'current': currentStats,
      'previous': lastStats,
      'month_over_month_change': {
        'employee_count_change': employeeCountChange,
        'employee_count_change_percent': employeeCountChangePercent,
        'total_salary_change': totalSalaryChange,
        'total_salary_change_percent': totalSalaryChangePercent,
        'average_salary_change': averageSalaryChange,
        'average_salary_change_percent': averageSalaryChangePercent,
      },
    };
  }

  /// 获取岗位同比变化数据（与去年同期对比）
  Future<Map<String, dynamic>> getPositionYearOverYearChange({
    required int year,
    required int month,
    required String position,
  }) async {
    // 获取当前月数据
    final currentStatsList = await getPositionSalaryStats(
      year: year,
      month: month,
      position: position,
    );

    if (currentStatsList.isEmpty) {
      return {};
    }

    final currentStats = currentStatsList.first;

    // 获取去年同期数据
    final lastYearStatsList = await getPositionSalaryStats(
      year: year - 1,
      month: month,
      position: position,
    );

    if (lastYearStatsList.isEmpty) {
      return {
        'current': currentStats,
        'previous': null,
        'year_over_year_change': null,
      };
    }

    final lastYearStats = lastYearStatsList.first;

    // 计算同比变化
    final employeeCountChange =
        currentStats.employeeCount - lastYearStats.employeeCount;
    final totalSalaryChange =
        currentStats.totalNetSalary - lastYearStats.totalNetSalary;
    final averageSalaryChange =
        currentStats.averageNetSalary - lastYearStats.averageNetSalary;

    final employeeCountChangePercent = lastYearStats.employeeCount > 0
        ? (employeeCountChange / lastYearStats.employeeCount) * 100
        : 0.0;
    final totalSalaryChangePercent = lastYearStats.totalNetSalary > 0
        ? (totalSalaryChange / lastYearStats.totalNetSalary) * 100
        : 0.0;
    final averageSalaryChangePercent = lastYearStats.averageNetSalary > 0
        ? (averageSalaryChange / lastYearStats.averageNetSalary) * 100
        : 0.0;

    return {
      'current': currentStats,
      'previous': lastYearStats,
      'year_over_year_change': {
        'employee_count_change': employeeCountChange,
        'employee_count_change_percent': employeeCountChangePercent,
        'total_salary_change': totalSalaryChange,
        'total_salary_change_percent': totalSalaryChangePercent,
        'average_salary_change': averageSalaryChange,
        'average_salary_change_percent': averageSalaryChangePercent,
      },
    };
  }
}
