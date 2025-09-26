// 基础多期间报告生成器抽象类
// 提供统一的数据聚合和分析框架，供季度、多季度、年度、多年度报告继承

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/services/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/services/ai_summary_service.dart';
import 'package:salary_report/src/isar/salary_list.dart';

/// 多期间报告生成器的基础抽象类
/// 提供通用的数据聚合、分析和报告生成功能
abstract class BaseMultiPeriodReportGenerator
    implements EnhancedReportGenerator {
  final DataAnalysisService _analysisService;
  final ReportService _reportService;
  final AISummaryService _aiSummaryService;

  BaseMultiPeriodReportGenerator({
    DataAnalysisService? analysisService,
    ReportService? reportService,
    AISummaryService? aiSummaryService,
  }) : _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService(),
       _aiSummaryService = aiSummaryService ?? AISummaryService();

  /// 定义期间类型
  PeriodType get periodType;

  /// 获取图表服务
  dynamic get chartService;

  /// 获取文档写入服务
  dynamic get docxService;

  /// 子类实现：创建报告内容模型
  Future<dynamic> createReportContentModel({
    required Map<String, dynamic> periodData,
    required DateTime startTime,
    required DateTime endTime,
  });

  /// 子类实现：生成图表
  Future<dynamic> generateCharts({
    required GlobalKey previewContainerKey,
    required Map<String, dynamic> periodData,
    required List<dynamic> departmentStats,
  });

  @override
  Future<String> generateEnhancedReport({
    required GlobalKey previewContainerKey,
    required dynamic departmentStats,
    required Map<String, dynamic> analysisData,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousMonthData,
    required int year,
    required int month,
    required bool isMultiMonth,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      logger.info('Starting enhanced ${periodType.name} report generation...');

      // 1. 生成期间数据 - 核心统一逻辑
      final periodData = await _generatePeriodData(startTime, endTime);

      // 2. 生成图表
      final chartImages = await generateCharts(
        previewContainerKey: previewContainerKey,
        periodData: periodData,
        departmentStats: departmentStats,
      );

      // 3. 创建报告内容模型
      final reportContent = await createReportContentModel(
        periodData: periodData,
        startTime: startTime,
        endTime: endTime,
      );

      // 4. 写入报告文件
      final reportPath = await docxService.writeReport(
        data: reportContent,
        images: chartImages,
      );

      // 5. 添加报告记录到数据库
      await _reportService.addReportRecord(reportPath);

      logger.info(
        'Enhanced ${periodType.name} report generation complete: $reportPath',
      );
      return reportPath;
    } catch (e, stackTrace) {
      logger.severe(
        'Fatal error during enhanced ${periodType.name} report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 生成期间数据的统一方法
  /// 根据periodType自动按月收集数据，然后按期间聚合
  Future<Map<String, dynamic>> _generatePeriodData(
    DateTime startTime,
    DateTime endTime,
  ) async {
    // 1. 按月收集原始数据
    final monthlyData = await _collectMonthlyData(startTime, endTime);

    // 2. 根据期间类型进行聚合
    final aggregatedData = _aggregateDataByPeriod(
      monthlyData,
      startTime,
      endTime,
    );

    // 3. 生成对比数据（环比、同比）
    final comparisonData = await _generateComparisonData(aggregatedData);

    // 4. 生成AI分析
    final aiAnalysis = await _generateAIAnalysis(
      aggregatedData,
      comparisonData,
    );

    return {
      'monthlyData': monthlyData,
      'aggregatedData': aggregatedData,
      'comparisonData': comparisonData,
      'aiAnalysis': aiAnalysis,
      'summaryStats': _calculateSummaryStats(aggregatedData),
    };
  }

  /// 按月收集数据
  Future<List<Map<String, dynamic>>> _collectMonthlyData(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final monthlyData = <Map<String, dynamic>>[];
    DateTime currentMonth = DateTime(startTime.year, startTime.month);
    final endMonth = DateTime(endTime.year, endTime.month);

    while (currentMonth.isBefore(endMonth) ||
        currentMonth.isAtSameMomentAs(endMonth)) {
      final monthData = await _getMonthData(
        currentMonth.year,
        currentMonth.month,
      );
      if (monthData != null) {
        monthlyData.add({
          'year': currentMonth.year,
          'month': currentMonth.month,
          'data': monthData,
        });
      }

      // 移动到下一个月
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      if (currentMonth.month > 12) {
        currentMonth = DateTime(currentMonth.year + 1, 1);
      }
    }

    return monthlyData;
  }

  /// 获取单月数据
  Future<Map<String, dynamic>?> _getMonthData(int year, int month) async {
    try {
      // 获取月度薪资数据
      final monthlyData = await _analysisService.getMonthlySalaryData(
        year,
        month,
      );
      if (monthlyData == null) return null;

      // 获取部门统计
      final deptStats = await _analysisService.getDepartmentSalaryStats(
        year: year,
        month: month,
      );

      // 获取薪资构成
      final salarySummary = await _analysisService.getSalarySummaryData(
        year: year,
        month: month,
      );

      // 获取薪资区间
      final salaryRanges = await _analysisService.getSalaryRangeAggregation(
        year,
        month,
      );

      return {
        'totalSalary': monthlyData.summaryData['税前工资'] ?? 0.0,
        'averageSalary': _calculateAverageSalary(monthlyData.records),
        'employeeCount': monthlyData.records.length,
        'departmentStats': deptStats,
        'salarySummary': salarySummary ?? {},
        'salaryRanges': salaryRanges,
      };
    } catch (e) {
      logger.warning('Failed to get data for $year-$month: $e');
      return null;
    }
  }

  /// 根据期间类型聚合数据
  Map<String, dynamic> _aggregateDataByPeriod(
    List<Map<String, dynamic>> monthlyData,
    DateTime startTime,
    DateTime endTime,
  ) {
    switch (periodType) {
      case PeriodType.quarterly:
        return _aggregateByQuarter(monthlyData, startTime, endTime);
      case PeriodType.multiQuarter:
        return _aggregateByMultiQuarter(monthlyData, startTime, endTime);
      case PeriodType.yearly:
        return _aggregateByYear(monthlyData, startTime, endTime);
      case PeriodType.multiYear:
        return _aggregateByMultiYear(monthlyData, startTime, endTime);
    }
  }

  /// 按季度聚合
  Map<String, dynamic> _aggregateByQuarter(
    List<Map<String, dynamic>> monthlyData,
    DateTime startTime,
    DateTime endTime,
  ) {
    final quarters = <Map<String, dynamic>>[];

    // 按季度分组
    final quarterGroups = <String, List<Map<String, dynamic>>>{};
    for (final monthData in monthlyData) {
      final year = monthData['year'] as int;
      final month = monthData['month'] as int;
      final quarter = (month - 1) ~/ 3 + 1;
      final quarterKey = '$year-Q$quarter';

      if (!quarterGroups.containsKey(quarterKey)) {
        quarterGroups[quarterKey] = [];
      }
      quarterGroups[quarterKey]!.add(monthData);
    }

    // 聚合每个季度的数据
    quarterGroups.forEach((quarterKey, months) {
      final quarterData = _aggregateMonths(months);
      quarterData['periodKey'] = quarterKey;
      quarters.add(quarterData);
    });

    return {
      'periods': quarters,
      'periodType': 'quarterly',
      'totalMonths': monthlyData.length,
    };
  }

  /// 按多季度聚合
  Map<String, dynamic> _aggregateByMultiQuarter(
    List<Map<String, dynamic>> monthlyData,
    DateTime startTime,
    DateTime endTime,
  ) {
    // 先按季度分组，然后合并多个季度
    final quarterData = _aggregateByQuarter(monthlyData, startTime, endTime);
    return {
      'periods': quarterData['periods'],
      'periodType': 'multiQuarter',
      'totalMonths': monthlyData.length,
      'quarterCount': (quarterData['periods'] as List).length,
    };
  }

  /// 按年度聚合
  Map<String, dynamic> _aggregateByYear(
    List<Map<String, dynamic>> monthlyData,
    DateTime startTime,
    DateTime endTime,
  ) {
    final years = <Map<String, dynamic>>[];

    // 按年分组
    final yearGroups = <int, List<Map<String, dynamic>>>{};
    for (final monthData in monthlyData) {
      final year = monthData['year'] as int;

      if (!yearGroups.containsKey(year)) {
        yearGroups[year] = [];
      }
      yearGroups[year]!.add(monthData);
    }

    // 聚合每年的数据
    yearGroups.forEach((year, months) {
      final yearData = _aggregateMonths(months);
      yearData['periodKey'] = '$year';
      years.add(yearData);
    });

    return {
      'periods': years,
      'periodType': 'yearly',
      'totalMonths': monthlyData.length,
    };
  }

  /// 按多年度聚合
  Map<String, dynamic> _aggregateByMultiYear(
    List<Map<String, dynamic>> monthlyData,
    DateTime startTime,
    DateTime endTime,
  ) {
    // 先按年度分组，然后合并多个年度
    final yearData = _aggregateByYear(monthlyData, startTime, endTime);
    return {
      'periods': yearData['periods'],
      'periodType': 'multiYear',
      'totalMonths': monthlyData.length,
      'yearCount': (yearData['periods'] as List).length,
    };
  }

  /// 聚合多个月的数据
  Map<String, dynamic> _aggregateMonths(List<Map<String, dynamic>> months) {
    if (months.isEmpty) return {};

    double totalSalary = 0.0;
    double totalAverageSalary = 0.0;
    int totalEmployeeCount = 0;
    final deptStatsMap = <String, List<DepartmentSalaryStats>>{};
    final salaryRangesMap = <String, List<SalaryRangeStats>>{};

    for (final monthData in months) {
      final data = monthData['data'] as Map<String, dynamic>;

      totalSalary += (data['totalSalary'] as num).toDouble();
      totalAverageSalary += (data['averageSalary'] as num).toDouble();
      totalEmployeeCount += data['employeeCount'] as int;

      // 聚合部门数据
      final deptStats = data['departmentStats'] as List<DepartmentSalaryStats>;
      for (final dept in deptStats) {
        if (!deptStatsMap.containsKey(dept.department)) {
          deptStatsMap[dept.department] = [];
        }
        deptStatsMap[dept.department]!.add(dept);
      }

      // 聚合薪资区间数据
      final salaryRanges = data['salaryRanges'] as List<SalaryRangeStats>;
      for (final range in salaryRanges) {
        if (!salaryRangesMap.containsKey(range.range)) {
          salaryRangesMap[range.range] = [];
        }
        salaryRangesMap[range.range]!.add(range);
      }
    }

    // 计算聚合后的部门统计
    final aggregatedDeptStats = <DepartmentSalaryStats>[];
    deptStatsMap.forEach((deptName, deptList) {
      final totalDeptSalary = deptList.fold<double>(
        0.0,
        (sum, dept) => sum + dept.totalNetSalary,
      );
      final totalDeptEmployees = deptList.fold<int>(
        0,
        (sum, dept) => sum + dept.employeeCount,
      );

      aggregatedDeptStats.add(
        DepartmentSalaryStats(
          department: deptName,
          employeeCount: totalDeptEmployees,
          totalNetSalary: totalDeptSalary,
          averageNetSalary: totalDeptEmployees > 0
              ? totalDeptSalary / totalDeptEmployees
              : 0.0,
          year: months.first['year'],
          month: months.first['month'],
          maxSalary: deptList.fold<double>(
            0.0,
            (max, dept) => dept.maxSalary > max ? dept.maxSalary : max,
          ),
          minSalary: deptList.fold<double>(
            double.infinity,
            (min, dept) => dept.minSalary < min ? dept.minSalary : min,
          ),
        ),
      );
    });

    // 计算聚合后的薪资区间统计
    final aggregatedSalaryRanges = <SalaryRangeStats>[];
    salaryRangesMap.forEach((rangeName, rangeList) {
      final totalRangeSalary = rangeList.fold<double>(
        0.0,
        (sum, range) => sum + range.totalSalary,
      );
      final totalRangeEmployees = rangeList.fold<int>(
        0,
        (sum, range) => sum + range.employeeCount,
      );

      aggregatedSalaryRanges.add(
        SalaryRangeStats(
          range: rangeName,
          employeeCount: totalRangeEmployees,
          totalSalary: totalRangeSalary,
          averageSalary: totalRangeEmployees > 0
              ? totalRangeSalary / totalRangeEmployees
              : 0.0,
          year: months.first['year'],
          month: months.first['month'],
        ),
      );
    });

    return {
      'totalSalary': totalSalary,
      'averageSalary': totalAverageSalary / months.length,
      'employeeCount': (totalEmployeeCount / months.length).round(),
      'departmentStats': aggregatedDeptStats,
      'salaryRanges': aggregatedSalaryRanges,
      'monthCount': months.length,
    };
  }

  /// 生成对比数据（环比、同比）
  Future<Map<String, dynamic>> _generateComparisonData(
    Map<String, dynamic> aggregatedData,
  ) async {
    // 环比数据 - 与上一期间对比
    final periodOverPeriodData = await _calculatePeriodOverPeriodChange(
      aggregatedData,
    );

    // 同比数据 - 与去年同期对比
    final yearOverYearData = await _calculateYearOverYearChange(aggregatedData);

    return {
      'periodOverPeriod': periodOverPeriodData,
      'yearOverYear': yearOverYearData,
    };
  }

  /// 计算环比变化
  Future<Map<String, dynamic>> _calculatePeriodOverPeriodChange(
    Map<String, dynamic> aggregatedData,
  ) async {
    // TODO: 实现环比计算逻辑
    return {};
  }

  /// 计算同比变化
  Future<Map<String, dynamic>> _calculateYearOverYearChange(
    Map<String, dynamic> aggregatedData,
  ) async {
    // TODO: 实现同比计算逻辑
    return {};
  }

  /// 生成AI分析
  Future<Map<String, dynamic>> _generateAIAnalysis(
    Map<String, dynamic> aggregatedData,
    Map<String, dynamic> comparisonData,
  ) async {
    final periods = aggregatedData['periods'] as List<Map<String, dynamic>>;
    if (periods.isEmpty) return {};

    // 构建AI分析所需的薪资区间数据
    final List<Map<String, int>> salaryRangesForAI = [];
    for (final period in periods) {
      final ranges = period['salaryRanges'] as List<SalaryRangeStats>;
      final rangeMap = <String, int>{};
      for (final range in ranges) {
        rangeMap[range.range] = range.employeeCount;
      }
      if (rangeMap.isNotEmpty) {
        salaryRangesForAI.add(rangeMap);
      }
    }

    // 构建部门统计数据
    final List<DepartmentSalaryStats> deptStatsList = [];
    for (final period in periods) {
      final deptStats =
          period['departmentStats'] as List<DepartmentSalaryStats>;
      deptStatsList.addAll(deptStats);
    }

    // 生成AI分析内容
    final salaryRangeFeatureSummary = await _aiSummaryService
        .generateSalaryRangeFeatureSummary(salaryRangesForAI, deptStatsList);

    final departmentSalaryAnalysis = await _aiSummaryService
        .generateDepartmentSalaryAnalysis(deptStatsList);

    final keySalaryPoint = await _aiSummaryService.generateKeySalaryPoint(
      deptStatsList,
      salaryRangesForAI,
    );

    return {
      'salaryRangeFeatureSummary': salaryRangeFeatureSummary,
      'departmentSalaryAnalysis': departmentSalaryAnalysis,
      'keySalaryPoint': keySalaryPoint,
    };
  }

  /// 计算汇总统计
  Map<String, dynamic> _calculateSummaryStats(
    Map<String, dynamic> aggregatedData,
  ) {
    final periods = aggregatedData['periods'] as List<Map<String, dynamic>>;
    if (periods.isEmpty) return {};

    final totalSalary = periods.fold<double>(
      0.0,
      (sum, period) => sum + (period['totalSalary'] as double),
    );
    final averageSalary =
        periods.fold<double>(
          0.0,
          (sum, period) => sum + (period['averageSalary'] as double),
        ) /
        periods.length;
    final totalEmployees = periods.last['employeeCount'] as int; // 使用最后一个期间的员工数

    return {
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'totalEmployees': totalEmployees,
      'periodCount': periods.length,
    };
  }

  /// 计算平均工资
  double _calculateAverageSalary(List<SalaryListRecord> records) {
    if (records.isEmpty) return 0.0;

    double totalSalary = 0.0;
    int validCount = 0;

    for (final record in records) {
      if (record.netSalary != null) {
        final salaryStr = record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '');
        final salary = double.tryParse(salaryStr) ?? 0.0;
        if (salary > 0) {
          totalSalary += salary;
          validCount++;
        }
      }
    }

    return validCount > 0 ? totalSalary / validCount : 0.0;
  }

  /// 生成员工详情描述
  String _generateEmployeeDetails(Map<String, dynamic> summaryStats) {
    final totalEmployees = summaryStats['totalEmployees'] as int? ?? 0;
    final averageSalary = summaryStats['averageSalary'] as double? ?? 0.0;
    final totalSalary = summaryStats['totalSalary'] as double? ?? 0.0;

    return '本${periodType.displayName}共有员工 $totalEmployees 人，'
        '工资总额 ${totalSalary.toStringAsFixed(2)} 元，'
        '平均工资 ${averageSalary.toStringAsFixed(2)} 元';
  }

  /// 生成部门详情描述
  String _generateDepartmentDetails(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(
      '本${periodType.displayName}内共有${departmentStats.length}个部门：',
    );

    for (final dept in departmentStats) {
      buffer.writeln(
        '- ${dept.department}部门：${dept.employeeCount}人，'
        '工资总额${dept.totalNetSalary.toStringAsFixed(2)}元，'
        '平均工资${dept.averageNetSalary.toStringAsFixed(2)}元',
      );
    }

    return buffer.toString();
  }

  /// 生成薪资结构数据
  List<Map<String, dynamic>> _createSalaryStructureData(
    Map<String, dynamic>? salarySummary,
  ) {
    final salaryStructureData = <Map<String, dynamic>>[];

    if (salarySummary == null) return salaryStructureData;

    final structureFields = ['基本工资', '岗位工资', '绩效工资', '补贴工资', '饭补'];

    structureFields.forEach((key) {
      if (salarySummary.containsKey(key)) {
        final fieldValue = salarySummary[key];
        double numValue = 0.0;

        if (fieldValue is String) {
          numValue = double.tryParse(fieldValue) ?? 0.0;
        } else if (fieldValue is num) {
          numValue = fieldValue.toDouble();
        }

        salaryStructureData.add({'category': key, 'value': numValue});
      }
    });

    return salaryStructureData;
  }
}

/// 期间类型枚举
enum PeriodType {
  quarterly('quarterly', '季度'),
  multiQuarter('multiQuarter', '多季度'),
  yearly('yearly', '年度'),
  multiYear('multiYear', '多年度');

  const PeriodType(this.name, this.displayName);
  final String name;
  final String displayName;
}
