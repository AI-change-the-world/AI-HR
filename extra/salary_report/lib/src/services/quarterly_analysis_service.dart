import 'package:isar_community/isar.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/isar/salary_list.dart';
import 'package:salary_report/src/services/monthly_analysis_service.dart';

class QuarterlyAnalysisService {
  final IsarDatabase _database;
  final MonthlyAnalysisService _monthlyService;

  QuarterlyAnalysisService(this._database)
    : _monthlyService = MonthlyAnalysisService(_database);

  /// 多季度数据对比功能
  Future<MultiMonthComparisonData?> getMultiQuarterComparisonData(
    int startYear,
    int startQuarter,
    int endYear,
    int endQuarter,
  ) async {
    try {
      // 验证日期范围
      // 将季度转换为月份进行比较
      final startMonth = (startQuarter - 1) * 3 + 1;
      final endMonth = (endQuarter - 1) * 3 + 3;

      final startDateTime = DateTime(startYear, startMonth);
      final endDateTime = DateTime(endYear, endMonth);

      if (startDateTime.isAfter(endDateTime)) {
        logger.warning('Start date is after end date');
        return null;
      }

      // 生成需要查询的季度列表
      final quarterList = _generateQuarterList(
        startYear,
        startQuarter,
        endYear,
        endQuarter,
      );

      logger.info('Generated quarter list: $quarterList');
      final monthlyComparisons = <MonthlyComparisonData>[];

      // 遍历季度列表获取数据
      for (var quarterInfo in quarterList) {
        final year = quarterInfo['year']!;
        final quarter = quarterInfo['quarter']!;

        // 计算季度的月份范围
        final quarterStartMonth = (quarter - 1) * 3 + 1;
        final quarterEndMonth = quarter * 3;

        // 获取季度内每个月份的数据
        for (int month = quarterStartMonth; month <= quarterEndMonth; month++) {
          final monthlyData = await _monthlyService.getMultiMonthComparisonData(
            year,
            month,
            year,
            month,
          );

          if (monthlyData != null &&
              monthlyData.monthlyComparisons.isNotEmpty) {
            monthlyComparisons.addAll(monthlyData.monthlyComparisons);
          }
        }
      }

      logger.info(
        'Returning quarterly comparison data as MultiMonthComparisonData',
      );

      return MultiMonthComparisonData(
        monthlyComparisons: monthlyComparisons,
        startDate: startDateTime,
        endDate: endDateTime,
      );
    } catch (e) {
      logger.severe('Error getting multi-quarter comparison data: $e');
      rethrow; // 重新抛出异常而不是返回null
    }
  }

  // 生成季度列表的辅助函数
  List<Map<String, int>> _generateQuarterList(
    int startYear,
    int startQuarter,
    int endYear,
    int endQuarter,
  ) {
    final quarterList = <Map<String, int>>[];

    int currentYear = startYear;
    int currentQuarter = startQuarter;

    while (currentYear < endYear ||
        (currentYear == endYear && currentQuarter <= endQuarter)) {
      quarterList.add({'year': currentYear, 'quarter': currentQuarter});

      // 移动到下一个季度
      if (currentQuarter == 4) {
        currentYear++;
        currentQuarter = 1;
      } else {
        currentQuarter++;
      }
    }

    return quarterList;
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
    final monthlyService = MonthlyAnalysisService(_database);

    // 计算季度的月份范围
    int? startMonth, endMonth;
    if (quarter != null) {
      startMonth = (quarter - 1) * 3 + 1;
      endMonth = quarter * 3;
    }

    // 获取符合时间范围的数据
    List<SalaryList> salaryLists = [];

    // 如果指定了具体的年份和季度，直接查询
    if (year != null && quarter != null) {
      // 生成需要查询的月份列表
      final monthList = monthlyService.generateMonthList(
        year,
        startMonth!,
        year,
        endMonth!,
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
    // 如果指定了年份范围
    else if (startYear != null && endYear != null && quarter != null) {
      // 生成需要查询的月份列表
      final monthList = <Map<String, int>>[];

      // 为每年生成该季度的月份
      for (int y = startYear; y <= endYear; y++) {
        final quarterMonths = monthlyService.generateMonthList(
          y,
          startMonth!,
          y,
          endMonth!,
        );
        monthList.addAll(quarterMonths);
      }

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
    // 如果指定了年份范围
    else if (startYear != null && endYear != null) {
      salaryLists = await isar.salaryLists
          .filter()
          .yearBetween(startYear, endYear)
          .findAll();
    }
    // 如果指定了季度但没有指定年份
    else if (quarter != null) {
      // 获取所有数据然后在内存中过滤
      final allSalaryLists = await isar.salaryLists.where().findAll();

      for (var salaryList in allSalaryLists) {
        if (salaryList.month >= startMonth! && salaryList.month <= endMonth!) {
          salaryLists.add(salaryList);
        }
      }
    }
    // 如果没有指定时间范围，获取所有数据
    else {
      salaryLists = await isar.salaryLists.where().findAll();
    }

    // 按部门聚合数据
    final departmentMap = <String, List<SalaryListRecord>>{};

    for (var salaryList in salaryLists) {
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

        // 如果是单年查询，使用查询参数
        if (year != null) {
          statYear = year;
        }
        // 如果有具体的月份范围，从第一条记录中获取月份信息
        if (salaryLists.isNotEmpty) {
          statMonth = salaryLists[0].month;
        }
        // 如果是多月查询，从第一条记录中获取年月信息
        else if (salaryLists.isNotEmpty) {
          statYear = salaryLists[0].year;
          statMonth = salaryLists[0].month;
        }

        stats.add(
          DepartmentSalaryStats(
            department: dept,
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

    return stats;
  }
}
