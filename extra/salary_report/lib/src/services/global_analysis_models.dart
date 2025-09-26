// 考勤统计结果
import 'dart:typed_data';
import 'package:salary_report/src/isar/salary_list.dart';
import 'trend_analysis_chart_service.dart';

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

extension ALotOfUsefulExtension on List<MonthlyComparisonData> {
  // 获取周期内不重复的员工信息
  List<MinimalEmployeeInfo> findUniques() {
    final uniqueEmployees = <MinimalEmployeeInfo>{};
    for (final employee in this) {
      uniqueEmployees.addAll(employee.workers);
    }
    return uniqueEmployees.toList();
  }

  // 根据部门聚合员工，但是没有月份年份信息
  Map<String, List<MinimalEmployeeInfo>> getWorkersByDepartment() {
    final workersByDepartment = <String, List<MinimalEmployeeInfo>>{};
    for (final employee in this) {
      for (final worker in employee.workers) {
        workersByDepartment.putIfAbsent(worker.department, () => []);
        workersByDepartment[worker.department]!.add(worker);
      }
    }
    return workersByDepartment;
  }

  /// 获取月度薪资变化趋势
  List<MonthlySalaryChange> getMonthlySalaryChange() {
    if (isEmpty) return [];

    // 按年月排序
    final sortedData = [...this];
    sortedData.sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return aDate.compareTo(bDate);
    });

    List<MonthlySalaryChange> changes = [];

    for (int i = 0; i < sortedData.length; i++) {
      final current = sortedData[i];

      // 如果不是第一个月，计算与上月的变化
      if (i > 0) {
        final prev = sortedData[i - 1];

        // 计算变化值和百分比
        final totalSalaryChange = current.totalSalary - prev.totalSalary;
        final averageSalaryChange = current.averageSalary - prev.averageSalary;
        final employeeCountChange = current.employeeCount - prev.employeeCount;

        final totalSalaryChangePercent = prev.totalSalary != 0
            ? (totalSalaryChange / prev.totalSalary) * 100
            : 0.0;
        final averageSalaryChangePercent = prev.averageSalary != 0
            ? (averageSalaryChange / prev.averageSalary) * 100
            : 0.0;

        changes.add(
          MonthlySalaryChange(
            year: current.year,
            month: current.month,
            totalSalary: current.totalSalary,
            averageSalary: current.averageSalary,
            highestSalary: current.highestSalary,
            lowestSalary: current.lowestSalary,
            employeeCount: current.employeeCount,
            totalSalaryChange: totalSalaryChange,
            averageSalaryChange: averageSalaryChange,
            totalSalaryChangePercent: totalSalaryChangePercent,
            averageSalaryChangePercent: averageSalaryChangePercent,
            employeeCountChange: employeeCountChange,
          ),
        );
      } else {
        // 第一个月没有变化数据
        changes.add(
          MonthlySalaryChange(
            year: current.year,
            month: current.month,
            totalSalary: current.totalSalary,
            averageSalary: current.averageSalary,
            highestSalary: current.highestSalary,
            lowestSalary: current.lowestSalary,
            employeeCount: current.employeeCount,
          ),
        );
      }
    }

    return changes;
  }

  // 获取月度工资变化
  String getMonthlySalaryChangeText() {
    List<MonthlySalaryChange> changes = getMonthlySalaryChange();
    StringBuffer buffer = StringBuffer();
    
    if (changes.isEmpty) {
      return "暂无月度薪资变化数据。";
    }
    
    buffer.writeln("月度薪资变化分析报告\n");
    buffer.writeln("=" * 50);
    
    for (int i = 0; i < changes.length; i++) {
      final change = changes[i];
      buffer.writeln("\n${change.year}年${change.month}月薪资分析：");
      buffer.writeln("  总薪资：${change.totalSalary.toStringAsFixed(2)}元");
      buffer.writeln("  平均薪资：${change.averageSalary.toStringAsFixed(2)}元");
      buffer.writeln("  最高薪资：${change.highestSalary.toStringAsFixed(2)}元");
      buffer.writeln("  最低薪资：${change.lowestSalary.toStringAsFixed(2)}元");
      buffer.writeln("  员工人数：${change.employeeCount}人");
      
      // 如果有变化数据，显示与上月的对比
      if (change.totalSalaryChange != null) {
        final changeText = change.totalSalaryChange! >= 0 ? "增长" : "下降";
        buffer.writeln("  与上月相比总薪资$changeText${change.totalSalaryChange!.abs().toStringAsFixed(2)}元（${change.totalSalaryChangePercent!.toStringAsFixed(2)}%）");
        
        final avgChangeText = change.averageSalaryChange! >= 0 ? "增长" : "下降";
        buffer.writeln("  与上月相比平均薪资$avgChangeText${change.averageSalaryChange!.abs().toStringAsFixed(2)}元（${change.averageSalaryChangePercent!.toStringAsFixed(2)}%）");
        
        final empChangeText = change.employeeCountChange! >= 0 ? "增加" : "减少";
        buffer.writeln("  与上月相比员工人数$empChangeText${change.employeeCountChange!.abs()}人");
      }
      
      if (i < changes.length - 1) {
        buffer.writeln("\n${"-" * 30}");
      }
    }
    
    // 添加总体趋势分析
    if (changes.length > 1) {
      buffer.writeln("\n\n总体趋势分析：");
      buffer.writeln("=" * 30);
      
      final firstMonth = changes.first;
      final lastMonth = changes.last;
      
      final totalSalaryGrowth = lastMonth.totalSalary - firstMonth.totalSalary;
      final avgSalaryGrowth = lastMonth.averageSalary - firstMonth.averageSalary;
      final employeeGrowth = lastMonth.employeeCount - firstMonth.employeeCount;
      
      final totalGrowthPercent = firstMonth.totalSalary > 0 
          ? (totalSalaryGrowth / firstMonth.totalSalary) * 100 
          : 0.0;
      final avgGrowthPercent = firstMonth.averageSalary > 0 
          ? (avgSalaryGrowth / firstMonth.averageSalary) * 100 
          : 0.0;
      
      buffer.writeln("从${firstMonth.year}年${firstMonth.month}月到${lastMonth.year}年${lastMonth.month}月：");
      buffer.writeln("  总薪资变化：${totalSalaryGrowth >= 0 ? '+' : ''}${totalSalaryGrowth.toStringAsFixed(2)}元（${totalGrowthPercent >= 0 ? '+' : ''}${totalGrowthPercent.toStringAsFixed(2)}%）");
      buffer.writeln("  平均薪资变化：${avgSalaryGrowth >= 0 ? '+' : ''}${avgSalaryGrowth.toStringAsFixed(2)}元（${avgGrowthPercent >= 0 ? '+' : ''}${avgGrowthPercent.toStringAsFixed(2)}%）");
      buffer.writeln("  员工人数变化：${employeeGrowth >= 0 ? '+' : ''}$employeeGrowth人");
    }
    
    return buffer.toString();
  }

  /// 根据每月信息，获取部门/员工变化情况
  List<EmployeeChange> getMonthlyEmployeeChange() {
    if (isEmpty) return [];

    // 按年月排序
    final sortedData = [...this];
    sortedData.sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return aDate.compareTo(bDate);
    });

    List<EmployeeChange> employeeChanges = [];

    for (int i = 0; i < sortedData.length; i++) {
      final current = sortedData[i];

      List<MinimalEmployeeInfo> newEmployees = [];
      List<MinimalEmployeeInfo> leftEmployees = [];
      List<MinimalEmployeeInfo> continuousEmployees = [];

      if (i > 0) {
        final previous = sortedData[i - 1];

        // 获取上月和当月的员工标识集合（使用姓名+部门组合）
        final previousEmployeeKeys = previous.workers
            .map((w) => '${w.name}_${w.department}')
            .toSet();
        final currentEmployeeKeys = current.workers
            .map((w) => '${w.name}_${w.department}')
            .toSet();

        // 新增员工：当月有但上月没有的员工
        final newEmployeeKeys = currentEmployeeKeys.difference(
          previousEmployeeKeys,
        );
        newEmployees = current.workers
            .where((w) => newEmployeeKeys.contains('${w.name}_${w.department}'))
            .toList();

        // 离职员工：上月有但当月没有的员工
        final leftEmployeeKeys = previousEmployeeKeys.difference(
          currentEmployeeKeys,
        );
        leftEmployees = previous.workers
            .where(
              (w) => leftEmployeeKeys.contains('${w.name}_${w.department}'),
            )
            .toList();

        // 持续在职员工：上月和当月都有的员工
        final continuousEmployeeKeys = currentEmployeeKeys.intersection(
          previousEmployeeKeys,
        );
        continuousEmployees = current.workers
            .where(
              (w) =>
                  continuousEmployeeKeys.contains('${w.name}_${w.department}'),
            )
            .toList();
      } else {
        // 第一个月，所有员工都算作持续在职员工
        continuousEmployees = [...current.workers];
      }

      // 计算离职率
      final totalEmployeeCount = current.employeeCount;
      final leftEmployeeCount = leftEmployees.length;
      final turnoverRate = totalEmployeeCount > 0
          ? (leftEmployeeCount / totalEmployeeCount) * 100
          : 0.0;

      employeeChanges.add(
        EmployeeChange(
          year: current.year,
          month: current.month,
          newEmployees: newEmployees,
          leftEmployees: leftEmployees,
          continuousEmployees: continuousEmployees,
          totalEmployeeCount: totalEmployeeCount,
          newEmployeeCount: newEmployees.length,
          leftEmployeeCount: leftEmployeeCount,
          turnoverRate: turnoverRate,
        ),
      );
    }

    return employeeChanges;
  }

  String getMonthlyEmployeeChangeText() {
    List<EmployeeChange> employeeChanges = getMonthlyEmployeeChange();
    StringBuffer buffer = StringBuffer();
    
    if (employeeChanges.isEmpty) {
      return "暂无月度员工变化数据。";
    }
    
    buffer.writeln("月度员工变化分析报告\n");
    buffer.writeln("=" * 50);
    
    for (int i = 0; i < employeeChanges.length; i++) {
      final change = employeeChanges[i];
      buffer.writeln("\n${change.year}年${change.month}月员工变化情况：");
      buffer.writeln("  总员工数：${change.totalEmployeeCount}人");
      buffer.writeln("  新增员工：${change.newEmployeeCount}人");
      buffer.writeln("  离职员工：${change.leftEmployeeCount}人");
      buffer.writeln("  持续在职员工：${change.continuousEmployees.length}人");
      buffer.writeln("  离职率：${change.turnoverRate.toStringAsFixed(2)}%");
      
      // 显示新增员工详情
      if (change.newEmployees.isNotEmpty) {
        buffer.writeln("  新增员工详情：");
        for (final employee in change.newEmployees) {
          buffer.writeln("    - ${employee.name}（${employee.department}）");
        }
      }
      
      // 显示离职员工详情
      if (change.leftEmployees.isNotEmpty) {
        buffer.writeln("  离职员工详情：");
        for (final employee in change.leftEmployees) {
          buffer.writeln("    - ${employee.name}（${employee.department}）");
        }
      }
      
      // 人员变动分析
      final netChange = change.newEmployeeCount - change.leftEmployeeCount;
      if (netChange > 0) {
        buffer.writeln("  人员变动分析：本月净增加$netChange人，团队规模扩大");
      } else if (netChange < 0) {
        buffer.writeln("  人员变动分析：本月净减少${netChange.abs()}人，团队规模缩小");
      } else {
        buffer.writeln("  人员变动分析：本月人员进出平衡，团队规模保持稳定");
      }
      
      if (i < employeeChanges.length - 1) {
        buffer.writeln("\n${"-" * 30}");
      }
    }
    
    // 添加总体趋势分析
    if (employeeChanges.length > 1) {
      buffer.writeln("\n\n总体趋势分析：");
      buffer.writeln("=" * 30);
      
      final firstMonth = employeeChanges.first;
      final lastMonth = employeeChanges.last;
      
      final totalEmployeeGrowth = lastMonth.totalEmployeeCount - firstMonth.totalEmployeeCount;
      final totalNewEmployees = employeeChanges.map((e) => e.newEmployeeCount).reduce((a, b) => a + b);
      final totalLeftEmployees = employeeChanges.map((e) => e.leftEmployeeCount).reduce((a, b) => a + b);
      final avgTurnoverRate = employeeChanges.map((e) => e.turnoverRate).reduce((a, b) => a + b) / employeeChanges.length;
      
      buffer.writeln("从${firstMonth.year}年${firstMonth.month}月到${lastMonth.year}年${lastMonth.month}月：");
      buffer.writeln("  员工总数变化：${totalEmployeeGrowth >= 0 ? '+' : ''}$totalEmployeeGrowth人");
      buffer.writeln("  累计新增员工：$totalNewEmployees人");
      buffer.writeln("  累计离职员工：$totalLeftEmployees人");
      buffer.writeln("  平均离职率：${avgTurnoverRate.toStringAsFixed(2)}%");
      
      // 人员稳定性分析
      if (avgTurnoverRate < 5.0) {
        buffer.writeln("  人员稳定性：优秀，员工流失率较低，团队稳定性良好");
      } else if (avgTurnoverRate < 10.0) {
        buffer.writeln("  人员稳定性：良好，员工流失率在正常范围内");
      } else if (avgTurnoverRate < 20.0) {
        buffer.writeln("  人员稳定性：一般，需要关注员工满意度和留存策略");
      } else {
        buffer.writeln("  人员稳定性：需要改善，员工流失率较高，建议加强人才保留措施");
      }
    }
    
    return buffer.toString();
  }

  /// 获取季度薪资变化分析
  List<QuarterlySalaryChange> getQuarterlySalaryChange() {
    if (isEmpty) return [];

    // 按年月排序
    final sortedData = [...this];
    sortedData.sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return aDate.compareTo(bDate);
    });

    // 获取月度变化数据
    final monthlyChanges = getMonthlySalaryChange();
    
    // 按季度分组
    final Map<String, List<MonthlySalaryChange>> quarterlyGroups = {};
    for (final change in monthlyChanges) {
      final quarter = _getQuarter(change.month);
      final key = '${change.year}-Q$quarter';
      quarterlyGroups.putIfAbsent(key, () => []);
      quarterlyGroups[key]!.add(change);
    }

    List<QuarterlySalaryChange> quarterlyChanges = [];
    final sortedKeys = quarterlyGroups.keys.toList()..sort();

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final parts = key.split('-Q');
      final year = int.parse(parts[0]);
      final quarter = int.parse(parts[1]);
      final quarterData = quarterlyGroups[key]!;

      // 计算季度汇总数据
      final totalSalary = quarterData.map((e) => e.totalSalary).reduce((a, b) => a + b) / quarterData.length;
      final averageSalary = quarterData.map((e) => e.averageSalary).reduce((a, b) => a + b) / quarterData.length;
      final highestSalary = quarterData.map((e) => e.highestSalary).reduce((a, b) => a > b ? a : b);
      final lowestSalary = quarterData.map((e) => e.lowestSalary).reduce((a, b) => a < b ? a : b);
      final employeeCount = quarterData.map((e) => e.employeeCount).reduce((a, b) => a + b) ~/ quarterData.length;

      // 计算与上季度的变化
      double? totalSalaryChange;
      double? averageSalaryChange;
      double? totalSalaryChangePercent;
      double? averageSalaryChangePercent;
      int? employeeCountChange;

      if (i > 0) {
        final prevQuarterData = quarterlyGroups[sortedKeys[i - 1]]!;
        final prevTotalSalary = prevQuarterData.map((e) => e.totalSalary).reduce((a, b) => a + b) / prevQuarterData.length;
        final prevAverageSalary = prevQuarterData.map((e) => e.averageSalary).reduce((a, b) => a + b) / prevQuarterData.length;
        final prevEmployeeCount = prevQuarterData.map((e) => e.employeeCount).reduce((a, b) => a + b) ~/ prevQuarterData.length;

        totalSalaryChange = totalSalary - prevTotalSalary;
        averageSalaryChange = averageSalary - prevAverageSalary;
        employeeCountChange = employeeCount - prevEmployeeCount;

        totalSalaryChangePercent = prevTotalSalary > 0 ? (totalSalaryChange / prevTotalSalary) * 100 : 0.0;
        averageSalaryChangePercent = prevAverageSalary > 0 ? (averageSalaryChange / prevAverageSalary) * 100 : 0.0;
      }

      quarterlyChanges.add(
        QuarterlySalaryChange(
          year: year,
          quarter: quarter,
          monthlyChanges: quarterData,
          totalSalary: totalSalary,
          averageSalary: averageSalary,
          highestSalary: highestSalary,
          lowestSalary: lowestSalary,
          employeeCount: employeeCount,
          totalSalaryChange: totalSalaryChange,
          averageSalaryChange: averageSalaryChange,
          totalSalaryChangePercent: totalSalaryChangePercent,
          averageSalaryChangePercent: averageSalaryChangePercent,
          employeeCountChange: employeeCountChange,
        ),
      );
    }

    return quarterlyChanges;
  }

  /// 获取季度薪资变化描述文本
  String getQuarterlySalaryChangeText() {
    List<QuarterlySalaryChange> quarterlyChanges = getQuarterlySalaryChange();
    StringBuffer buffer = StringBuffer();
    
    if (quarterlyChanges.isEmpty) {
      return "暂无季度薪资变化数据。";
    }
    
    buffer.writeln("季度薪资变化分析报告\n");
    buffer.writeln("=" * 50);
    
    for (int i = 0; i < quarterlyChanges.length; i++) {
      final change = quarterlyChanges[i];
      final quarterName = _getQuarterName(change.quarter);
      
      buffer.writeln("\n${change.year}年$quarterName薪资分析报告：");
      
      // 季度内部月度变化详情
      buffer.writeln("  季度内部月度变化详情：");
      for (final monthlyChange in change.monthlyChanges) {
        buffer.writeln("    ${monthlyChange.month}月：总薪资${monthlyChange.totalSalary.toStringAsFixed(2)}元，平均薪资${monthlyChange.averageSalary.toStringAsFixed(2)}元，员工${monthlyChange.employeeCount}人");
        if (monthlyChange.totalSalaryChange != null) {
          final changeText = monthlyChange.totalSalaryChange! >= 0 ? "增长" : "下降";
          buffer.writeln("    较上月总薪资$changeText${monthlyChange.totalSalaryChange!.abs().toStringAsFixed(2)}元（${monthlyChange.totalSalaryChangePercent!.toStringAsFixed(2)}%）");
          
          final avgChangeText = monthlyChange.averageSalaryChange! >= 0 ? "增长" : "下降";
          buffer.writeln("    较上月平均薪资$avgChangeText${monthlyChange.averageSalaryChange!.abs().toStringAsFixed(2)}元（${monthlyChange.averageSalaryChangePercent!.toStringAsFixed(2)}%）");
        }
      }
      
      // 季度汇总情况
      buffer.writeln("  季度汇总情况：");
      buffer.writeln("    平均总薪资：${change.totalSalary.toStringAsFixed(2)}元");
      buffer.writeln("    平均薪资水平：${change.averageSalary.toStringAsFixed(2)}元");
      buffer.writeln("    最高薪资：${change.highestSalary.toStringAsFixed(2)}元");
      buffer.writeln("    最低薪资：${change.lowestSalary.toStringAsFixed(2)}元");
      buffer.writeln("    平均员工数：${change.employeeCount}人");
      
      // 与上季度对比分析
      if (change.totalSalaryChange != null && i > 0) {
        final prevChange = quarterlyChanges[i - 1];
        final prevQuarterName = _getQuarterName(prevChange.quarter);
        
        buffer.writeln("  与${prevChange.year}年$prevQuarterName相比：");
        
        final totalChangeText = change.totalSalaryChange! >= 0 ? "增长" : "下降";
        buffer.writeln("    总薪资$totalChangeText${change.totalSalaryChange!.abs().toStringAsFixed(2)}元（${change.totalSalaryChangePercent!.toStringAsFixed(2)}%）");
        
        final avgChangeText = change.averageSalaryChange! >= 0 ? "增长" : "下降";
        buffer.writeln("    平均薪资$avgChangeText${change.averageSalaryChange!.abs().toStringAsFixed(2)}元（${change.averageSalaryChangePercent!.toStringAsFixed(2)}%）");
        
        final empChangeText = change.employeeCountChange! >= 0 ? "增加" : "减少";
        buffer.writeln("    员工人数$empChangeText${change.employeeCountChange!.abs()}人");
      }
      
      if (i < quarterlyChanges.length - 1) {
        buffer.writeln("\n${"-" * 40}");
      }
    }
    
    return buffer.toString();
  }

  /// 获取季度员工变化分析
  List<QuarterlyEmployeeChange> getQuarterlyEmployeeChange() {
    if (isEmpty) return [];

    // 获取月度员工变化数据
    final monthlyChanges = getMonthlyEmployeeChange();
    
    // 按季度分组
    final Map<String, List<EmployeeChange>> quarterlyGroups = {};
    for (final change in monthlyChanges) {
      final quarter = _getQuarter(change.month);
      final key = '${change.year}-Q$quarter';
      quarterlyGroups.putIfAbsent(key, () => []);
      quarterlyGroups[key]!.add(change);
    }

    List<QuarterlyEmployeeChange> quarterlyChanges = [];
    final sortedKeys = quarterlyGroups.keys.toList()..sort();

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final parts = key.split('-Q');
      final year = int.parse(parts[0]);
      final quarter = int.parse(parts[1]);
      final quarterData = quarterlyGroups[key]!;

      // 计算季度员工变化汇总
      final quarterStartEmployees = quarterData.first.continuousEmployees.toSet();
      final quarterEndEmployees = quarterData.last.continuousEmployees.toSet()
        ..addAll(quarterData.last.newEmployees);

      // 季度新增员工：季度内任何月份新增的员工
      final newEmployees = <MinimalEmployeeInfo>{};
      for (final monthData in quarterData) {
        newEmployees.addAll(monthData.newEmployees);
      }

      // 季度离职员工：季度内任何月份离职的员工
      final leftEmployees = <MinimalEmployeeInfo>{};
      for (final monthData in quarterData) {
        leftEmployees.addAll(monthData.leftEmployees);
      }

      // 季度持续在职员工：整个季度都在职的员工
      final continuousEmployees = quarterStartEmployees.intersection(quarterEndEmployees);

      final totalEmployeeCount = quarterData.last.totalEmployeeCount;
      final newEmployeeCount = newEmployees.length;
      final leftEmployeeCount = leftEmployees.length;
      final turnoverRate = totalEmployeeCount > 0 ? (leftEmployeeCount / totalEmployeeCount) * 100 : 0.0;

      quarterlyChanges.add(
        QuarterlyEmployeeChange(
          year: year,
          quarter: quarter,
          monthlyChanges: quarterData,
          newEmployees: newEmployees.toList(),
          leftEmployees: leftEmployees.toList(),
          continuousEmployees: continuousEmployees.toList(),
          totalEmployeeCount: totalEmployeeCount,
          newEmployeeCount: newEmployeeCount,
          leftEmployeeCount: leftEmployeeCount,
          turnoverRate: turnoverRate,
        ),
      );
    }

    return quarterlyChanges;
  }

  /// 获取季度员工变化描述文本
  String getQuarterlyEmployeeChangeText() {
    List<QuarterlyEmployeeChange> quarterlyChanges = getQuarterlyEmployeeChange();
    StringBuffer buffer = StringBuffer();
    
    if (quarterlyChanges.isEmpty) {
      return "暂无季度员工变化数据。";
    }
    
    buffer.writeln("季度员工变化分析报告\n");
    buffer.writeln("=" * 50);
    
    for (int i = 0; i < quarterlyChanges.length; i++) {
      final change = quarterlyChanges[i];
      final quarterName = _getQuarterName(change.quarter);
      
      buffer.writeln("\n${change.year}年$quarterName员工变化情况：");
      
      // 季度内部月度变化详情
      buffer.writeln("  季度内部月度变化详情：");
      for (final monthlyChange in change.monthlyChanges) {
        buffer.writeln("    ${monthlyChange.month}月：总员工${monthlyChange.totalEmployeeCount}人，新增${monthlyChange.newEmployeeCount}人，离职${monthlyChange.leftEmployeeCount}人，离职率${monthlyChange.turnoverRate.toStringAsFixed(2)}%");
        
        if (monthlyChange.newEmployees.isNotEmpty) {
          buffer.writeln("      新增员工：${monthlyChange.newEmployees.map((e) => '${e.name}(${e.department})').join('、')}");
        }
        if (monthlyChange.leftEmployees.isNotEmpty) {
          buffer.writeln("      离职员工：${monthlyChange.leftEmployees.map((e) => '${e.name}(${e.department})').join('、')}");
        }
      }
      
      // 季度汇总情况
      buffer.writeln("  季度汇总情况：");
      buffer.writeln("    期末总员工数：${change.totalEmployeeCount}人");
      buffer.writeln("    季度新增员工：${change.newEmployeeCount}人");
      buffer.writeln("    季度离职员工：${change.leftEmployeeCount}人");
      buffer.writeln("    季度持续在职员工：${change.continuousEmployees.length}人");
      buffer.writeln("    季度离职率：${change.turnoverRate.toStringAsFixed(2)}%");
      
      // 人员变动分析
      final netChange = change.newEmployeeCount - change.leftEmployeeCount;
      if (netChange > 0) {
        buffer.writeln("    人员变动分析：本季度净增加$netChange人，团队规模扩大");
      } else if (netChange < 0) {
        buffer.writeln("    人员变动分析：本季度净减少${netChange.abs()}人，团队规模缩小");
      } else {
        buffer.writeln("    人员变动分析：本季度人员进出平衡，团队规模保持稳定");
      }
      
      if (i < quarterlyChanges.length - 1) {
        buffer.writeln("\n${"-" * 40}");
      }
    }
    
    return buffer.toString();
  }

  /// 获取年度薪资变化分析
  List<YearlySalaryChange> getYearlySalaryChange() {
    if (isEmpty) return [];

    // 按年月排序
    final sortedData = [...this];
    sortedData.sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return aDate.compareTo(bDate);
    });

    // 获取月度变化数据
    final monthlyChanges = getMonthlySalaryChange();
    
    // 按年分组
    final Map<int, List<MonthlySalaryChange>> yearlyGroups = {};
    for (final change in monthlyChanges) {
      yearlyGroups.putIfAbsent(change.year, () => []);
      yearlyGroups[change.year]!.add(change);
    }

    List<YearlySalaryChange> yearlyChanges = [];
    final sortedYears = yearlyGroups.keys.toList()..sort();

    for (int i = 0; i < sortedYears.length; i++) {
      final year = sortedYears[i];
      final yearData = yearlyGroups[year]!;

      // 计算年度汇总数据
      final totalSalary = yearData.map((e) => e.totalSalary).reduce((a, b) => a + b) / yearData.length;
      final averageSalary = yearData.map((e) => e.averageSalary).reduce((a, b) => a + b) / yearData.length;
      final highestSalary = yearData.map((e) => e.highestSalary).reduce((a, b) => a > b ? a : b);
      final lowestSalary = yearData.map((e) => e.lowestSalary).reduce((a, b) => a < b ? a : b);
      final employeeCount = yearData.last.employeeCount;
      final averageEmployeeCount = yearData.map((e) => e.employeeCount).reduce((a, b) => a + b) / yearData.length;

      // 计算与上年的变化
      double? totalSalaryChange;
      double? averageSalaryChange;
      double? totalSalaryChangePercent;
      double? averageSalaryChangePercent;
      int? employeeCountChange;

      if (i > 0) {
        final prevYearData = yearlyGroups[sortedYears[i - 1]]!;
        final prevTotalSalary = prevYearData.map((e) => e.totalSalary).reduce((a, b) => a + b) / prevYearData.length;
        final prevAverageSalary = prevYearData.map((e) => e.averageSalary).reduce((a, b) => a + b) / prevYearData.length;
        final prevAverageEmployeeCount = prevYearData.map((e) => e.employeeCount).reduce((a, b) => a + b) / prevYearData.length;

        totalSalaryChange = totalSalary - prevTotalSalary;
        averageSalaryChange = averageSalary - prevAverageSalary;
        employeeCountChange = (averageEmployeeCount - prevAverageEmployeeCount).round();

        totalSalaryChangePercent = prevTotalSalary > 0 ? (totalSalaryChange / prevTotalSalary) * 100 : 0.0;
        averageSalaryChangePercent = prevAverageSalary > 0 ? (averageSalaryChange / prevAverageSalary) * 100 : 0.0;
      }

      yearlyChanges.add(
        YearlySalaryChange(
          year: year,
          monthlyChanges: yearData,
          totalSalary: totalSalary,
          averageSalary: averageSalary,
          highestSalary: highestSalary,
          lowestSalary: lowestSalary,
          employeeCount: employeeCount,
          averageEmployeeCount: averageEmployeeCount,
          totalSalaryChange: totalSalaryChange,
          averageSalaryChange: averageSalaryChange,
          totalSalaryChangePercent: totalSalaryChangePercent,
          averageSalaryChangePercent: averageSalaryChangePercent,
          employeeCountChange: employeeCountChange,
        ),
      );
    }

    return yearlyChanges;
  }

  /// 获取年度薪资变化描述文本
  String getYearlySalaryChangeText() {
    List<YearlySalaryChange> yearlyChanges = getYearlySalaryChange();
    StringBuffer buffer = StringBuffer();
    
    if (yearlyChanges.isEmpty) {
      return "暂无年度薪资变化数据。";
    }
    
    buffer.writeln("年度薪资变化分析报告\n");
    buffer.writeln("=" * 50);
    
    for (int i = 0; i < yearlyChanges.length; i++) {
      final change = yearlyChanges[i];
      
      buffer.writeln("\n${change.year}年度薪资分析报告：");
      
      // 年度内部月度变化详情
      buffer.writeln("  年度内部月度变化详情：");
      for (final monthlyChange in change.monthlyChanges) {
        buffer.writeln("    ${monthlyChange.month}月：总薪资${monthlyChange.totalSalary.toStringAsFixed(2)}元，平均薪资${monthlyChange.averageSalary.toStringAsFixed(2)}元，员工${monthlyChange.employeeCount}人");
      }
      
      // 年度汇总情况
      buffer.writeln("  年度汇总情况：");
      buffer.writeln("    年度平均总薪资：${change.totalSalary.toStringAsFixed(2)}元");
      buffer.writeln("    年度平均薪资水平：${change.averageSalary.toStringAsFixed(2)}元");
      buffer.writeln("    年度最高薪资：${change.highestSalary.toStringAsFixed(2)}元");
      buffer.writeln("    年度最低薪资：${change.lowestSalary.toStringAsFixed(2)}元");
      buffer.writeln("    年末员工数：${change.employeeCount}人");
      buffer.writeln("    年度平均员工数：${change.averageEmployeeCount.toStringAsFixed(1)}人");
      
      // 薪资结构分析
      final salaryRange = change.highestSalary - change.lowestSalary;
      buffer.writeln("    薪资结构分析：薪资差距${salaryRange.toStringAsFixed(2)}元，薪资分布${change.lowestSalary.toStringAsFixed(2)}-${change.highestSalary.toStringAsFixed(2)}元");
      
      // 与上年对比分析
      if (change.totalSalaryChange != null && i > 0) {
        final prevChange = yearlyChanges[i - 1];
        
        buffer.writeln("  与${prevChange.year}年对比分析：");
        
        final totalChangeText = change.totalSalaryChange! >= 0 ? "增长" : "下降";
        buffer.writeln("    总薪资$totalChangeText${change.totalSalaryChange!.abs().toStringAsFixed(2)}元（${change.totalSalaryChangePercent!.toStringAsFixed(2)}%）");
        
        final avgChangeText = change.averageSalaryChange! >= 0 ? "增长" : "下降";
        buffer.writeln("    平均薪资$avgChangeText${change.averageSalaryChange!.abs().toStringAsFixed(2)}元（${change.averageSalaryChangePercent!.toStringAsFixed(2)}%）");
        
        final empChangeText = change.employeeCountChange! >= 0 ? "增加" : "减少";
        buffer.writeln("    员工人数$empChangeText${change.employeeCountChange!.abs()}人");
      }
      
      if (i < yearlyChanges.length - 1) {
        buffer.writeln("\n${"-" * 50}");
      }
    }
    
    return buffer.toString();
  }

  /// 获取年度员工变化分析
  List<YearlyEmployeeChange> getYearlyEmployeeChange() {
    if (isEmpty) return [];

    // 获取月度员工变化数据
    final monthlyChanges = getMonthlyEmployeeChange();
    
    // 按年分组
    final Map<int, List<EmployeeChange>> yearlyGroups = {};
    for (final change in monthlyChanges) {
      yearlyGroups.putIfAbsent(change.year, () => []);
      yearlyGroups[change.year]!.add(change);
    }

    List<YearlyEmployeeChange> yearlyChanges = [];
    final sortedYears = yearlyGroups.keys.toList()..sort();

    for (final year in sortedYears) {
      final yearData = yearlyGroups[year]!;

      // 计算年度员工变化汇总
      final yearStartEmployees = yearData.first.continuousEmployees.toSet();
      final yearEndEmployees = yearData.last.continuousEmployees.toSet()
        ..addAll(yearData.last.newEmployees);

      // 年度新增员工：年度内任何月份新增的员工
      final newEmployees = <MinimalEmployeeInfo>{};
      for (final monthData in yearData) {
        newEmployees.addAll(monthData.newEmployees);
      }

      // 年度离职员工：年度内任何月份离职的员工
      final leftEmployees = <MinimalEmployeeInfo>{};
      for (final monthData in yearData) {
        leftEmployees.addAll(monthData.leftEmployees);
      }

      // 年度持续在职员工：整个年度都在职的员工
      final continuousEmployees = yearStartEmployees.intersection(yearEndEmployees);

      final totalEmployeeCount = yearData.last.totalEmployeeCount;
      final newEmployeeCount = newEmployees.length;
      final leftEmployeeCount = leftEmployees.length;
      final averageEmployeeCount = yearData.map((e) => e.totalEmployeeCount).reduce((a, b) => a + b) / yearData.length;
      final turnoverRate = averageEmployeeCount > 0 ? (leftEmployeeCount / averageEmployeeCount) * 100 : 0.0;

      yearlyChanges.add(
        YearlyEmployeeChange(
          year: year,
          monthlyChanges: yearData,
          newEmployees: newEmployees.toList(),
          leftEmployees: leftEmployees.toList(),
          continuousEmployees: continuousEmployees.toList(),
          totalEmployeeCount: totalEmployeeCount,
          newEmployeeCount: newEmployeeCount,
          leftEmployeeCount: leftEmployeeCount,
          averageEmployeeCount: averageEmployeeCount,
          turnoverRate: turnoverRate,
        ),
      );
    }

    return yearlyChanges;
  }

  /// 获取年度员工变化描述文本
  String getYearlyEmployeeChangeText() {
    List<YearlyEmployeeChange> yearlyChanges = getYearlyEmployeeChange();
    StringBuffer buffer = StringBuffer();
    
    if (yearlyChanges.isEmpty) {
      return "暂无年度员工变化数据。";
    }
    
    buffer.writeln("年度员工变化分析报告\n");
    buffer.writeln("=" * 50);
    
    for (int i = 0; i < yearlyChanges.length; i++) {
      final change = yearlyChanges[i];
      
      buffer.writeln("\n${change.year}年度员工变化情况：");
      
      // 年度内部月度变化详情
      buffer.writeln("  年度内部月度变化详情：");
      for (final monthlyChange in change.monthlyChanges) {
        buffer.writeln("    ${monthlyChange.month}月：总员工${monthlyChange.totalEmployeeCount}人，新增${monthlyChange.newEmployeeCount}人，离职${monthlyChange.leftEmployeeCount}人，离职率${monthlyChange.turnoverRate.toStringAsFixed(2)}%");
      }
      
      // 年度汇总情况
      buffer.writeln("  年度汇总情况：");
      buffer.writeln("    年末总员工数：${change.totalEmployeeCount}人");
      buffer.writeln("    年度新增员工：${change.newEmployeeCount}人");
      buffer.writeln("    年度离职员工：${change.leftEmployeeCount}人");
      buffer.writeln("    年度持续在职员工：${change.continuousEmployees.length}人");
      buffer.writeln("    年度平均员工数：${change.averageEmployeeCount.toStringAsFixed(1)}人");
      buffer.writeln("    年度离职率：${change.turnoverRate.toStringAsFixed(2)}%");
      
      // 人员变动效率分析
      final netChange = change.newEmployeeCount - change.leftEmployeeCount;
      if (netChange > 0) {
        buffer.writeln("    人员变动分析：本年度净增加$netChange人，团队规模扩大，人才储备增强");
      } else if (netChange < 0) {
        buffer.writeln("    人员变动分析：本年度净减少${netChange.abs()}人，团队规模缩小，需要关注人才保留");
      } else {
        buffer.writeln("    人员变动分析：本年度人员进出平衡，团队规模保持稳定");
      }
      
      if (i < yearlyChanges.length - 1) {
        buffer.writeln("\n${"-" * 50}");
      }
    }
    
    return buffer.toString();
  }

  /// 获取月份对应的季度
  int _getQuarter(int month) {
    return ((month - 1) ~/ 3) + 1;
  }

  /// 获取季度名称
  String _getQuarterName(int quarter) {
    return "第$quarter季度";
  }

  /// 生成月度薪资变化趋势图表
  Future<Uint8List?> generateMonthlySalaryTrendChart() async {
    final chartService = TrendAnalysisChartService();
    final monthlyChanges = getMonthlySalaryChange();
    return await chartService.generateMonthlySalaryTrendChart(monthlyChanges);
  }

  /// 生成月度员工变化趋势图表
  Future<Uint8List?> generateMonthlyEmployeeTrendChart() async {
    final chartService = TrendAnalysisChartService();
    final employeeChanges = getMonthlyEmployeeChange();
    return await chartService.generateMonthlyEmployeeTrendChart(employeeChanges);
  }

  /// 生成季度薪资变化趋势图表
  Future<Uint8List?> generateQuarterlySalaryTrendChart() async {
    final chartService = TrendAnalysisChartService();
    final quarterlyChanges = getQuarterlySalaryChange();
    return await chartService.generateQuarterlySalaryTrendChart(quarterlyChanges);
  }

  /// 生成年度薪资变化趋势图表
  Future<Uint8List?> generateYearlySalaryTrendChart() async {
    final chartService = TrendAnalysisChartService();
    final yearlyChanges = getYearlySalaryChange();
    return await chartService.generateYearlySalaryTrendChart(yearlyChanges);
  }

  /// 生成年度员工变化趋势图表
  Future<Uint8List?> generateYearlyEmployeeTrendChart() async {
    final chartService = TrendAnalysisChartService();
    final yearlyChanges = getYearlyEmployeeChange();
    return await chartService.generateYearlyEmployeeTrendChart(yearlyChanges);
  }

  /// 生成所有趋势分析图表
  Future<TrendAnalysisChartImages> generateAllTrendCharts() async {
    final monthlySalaryChart = await generateMonthlySalaryTrendChart();
    final monthlyEmployeeChart = await generateMonthlyEmployeeTrendChart();
    final quarterlySalaryChart = await generateQuarterlySalaryTrendChart();
    final yearlySalaryChart = await generateYearlySalaryTrendChart();
    final yearlyEmployeeChart = await generateYearlyEmployeeTrendChart();

    return TrendAnalysisChartImages(
      monthlySalaryTrendChart: monthlySalaryChart,
      monthlyEmployeeTrendChart: monthlyEmployeeChart,
      quarterlySalaryTrendChart: quarterlySalaryChart,
      yearlySalaryTrendChart: yearlySalaryChart,
      yearlyEmployeeTrendChart: yearlyEmployeeChart,
    );
  }
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

/*=============================================================================*/
// 薪资变化趋势相关数据模型

// 月度薪资变化数据
class MonthlySalaryChange {
  final int year;
  final int month;
  final double totalSalary;
  final double averageSalary;
  final double highestSalary;
  final double lowestSalary;
  final int employeeCount;
  final double? totalSalaryChange; // 与上月相比的总薪资变化
  final double? averageSalaryChange; // 与上月相比的平均薪资变化
  final double? totalSalaryChangePercent; // 与上月相比的总薪资变化百分比
  final double? averageSalaryChangePercent; // 与上月相比的平均薪资变化百分比
  final int? employeeCountChange; // 与上月相比的员工数量变化

  MonthlySalaryChange({
    required this.year,
    required this.month,
    required this.totalSalary,
    required this.averageSalary,
    required this.highestSalary,
    required this.lowestSalary,
    required this.employeeCount,
    this.totalSalaryChange,
    this.averageSalaryChange,
    this.totalSalaryChangePercent,
    this.averageSalaryChangePercent,
    this.employeeCountChange,
  });
}

// 部门薪资变化数据
class DepartmentSalaryChange {
  final String department;
  final int year;
  final int month;
  final double totalSalary;
  final double averageSalary;
  final int employeeCount;
  final double? totalSalaryChange; // 与上月相比的变化
  final double? averageSalaryChange; // 与上月相比的变化
  final double? totalSalaryChangePercent; // 与上月相比的变化百分比
  final double? averageSalaryChangePercent; // 与上月相比的变化百分比
  final int? employeeCountChange; // 与上月相比的员工数量变化

  DepartmentSalaryChange({
    required this.department,
    required this.year,
    required this.month,
    required this.totalSalary,
    required this.averageSalary,
    required this.employeeCount,
    this.totalSalaryChange,
    this.averageSalaryChange,
    this.totalSalaryChangePercent,
    this.averageSalaryChangePercent,
    this.employeeCountChange,
  });
}

// 员工变化情况数据
class EmployeeChange {
  final int year;
  final int month;
  final List<MinimalEmployeeInfo> newEmployees; // 新增员工
  final List<MinimalEmployeeInfo> leftEmployees; // 离职员工
  final List<MinimalEmployeeInfo> continuousEmployees; // 持续在职员工
  final int totalEmployeeCount; // 当月总员工数
  final int newEmployeeCount; // 新增员工数
  final int leftEmployeeCount; // 离职员工数
  final double turnoverRate; // 离职率

  EmployeeChange({
    required this.year,
    required this.month,
    required this.newEmployees,
    required this.leftEmployees,
    required this.continuousEmployees,
    required this.totalEmployeeCount,
    required this.newEmployeeCount,
    required this.leftEmployeeCount,
    required this.turnoverRate,
  });
}

// 部门员工变化情况数据
class DepartmentEmployeeChange {
  final String department;
  final int year;
  final int month;
  final List<MinimalEmployeeInfo> newEmployees; // 新增员工
  final List<MinimalEmployeeInfo> leftEmployees; // 离职员工
  final List<MinimalEmployeeInfo> continuousEmployees; // 持续在职员工
  final int totalEmployeeCount; // 当月总员工数
  final int newEmployeeCount; // 新增员工数
  final int leftEmployeeCount; // 离职员工数
  final double turnoverRate; // 离职率

  DepartmentEmployeeChange({
    required this.department,
    required this.year,
    required this.month,
    required this.newEmployees,
    required this.leftEmployees,
    required this.continuousEmployees,
    required this.totalEmployeeCount,
    required this.newEmployeeCount,
    required this.leftEmployeeCount,
    required this.turnoverRate,
  });
}

// 季度薪资变化数据
class QuarterlySalaryChange {
  final int year;
  final int quarter;
  final List<MonthlySalaryChange> monthlyChanges; // 季度内各月变化
  final double totalSalary;
  final double averageSalary;
  final double highestSalary;
  final double lowestSalary;
  final int employeeCount;
  final double? totalSalaryChange; // 与上季度相比的总薪资变化
  final double? averageSalaryChange; // 与上季度相比的平均薪资变化
  final double? totalSalaryChangePercent; // 与上季度相比的总薪资变化百分比
  final double? averageSalaryChangePercent; // 与上季度相比的平均薪资变化百分比
  final int? employeeCountChange; // 与上季度相比的员工数量变化

  QuarterlySalaryChange({
    required this.year,
    required this.quarter,
    required this.monthlyChanges,
    required this.totalSalary,
    required this.averageSalary,
    required this.highestSalary,
    required this.lowestSalary,
    required this.employeeCount,
    this.totalSalaryChange,
    this.averageSalaryChange,
    this.totalSalaryChangePercent,
    this.averageSalaryChangePercent,
    this.employeeCountChange,
  });
}

// 季度员工变化数据
class QuarterlyEmployeeChange {
  final int year;
  final int quarter;
  final List<EmployeeChange> monthlyChanges; // 季度内各月变化
  final List<MinimalEmployeeInfo> newEmployees; // 季度新增员工
  final List<MinimalEmployeeInfo> leftEmployees; // 季度离职员工
  final List<MinimalEmployeeInfo> continuousEmployees; // 季度持续在职员工
  final int totalEmployeeCount; // 季末总员工数
  final int newEmployeeCount; // 季度新增员工数
  final int leftEmployeeCount; // 季度离职员工数
  final double turnoverRate; // 季度离职率

  QuarterlyEmployeeChange({
    required this.year,
    required this.quarter,
    required this.monthlyChanges,
    required this.newEmployees,
    required this.leftEmployees,
    required this.continuousEmployees,
    required this.totalEmployeeCount,
    required this.newEmployeeCount,
    required this.leftEmployeeCount,
    required this.turnoverRate,
  });
}

// 年度薪资变化数据
class YearlySalaryChange {
  final int year;
  final List<MonthlySalaryChange> monthlyChanges; // 年度内各月变化
  final double totalSalary;
  final double averageSalary;
  final double highestSalary;
  final double lowestSalary;
  final int employeeCount;
  final double averageEmployeeCount; // 年度平均员工数
  final double? totalSalaryChange; // 与上年相比的总薪资变化
  final double? averageSalaryChange; // 与上年相比的平均薪资变化
  final double? totalSalaryChangePercent; // 与上年相比的总薪资变化百分比
  final double? averageSalaryChangePercent; // 与上年相比的平均薪资变化百分比
  final int? employeeCountChange; // 与上年相比的员工数量变化

  YearlySalaryChange({
    required this.year,
    required this.monthlyChanges,
    required this.totalSalary,
    required this.averageSalary,
    required this.highestSalary,
    required this.lowestSalary,
    required this.employeeCount,
    required this.averageEmployeeCount,
    this.totalSalaryChange,
    this.averageSalaryChange,
    this.totalSalaryChangePercent,
    this.averageSalaryChangePercent,
    this.employeeCountChange,
  });
}

// 年度员工变化数据
class YearlyEmployeeChange {
  final int year;
  final List<EmployeeChange> monthlyChanges; // 年度内各月变化
  final List<MinimalEmployeeInfo> newEmployees; // 年度新增员工
  final List<MinimalEmployeeInfo> leftEmployees; // 年度离职员工
  final List<MinimalEmployeeInfo> continuousEmployees; // 年度持续在职员工
  final int totalEmployeeCount; // 年末总员工数
  final int newEmployeeCount; // 年度新增员工数
  final int leftEmployeeCount; // 年度离职员工数
  final double averageEmployeeCount; // 年度平均员工数
  final double turnoverRate; // 年度离职率

  YearlyEmployeeChange({
    required this.year,
    required this.monthlyChanges,
    required this.newEmployees,
    required this.leftEmployees,
    required this.continuousEmployees,
    required this.totalEmployeeCount,
    required this.newEmployeeCount,
    required this.leftEmployeeCount,
    required this.averageEmployeeCount,
    required this.turnoverRate,
  });
}
