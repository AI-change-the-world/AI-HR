// src/services/multi_quarter/enhanced_multi_quarter_report_generator.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/services/multi_quarter/multi_quarter.dart';
import 'package:salary_report/src/services/ai_summary_service.dart';
import 'package:salary_report/src/services/base_multi_period_report_generator.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 增强版多季度报告生成器 - 基于统一多期间框架
class EnhancedMultiQuarterReportGenerator
    extends BaseMultiPeriodReportGenerator {
  final MultiQuarterChartGenerationService _chartService;
  final MultiQuarterDocxWriterService _docxService;

  EnhancedMultiQuarterReportGenerator({
    MultiQuarterChartGenerationService? chartService,
    MultiQuarterDocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
    AISummaryService? aiSummaryService,
  }) : _chartService = chartService ?? MultiQuarterChartGenerationService(),
       _docxService = docxService ?? MultiQuarterDocxWriterService(),
       super(
         analysisService: analysisService,
         reportService: reportService,
         aiSummaryService: aiSummaryService,
       );

  @override
  PeriodType get periodType => PeriodType.multiQuarter;

  @override
  dynamic get chartService => _chartService;

  @override
  dynamic get docxService => _docxService;

  @override
  Future<MultiQuarterReportContentModel> createReportContentModel({
    required Map<String, dynamic> periodData,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final aggregatedData = periodData['aggregatedData'] as Map<String, dynamic>;
    final summaryStats = periodData['summaryStats'] as Map<String, dynamic>;
    final aiAnalysis = periodData['aiAnalysis'] as Map<String, dynamic>;
    final comparisonData = periodData['comparisonData'] as Map<String, dynamic>;

    // 获取多季度数据
    final periods = aggregatedData['periods'] as List<Map<String, dynamic>>;
    final quarterCount =
        aggregatedData['quarterCount'] as int? ?? periods.length;

    String reportTime =
        '${startTime.year}年${startTime.month}月 - ${endTime.year}年${endTime.month}月';

    // 获取最后一个季度的部门统计数据
    final lastQuarterDepartmentStats = periods.isNotEmpty
        ? (periods.last['departmentStats'] as List<DepartmentSalaryStats>? ??
              [])
        : <DepartmentSalaryStats>[];

    // 聚合所有季度的部门统计数据
    final allDepartmentStats = <DepartmentSalaryStats>[];
    for (final period in periods) {
      final deptStats =
          period['departmentStats'] as List<DepartmentSalaryStats>? ?? [];
      allDepartmentStats.addAll(deptStats);
    }

    // 获取薪资结构数据
    final salaryStructureData = _createSalaryStructureData(null);

    return MultiQuarterReportContentModel(
      reportTitle: '多季度工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime: reportTime,
      startTime: '${startTime.year}年${startTime.month}月',
      endTime: '${endTime.year}年${endTime.month}月',
      compareLast: '多季度趋势分析',
      totalEmployees: summaryStats['totalEmployees'] as int? ?? 0,
      totalSalary: summaryStats['totalSalary'] as double? ?? 0.0,
      averageSalary: summaryStats['averageSalary'] as double? ?? 0.0,
      departmentCount: lastQuarterDepartmentStats.length,
      employeeCount: summaryStats['totalEmployees'] as int? ?? 0,
      employeeDetails: _generateEmployeeDetails(summaryStats),
      departmentDetails: _generateDepartmentDetails(lastQuarterDepartmentStats),
      salaryRangeDescription: _generateQuarterlyBreakdown(periods),
      salaryRangeFeatureSummary:
          aiAnalysis['salaryRangeFeatureSummary'] as String? ?? '薪资区间特征总结',
      departmentSalaryAnalysis:
          aiAnalysis['departmentSalaryAnalysis'] as String? ?? '部门工资分析',
      keySalaryPoint: aiAnalysis['keySalaryPoint'] as String? ?? '关键工资点',
      salaryRankings: _generateSalaryOrder(lastQuarterDepartmentStats),
      basicSalaryRate: 0.7,
      performanceSalaryRate: 0.3,
      salaryStructure: _generateSalaryStructureDescription(salaryStructureData),
      salaryStructureAdvice: '多季度薪资结构优化建议',
      salaryStructureData: salaryStructureData,
      departmentStats: allDepartmentStats,
      // 多季度专用字段
      employeeCountPerQuarter: periods
          .map(
            (q) => {
              'quarter': q['periodKey'] as String? ?? '',
              'count': q['employeeCount'] as int? ?? 0,
            },
          )
          .toList(),
      averageSalaryPerQuarter: periods
          .map(
            (q) => {
              'quarter': q['periodKey'] as String? ?? '',
              'average': q['averageSalary'] as double? ?? 0.0,
            },
          )
          .toList(),
      totalSalaryPerQuarter: periods
          .map(
            (q) => {
              'quarter': q['periodKey'] as String? ?? '',
              'total': q['totalSalary'] as double? ?? 0.0,
            },
          )
          .toList(),
      departmentDetailsPerQuarter: periods
          .map(
            (q) => {
              'quarter': q['periodKey'] as String? ?? '',
              'departments':
                  (q['departmentStats'] as List<DepartmentSalaryStats>? ?? [])
                      .asMap()
                      .map(
                        (index, dept) =>
                            MapEntry(dept.department, dept.averageNetSalary),
                      ),
            },
          )
          .toList(),
    );
  }

  @override
  Future<MultiQuarterReportChartImages> generateCharts({
    required GlobalKey previewContainerKey,
    required Map<String, dynamic> periodData,
    required List<dynamic> departmentStats,
  }) async {
    final aggregatedData = periodData['aggregatedData'] as Map<String, dynamic>;
    final periods = aggregatedData['periods'] as List<Map<String, dynamic>>;

    // 处理薪资区间数据 - 取最后一个季度的数据
    final lastQuarter = periods.isNotEmpty ? periods.last : <String, dynamic>{};
    final salaryRanges =
        lastQuarter['salaryRanges'] as List<SalaryRangeStats>? ?? [];
    final salaryRangeChartData = salaryRanges
        .map((range) => {'range': range.range, 'count': range.employeeCount})
        .toList();

    // 处理部门数据 - 转换为图表服务所需的格式
    final lastQuarterDeptStats =
        lastQuarter['departmentStats'] as List<DepartmentSalaryStats>? ?? [];
    final departmentStatsForChart = lastQuarterDeptStats
        .map((dept) => dept)
        .toList();

    // 处理薪资结构数据
    final salaryStructureData = _createSalaryStructureData(null);

    // 生成季度趋势图表数据
    final employeeCountPerQuarter = periods
        .map(
          (q) => {
            'quarter': q['periodKey'] as String? ?? '',
            'employeeCount': q['employeeCount'] as int? ?? 0,
          },
        )
        .toList();

    final averageSalaryPerQuarter = periods
        .map(
          (q) => {
            'quarter': q['periodKey'] as String? ?? '',
            'averageSalary': q['averageSalary'] as double? ?? 0.0,
          },
        )
        .toList();

    final totalSalaryPerQuarter = periods
        .map(
          (q) => {
            'quarter': q['periodKey'] as String? ?? '',
            'totalSalary': q['totalSalary'] as double? ?? 0.0,
          },
        )
        .toList();

    final departmentDetailsPerQuarter = periods
        .map(
          (q) => {
            'quarter': q['periodKey'] as String? ?? '',
            'departments':
                (q['departmentStats'] as List<DepartmentSalaryStats>? ?? [])
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
      departmentStats: departmentStatsForChart,
      salaryRanges: salaryRangeChartData,
      salaryStructureData: salaryStructureData,
      employeeCountPerQuarter: employeeCountPerQuarter,
      averageSalaryPerQuarter: averageSalaryPerQuarter,
      totalSalaryPerQuarter: totalSalaryPerQuarter,
      departmentDetailsPerQuarter: departmentDetailsPerQuarter,
    );
  }

  /// 创建薪资结构数据
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

  /// 生成员工详情描述
  String _generateEmployeeDetails(Map<String, dynamic> summaryStats) {
    final totalEmployees = summaryStats['totalEmployees'] as int? ?? 0;
    final averageSalary = summaryStats['averageSalary'] as double? ?? 0.0;
    final totalSalary = summaryStats['totalSalary'] as double? ?? 0.0;

    return '本多季度期间共有员工 $totalEmployees 人，'
        '工资总额 ${totalSalary.toStringAsFixed(2)} 元，'
        '平均工资 ${averageSalary.toStringAsFixed(2)} 元';
  }

  /// 生成部门详情描述
  String _generateDepartmentDetails(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('多季度期间各部门情况：');

    for (final dept in departmentStats) {
      buffer.writeln(
        '- ${dept.department}部门：${dept.employeeCount}人，'
        '工资总额${dept.totalNetSalary.toStringAsFixed(2)}元，'
        '平均工资${dept.averageNetSalary.toStringAsFixed(2)}元',
      );
    }

    return buffer.toString();
  }

  /// 生成季度分解描述
  String _generateQuarterlyBreakdown(List<Map<String, dynamic>> periods) {
    final buffer = StringBuffer();
    buffer.writeln('季度工资数据分解：');

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
    buffer.write('多季度期间部门平均薪资排名（从高到低）：');

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
    buffer.write('多季度平均薪资结构分析如下：');

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
