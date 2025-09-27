// src/services/multi_year/enhanced_multi_year_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/services/base_multi_period_report_generator.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/multi_year/multi_year_report_models.dart';
import 'package:salary_report/src/services/multi_year/chart_generation_service.dart';
import 'package:salary_report/src/services/multi_year/docx_writer_service.dart';

/// 增强版多年度报告生成器 - 基于统一多期间框架
class EnhancedMultiYearReportGenerator extends BaseMultiPeriodReportGenerator {
  final MultiYearChartGenerationService _chartService;
  final MultiYearDocxWriterService _docxService;

  EnhancedMultiYearReportGenerator({
    MultiYearChartGenerationService? chartService,
    MultiYearDocxWriterService? docxService,
    super.analysisService,
    super.reportService,
    super.aiSummaryService,
  }) : _chartService = chartService ?? MultiYearChartGenerationService(),
       _docxService = docxService ?? MultiYearDocxWriterService();

  @override
  PeriodType get periodType => PeriodType.multiYear;

  @override
  dynamic get chartService => _chartService;

  @override
  dynamic get docxService => _docxService;

  @override
  Future<MultiYearReportContentModel> createReportContentModel({
    required Map<String, dynamic> periodData,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final aggregatedData = periodData['aggregatedData'] as Map<String, dynamic>;
    final summaryStats = periodData['summaryStats'] as Map<String, dynamic>;
    final aiAnalysis = periodData['aiAnalysis'] as Map<String, dynamic>;
    final comparisonData = periodData['comparisonData'] as Map<String, dynamic>;

    // 获取多年度数据
    final periods = aggregatedData['periods'] as List<Map<String, dynamic>>;
    final yearCount = aggregatedData['yearCount'] as int? ?? periods.length;

    String reportTime = '${startTime.year}年 - ${endTime.year}年';

    // 获取最后一年的部门统计数据
    final lastYearDepartmentStats = periods.isNotEmpty
        ? (periods.last['departmentStats'] as List<DepartmentSalaryStats>? ??
              [])
        : <DepartmentSalaryStats>[];

    // 聚合所有年度的部门统计数据
    final allDepartmentStats = <DepartmentSalaryStats>[];
    for (final period in periods) {
      final deptStats =
          period['departmentStats'] as List<DepartmentSalaryStats>? ?? [];
      allDepartmentStats.addAll(deptStats);
    }

    // 获取薪资结构数据
    final salaryStructureData = _createSalaryStructureData(null);

    return MultiYearReportContentModel(
      reportTitle: '多年度工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: '公司名称',
      reportTime: reportTime,
      startTime: '${startTime.year}年',
      endTime: '${endTime.year}年',
      compareLast: '多年度趋势分析',
      totalEmployees: summaryStats['totalEmployees'] as int? ?? 0,
      totalSalary: summaryStats['totalSalary'] as double? ?? 0.0,
      averageSalary: summaryStats['averageSalary'] as double? ?? 0.0,
      departmentCount: lastYearDepartmentStats.length,
      employeeCount: summaryStats['totalEmployees'] as int? ?? 0,
      employeeDetails: _generateEmployeeDetails(summaryStats),
      departmentDetails: _generateDepartmentDetails(lastYearDepartmentStats),
      salaryRangeDescription: _generateYearlyBreakdown(periods),
      salaryRangeFeatureSummary:
          aiAnalysis['salaryRangeFeatureSummary'] as String? ?? '薪资区间特征总结',
      departmentSalaryAnalysis:
          aiAnalysis['departmentSalaryAnalysis'] as String? ?? '部门工资分析',
      keySalaryPoint: aiAnalysis['keySalaryPoint'] as String? ?? '关键工资点',
      salaryRankings: _generateSalaryOrder(lastYearDepartmentStats),
      basicSalaryRate: 0.7,
      performanceSalaryRate: 0.3,
      salaryStructure: _generateSalaryStructureDescription(salaryStructureData),
      salaryStructureAdvice: '多年度薪资结构优化建议',
      salaryStructureData: salaryStructureData,
      departmentStats: allDepartmentStats,
    );
  }

  @override
  Future<MultiYearReportChartImages> generateCharts({
    required GlobalKey previewContainerKey,
    required Map<String, dynamic> periodData,
    required List<dynamic> departmentStats,
  }) async {
    final aggregatedData = periodData['aggregatedData'] as Map<String, dynamic>;
    final periods = aggregatedData['periods'] as List<Map<String, dynamic>>;

    // 处理薪资区间数据 - 取最后一年的数据
    final lastYear = periods.isNotEmpty ? periods.last : <String, dynamic>{};
    final salaryRanges =
        lastYear['salaryRanges'] as List<SalaryRangeStats>? ?? [];
    final salaryRangeChartData = salaryRanges
        .map((range) => {'range': range.range, 'count': range.employeeCount})
        .toList();

    // 生成年度趋势图表数据
    final employeeCountPerYear = periods
        .map(
          (y) => {
            'year': '${y['periodKey']}年',
            'employeeCount': y['employeeCount'] as int? ?? 0,
          },
        )
        .toList();

    final averageSalaryPerYear = periods
        .map(
          (y) => {
            'year': '${y['periodKey']}年',
            'averageSalary': y['averageSalary'] as double? ?? 0.0,
          },
        )
        .toList();

    final totalSalaryPerYear = periods
        .map(
          (y) => {
            'year': '${y['periodKey']}年',
            'totalSalary': y['totalSalary'] as double? ?? 0.0,
          },
        )
        .toList();

    final departmentDetailsPerYear = periods
        .map(
          (y) => {
            'year': '${y['periodKey']}年',
            'departments':
                (y['departmentStats'] as List<DepartmentSalaryStats>? ?? [])
                    .map(
                      (dept) => {
                        'department': dept.department,
                        'averageSalary': dept.averageNetSalary,
                      },
                    )
                    .toList(),
          },
        )
        .toList();

    return await _chartService.generateAllCharts(
      previewContainerKey: previewContainerKey,
      departmentStats: departmentStats as List<DepartmentSalaryStats>,
      salaryRanges: salaryRangeChartData,
      employeeCountPerYear: employeeCountPerYear,
      averageSalaryPerYear: averageSalaryPerYear,
      totalSalaryPerYear: totalSalaryPerYear,
      departmentDetailsPerYear: departmentDetailsPerYear,
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

    return '本多年度期间共有员工 $totalEmployees 人，'
        '工资总额 ${totalSalary.toStringAsFixed(2)} 元，'
        '平均工资 ${averageSalary.toStringAsFixed(2)} 元';
  }

  /// 生成部门详情描述
  String _generateDepartmentDetails(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('多年度期间各部门情况：');

    for (final dept in departmentStats) {
      buffer.writeln(
        '- ${dept.department}部门：${dept.employeeCount}人，'
        '工资总额${dept.totalNetSalary.toStringAsFixed(2)}元，'
        '平均工资${dept.averageNetSalary.toStringAsFixed(2)}元',
      );
    }

    return buffer.toString();
  }

  /// 生成年度分解描述
  String _generateYearlyBreakdown(List<Map<String, dynamic>> periods) {
    final buffer = StringBuffer();
    buffer.writeln('年度工资数据分解：');

    for (final period in periods) {
      final periodKey = period['periodKey'] as String? ?? '';
      final employeeCount = period['employeeCount'] as int? ?? 0;
      final totalSalary = period['totalSalary'] as double? ?? 0.0;
      final averageSalary = period['averageSalary'] as double? ?? 0.0;

      buffer.writeln(
        '- $periodKey：员工数 $employeeCount人，'
        '工资总额 ${totalSalary.toStringAsFixed(2)}元，'
        '平均工资 ${averageSalary.toStringAsFixed(2)}元',
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
    buffer.write('多年度期间部门平均薪资排名（从高到低）：');

    for (int i = 0; i < sortedDepartments.length; i++) {
      final dept = sortedDepartments[i];
      final rank = i + 1;

      if (i > 0) {
        buffer.write('；');
      }

      buffer.write(
        '第$rank名 ${dept.department}，平均薪资${dept.averageNetSalary.toStringAsFixed(2)}元',
      );
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
    buffer.write('多年度平均薪资结构分析如下：');

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
