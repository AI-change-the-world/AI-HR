// src/report/enhanced_multi_quarter_report_generator.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/services/multi_quarter/multi_quarter.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';
import 'package:salary_report/src/services/multi_quarter/multi_quarter_analysis_json_converter.dart';

/// 增强版多季度报告生成器
class EnhancedMultiQuarterReportGenerator implements EnhancedReportGenerator {
  final MultiQuarterChartGenerationService _chartService;
  final MultiQuarterChartGenerationFromJsonService _jsonChartService;
  final MultiQuarterDocxWriterService _docxService;
  final DataAnalysisService _analysisService;
  final ReportService _reportService;
  final AISummaryService _aiSummaryService;

  EnhancedMultiQuarterReportGenerator({
    MultiQuarterChartGenerationService? chartService,
    MultiQuarterChartGenerationFromJsonService? jsonChartService,
    MultiQuarterDocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
    AISummaryService? aiSummaryService,
  }) : _chartService = chartService ?? MultiQuarterChartGenerationService(),
       _jsonChartService =
           jsonChartService ?? MultiQuarterChartGenerationFromJsonService(),
       _docxService = docxService ?? MultiQuarterDocxWriterService(),
       _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService(),
       _aiSummaryService = aiSummaryService ?? AISummaryService();

  /// 生成包含描述和图表的增强版多季度报告
  @override
  Future<String> generateEnhancedReport({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
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
      logger.info(
        'Starting enhanced multi-quarter salary report generation...',
      );

      // 1. 生成JSON格式的分析数据
      final jsonString =
          MultiQuarterAnalysisJsonConverter.convertAnalysisDataToJson(
            comparisonData:
                analysisData['comparisonData'] as MultiQuarterComparisonData,
            attendanceStats: attendanceStats,
            startDate: startTime,
            endDate: endTime,
            departmentQuarterOverQuarterData:
                analysisData['departmentQoQData']
                    as List<Map<String, dynamic>>?,
            departmentYearOverYearData:
                analysisData['departmentYoYData']
                    as List<Map<String, dynamic>>?,
          );

      // 2. 解析JSON数据
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // 3. 生成图表图像（从UI）
      // 准备薪资区间数据
      final salaryRanges = <Map<String, dynamic>>[];
      for (var quarterlyData
          in (analysisData['comparisonData'] as MultiQuarterComparisonData)
              .quarterlyComparisons) {
        for (var entry in quarterlyData.salaryRangeStats.entries) {
          salaryRanges.add({
            'range': entry.key,
            'count': entry.value.employeeCount,
          });
        }
      }

      // 准备季度数据
      final employeeCountPerQuarter =
          (analysisData['comparisonData'] as MultiQuarterComparisonData)
              .quarterlyComparisons
              .map(
                (q) => {
                  'quarter': '${q.year}年第${q.quarter}季度',
                  'employeeCount': q.employeeCount,
                },
              )
              .toList();

      final averageSalaryPerQuarter =
          (analysisData['comparisonData'] as MultiQuarterComparisonData)
              .quarterlyComparisons
              .map(
                (q) => {
                  'quarter': '${q.year}年第${q.quarter}季度',
                  'averageSalary': q.averageSalary,
                },
              )
              .toList();

      final totalSalaryPerQuarter =
          (analysisData['comparisonData'] as MultiQuarterComparisonData)
              .quarterlyComparisons
              .map(
                (q) => {
                  'quarter': '${q.year}年第${q.quarter}季度',
                  'totalSalary': q.totalSalary,
                },
              )
              .toList();

      final departmentDetailsPerQuarter =
          (analysisData['comparisonData'] as MultiQuarterComparisonData)
              .quarterlyComparisons
              .map(
                (q) => {
                  'quarter': '${q.year}年第${q.quarter}季度',
                  'departments': q.departmentStats.entries
                      .map(
                        (e) => {
                          'department': e.key,
                          'averageSalary': e.value.averageNetSalary,
                        },
                      )
                      .toList(),
                },
              )
              .toList();

      final chartImagesFromUI = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: salaryRanges,
        employeeCountPerQuarter: employeeCountPerQuarter,
        averageSalaryPerQuarter: averageSalaryPerQuarter,
        totalSalaryPerQuarter: totalSalaryPerQuarter,
        departmentDetailsPerQuarter: departmentDetailsPerQuarter,
      );

      // 4. 生成图表图像（从JSON数据）
      // 注意：我们现在直接使用从UI生成的图表，不再使用从JSON生成的图表
      // 但保留此代码以便将来可能的扩展
      // final chartImagesFromJson = await _jsonChartService
      //     .generateAllChartsFromJson(jsonData: jsonData);

      // 5. 创建组合图表图像集合
      final combinedChartImages = MultiQuarterReportChartImages(
        mainChart: chartImagesFromUI.mainChart,
        departmentDetailsChart: chartImagesFromUI.departmentDetailsChart,
        salaryRangeChart: chartImagesFromUI.salaryRangeChart,
        salaryStructureChart: chartImagesFromUI.salaryStructureChart,
        employeeCountPerQuarterChart:
            chartImagesFromUI.employeeCountPerQuarterChart,
        averageSalaryPerQuarterChart:
            chartImagesFromUI.averageSalaryPerQuarterChart,
        totalSalaryPerQuarterChart:
            chartImagesFromUI.totalSalaryPerQuarterChart,
        departmentDetailsPerQuarterChart:
            chartImagesFromUI.departmentDetailsPerQuarterChart,
      );

      // 6. 创建报告内容模型
      final reportContent = await _createReportContentModel(
        jsonData,
        analysisData,
        startTime,
        endTime,
      );

      // 7. 写入报告文件
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: combinedChartImages,
      );

      // 8. 添加报告记录到数据库
      await _reportService.addReportRecord(reportPath);

      logger.info(
        'Enhanced multi-quarter report generation complete: $reportPath',
      );

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe(
        'Fatal error during enhanced multi-quarter report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 创建报告内容模型
  Future<MultiQuarterReportContentModel> _createReportContentModel(
    Map<String, dynamic> jsonData,
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // 从JSON数据中提取关键信息来构建报告内容模型
    final keyMetrics = jsonData['key_metrics'] as Map<String, dynamic>;
    final comparisonData =
        analysisData['comparisonData'] as MultiQuarterComparisonData;

    // 生成季度趋势分析
    final quarterlyTrendAnalysis = await _aiSummaryService
        .generateQuarterlyTrendAnalysis(comparisonData.quarterlyComparisons);

    // 获取部门统计数据用于分析
    final deptStatsForAnalysis = <DepartmentSalaryStats>[];
    for (var quarterlyData in comparisonData.quarterlyComparisons) {
      deptStatsForAnalysis.addAll(quarterlyData.departmentStats.values);
    }

    // 生成部门对比分析
    final departmentComparisonAnalysis = await _aiSummaryService
        .generateDepartmentComparisonAnalysis(deptStatsForAnalysis);

    // 生成季度环比分析
    final quarterOverQuarterAnalysis = await _aiSummaryService
        .generateQuarterOverQuarterAnalysis(
          comparisonData.quarterlyComparisons,
        );

    // 生成季度同比分析
    final yearOverYearAnalysis = await _aiSummaryService
        .generateYearOverYearAnalysis(comparisonData.quarterlyComparisons);

    // 构建薪资区间数据
    final salaryRanges = <Map<String, int>>[];
    for (var quarterlyData in comparisonData.quarterlyComparisons) {
      final rangeMap = <String, int>{};
      for (var entry in quarterlyData.salaryRangeStats.entries) {
        rangeMap[entry.key] = entry.value.employeeCount;
      }
      if (rangeMap.isNotEmpty) {
        salaryRanges.add(rangeMap);
      }
    }

    // 获取部门统计数据
    final departmentStatsList = <DepartmentSalaryStats>[];
    for (var quarterlyData in comparisonData.quarterlyComparisons) {
      departmentStatsList.addAll(quarterlyData.departmentStats.values);
    }

    // 生成薪资区间分析
    final salaryRangeAnalysis = await _aiSummaryService
        .generateSalaryRangeFeatureSummary(salaryRanges, departmentStatsList);

    // 生成多季度结论和建议
    final conclusionsAndRecommendations = await _aiSummaryService.getAnswer('''
请基于以下多季度工资数据分析，提供综合结论和优化建议：

季度趋势分析：${quarterlyTrendAnalysis}
部门对比分析：${departmentComparisonAnalysis}
环比分析：${quarterOverQuarterAnalysis}
同比分析：${yearOverYearAnalysis}
薪资区间分析：${salaryRangeAnalysis}

请提供一段关于多季度薪资数据的综合结论，以及针对性的优化建议。要求语言严谨、简洁，体现报告风格。
      ''');

    return MultiQuarterReportContentModel(
      reportTitle: '多季度工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      startTime: '${startTime.year}年${startTime.month}月',
      endTime: '${endTime.year}年${endTime.month}月',
      compareLast: '上季度',
      totalEmployees: keyMetrics['total_employees'] as int,
      employeeCount: keyMetrics['total_employees'] as int,
      // averageEmployees 参数已移除
      totalSalary: (keyMetrics['total_salary'] as num).toDouble(),
      averageSalary: (keyMetrics['average_salary'] as num).toDouble(),
      departmentCount: departmentStatsList
          .map((e) => e.department)
          .toSet()
          .length,
      employeeDetails: '多季度员工详情',
      departmentDetails: _generateDepartmentBreakdown(comparisonData),
      salaryRangeDescription: _generateQuarterlyBreakdown(comparisonData),
      salaryRangeFeatureSummary: salaryRangeAnalysis,
      departmentSalaryAnalysis: departmentComparisonAnalysis,
      keySalaryPoint: quarterlyTrendAnalysis,
      salaryRankings: quarterOverQuarterAnalysis,
      basicSalaryRate: 0.7, // 假设基本工资占比
      performanceSalaryRate: 0.3, // 假设绩效工资占比
      salaryStructure: yearOverYearAnalysis,
      salaryStructureAdvice: conclusionsAndRecommendations,
      salaryStructureData: [], // 可以添加工资结构数据
      departmentStats: departmentStatsList,
      employeeCountPerQuarter: comparisonData.quarterlyComparisons
          .map(
            (q) => {
              'quarter': '${q.year}年第${q.quarter}季度',
              'count': q.employeeCount,
            },
          )
          .toList(),
      averageSalaryPerQuarter: comparisonData.quarterlyComparisons
          .map(
            (q) => {
              'quarter': '${q.year}年第${q.quarter}季度',
              'average': q.averageSalary,
            },
          )
          .toList(),
      totalSalaryPerQuarter: comparisonData.quarterlyComparisons
          .map(
            (q) => {
              'quarter': '${q.year}年第${q.quarter}季度',
              'total': q.totalSalary,
            },
          )
          .toList(),
      departmentDetailsPerQuarter: comparisonData.quarterlyComparisons
          .map(
            (q) => {
              'quarter': '${q.year}年第${q.quarter}季度',
              'departments': q.departmentStats.map(
                (k, v) => MapEntry(k, v.averageNetSalary),
              ),
            },
          )
          .toList(),
    );
  }

  /// 生成季度分解描述
  String _generateQuarterlyBreakdown(
    MultiQuarterComparisonData comparisonData,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('季度工资数据分解：');

    for (var quarterData in comparisonData.quarterlyComparisons) {
      buffer.writeln(
        '- ${quarterData.year}年第${quarterData.quarter}季度：员工数 ${quarterData.employeeCount}人，'
        '工资总额 ${quarterData.totalSalary.toStringAsFixed(2)}元，'
        '平均工资 ${quarterData.averageSalary.toStringAsFixed(2)}元',
      );
    }

    return buffer.toString();
  }

  /// 生成部门分解描述
  String _generateDepartmentBreakdown(
    MultiQuarterComparisonData comparisonData,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('部门工资数据分解：');

    // 从季度数据中提取部门信息
    final departmentMap = <String, Map<String, dynamic>>{};

    for (var quarterData in comparisonData.quarterlyComparisons) {
      for (var entry in quarterData.departmentStats.entries) {
        final deptName = entry.key;
        final deptStat = entry.value;

        if (departmentMap.containsKey(deptName)) {
          final existingData = departmentMap[deptName]!;
          existingData['employeeCount'] =
              (existingData['employeeCount'] as int) + deptStat.employeeCount;
          existingData['totalSalary'] =
              (existingData['totalSalary'] as double) + deptStat.totalNetSalary;
          existingData['count'] = (existingData['count'] as int) + 1;
        } else {
          departmentMap[deptName] = {
            'employeeCount': deptStat.employeeCount,
            'totalSalary': deptStat.totalNetSalary,
            'count': 1,
          };
        }
      }
    }

    // 计算平均值并生成描述
    for (var entry in departmentMap.entries) {
      final deptName = entry.key;
      final data = entry.value;
      final avgEmployeeCount =
          (data['employeeCount'] as int) ~/ (data['count'] as int);
      final avgTotalSalary =
          (data['totalSalary'] as double) / (data['count'] as int);
      final avgSalary = avgEmployeeCount > 0
          ? avgTotalSalary / avgEmployeeCount
          : 0.0;

      buffer.writeln(
        '- ${deptName}部门：平均员工数 ${avgEmployeeCount}人，'
        '平均工资总额 ${avgTotalSalary.toStringAsFixed(2)}元，'
        '平均工资 ${avgSalary.toStringAsFixed(2)}元',
      );
    }

    return buffer.toString();
  }
}
