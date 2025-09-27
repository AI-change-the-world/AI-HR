// src/services/quarterly/enhanced_quarterly_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/services/quarterly/quarterly.dart';
import 'package:salary_report/src/services/base_multi_period_report_generator.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 增强版季度报告生成器 - 基于统一多期间框架
class EnhancedQuarterlyReportGenerator extends BaseMultiPeriodReportGenerator {
  final QuarterlyChartGenerationService _chartService;
  final QuarterlyDocxWriterService _docxService;

  EnhancedQuarterlyReportGenerator({
    QuarterlyChartGenerationService? chartService,
    QuarterlyDocxWriterService? docxService,
    super.analysisService,
    super.reportService,
    super.aiSummaryService,
  }) : _chartService = chartService ?? QuarterlyChartGenerationService(),
       _docxService = docxService ?? QuarterlyDocxWriterService();

  @override
  PeriodType get periodType => PeriodType.quarterly;

  @override
  dynamic get chartService => _chartService;

  @override
  dynamic get docxService => _docxService;

  @override
  Future<QuarterlyReportContentModel> createReportContentModel({
    required Map<String, dynamic> periodData,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final aggregatedData = periodData['aggregatedData'] as Map<String, dynamic>;
    final summaryStats = periodData['summaryStats'] as Map<String, dynamic>;
    final aiAnalysis = periodData['aiAnalysis'] as Map<String, dynamic>;
    final comparisonData = periodData['comparisonData'] as Map<String, dynamic>;

    // 获取季度数据
    final periods = aggregatedData['periods'] as List<Map<String, dynamic>>;
    final currentQuarter = periods.isNotEmpty
        ? periods.last
        : <String, dynamic>{};

    // 计算季度信息
    final quarter = (startTime.month - 1) ~/ 3 + 1;

    String reportTime;
    if (startTime.month == endTime.month && startTime.year == endTime.year) {
      reportTime = '${startTime.year}年${startTime.month}月';
    } else {
      reportTime = '${startTime.year}年第$quarter季度';
    }

    // 获取部门统计数据
    final departmentStats =
        currentQuarter['departmentStats'] as List<DepartmentSalaryStats>? ?? [];

    // 获取薪资结构数据
    final salaryStructureData = _createSalaryStructureData(
      null,
    ); // 可以根据需要传入实际数据

    return QuarterlyReportContentModel(
      reportTitle: '季度工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime: reportTime,
      startTime: '${startTime.year}年${startTime.month}月',
      endTime: '${endTime.year}年${endTime.month}月',
      compareLast: comparisonData['periodOverPeriod']?.toString() ?? '',
      totalEmployees: summaryStats['totalEmployees'] as int? ?? 0,
      totalSalary: summaryStats['totalSalary'] as double? ?? 0.0,
      averageSalary: summaryStats['averageSalary'] as double? ?? 0.0,
      departmentCount: departmentStats.length,
      employeeCount: summaryStats['totalEmployees'] as int? ?? 0,
      employeeDetails: _generateEmployeeDetails(summaryStats),
      departmentDetails: _generateDepartmentDetails(departmentStats),
      salaryRangeDescription: _generateSalaryRangeDescription(
        currentQuarter['salaryRanges'] ?? [],
      ),
      salaryRangeFeatureSummary:
          aiAnalysis['salaryRangeFeatureSummary'] as String? ?? '薪资区间特征总结',
      departmentSalaryAnalysis:
          aiAnalysis['departmentSalaryAnalysis'] as String? ?? '部门工资分析',
      keySalaryPoint: aiAnalysis['keySalaryPoint'] as String? ?? '关键工资点',
      salaryRankings: _generateSalaryOrder(departmentStats),
      basicSalaryRate: 0.7,
      performanceSalaryRate: 0.3,
      salaryStructure: _generateSalaryStructureDescription(salaryStructureData),
      salaryStructureAdvice: '薪资结构优化建议',
      salaryStructureData: salaryStructureData,
      departmentStats: departmentStats,
    );
  }

  @override
  Future<QuarterlyReportChartImages> generateCharts({
    required GlobalKey previewContainerKey,
    required Map<String, dynamic> periodData,
    required List<dynamic> departmentStats,
  }) async {
    final aggregatedData = periodData['aggregatedData'] as Map<String, dynamic>;
    final periods = aggregatedData['periods'] as List<Map<String, dynamic>>;
    final currentQuarter = periods.isNotEmpty
        ? periods.last
        : <String, dynamic>{};

    // 处理薪资区间数据
    final salaryRanges =
        currentQuarter['salaryRanges'] as List<SalaryRangeStats>? ?? [];
    final salaryRangeChartData = salaryRanges
        .map((range) => {'range': range.range, 'count': range.employeeCount})
        .toList();

    // 处理薪资结构数据
    final salaryStructureData = _createSalaryStructureData(null);

    // 处理部门数据 - 转换为图表服务所需的 Map<String, int> 格式
    final departmentStatsMap = Map<String, int>.fromEntries(
      (currentQuarter['departmentStats'] as List<DepartmentSalaryStats>? ?? [])
          .map((dept) => MapEntry(dept.department, dept.employeeCount)),
    );

    return await _chartService.generateAllCharts(
      previewContainerKey: previewContainerKey,
      departmentStats: departmentStatsMap,
      salaryRanges: salaryRangeChartData,
      salaryStructureData: salaryStructureData,
    );
  }

  /// 创建薪资结构数据
  List<Map<String, dynamic>> _createSalaryStructureData(
    Map<String, dynamic>? salarySummary,
  ) {
    final salaryStructureData = <Map<String, dynamic>>[];

    if (salarySummary == null) return salaryStructureData;

    final structureFields = ['基本工资', '岗位工资', '绩效工资', '补贴工资', '饭补'];

    for (var key in structureFields) {
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
    }

    return salaryStructureData;
  }

  /// 生成员工详情描述
  String _generateEmployeeDetails(Map<String, dynamic> summaryStats) {
    final totalEmployees = summaryStats['totalEmployees'] as int? ?? 0;
    final averageSalary = summaryStats['averageSalary'] as double? ?? 0.0;
    final totalSalary = summaryStats['totalSalary'] as double? ?? 0.0;

    return '本季度共有员工 $totalEmployees 人，'
        '工资总额 ${totalSalary.toStringAsFixed(2)} 元，'
        '平均工资 ${averageSalary.toStringAsFixed(2)} 元';
  }

  /// 生成部门详情描述
  String _generateDepartmentDetails(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('本季度内共有${departmentStats.length}个部门：');

    for (final dept in departmentStats) {
      buffer.writeln(
        '- ${dept.department}部门：${dept.employeeCount}人，'
        '工资总额${dept.totalNetSalary.toStringAsFixed(2)}元，'
        '平均工资${dept.averageNetSalary.toStringAsFixed(2)}元',
      );
    }

    return buffer.toString();
  }

  /// 生成薪资区间描述
  String _generateSalaryRangeDescription(List<SalaryRangeStats> salaryRanges) {
    final buffer = StringBuffer();
    buffer.write('本季度薪资区间分布情况：');

    for (int i = 0; i < salaryRanges.length; i++) {
      final range = salaryRanges[i];

      if (i > 0) {
        buffer.write('；');
      }

      buffer.write(
        '${range.range}区间有${range.employeeCount}发薪人次，'
        '工资总额${range.totalSalary.toStringAsFixed(2)}元，'
        '平均工资${range.averageSalary.toStringAsFixed(2)}元',
      );
    }

    return buffer.toString();
  }

  /// 生成部门平均薪资排名描述
  String _generateSalaryOrder(List<DepartmentSalaryStats> departmentStats) {
    if (departmentStats.isEmpty) {
      return '暂无部门平均薪资排名数据';
    }

    // 按平均薪资从高到低排序部门
    final sortedDepartments = List<DepartmentSalaryStats>.from(departmentStats)
      ..sort((a, b) => b.averageNetSalary.compareTo(a.averageNetSalary));

    final buffer = StringBuffer();
    buffer.write('本季度部门平均薪资排名（从高到低）：');

    for (int i = 0; i < sortedDepartments.length; i++) {
      final dept = sortedDepartments[i];
      final rank = i + 1;

      if (i > 0) {
        buffer.write('；');
      }

      buffer.write(
        '第$rank名 ${dept.department}，平均薪资${dept.averageNetSalary.toStringAsFixed(2)}元',
      );

      // 添加与上一名的差距（从第二名开始）
      if (i > 0) {
        final prevDept = sortedDepartments[i - 1];
        final diff = prevDept.averageNetSalary - dept.averageNetSalary;
        final percentage = (diff / dept.averageNetSalary * 100).toStringAsFixed(
          2,
        );

        buffer.write('，比上一名低${diff.toStringAsFixed(2)}元（$percentage%）');
      }

      // 如果部门人数很少（少于5人），添加提示
      if (dept.employeeCount < 5) {
        buffer.write('（注：该部门仅有${dept.employeeCount}人，数据可能不具有统计意义）');
      }
    }

    return buffer.toString();
  }

  /// 生成薪资结构的自然语言描述
  String _generateSalaryStructureDescription(
    List<Map<String, dynamic>> salaryStructureData,
  ) {
    if (salaryStructureData.isEmpty) {
      return '暂无薪资结构数据。';
    }

    final buffer = StringBuffer();
    buffer.write('季度平均薪资结构分析如下：');

    // 按值排序，显示最重要的组成部分
    final sortedData = List<Map<String, dynamic>>.from(salaryStructureData);
    sortedData.sort(
      (a, b) => (b['value'] as double).compareTo(a['value'] as double),
    );

    for (int i = 0; i < sortedData.length; i++) {
      final item = sortedData[i];
      final category = item['category'] as String;
      final value = (item['value'] as double).toStringAsFixed(2);

      buffer.write('$category为$value元');

      if (i < sortedData.length - 1) {
        buffer.write('，');
      }
    }

    buffer.write('。');
    return buffer.toString();
  }
}
