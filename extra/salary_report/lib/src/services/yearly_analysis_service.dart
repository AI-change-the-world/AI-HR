import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/monthly_analysis_service.dart';

class YearlyAnalysisService {
  final IsarDatabase _database;
  final MonthlyAnalysisService _monthlyService;

  YearlyAnalysisService(this._database)
    : _monthlyService = MonthlyAnalysisService(_database);

  /// 多年数据对比功能
  Future<MultiYearComparisonData?> getMultiYearComparisonData(
    int startYear,
    int endYear,
  ) async {
    try {
      // 验证日期范围
      if (startYear > endYear) {
        logger.warning('Start year is after end year');
        return null;
      }

      final yearlyComparisons = <YearlyComparisonData>[];

      // 遍历年份列表获取数据
      for (int year = startYear; year <= endYear; year++) {
        // 获取该年所有月份的部门统计数据
        final departmentStatsList = await _monthlyService
            .getDepartmentSalaryStats(startYear: year, endYear: year);

        // 合并年内的部门统计数据
        final departmentStatsMap = <String, DepartmentSalaryStats>{};
        final departmentMonthlyData = <String, List<DepartmentSalaryStats>>{};

        // 按部门分组月度数据
        for (var stat in departmentStatsList) {
          if (!departmentMonthlyData.containsKey(stat.department)) {
            departmentMonthlyData[stat.department] = [];
          }
          departmentMonthlyData[stat.department]!.add(stat);
        }

        // 计算每个部门的年统计数据
        departmentMonthlyData.forEach((deptName, monthlyStats) {
          int totalEmployeeCount = 0;
          double totalNetSalary = 0.0;

          for (var stat in monthlyStats) {
            totalEmployeeCount += stat.employeeCount;
            totalNetSalary += stat.totalNetSalary;
          }

          final averageNetSalary = monthlyStats.isNotEmpty
              ? totalNetSalary / totalEmployeeCount
              : 0.0;

          departmentStatsMap[deptName] = DepartmentSalaryStats(
            department: deptName,
            totalNetSalary: totalNetSalary,
            averageNetSalary: averageNetSalary,
            employeeCount: totalEmployeeCount,
            year: year,
            month: 1, // 使用年份的1月作为代表
          );
        });

        // 获取薪资范围统计数据（使用年中月份）
        final middleMonth = 6;
        final salaryRangeStatsList = await _monthlyService
            .getSalaryRangeAggregation(year, middleMonth);
        final salaryRangeStatsMap = <String, SalaryRangeStats>{};
        for (var stat in salaryRangeStatsList) {
          salaryRangeStatsMap[stat.range] = stat;
        }

        // 收集每个月的员工姓名用于去重统计
        final uniqueEmployees = <String, List<String>>{};
        int totalEmployeeCount = 0;

        // 获取该年所有月份的数据
        for (int month = 1; month <= 12; month++) {
          final monthlyData = await _monthlyService.getMonthlySalaryData(
            year,
            month,
          );
          if (monthlyData != null) {
            final employeeNames = <String>[];
            for (var record in monthlyData.records) {
              if (record.name != null) {
                employeeNames.add(record.name!);
              }
            }
            uniqueEmployees['$month月'] = employeeNames;
          }
        }

        // 计算全年去重员工数
        final allEmployeeNames = <String>{};
        for (var names in uniqueEmployees.values) {
          allEmployeeNames.addAll(names);
        }
        totalEmployeeCount = allEmployeeNames.length;

        // 计算总体统计数据
        int employeeCount = 0;
        double totalSalary = 0.0;
        double averageSalary = 0.0;
        double highestSalary = 0.0; // 初始化最高工资
        double lowestSalary = double.infinity; // 初始化最低工资

        for (var stat in departmentStatsMap.values) {
          employeeCount += stat.employeeCount;
          totalSalary += stat.totalNetSalary;

          // 更新最高和最低工资
          if (stat.averageNetSalary > highestSalary) {
            highestSalary = stat.averageNetSalary;
          }

          if (stat.averageNetSalary < lowestSalary) {
            lowestSalary = stat.averageNetSalary;
          }
        }

        if (employeeCount > 0) {
          averageSalary = totalSalary / employeeCount;
        }

        // 确保最低工资有合理的默认值
        if (lowestSalary == double.infinity) {
          lowestSalary = 0.0;
        }

        yearlyComparisons.add(
          YearlyComparisonData(
            year: year,
            employeeCount: employeeCount,
            totalSalary: totalSalary,
            averageSalary: averageSalary,
            highestSalary: highestSalary,
            lowestSalary: lowestSalary,
            departmentStats: departmentStatsMap,
            salaryRangeStats: salaryRangeStatsMap,
            uniqueEmployees: uniqueEmployees,
            totalEmployeeCount: totalEmployeeCount,
          ),
        );
      }

      return MultiYearComparisonData(
        yearlyComparisons: yearlyComparisons,
        startDate: DateTime(startYear),
        endDate: DateTime(endYear),
      );
    } catch (e) {
      logger.severe('Error getting multi-year comparison data: $e');
      rethrow;
    }
  }
}
