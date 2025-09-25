// src/report/enhanced_multi_year_report_generator.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/services/multi_year/multi_year.dart';
import 'package:salary_report/src/services/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/services/ai_summary_service.dart';

/// 增强版多年度报告生成器
class EnhancedMultiYearReportGenerator implements EnhancedReportGenerator {
  final MultiYearChartGenerationService _chartService;
  final MultiYearChartGenerationFromJsonService _jsonChartService;
  final MultiYearDocxWriterService _docxService;
  final DataAnalysisService _analysisService;
  final ReportService _reportService;
  final AISummaryService _aiSummaryService;

  EnhancedMultiYearReportGenerator({
    MultiYearChartGenerationService? chartService,
    MultiYearChartGenerationFromJsonService? jsonChartService,
    MultiYearDocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
    AISummaryService? aiSummaryService,
  }) : _chartService = chartService ?? MultiYearChartGenerationService(),
       _jsonChartService =
           jsonChartService ?? MultiYearChartGenerationFromJsonService(),
       _docxService = docxService ?? MultiYearDocxWriterService(),
       _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService(),
       _aiSummaryService = aiSummaryService ?? AISummaryService();

  /// 生成包含描述和图表的增强版多年度报告
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
      logger.info('Starting enhanced multi-year salary report generation...');

      // 1. 生成JSON格式的分析数据
      final jsonString =
          MultiYearAnalysisJsonConverter.convertAnalysisDataToJson(
            comparisonData:
                analysisData['comparisonData'] as MultiYearComparisonData,
            attendanceStats: attendanceStats,
            startDate: startTime,
            endDate: endTime,
            departmentYearOverYearData:
                analysisData['departmentYoYData']
                    as List<Map<String, dynamic>>?,
          );

      // 2. 解析JSON数据
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // 3. 生成图表图像（从UI）
      // 准备薪资区间数据
      final salaryRanges = <Map<String, dynamic>>[];
      for (var yearlyData
          in (analysisData['comparisonData'] as MultiYearComparisonData)
              .yearlyComparisons) {
        for (var entry in yearlyData.salaryRangeStats.entries) {
          salaryRanges.add({
            'range': entry.key,
            'count': entry.value.employeeCount,
          });
        }
      }

      // 准备年度数据
      final employeeCountPerYear =
          (analysisData['comparisonData'] as MultiYearComparisonData)
              .yearlyComparisons
              .map(
                (y) => {'year': '${y.year}年', 'employeeCount': y.employeeCount},
              )
              .toList();

      final averageSalaryPerYear =
          (analysisData['comparisonData'] as MultiYearComparisonData)
              .yearlyComparisons
              .map(
                (y) => {'year': '${y.year}年', 'averageSalary': y.averageSalary},
              )
              .toList();

      final totalSalaryPerYear =
          (analysisData['comparisonData'] as MultiYearComparisonData)
              .yearlyComparisons
              .map((y) => {'year': '${y.year}年', 'totalSalary': y.totalSalary})
              .toList();

      final departmentDetailsPerYear =
          (analysisData['comparisonData'] as MultiYearComparisonData)
              .yearlyComparisons
              .map(
                (y) => {
                  'year': '${y.year}年',
                  'departments': y.departmentStats.entries
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
        employeeCountPerYear: employeeCountPerYear,
        averageSalaryPerYear: averageSalaryPerYear,
        totalSalaryPerYear: totalSalaryPerYear,
        departmentDetailsPerYear: departmentDetailsPerYear,
      );

      // 4. 生成图表图像（从JSON数据）
      // 注意：我们现在直接使用从UI生成的图表，不再使用从JSON生成的图表
      // 但保留此代码以便将来可能的扩展
      // final chartImagesFromJson = await _jsonChartService
      //     .generateAllChartsFromJson(jsonData: jsonData);

      // 5. 创建组合图表图像集合
      final combinedChartImages = MultiYearReportChartImages(
        mainChart: chartImagesFromUI.mainChart,
        departmentDetailsChart: chartImagesFromUI.departmentDetailsChart,
        salaryRangeChart: chartImagesFromUI.salaryRangeChart,
        salaryStructureChart: chartImagesFromUI.salaryStructureChart,
        employeeCountPerYearChart: chartImagesFromUI.employeeCountPerYearChart,
        averageSalaryPerYearChart: chartImagesFromUI.averageSalaryPerYearChart,
        totalSalaryPerYearChart: chartImagesFromUI.totalSalaryPerYearChart,
        departmentDetailsPerYearChart:
            chartImagesFromUI.departmentDetailsPerYearChart,
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
        'Enhanced multi-year report generation complete: $reportPath',
      );

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe(
        'Fatal error during enhanced multi-year report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 创建报告内容模型
  Future<MultiYearReportContentModel> _createReportContentModel(
    Map<String, dynamic> jsonData,
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // 从JSON数据中提取关键信息来构建报告内容模型
    final keyMetrics = jsonData['key_metrics'] as Map<String, dynamic>;
    final comparisonData =
        analysisData['comparisonData'] as MultiYearComparisonData;

    // 生成年度趋势分析
    final yearlyTrendAnalysis = await _aiSummaryService
        .generateYearlyTrendAnalysis(comparisonData.yearlyComparisons);

    // 获取部门统计数据用于分析
    final deptStatsForAnalysis = <DepartmentSalaryStats>[];
    for (var yearlyData in comparisonData.yearlyComparisons) {
      deptStatsForAnalysis.addAll(yearlyData.departmentStats.values);
    }

    // 生成部门对比分析
    final departmentComparisonAnalysis = await _aiSummaryService
        .generateDepartmentComparisonAnalysis(deptStatsForAnalysis);

    // 生成年度同比分析
    final yearOverYearAnalysis = await _aiSummaryService
        .generateYearOverYearAnalysis(comparisonData.yearlyComparisons);

    // 构建薪资区间数据
    final salaryRanges = <Map<String, int>>[];
    for (var yearlyData in comparisonData.yearlyComparisons) {
      final rangeMap = <String, int>{};
      for (var entry in yearlyData.salaryRangeStats.entries) {
        rangeMap[entry.key] = entry.value.employeeCount;
      }
      if (rangeMap.isNotEmpty) {
        salaryRanges.add(rangeMap);
      }
    }

    // 获取部门统计数据
    final departmentStatsList = <DepartmentSalaryStats>[];
    for (var yearlyData in comparisonData.yearlyComparisons) {
      departmentStatsList.addAll(yearlyData.departmentStats.values);
    }

    // 生成薪资区间分析
    final salaryRangeAnalysis = await _aiSummaryService
        .generateSalaryRangeFeatureSummary(salaryRanges, departmentStatsList);

    // 生成多年度结论和建议
    final conclusionsAndRecommendations = await _aiSummaryService.getAnswer('''
请基于以下多年度工资数据分析，提供综合结论和优化建议：

年度趋势分析：$yearlyTrendAnalysis
部门对比分析：$departmentComparisonAnalysis
同比分析：$yearOverYearAnalysis
薪资区间分析：$salaryRangeAnalysis

请提供一段关于多年度薪资数据的综合结论，以及针对性的优化建议。要求语言严谨、简洁，体现报告风格。
      ''');

    return MultiYearReportContentModel(
      reportTitle: '多年度工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      startTime: '${startTime.year}年',
      endTime: '${endTime.year}年',
      compareLast: '上年度',
      totalEmployees: keyMetrics['total_employees'] as int,
      employeeCount: keyMetrics['total_employees'] as int,
      // averageEmployees 参数已移除
      totalSalary: (keyMetrics['total_salary'] as num).toDouble(),
      averageSalary: (keyMetrics['average_salary'] as num).toDouble(),
      departmentCount: departmentStatsList
          .map((e) => e.department)
          .toSet()
          .length,
      employeeDetails: '多年度员工详情',
      departmentDetails: _generateDepartmentBreakdown(comparisonData),
      salaryRangeDescription: _generateYearlyBreakdown(comparisonData),
      salaryRangeFeatureSummary: salaryRangeAnalysis,
      departmentSalaryAnalysis: departmentComparisonAnalysis,
      keySalaryPoint: yearlyTrendAnalysis,
      salaryRankings: yearOverYearAnalysis,
      basicSalaryRate: 0.7, // 假设基本工资占比
      performanceSalaryRate: 0.3, // 假设绩效工资占比
      salaryStructure: yearOverYearAnalysis,
      salaryStructureAdvice: conclusionsAndRecommendations,
      salaryStructureData: [], // 可以添加工资结构数据
      departmentStats: departmentStatsList,
    );
  }

  /// 生成年度分解描述
  String _generateYearlyBreakdown(MultiYearComparisonData comparisonData) {
    final buffer = StringBuffer();
    buffer.writeln('年度工资数据分解：');

    for (var yearData in comparisonData.yearlyComparisons) {
      buffer.writeln(
        '- ${yearData.year}年：员工数 ${yearData.employeeCount}人，'
        '工资总额 ${yearData.totalSalary.toStringAsFixed(2)}元，'
        '平均工资 ${yearData.averageSalary.toStringAsFixed(2)}元',
      );
    }

    return buffer.toString();
  }

  /// 生成部门分解描述
  String _generateDepartmentBreakdown(MultiYearComparisonData comparisonData) {
    final buffer = StringBuffer();
    buffer.writeln('部门工资数据分解：');

    // 从年度数据中提取部门信息
    final departmentMap = <String, Map<String, dynamic>>{};

    for (var yearData in comparisonData.yearlyComparisons) {
      for (var entry in yearData.departmentStats.entries) {
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
        '- $deptName部门：平均员工数 $avgEmployeeCount人，'
        '平均工资总额 ${avgTotalSalary.toStringAsFixed(2)}元，'
        '平均工资 ${avgSalary.toStringAsFixed(2)}元',
      );
    }

    return buffer.toString();
  }
}
