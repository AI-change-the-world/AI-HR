import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/isar/salary_list.dart';

class MonthlyAnalysisService {
  final IsarDatabase _database;

  MonthlyAnalysisService(this._database);

  /// 基础的按月查询功能
  Future<MonthlySalaryData?> getMonthlySalaryData(int year, int month) async {
    try {
      final isar = _database.isar!;

      // 直接查询指定年月的工资数据
      final salaryList = await isar.salaryLists
          .filter()
          .yearEqualTo(year)
          .monthEqualTo(month)
          .findFirst();

      if (salaryList != null) {
        // 解析汇总数据
        Map<String, dynamic> summaryData = {};
        if (salaryList.extraInfo.isNotEmpty) {
          try {
            summaryData =
                jsonDecode(salaryList.extraInfo) as Map<String, dynamic>;
          } catch (e) {
            logger.warning('Failed to parse summary data for $year-$month: $e');
          }
        }

        return MonthlySalaryData(
          year: salaryList.year,
          month: salaryList.month,
          records: salaryList.records,
          summaryData: summaryData,
        );
      }

      return null;
    } catch (e) {
      logger.severe('Error getting monthly salary data for $year-$month: $e');
      return null;
    }
  }

  /// 生成月份列表
  List<Map<String, int>> generateMonthList(
    int startYear,
    int startMonth,
    int endYear,
    int endMonth,
  ) {
    final monthList = <Map<String, int>>[];

    int currentYear = startYear;
    int currentMonth = startMonth;

    while (currentYear < endYear ||
        (currentYear == endYear && currentMonth <= endMonth)) {
      monthList.add({'year': currentYear, 'month': currentMonth});

      // 移动到下一个月
      if (currentMonth == 12) {
        currentYear++;
        currentMonth = 1;
      } else {
        currentMonth++;
      }
    }

    return monthList;
  }

  /// 多月数据查询功能
  Future<MultiMonthSalaryData?> getMultiMonthSalaryData(
    int startYear,
    int startMonth,
    int endYear,
    int endMonth,
  ) async {
    try {
      // 验证日期范围
      if (startYear > endYear ||
          (startYear == endYear && startMonth > endMonth)) {
        logger.warning('Start date is after end date');
        return null;
      }

      // 生成需要查询的月份列表
      final monthList = generateMonthList(
        startYear,
        startMonth,
        endYear,
        endMonth,
      );
      final monthlyData = <MonthlySalaryData>[];

      // 遍历月份列表获取数据
      for (var monthInfo in monthList) {
        final monthlySalaryData = await getMonthlySalaryData(
          monthInfo['year']!,
          monthInfo['month']!,
        );
        if (monthlySalaryData != null) {
          monthlyData.add(monthlySalaryData);
        }
      }

      return MultiMonthSalaryData(
        monthlyData: monthlyData,
        startDate: DateTime(startYear, startMonth),
        endDate: DateTime(endYear, endMonth),
      );
    } catch (e) {
      logger.severe('Error getting multi-month salary data: $e');
      return null;
    }
  }

  /// 按部门聚合功能
  Future<List<DepartmentSalaryStats>> getDepartmentAggregation(
    int year,
    int month, {
    String? department,
    String? name,
  }) async {
    try {
      return await getDepartmentSalaryStats(
        year: year,
        month: month,
        department: department,
        name: name,
      );
    } catch (e) {
      logger.severe(
        'Error getting department aggregation for $year-$month: $e',
      );
      return [];
    }
  }

  /// 按薪资范围聚合功能
  Future<List<SalaryRangeStats>> getSalaryRangeAggregation(
    int year,
    int month,
  ) async {
    try {
      // 首先获取月度数据
      final monthlyData = await getMonthlySalaryData(year, month);
      if (monthlyData == null) {
        return [];
      }

      // 定义薪资范围
      final salaryRanges = [
        {'min': 0.0, 'max': 3000.0, 'label': '< 3000'},
        {'min': 3000.0, 'max': 4000.0, 'label': '3000-4000'},
        {'min': 4000.0, 'max': 5000.0, 'label': '4000-5000'},
        {'min': 5000.0, 'max': 6000.0, 'label': '5000-6000'},
        {'min': 6000.0, 'max': 7000.0, 'label': '6000-7000'},
        {'min': 7000.0, 'max': 8000.0, 'label': '7000-8000'},
        {'min': 8000.0, 'max': 9000.0, 'label': '8000-9000'},
        {'min': 9000.0, 'max': 10000.0, 'label': '9000-10000'},
        {'min': 10000.0, 'max': double.infinity, 'label': '10000以上'},
      ];

      final rangeStats = <SalaryRangeStats>[];

      // 为每个薪资范围计算统计数据
      for (var range in salaryRanges) {
        int employeeCount = 0;
        double totalSalary = 0.0;

        for (var record in monthlyData.records) {
          if (record.netSalary != null) {
            // 解析薪资字符串
            final salaryStr = record.netSalary!.replaceAll(
              RegExp(r'[^\d.-]'),
              '',
            );
            final salary = double.tryParse(salaryStr);

            final min = range['min']! as double;
            final max = range['max']! as double;
            if (salary != null && salary >= min && salary < max) {
              employeeCount++;
              totalSalary += salary;
            }
          }
        }

        if (employeeCount > 0) {
          rangeStats.add(
            SalaryRangeStats(
              range: range['label'] as String,
              employeeCount: employeeCount,
              totalSalary: totalSalary,
              averageSalary: totalSalary / employeeCount,
              year: year,
              month: month,
            ),
          );
        }
      }

      return rangeStats;
    } catch (e) {
      logger.severe(
        'Error getting salary range aggregation for $year-$month: $e',
      );
      return [];
    }
  }

  /// 部门和薪资范围联合聚合功能
  Future<List<DepartmentSalaryRangeStats>> getDepartmentSalaryRangeAggregation(
    int year,
    int month,
  ) async {
    try {
      // 首先获取月度数据
      final monthlyData = await getMonthlySalaryData(year, month);
      if (monthlyData == null) {
        return [];
      }

      // 定义薪资范围
      final salaryRanges = [
        {'min': 0.0, 'max': 3000.0, 'label': '< 3000'},
        {'min': 3000.0, 'max': 4000.0, 'label': '3000-4000'},
        {'min': 4000.0, 'max': 5000.0, 'label': '4000-5000'},
        {'min': 5000.0, 'max': 6000.0, 'label': '5000-6000'},
        {'min': 6000.0, 'max': 7000.0, 'label': '6000-7000'},
        {'min': 7000.0, 'max': 8000.0, 'label': '7000-8000'},
        {'min': 8000.0, 'max': 9000.0, 'label': '8000-9000'},
        {'min': 9000.0, 'max': 10000.0, 'label': '9000-10000'},
        {'min': 10000.0, 'max': double.infinity, 'label': '10000以上'},
      ];

      final deptRangeStats = <DepartmentSalaryRangeStats>[];

      // 按部门分组记录
      final departmentRecords = <String, List<SalaryListRecord>>{};
      for (var record in monthlyData.records) {
        if (record.department != null && record.netSalary != null) {
          final dept = record.department!;
          if (!departmentRecords.containsKey(dept)) {
            departmentRecords[dept] = [];
          }
          departmentRecords[dept]!.add(record);
        }
      }

      // 为每个部门和薪资范围计算统计数据
      departmentRecords.forEach((dept, records) {
        for (var range in salaryRanges) {
          int employeeCount = 0;
          double totalSalary = 0.0;

          for (var record in records) {
            if (record.netSalary != null) {
              // 解析薪资字符串
              final salaryStr = record.netSalary!.replaceAll(
                RegExp(r'[^\d.-]'),
                '',
              );
              final salary = double.tryParse(salaryStr);

              final min = range['min']! as double;
              final max = range['max']! as double;
              if (salary != null && salary >= min && salary < max) {
                employeeCount++;
                totalSalary += salary;
              }
            }
          }

          if (employeeCount > 0) {
            deptRangeStats.add(
              DepartmentSalaryRangeStats(
                department: dept,
                salaryRange: range['label'] as String,
                employeeCount: employeeCount,
                totalSalary: totalSalary,
                averageSalary: totalSalary / employeeCount,
                year: year,
                month: month,
              ),
            );
          }
        }
      });

      return deptRangeStats;
    } catch (e) {
      logger.severe(
        'Error getting department-salary range aggregation for $year-$month: $e',
      );
      return [];
    }
  }

  Future<List<MonthlyComparisonData>> getMonthlyComparisonDataList(
    int startYear,
    int startMonth,
    int endYear,
    int endMonth,
  ) async {
    final monthList = generateMonthList(
      startYear,
      startMonth,
      endYear,
      endMonth,
    );

    final monthlyComparisonDataList = <MonthlyComparisonData>[];

    // 遍历月份列表获取数据
    for (var monthInfo in monthList) {
      final year = monthInfo['year']!;
      final month = monthInfo['month']!;

      // 获取月度工资数据用于员工信息收集
      final monthlySalaryData = await getMonthlySalaryData(year, month);

      // 收集员工信息
      final workers = <MinimalEmployeeInfo>[];
      if (monthlySalaryData != null) {
        for (var record in monthlySalaryData.records) {
          if (record.name != null && record.department != null) {
            workers.add(
              MinimalEmployeeInfo(
                name: record.name!,
                department: record.department!,
              ),
            );
          }
        }
      }

      // 获取部门统计数据
      final departmentStatsList = await getDepartmentAggregation(year, month);
      final departmentStatsMap = <String, DepartmentSalaryStats>{};
      for (var stat in departmentStatsList) {
        departmentStatsMap[stat.department] = stat;
      }

      // 获取薪资范围统计数据
      final salaryRangeStatsList = await getSalaryRangeAggregation(year, month);
      final salaryRangeStatsMap = <String, SalaryRangeStats>{};
      for (var stat in salaryRangeStatsList) {
        salaryRangeStatsMap[stat.range] = stat;
      }

      // 计算总体统计数据
      int totalEmployeeCount = 0;
      double totalSalary = 0.0;
      double averageSalary = 0.0;
      double highestSalary = 0.0; // 初始化最高工资
      double lowestSalary = double.infinity; // 初始化最低工资

      // 重新计算月度总工资和员工数（正确的方式）
      double monthlyTotalSalary = 0.0;
      int monthlyTotalEmployeeCount = 0;

      // 获取月度工资数据用于最高最低工资计算
      if (monthlySalaryData != null) {
        for (var record in monthlySalaryData.records) {
          if (record.netSalary != null) {
            final salaryStr = record.netSalary!.replaceAll(
              RegExp(r'[^\d.-]'),
              '',
            );
            final salary = double.tryParse(salaryStr) ?? 0;
            monthlyTotalSalary += salary;
            monthlyTotalEmployeeCount++;

            // 更新最高和最低工资
            if (salary > highestSalary) {
              highestSalary = salary;
            }
            if (salary < lowestSalary && salary > 0) {
              // 忽略0工资
              lowestSalary = salary;
            }
          }
        }
      }

      // 使用正确的月度统计数据
      totalEmployeeCount = monthlyTotalEmployeeCount;
      totalSalary = monthlyTotalSalary;
      averageSalary = totalEmployeeCount > 0
          ? totalSalary / totalEmployeeCount
          : 0.0;

      // 确保最低工资有合理的默认值
      if (lowestSalary == double.infinity) {
        lowestSalary = 0.0;
      }

      monthlyComparisonDataList.add(
        MonthlyComparisonData(
          year: year,
          month: month,
          employeeCount: totalEmployeeCount,
          totalSalary: totalSalary,
          averageSalary: averageSalary,
          highestSalary: highestSalary,
          lowestSalary: lowestSalary,
          departmentStats: departmentStatsMap,
          salaryRangeStats: salaryRangeStatsMap,
          workers: workers, // 添加员工列表字段
        ),
      );
    }

    return monthlyComparisonDataList;
  }

  /// 多月数据对比功能
  Future<MultiMonthComparisonData?> getMultiMonthComparisonData(
    int startYear,
    int startMonth,
    int endYear,
    int endMonth,
  ) async {
    try {
      // 验证日期范围
      if (startYear > endYear ||
          (startYear == endYear && startMonth > endMonth)) {
        logger.warning('Start date is after end date');
        return null;
      }

      // 生成需要查询的月份列表
      final monthlyComparisonDataList = await getMonthlyComparisonDataList(
        startYear,
        startMonth,
        endYear,
        endMonth,
      );

      logger.info('Returning monthly comparison data');

      return MultiMonthComparisonData(
        monthlyComparisons: monthlyComparisonDataList,
        startDate: DateTime(startYear, startMonth),
        endDate: DateTime(endYear, endMonth),
      );
    } catch (e) {
      logger.severe('Error getting multi-month comparison data: $e');
      return null;
    }
  }

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

  /// 查询某年所有月份中某员工的工资记录
  Future<Map<int, SalaryListRecord>> getEmployeeSalaryByYear({
    required int year,
    required String employeeName,
  }) async {
    final isar = _database.isar!;

    final salaryLists = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .findAll();

    final results = <int, SalaryListRecord>{};

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          results[salaryList.month] = record;
        }
      }
    }

    return results;
  }

  /// 查询所有年份中某月份某员工的工资记录
  Future<Map<int, SalaryListRecord>> getEmployeeSalaryByMonth({
    required int month,
    required String employeeName,
  }) async {
    final isar = _database.isar!;

    final salaryLists = await isar.salaryLists
        .filter()
        .monthEqualTo(month)
        .findAll();

    final results = <int, SalaryListRecord>{};

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          results[salaryList.year] = record;
        }
      }
    }

    return results;
  }

  /// 查询所有记录中某员工的工资信息
  Future<List<Map<String, dynamic>>> getAllEmployeeSalary({
    required String employeeName,
  }) async {
    final isar = _database.isar!;

    // 获取所有包含该员工的工资列表，避免全表扫描
    // 使用 Isar 的查询功能来优化性能
    final salaryLists = await isar.salaryLists.where().findAll();

    final results = <Map<String, dynamic>>[];

    for (var salaryList in salaryLists) {
      bool hasEmployee = false;
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          hasEmployee = true;
          break;
        }
      }

      if (hasEmployee) {
        for (var record in salaryList.records) {
          if (record.name == employeeName) {
            results.add({
              'year': salaryList.year,
              'month': salaryList.month,
              'record': record,
            });
          }
        }
      }
    }

    return results;
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

  (int, int) getLastMonth(int year, int month) {
    if (month == 1) {
      return (year - 1, 12);
    } else {
      return (year, month - 1);
    }
  }

  Future<String> getMonthlyDepartmentEmployeeCountDescription({
    required int year,
    required int month,
  }) async {
    final isar = _database.isar!;
    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();
    if (salaryList == null) return '';

    final lastTime = getLastMonth(year, month);

    final lastSalaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(lastTime.$1)
        .monthEqualTo(lastTime.$2)
        .findFirst();

    final departmentDescription = StringBuffer();
    departmentDescription.write('其中，');

    Map<String, List<MinimalEmployeeInfo>> departmentEmployeeCounts = {};
    for (var r in salaryList.records) {
      final info = MinimalEmployeeInfo(
        name: r.name!,
        department: r.department ?? "",
      );
      if (departmentEmployeeCounts.containsKey(info.department)) {
        departmentEmployeeCounts[info.department]!.add(info);
      } else {
        departmentEmployeeCounts[info.department] = [info];
      }
    }

    for (var entry in departmentEmployeeCounts.entries) {
      departmentDescription.write('，${entry.key}部门有${entry.value.length}人');
    }
    departmentDescription.write('。');

    if (lastSalaryList != null) {
      departmentDescription.write('相比于上个月，');
      if (lastSalaryList.records.length == salaryList.records.length) {
        departmentDescription.write('部门人数没有变化。');
      } else if (lastSalaryList.records.length > salaryList.records.length) {
        departmentDescription.write(
          '部门人数减少${lastSalaryList.records.length - salaryList.records.length}人。',
        );
      } else {
        departmentDescription.write(
          '部门人数增加${salaryList.records.length - lastSalaryList.records.length}人。',
        );
      }

      String details = describeDepartmentChanges(
        lastSalaryList.records,
        salaryList.records,
      );
      if (details.isNotEmpty) {
        departmentDescription.write(details);
      }
    }
    return departmentDescription.toString();
  }

  String describeDepartmentChanges(
    List<SalaryListRecord> lastMonth,
    List<SalaryListRecord> thisMonth,
  ) {
    final buffer = StringBuffer();

    final lastMap = {for (var e in lastMonth) e.name!: e};
    final thisMap = {for (var e in thisMonth) e.name!: e};

    final joined = <SalaryListRecord>[];
    final left = <SalaryListRecord>[];
    final transferred = <Map<String, String>>[];

    // 遍历上月数据
    for (var entry in lastMonth) {
      final name = entry.name!;
      if (!thisMap.containsKey(name)) {
        left.add(entry);
      } else {
        final thisDept = thisMap[name]!.department;
        if (entry.department != thisDept) {
          transferred.add({
            "name": name,
            "from": entry.department ?? "",
            "to": thisDept ?? "",
          });
        }
      }
    }

    // 遍历本月数据
    for (var entry in thisMonth) {
      final name = entry.name!;
      if (!lastMap.containsKey(name)) {
        joined.add(entry);
      }
    }

    // 拼接自然语言描述
    if (joined.isNotEmpty) {
      buffer.write("本月新增 ${joined.length} 人：");
      buffer.write(joined.map((e) => "${e.name}(${e.department})").join("，"));
      buffer.write("。");
    }
    if (left.isNotEmpty) {
      buffer.write(" 离职 ${left.length} 人：");
      buffer.write(left.map((e) => "${e.name}(${e.department})").join("，"));
      buffer.write("。");
    }
    if (transferred.isNotEmpty) {
      buffer.write(" 转岗 ${transferred.length} 人：");
      buffer.write(
        transferred
            .map((e) => "${e['name']}：${e['from']} → ${e['to']}")
            .join("，"),
      );
      buffer.write("。");
    }

    if (buffer.isEmpty) {
      return "本月人员结构无明显变化。";
    }

    return buffer.toString().trim();
  }

  /// 计算基尼系数
  Future<(double, String)> caculateGiniCoefficient({
    required int year,
    required int month,
  }) async {
    final isar = _database.isar!;

    final salaryList = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();
    if (salaryList == null) return (0.0, '');

    final gini = calculateGiniCoefficient(salaryList.records);
    final giniLevel = describeGini(gini);

    return (gini, giniLevel);
  }

  double calculateGiniCoefficient(List<SalaryListRecord> records) {
    // 提取工资，转换为 double
    List<double> salaries = records
        .map((r) => double.tryParse(r.netSalary ?? '0') ?? 0.0)
        .where((s) => s > 0)
        .toList();

    if (salaries.isEmpty) return 0.0;

    // 按升序排序
    salaries.sort();

    int n = salaries.length;
    double cumulativeIncome = 0.0;
    double weightedSum = 0.0;

    for (int i = 0; i < n; i++) {
      cumulativeIncome += salaries[i];
      weightedSum += (i + 1) * salaries[i];
    }

    double meanIncome = cumulativeIncome / n;
    if (meanIncome == 0) return 0.0;

    // Gini 公式: G = (2 * Σ(i*xi)) / (n * Σxi) - (n+1)/n
    double gini = (2 * weightedSum) / (n * cumulativeIncome) - (n + 1) / n;

    return gini;
  }

  /// 给出自然语言描述
  String describeGini(double gini) {
    String level;
    if (gini < 0.2) {
      level = "收入分配非常平均，极为健康";
    } else if (gini < 0.3) {
      level = "收入分配较为均衡，比较健康";
    } else if (gini < 0.4) {
      level = "收入分配存在一定差距，整体尚可接受";
    } else if (gini < 0.5) {
      level = "收入分配差距较大，需要关注";
    } else {
      level = "收入差距过大，结构不健康";
    }

    return "当前的基尼系数为 ${gini.toStringAsFixed(3)}，$level。";
  }

  /// 查询某年某月工资最高的前N名员工
  @Deprecated("工资排名会有攀比心理，而且泄露出去不好")
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
  @Deprecated("工资排名会有攀比心理，而且泄露出去不好")
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
            'leave': record.personalLeave,
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
      final monthList = generateMonthList(
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
      // 修复：正确过滤年份范围
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
          if (department != null && record.department != department) continue;
          if (name != null && record.name != name) continue;
          if (record.department == null || record.netSalary == null) continue;

          monthlyData[monthKey]!.add(record);
        }
      }

      // 为每个月份计算部门统计数据
      monthlyData.forEach((monthKey, records) {
        // 按部门分组
        final deptMap = <String, List<SalaryListRecord>>{};
        for (var record in records) {
          final dept = record.department!;
          if (!deptMap.containsKey(dept)) {
            deptMap[dept] = [];
          }
          deptMap[dept]!.add(record);
        }

        // 计算每个部门的统计数据
        deptMap.forEach((dept, deptRecords) {
          double totalSalary = 0;
          int validRecordCount = 0;
          double maxSalary = 0; // 添加最高工资变量
          double minSalary = double.infinity; // 添加最低工资变量

          for (var record in deptRecords) {
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
      });
    }

    return stats;
  }

  /// 获取多月部门工资统计数据（按月份分组）
  Future<List<DepartmentSalaryStats>> getMonthlyDepartmentSalaryStats({
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
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
      yearMatch = salaryList.year >= startYear && salaryList.year <= endYear;

      // 月份过滤
      monthMatch =
          salaryList.month >= startMonth && salaryList.month <= endMonth;

      if (yearMatch && monthMatch) {
        filteredSalaryLists.add(salaryList);
      }
    }

    // 按月份分组计算
    final stats = <DepartmentSalaryStats>[];

    // 按月份分组计算
    final monthlyData = <String, List<SalaryListRecord>>{};

    for (var salaryList in filteredSalaryLists) {
      final monthKey = '${salaryList.year}-${salaryList.month}';
      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = [];
      }

      for (var record in salaryList.records) {
        // 过滤条件
        if (department != null && record.department != department) continue;
        if (name != null && record.name != name) continue;
        if (record.department == null || record.netSalary == null) continue;

        monthlyData[monthKey]!.add(record);
      }
    }

    // 为每个月份计算部门统计数据
    monthlyData.forEach((monthKey, records) {
      // 按部门分组
      final deptMap = <String, List<SalaryListRecord>>{};
      for (var record in records) {
        final dept = record.department!;
        if (!deptMap.containsKey(dept)) {
          deptMap[dept] = [];
        }
        deptMap[dept]!.add(record);
      }

      // 计算每个部门的统计数据
      deptMap.forEach((dept, deptRecords) {
        double totalSalary = 0;
        int validRecordCount = 0;

        for (var record in deptRecords) {
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
          // 解析月份键
          final parts = monthKey.split('-');
          final statYear = int.parse(parts[0]);
          final statMonth = int.parse(parts[1]);

          stats.add(
            DepartmentSalaryStats(
              department: dept,
              totalNetSalary: totalSalary,
              averageNetSalary: totalSalary / validRecordCount,
              employeeCount: validRecordCount,
              year: statYear,
              month: statMonth,
            ),
          );
        }
      });
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
      final monthList = generateMonthList(
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

    // 收集考勤数据
    final attendanceStats = <AttendanceStats>[];

    for (var salaryList in salaryLists) {
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

        if (record.personalLeave != null) {
          final leaveStr = record.personalLeave!.replaceAll(
            RegExp(r'[^\d.-]'),
            '',
          );
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
            year: salaryList.year, // 设置年份
            month: salaryList.month, // 设置月份
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
      final monthList = generateMonthList(
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

    // 统计病假和事假数据
    double totalSickLeave = 0;
    double totalLeave = 0;
    int employeeCount = 0;

    for (var salaryList in salaryLists) {
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

        if (record.personalLeave != null) {
          final leaveStr = record.personalLeave!.replaceAll(
            RegExp(r'[^\d.-]'),
            '',
          );
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

    // 确定年份和月份信息
    int? statYear;
    int? statMonth;

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

    return LeaveRatioStats(
      sickLeaveRatio: sickLeaveRatio,
      leaveRatio: leaveRatio,
      totalEmployees: employeeCount,
      year: statYear,
      month: statMonth,
    );
  }

  /// 获取多月病假和事假的比例统计
  Future<List<LeaveRatioStats>> getMonthlyLeaveRatioStats({
    int? startYear,
    int? endYear,
    int? startMonth,
    int? endMonth,
    String? department,
    String? name,
  }) async {
    final isar = _database.isar!;

    // 获取符合时间范围的数据
    List<SalaryList> salaryLists = [];

    // 如果指定了年份范围和月份范围
    if (startYear != null &&
        endYear != null &&
        startMonth != null &&
        endMonth != null) {
      // 生成需要查询的月份列表
      final monthList = generateMonthList(
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
    else if (startYear != null && endYear != null) {
      salaryLists = await isar.salaryLists
          .filter()
          .yearBetween(startYear, endYear)
          .findAll();
    }
    // 如果只指定了月份
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

    // 按月份分组计算
    final stats = <LeaveRatioStats>[];

    // 按月份分组计算
    final monthlyData = <String, List<SalaryListRecord>>{};

    for (var salaryList in salaryLists) {
      final monthKey = '${salaryList.year}-${salaryList.month}';
      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = [];
      }

      for (var record in salaryList.records) {
        // 过滤条件
        if (department != null && record.department != department) continue;
        if (name != null && record.name != name) continue;

        monthlyData[monthKey]!.add(record);
      }
    }

    // 为每个月份计算病假和事假比例
    monthlyData.forEach((monthKey, records) {
      double totalSickLeave = 0;
      double totalLeave = 0;
      int employeeCount = 0;

      for (var record in records) {
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

        if (record.personalLeave != null) {
          final leaveStr = record.personalLeave!.replaceAll(
            RegExp(r'[^\d.-]'),
            '',
          );
          totalLeave += double.tryParse(leaveStr) ?? 0;
        }
      }

      // 计算比例
      final totalLeaveDays = totalSickLeave + totalLeave;
      final sickLeaveRatio = employeeCount > 0
          ? totalSickLeave / employeeCount
          : 0.0;
      final leaveRatio = employeeCount > 0 ? totalLeave / employeeCount : 0.0;

      // 解析月份键
      final parts = monthKey.split('-');
      final statYear = int.parse(parts[0]);
      final statMonth = int.parse(parts[1]);

      stats.add(
        LeaveRatioStats(
          sickLeaveRatio: sickLeaveRatio,
          leaveRatio: leaveRatio,
          totalEmployees: employeeCount,
          year: statYear,
          month: statMonth,
        ),
      );
    });

    return stats;
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

    logger.info('Salary list info found: ${salaryList?.extraInfo}');

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
}
