// src/report/enhanced_multi_month_report_generator.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/services/multi_month/multi_month.dart';
import 'package:salary_report/src/services/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/services/ai_summary_service.dart';

/// 增强版多月报告生成器
class EnhancedMultiMonthReportGenerator implements EnhancedReportGenerator {
  final MultiMonthChartGenerationService _chartService;
  final MultiMonthChartGenerationFromJsonService _jsonChartService;
  final MultiMonthDocxWriterService _docxService;
  final DataAnalysisService _analysisService;
  final ReportService _reportService;
  final AISummaryService _aiSummaryService;

  EnhancedMultiMonthReportGenerator({
    MultiMonthChartGenerationService? chartService,
    MultiMonthChartGenerationFromJsonService? jsonChartService,
    MultiMonthDocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
    AISummaryService? aiSummaryService,
  }) : _chartService = chartService ?? MultiMonthChartGenerationService(),
       _jsonChartService =
           jsonChartService ?? MultiMonthChartGenerationFromJsonService(),
       _docxService = docxService ?? MultiMonthDocxWriterService(),
       _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService(),
       _aiSummaryService = aiSummaryService ?? AISummaryService();

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
      logger.info('Starting enhanced multi-month salary report generation...');

      // 1. 生成JSON格式的分析数据
      // 需要将analysisData转换为MultiMonthComparisonData
      final multiMonthComparisonData = _convertToMultiMonthComparisonData(
        analysisData,
      );

      final jsonString =
          MultiMonthAnalysisJsonConverter.convertAnalysisDataToJson(
            comparisonData: multiMonthComparisonData,
            attendanceStats: attendanceStats,
            startDate: startTime,
            endDate: endTime,
            // 添加同比环比数据
            departmentMonthOverMonthData:
                analysisData['departmentMonthOverMonthData']
                    as List<Map<String, dynamic>>? ??
                [],
            departmentYearOverYearData:
                analysisData['departmentYearOverYearData']
                    as List<Map<String, dynamic>>? ??
                [],
            positionMonthOverMonthData:
                analysisData['positionMonthOverMonthData']
                    as List<Map<String, dynamic>>? ??
                [],
            positionYearOverYearData:
                analysisData['positionYearOverYearData']
                    as List<Map<String, dynamic>>? ??
                [],
          );

      // 2. 解析JSON数据
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // 3. 生成自然语言报告
      final naturalLanguageReport =
          MultiMonthAnalysisJsonConverter.generateMultiMonthNaturalLanguageReport(
            comparisonData: multiMonthComparisonData,
            attendanceStats: attendanceStats,
            startDate: startTime,
            endDate: endTime,
          );

      // 可以将自然语言报告保存到文件或用于其他用途
      logger.info('Generated natural language report: $naturalLanguageReport');

      logger.info('salarySummary: ${analysisData['salarySummary']}');

      // 4. 构建薪资结构数据
      final salaryStructureData = _createSalaryStructureData(
        analysisData.containsKey('salarySummary')
            ? analysisData['salarySummary'] as Map<String, dynamic>
            : null,
      );

      logger.info(
        'analysisData["salaryRanges"] data: ${_getAggregatedSalaryRanges(analysisData).runtimeType}',
      );

      // 4. 获取多月图表数据
      final employeeCountPerMonth =
          analysisData['employeeCountPerMonth']
              as List<Map<String, dynamic>>? ??
          [];
      final averageSalaryPerMonth =
          analysisData['averageSalaryPerMonth']
              as List<Map<String, dynamic>>? ??
          [];
      final totalSalaryPerMonth =
          analysisData['totalSalaryPerMonth'] as List<Map<String, dynamic>>? ??
          [];
      final departmentDetailsPerMonth = _getDepartmentDetailsPerMonth(
        analysisData,
      );
      final lastMonthDepartmentStats = _getLastMonthDepartmentStats(
        analysisData,
      );

      // 5. 生成图表图像（从UI）
      final chartImagesFromUI = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: _convertToSalaryRangeMap(
          _getAggregatedSalaryRanges(analysisData),
        ),
        salaryStructureData: salaryStructureData,
        // 多月报告专用图表数据
        employeeCountPerMonth: employeeCountPerMonth,
        averageSalaryPerMonth: averageSalaryPerMonth,
        totalSalaryPerMonth: totalSalaryPerMonth,
        departmentDetailsPerMonth: departmentDetailsPerMonth,
        lastMonthDepartmentStats: lastMonthDepartmentStats,
      );

      // 6. 生成图表图像（从JSON数据）
      final chartImagesFromJson = await _jsonChartService
          .generateAllChartsFromJson(jsonData: jsonData);

      // 7. 创建组合图表图像集合
      final combinedChartImages = MultiMonthReportChartImages(
        mainChart: chartImagesFromUI.mainChart,
        departmentDetailsChart: chartImagesFromJson.departmentChart,
        salaryRangeChart: chartImagesFromJson.salaryRangeChart,
        salaryStructureChart: chartImagesFromUI.salaryStructureChart, // 薪资结构饼图
        employeeCountPerMonthChart:
            chartImagesFromUI.employeeCountPerMonthChart,
        averageSalaryPerMonthChart:
            chartImagesFromUI.averageSalaryPerMonthChart,
        totalSalaryPerMonthChart: chartImagesFromUI.totalSalaryPerMonthChart,
        departmentDetailsPerMonthChart:
            chartImagesFromUI.departmentDetailsPerMonthChart,
        // 新增同比环比对比图表
        departmentMonthOverMonthChart:
            chartImagesFromJson.departmentMonthOverMonthChart,
        departmentYearOverYearChart:
            chartImagesFromJson.departmentYearOverYearChart,
        positionMonthOverMonthChart:
            chartImagesFromJson.positionMonthOverMonthChart,
        positionYearOverYearChart:
            chartImagesFromJson.positionYearOverYearChart,
      );

      logger.info('analysisData analysisData analysisData: $analysisData');

      // 7. 创建报告内容模型
      final reportContent = await _createReportContentModel(
        jsonData,
        analysisData,
        startTime,
        endTime,
      );

      // 8. 写入报告文件
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: combinedChartImages,
      );

      // 9. 添加报告记录到数据库
      await _reportService.addReportRecord(reportPath);

      logger.info(
        'Enhanced multi-month report generation complete: $reportPath',
      );

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe(
        'Fatal error during enhanced multi-month report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 创建薪资结构数据
  /// 支持多月数据聚合，处理不同类型的值
  List<Map<String, dynamic>> _createSalaryStructureData(
    Map<String, dynamic>? salarySummary,
  ) {
    final salaryStructureData = <Map<String, dynamic>>[];

    if (salarySummary == null) {
      return salaryStructureData;
    }

    // 定义薪资结构相关的字段
    final salaryStructureFields = {
      '基本工资': '基本工资',
      '岗位工资': '岗位工资',
      '绩效工资': '绩效工资',
      '补贴工资': '补贴工资',
      '饭补': '饭补',
      '电脑补贴等': '电脑补贴等',
    };

    // 创建一个Map来存储聚合后的数据
    final Map<String, double> aggregatedData = {};

    // 初始化聚合数据
    salaryStructureFields.forEach((key, _) {
      aggregatedData[key] = 0.0;
    });

    // 记录处理的月份数，用于计算平均值
    int monthCount = 0;

    // 遍历 salarySummary，处理多月数据
    salarySummary.forEach((monthKey, monthData) {
      // 检查 monthData 是否为 Map 类型
      if (monthData is Map<String, dynamic>) {
        monthCount++;

        // 遍历每个月的数据，提取关注的字段
        salaryStructureFields.forEach((fieldKey, _) {
          if (monthData.containsKey(fieldKey)) {
            var fieldValue = monthData[fieldKey];
            double numValue = 0.0;

            // 处理不同类型的值
            if (fieldValue is String) {
              numValue = double.tryParse(fieldValue) ?? 0.0;
            } else if (fieldValue is num) {
              numValue = fieldValue.toDouble();
            } else if (fieldValue is Map) {
              // 如果是嵌套的Map，尝试提取数值
              numValue = _extractNumericValue(fieldValue) ?? 0.0;
            }

            // 累加到聚合数据中
            aggregatedData[fieldKey] =
                (aggregatedData[fieldKey] ?? 0.0) + numValue;
          }
        });
      } else if (monthData is String) {
        // 如果 monthData 是字符串，可能是序列化的 JSON
        try {
          final Map<String, dynamic> parsedData = jsonDecode(monthData);
          monthCount++;

          // 处理解析后的数据
          salaryStructureFields.forEach((fieldKey, _) {
            if (parsedData.containsKey(fieldKey)) {
              var fieldValue = parsedData[fieldKey];
              double numValue = 0.0;

              if (fieldValue is String) {
                numValue = double.tryParse(fieldValue) ?? 0.0;
              } else if (fieldValue is num) {
                numValue = fieldValue.toDouble();
              }

              aggregatedData[fieldKey] =
                  (aggregatedData[fieldKey] ?? 0.0) + numValue;
            }
          });
        } catch (e) {
          // 忽略解析错误
          logger.warning('无法解析月度数据: $monthKey, 错误: $e');
        }
      }
    });

    // 如果没有处理任何月份数据，返回空列表
    if (monthCount == 0) {
      return salaryStructureData;
    }

    // 计算平均值并构建结果
    aggregatedData.forEach((key, totalValue) {
      // 计算平均值
      final averageValue = totalValue / monthCount;

      // 添加到结果列表
      salaryStructureData.add({
        'category': key,
        'value': averageValue,
        'total': totalValue,
        'monthCount': monthCount,
      });
    });

    // 按照值从大到小排序
    salaryStructureData.sort(
      (a, b) => (b['value'] as double).compareTo(a['value'] as double),
    );

    return salaryStructureData;
  }

  /// 从复杂的Map结构中提取数值
  double? _extractNumericValue(Map<dynamic, dynamic> data) {
    // 尝试找到数值类型的值
    for (var value in data.values) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        final numValue = double.tryParse(value);
        if (numValue != null) {
          return numValue;
        }
      }
    }
    return null;
  }

  /// 将薪资区间数据转换为图表服务所需的格式
  List<Map<String, dynamic>> _convertToSalaryRangeMap(
    List<dynamic> salaryRanges,
  ) {
    return salaryRanges.map<Map<String, dynamic>>((range) {
      if (range is SalaryRangeStats) {
        return {'range': range.range, 'count': range.employeeCount};
      } else if (range is Map<String, dynamic>) {
        return {
          'range': range['range'] as String,
          'count':
              range['employee_count'] as int? ?? range['count'] as int? ?? 0,
        };
      }
      return {'range': 'Unknown', 'count': 0};
    }).toList();
  }

  /// 将薪资区间数据转换为AI服务所需的格式
  List<Map<String, int>> _convertToSalaryRangeMapForAI(
    List<dynamic> salaryRanges,
  ) {
    return salaryRanges.map<Map<String, int>>((range) {
      if (range is SalaryRangeStats) {
        return {range.range: range.employeeCount};
      } else if (range is Map<String, dynamic>) {
        final rangeLabel = range['range'] as String? ?? 'Unknown';
        final count =
            range['employee_count'] as int? ?? range['count'] as int? ?? 0;
        return {rangeLabel: count};
      }
      return {'Unknown': 0};
    }).toList();
  }

  /// 聚合每月薪资范围数据
  List<dynamic> _getAggregatedSalaryRanges(Map<String, dynamic> analysisData) {
    // 如果有每月薪资范围数据，则聚合它们
    if (analysisData.containsKey('salaryRangesPerMonth') &&
        analysisData['salaryRangesPerMonth'] is List) {
      final monthlySalaryRanges = analysisData['salaryRangesPerMonth'] as List;
      final aggregatedRanges = <String, SalaryRangeStats>{};

      // 遍历每月数据进行聚合
      for (var monthlyData in monthlySalaryRanges) {
        if (monthlyData is Map<String, dynamic> &&
            monthlyData.containsKey('salaryRanges') &&
            monthlyData['salaryRanges'] is List) {
          final ranges = monthlyData['salaryRanges'] as List;
          for (var range in ranges) {
            if (range is Map<String, dynamic>) {
              final rangeName = range['range'] as String;
              if (aggregatedRanges.containsKey(rangeName)) {
                // 如果已存在该区间，累加数据
                final existing = aggregatedRanges[rangeName]!;
                aggregatedRanges[rangeName] = SalaryRangeStats(
                  range: rangeName,
                  employeeCount:
                      existing.employeeCount +
                      (range['employeeCount'] as int? ?? 0),
                  totalSalary:
                      existing.totalSalary +
                      (range['totalSalary'] as num? ?? 0).toDouble(),
                  averageSalary:
                      (existing.totalSalary +
                          (range['totalSalary'] as num? ?? 0).toDouble()) /
                      (existing.employeeCount +
                          (range['employeeCount'] as int? ?? 0)),
                  year: existing.year,
                  month: existing.month,
                );
              } else {
                // 如果不存在该区间，添加新记录
                aggregatedRanges[rangeName] = SalaryRangeStats(
                  range: rangeName,
                  employeeCount: range['employeeCount'] as int? ?? 0,
                  totalSalary: (range['totalSalary'] as num? ?? 0).toDouble(),
                  averageSalary: (range['averageSalary'] as num? ?? 0)
                      .toDouble(),
                  year: range['year'] as int? ?? DateTime.now().year,
                  month: range['month'] as int? ?? DateTime.now().month,
                );
              }
            }
          }
        }
      }

      return aggregatedRanges.values.toList();
    }

    // 如果没有每月薪资范围数据，返回原始的salaryRanges
    if (analysisData.containsKey('salaryRanges')) {
      return analysisData['salaryRanges'] as List<dynamic>;
    }

    return [];
  }

  /// 聚合每月部门统计数据
  List<dynamic> _getAggregatedDepartmentStats(
    Map<String, dynamic> analysisData,
  ) {
    // 如果有每月部门统计数据，则聚合它们
    if (analysisData.containsKey('departmentStatsPerMonth') &&
        analysisData['departmentStatsPerMonth'] is List) {
      final monthlyDepartmentStats =
          analysisData['departmentStatsPerMonth'] as List;
      final aggregatedStats = <String, DepartmentSalaryStats>{};

      // 遍历每月数据进行聚合
      for (var monthlyData in monthlyDepartmentStats) {
        if (monthlyData is Map<String, dynamic> &&
            monthlyData.containsKey('departmentStats') &&
            monthlyData['departmentStats'] is List) {
          final departments = monthlyData['departmentStats'] as List;
          for (var dept in departments) {
            if (dept is Map<String, dynamic>) {
              final deptName = dept['department'] as String;
              if (aggregatedStats.containsKey(deptName)) {
                // 如果已存在该部门，累加数据
                final existing = aggregatedStats[deptName]!;
                final totalEmployeeCount =
                    existing.employeeCount +
                    (dept['employeeCount'] as int? ?? 0);
                final totalNetSalary =
                    existing.totalNetSalary +
                    (dept['totalNetSalary'] as num? ?? 0).toDouble();

                aggregatedStats[deptName] = DepartmentSalaryStats(
                  department: deptName,
                  employeeCount: totalEmployeeCount,
                  totalNetSalary: totalNetSalary,
                  averageNetSalary: totalEmployeeCount > 0
                      ? totalNetSalary / totalEmployeeCount
                      : 0.0,
                  year: existing.year,
                  month: existing.month,
                  maxSalary:
                      (dept['maxSalary'] as num? ?? 0).toDouble() >
                          existing.maxSalary
                      ? (dept['maxSalary'] as num? ?? 0).toDouble()
                      : existing.maxSalary,
                  minSalary:
                      (dept['minSalary'] as num? ?? 0).toDouble() <
                          existing.minSalary
                      ? (dept['minSalary'] as num? ?? 0).toDouble()
                      : existing.minSalary,
                );
              } else {
                // 如果不存在该部门，添加新记录
                aggregatedStats[deptName] = DepartmentSalaryStats(
                  department: deptName,
                  employeeCount: dept['employeeCount'] as int? ?? 0,
                  totalNetSalary: (dept['totalNetSalary'] as num? ?? 0)
                      .toDouble(),
                  averageNetSalary: (dept['averageNetSalary'] as num? ?? 0)
                      .toDouble(),
                  year: dept['year'] as int? ?? DateTime.now().year,
                  month: dept['month'] as int? ?? DateTime.now().month,
                  maxSalary: (dept['maxSalary'] as num? ?? 0).toDouble(),
                  minSalary: (dept['minSalary'] as num? ?? 0).toDouble(),
                );
              }
            }
          }
        }
      }

      return aggregatedStats.values.toList();
    }

    // 如果没有每月部门统计数据，返回原始的departmentStats
    if (analysisData.containsKey('departmentStats')) {
      return analysisData['departmentStats'] as List<dynamic>;
    }

    return [];
  }

  Future<MultiMonthReportContentModel> _createReportContentModel(
    Map<String, dynamic> jsonData,
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // 从JSON数据中提取关键信息来构建报告内容模型
    final keyMetrics = jsonData['key_metrics'] as Map<String, dynamic>;
    final currentPeriodMetrics =
        keyMetrics['current_period'] as Map<String, dynamic>;

    // 获取部门统计信息
    final departmentStats = _getAggregatedDepartmentStats(analysisData);

    // 获取薪资区间信息
    final salaryRanges = _getAggregatedSalaryRanges(analysisData);

    // 构建薪资结构数据
    final salaryStructureData = _createSalaryStructureData(
      analysisData.containsKey('salarySummary')
          ? analysisData['salarySummary'] as Map<String, dynamic>
          : null,
    );

    // 生成薪资结构描述
    final salaryStructureDescription = _generateSalaryStructureDescription(
      salaryStructureData,
    );

    // 计算月份数量
    final monthCount = _calculateMonthCount(startTime, endTime);

    // 计算增长率（示例值，实际应根据数据计算）
    final totalSalaryGrowthRate = 0.05; // 5% 示例值
    final averageSalaryGrowthRate = 0.03; // 3% 示例值

    String reportTime;
    if (startTime.month == endTime.month && startTime.year == endTime.year) {
      reportTime = '${startTime.year}年${startTime.month}月';
    } else {
      reportTime =
          '${startTime.year}年${startTime.month}月 - '
          '${endTime.year}年${endTime.month}月';
    }

    // 转换部门统计数据为 DepartmentSalaryStats 列表，用于 AI 分析
    final deptStatsList = departmentStats.map((dept) {
      if (dept is Map<String, dynamic>) {
        return DepartmentSalaryStats(
          department: dept['department'] as String,
          employeeCount:
              dept['employeeCount'] as int? ?? dept['count'] as int? ?? 0,
          averageNetSalary:
              (dept['averageNetSalary'] as num? ?? dept['average'] as num? ?? 0)
                  .toDouble(),
          totalNetSalary:
              (dept['totalNetSalary'] as num? ?? dept['total'] as num? ?? 0)
                  .toDouble(),
          year: dept['year'] as int? ?? DateTime.now().year,
          month: dept['month'] as int? ?? DateTime.now().month,
          maxSalary: (dept['maxSalary'] as num? ?? dept['max'] as num? ?? 0)
              .toDouble(),
          minSalary: (dept['minSalary'] as num? ?? dept['min'] as num? ?? 0)
              .toDouble(),
        );
      }
      return dept as DepartmentSalaryStats;
    }).toList();

    // 转换薪资区间数据为 AI 分析所需的格式
    final salaryRangesForAI = _convertToSalaryRangeMapForAI(salaryRanges);

    // 为多月报告创建增强的 AI 分析提示
    final basePromptForSalaryRange = '''
请基于以下薪资分布数据和部门薪资数据，撰写一段薪资分布特征总结。
要求语言严谨、简洁，体现报告风格。内容需涵盖整体分布情况、主要集中区间，以及分布的均衡性或差异性。
仅输出总结内容，不添加额外说明。
''';

    final basePromptForDeptAnalysis = '''
请基于以下部门薪资数据，撰写一段严谨简洁的报告风格分析，阐述各部门之间薪资差异的原因，
内容需包含薪资差异的主要原因、影响因素分析以及可能的改进建议。
要求只输出一个连续的段落，不允许分段或使用任何格式标记。
''';

    final basePromptForKeySalaryPoint = '''
请基于以下部门薪资数据和薪资分布数据，分析关键岗位的薪资情况。
要求语言严谨、简洁，体现报告风格。内容需涵盖关键岗位识别、薪资水平分析、市场竞争力评估，以及优化建议。
仅输出分析内容，不添加额外说明，要求只输出一个连续的段落，不允许分段或使用任何格式标记。
''';

    // 使用增强的多月分析提示
    final enhancedSalaryRangePrompt = _generateMultiMonthAIPrompt(
      basePromptForSalaryRange,
      analysisData,
      startTime,
      endTime,
    );

    final enhancedDeptAnalysisPrompt = _generateMultiMonthAIPrompt(
      basePromptForDeptAnalysis,
      analysisData,
      startTime,
      endTime,
    );

    final enhancedKeySalaryPointPrompt = _generateMultiMonthAIPrompt(
      basePromptForKeySalaryPoint,
      analysisData,
      startTime,
      endTime,
    );

    // 生成 AI 分析内容，使用自定义提示
    String salaryRangeFeatureSummary = await _aiSummaryService
        .generateSalaryRangeFeatureSummaryWithCustomPrompt(
          salaryRangesForAI,
          deptStatsList,
          enhancedSalaryRangePrompt,
        );

    salaryRangeFeatureSummary = salaryRangeFeatureSummary.replaceAll(
      "\n\n",
      "\n",
    );

    final departmentSalaryAnalysis = await _aiSummaryService
        .generateDepartmentSalaryAnalysisWithCustomPrompt(
          deptStatsList,
          enhancedDeptAnalysisPrompt,
        );

    final keySalaryPoint = await _aiSummaryService
        .generateKeySalaryPointWithCustomPrompt(
          deptStatsList,
          salaryRangesForAI,
          enhancedKeySalaryPointPrompt,
        );

    // 生成薪资结构优化建议
    final salaryStructureAdvice = await _aiSummaryService
        .generateSalaryStructureAdvice(
          employeeDetails: _generateEmployeeDetails(analysisData),
          departmentDetails: _generateDepartmentDetails(departmentStats),
          salaryRange: _generateSalaryRangeDescription(salaryRanges),
          salaryRangeFeature: salaryRangeFeatureSummary.isNotEmpty
              ? salaryRangeFeatureSummary
              : '暂无薪资区间特征数据',
        );

    return MultiMonthReportContentModel(
      reportTitle: '多月工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime: reportTime,
      startTime: '${startTime.year}年${startTime.month}月',
      endTime: '${endTime.year}年${endTime.month}月',
      compareLast: '与上期对比',
      totalEmployees: currentPeriodMetrics['total_employees'] as int,
      totalSalary: (currentPeriodMetrics['total_salary'] as num).toDouble(),
      averageSalary: (currentPeriodMetrics['average_salary'] as num).toDouble(),
      departmentCount: departmentStats.length,
      employeeCount: 0, // 多月报告中可能需要重新计算
      employeeDetails: _generateEmployeeDetails(analysisData),
      payrollInfo: _generatePayrollInfo(jsonData),
      departmentDetails: _generateDepartmentDetails(departmentStats),
      salaryRangeDescription: _generateSalaryRangeDescription(salaryRanges),
      salaryRangeFeatureSummary: salaryRangeFeatureSummary.isNotEmpty
          ? salaryRangeFeatureSummary
          : '薪资区间特征总结',
      departmentSalaryAnalysis: departmentSalaryAnalysis.isNotEmpty
          ? departmentSalaryAnalysis
          : '部门工资分析',
      keySalaryPoint: keySalaryPoint.isNotEmpty ? keySalaryPoint : '关键工资点',
      salaryRankings: "",
      salaryOrder: _generateSalaryOrder(deptStatsList),
      basicSalaryRate: 0.7,
      performanceSalaryRate: 0.3,
      salaryStructure: salaryStructureDescription, // 使用生成的薪资结构描述
      salaryStructureAdvice: salaryStructureAdvice.isNotEmpty
          ? salaryStructureAdvice
          : '薪资结构优化建议',
      salaryStructureData: salaryStructureData,
      departmentStats: departmentStats.map((dept) {
        if (dept is Map<String, dynamic>) {
          return DepartmentSalaryStats(
            department: dept['department'] as String,
            employeeCount:
                dept['employeeCount'] as int? ?? dept['count'] as int? ?? 0,
            averageNetSalary:
                (dept['averageNetSalary'] as num? ??
                        dept['average'] as num? ??
                        0)
                    .toDouble(),
            totalNetSalary:
                (dept['totalNetSalary'] as num? ?? dept['total'] as num? ?? 0)
                    .toDouble(),
            year: dept['year'] as int? ?? DateTime.now().year,
            month: dept['month'] as int? ?? DateTime.now().month,
            maxSalary: (dept['maxSalary'] as num? ?? dept['max'] as num? ?? 0)
                .toDouble(),
            minSalary: (dept['minSalary'] as num? ?? dept['min'] as num? ?? 0)
                .toDouble(),
          );
        }
        return DepartmentSalaryStats(
          department: '未知部门',
          employeeCount: 0,
          averageNetSalary: 0.0,
          totalNetSalary: 0.0,
          year: DateTime.now().year,
          month: DateTime.now().month,
          maxSalary: 0.0,
          minSalary: 0.0,
        );
      }).toList(),
      // 多月报告专用字段
      employeeCountPerMonth: _extractEmployeeCountPerMonth(jsonData),
      averageSalaryPerMonth: _extractAverageSalaryPerMonth(jsonData),
      totalSalaryPerMonth: _extractTotalSalaryPerMonth(jsonData),
      departmentDetailsPerMonth: _extractDepartmentDetailsPerMonth(jsonData),
      // 多月同比环比对比专用字段
      departmentMonthOverMonthData:
          analysisData['departmentMonthOverMonthData']
              as List<Map<String, dynamic>>?,
      departmentYearOverYearData:
          analysisData['departmentYearOverYearData']
              as List<Map<String, dynamic>>?,
      positionMonthOverMonthData:
          analysisData['positionMonthOverMonthData']
              as List<Map<String, dynamic>>?,
      positionYearOverYearData:
          analysisData['positionYearOverYearData']
              as List<Map<String, dynamic>>?,
      // 多月报告特有字段
      monthCount: monthCount,
      totalSalaryGrowthRate: totalSalaryGrowthRate,
      averageSalaryGrowthRate: averageSalaryGrowthRate,
      trendAnalysisSummary: _generateTrendAnalysisSummary(analysisData),
    );
  }

  // 计算月份数量方法已移至全局

  /// 生成趋势分析总结
  String _generateTrendAnalysisSummary(Map<String, dynamic> analysisData) {
    final buffer = StringBuffer();
    buffer.writeln('多月趋势分析总结：');

    // 添加部门环比变化总结
    if (analysisData.containsKey('departmentMonthOverMonthData') &&
        analysisData['departmentMonthOverMonthData'] is List) {
      final deptMoMData = analysisData['departmentMonthOverMonthData'] as List;
      if (deptMoMData.isNotEmpty) {
        buffer.writeln('1. 部门环比变化：');
        for (var item in deptMoMData) {
          if (item is Map<String, dynamic>) {
            final dept = item['department'] as String? ?? '未知部门';
            final empChange = item['employee_count_change'] as int? ?? 0;
            buffer.writeln(
              '   - $dept部门员工数变化：${empChange > 0 ? '+' : ''}$empChange人',
            );
          }
        }
      }
    }

    // 添加部门同比变化总结
    if (analysisData.containsKey('departmentYearOverYearData') &&
        analysisData['departmentYearOverYearData'] is List) {
      final deptYoYData = analysisData['departmentYearOverYearData'] as List;
      if (deptYoYData.isNotEmpty) {
        buffer.writeln('2. 部门同比变化：');
        for (var item in deptYoYData) {
          if (item is Map<String, dynamic>) {
            final dept = item['department'] as String? ?? '未知部门';
            final empChange = item['employee_count_change'] as int? ?? 0;
            buffer.writeln(
              '   - $dept部门员工数变化：${empChange > 0 ? '+' : ''}$empChange人',
            );
          }
        }
      }
    }

    return buffer.toString();
  }

  /// 生成部门详情描述
  String _generateDepartmentDetails(List<dynamic> departmentStats) {
    final buffer = StringBuffer();
    buffer.writeln('本报告周期内共有${departmentStats.length}个部门：');
    for (var dept in departmentStats) {
      if (dept is Map<String, dynamic>) {
        buffer.writeln(
          '- ${dept['department']}部门：${dept['employeeCount'] ?? dept['count']}人，工资总额${(dept['totalNetSalary'] ?? dept['total'] as num).toStringAsFixed(2)}元，平均工资${(dept['averageNetSalary'] ?? dept['average'] as num).toStringAsFixed(2)}元',
        );
      } else if (dept is DepartmentSalaryStats) {
        buffer.writeln(
          '- ${dept.department}部门：${dept.employeeCount}人，工资总额${dept.totalNetSalary.toStringAsFixed(2)}元，平均工资${dept.averageNetSalary.toStringAsFixed(2)}元',
        );
      }
    }
    return buffer.toString();
  }

  /// 生成薪资区间描述
  String _generateSalaryRangeDescription(List<dynamic> salaryRanges) {
    final buffer = StringBuffer();
    buffer.write('本期薪资区间分布情况：');

    for (int i = 0; i < salaryRanges.length; i++) {
      var range = salaryRanges[i];

      if (i > 0) {
        buffer.write('；');
      }

      if (range is SalaryRangeStats) {
        buffer.write(
          '${range.range}区间有${range.employeeCount}发薪人次，工资总额${range.totalSalary.toStringAsFixed(2)}元，平均工资${range.averageSalary.toStringAsFixed(2)}元',
        );
      } else if (range is Map<String, dynamic>) {
        final employeeCount =
            range['employee_count'] ?? range['employeeCount'] ?? 0;
        final totalSalary = range['total_salary'] ?? range['totalSalary'] ?? 0;
        final averageSalary =
            range['average_salary'] ?? range['averageSalary'] ?? 0;

        buffer.write(
          '${range['range']}区间有$employeeCount发薪人次，工资总额${(totalSalary as num).toStringAsFixed(2)}元，平均工资${(averageSalary as num).toStringAsFixed(2)}元',
        );
      }
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
    buffer.write('本期部门平均薪资排名（从高到低）：');

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
    buffer.write('月均薪资结构分析如下：');

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

  // /// 生成工资排名描述
  // String _generateSalaryRankings(Map<String, dynamic> analysisData) {
  //   final buffer = StringBuffer();

  //   // 最高工资员工
  //   final topEmployees = analysisData['topSalaryEmployees'] as List<dynamic>;
  //   if (topEmployees.isNotEmpty) {
  //     buffer.writeln('工资最高的员工：');
  //     for (var i = 0; i < topEmployees.length && i < 5; i++) {
  //       final employee = topEmployees[i];
  //       if (employee is SalaryListRecord) {
  //         buffer.writeln(
  //           '- ${employee.name}（${employee.department}）：¥${employee.netSalary}',
  //         );
  //       } else if (employee is Map<String, dynamic>) {
  //         buffer.writeln(
  //           '- ${employee['name']}（${employee['department']}）：¥${employee['net_salary']}',
  //         );
  //       }
  //     }
  //   }

  //   // 最低工资员工
  //   final bottomEmployees =
  //       analysisData['bottomSalaryEmployees'] as List<dynamic>;
  //   if (bottomEmployees.isNotEmpty) {
  //     buffer.writeln('工资最低的员工：');
  //     for (var i = 0; i < bottomEmployees.length && i < 5; i++) {
  //       final employee = bottomEmployees[i];
  //       if (employee is SalaryListRecord) {
  //         buffer.writeln(
  //           '- ${employee.name}（${employee.department}）：¥${employee.netSalary}',
  //         );
  //       } else if (employee is Map<String, dynamic>) {
  //         buffer.writeln(
  //           '- ${employee['name']}（${employee['department']}）：¥${employee['net_salary']}',
  //         );
  //       }
  //     }
  //   }

  //   return buffer.toString();
  // }

  /// 提取每月员工数量数据
  List<Map<String, dynamic>>? _extractEmployeeCountPerMonth(
    Map<String, dynamic> jsonData,
  ) {
    if (jsonData.containsKey('monthly_breakdown_chart_data') &&
        jsonData['monthly_breakdown_chart_data'] is List) {
      final monthlyBreakdown = jsonData['monthly_breakdown_chart_data'] as List;
      // 按时间排序月度数据
      final sortedMonthlyData =
          List<Map<String, dynamic>>.from(monthlyBreakdown)..sort((a, b) {
            if (a['year'] != b['year']) {
              return (a['year'] as int).compareTo(b['year'] as int);
            }
            return (a['month'] as int).compareTo(b['month'] as int);
          });

      return sortedMonthlyData.map<Map<String, dynamic>>((item) {
        return {
          'month': '${item['year']}年${item['month']}月',
          'year': item['year'],
          'monthNum': item['month'],
          'employeeCount': item['employee_count'],
        };
      }).toList();
    }
    return null;
  }

  /// 提取每月平均工资数据
  List<Map<String, dynamic>>? _extractAverageSalaryPerMonth(
    Map<String, dynamic> jsonData,
  ) {
    if (jsonData.containsKey('monthly_breakdown_chart_data') &&
        jsonData['monthly_breakdown_chart_data'] is List) {
      final monthlyBreakdown = jsonData['monthly_breakdown_chart_data'] as List;
      // 按时间排序月度数据
      final sortedMonthlyData =
          List<Map<String, dynamic>>.from(monthlyBreakdown)..sort((a, b) {
            if (a['year'] != b['year']) {
              return (a['year'] as int).compareTo(b['year'] as int);
            }
            return (a['month'] as int).compareTo(b['month'] as int);
          });

      return sortedMonthlyData.map<Map<String, dynamic>>((item) {
        return {
          'month': '${item['year']}年${item['month']}月',
          'year': item['year'],
          'monthNum': item['month'],
          'averageSalary': item['average_salary'],
        };
        return {};
      }).toList();
    }
    return null;
  }

  /// 提取每月总工资数据
  List<Map<String, dynamic>>? _extractTotalSalaryPerMonth(
    Map<String, dynamic> jsonData,
  ) {
    if (jsonData.containsKey('monthly_breakdown_chart_data') &&
        jsonData['monthly_breakdown_chart_data'] is List) {
      final monthlyBreakdown = jsonData['monthly_breakdown_chart_data'] as List;
      // 按时间排序月度数据
      final sortedMonthlyData =
          List<Map<String, dynamic>>.from(monthlyBreakdown)..sort((a, b) {
            if (a['year'] != b['year']) {
              return (a['year'] as int).compareTo(b['year'] as int);
            }
            return (a['month'] as int).compareTo(b['month'] as int);
          });

      return sortedMonthlyData.map<Map<String, dynamic>>((item) {
        return {
          'month': '${item['year']}年${item['month']}月',
          'year': item['year'],
          'monthNum': item['month'],
          'totalSalary': item['total_salary'],
        };
        return {};
      }).toList();
    }
    return null;
  }

  /// 提取每月部门详情数据
  List<Map<String, dynamic>>? _extractDepartmentDetailsPerMonth(
    Map<String, dynamic> jsonData,
  ) {
    if (jsonData.containsKey('monthly_department_stats_chart_data') &&
        jsonData['monthly_department_stats_chart_data'] is List) {
      return List<Map<String, dynamic>>.from(
        jsonData['monthly_department_stats_chart_data'] as List,
      );
    }
    return null;
  }

  /// 提取部门统计信息
  Map<String, DepartmentSalaryStats> _extractDepartmentStats(
    Map<String, dynamic> analysisData,
    Map<String, dynamic> item,
  ) {
    final departmentStats = <String, DepartmentSalaryStats>{};

    // 如果analysisData包含departmentStatsPerMonth字段
    if (analysisData.containsKey('departmentStatsPerMonth') &&
        analysisData['departmentStatsPerMonth'] is List) {
      final monthlyDeptList = analysisData['departmentStatsPerMonth'] as List;

      // 如果item为空，使用最后一个月的数据
      if (item.isEmpty && monthlyDeptList.isNotEmpty) {
        final lastMonthData = monthlyDeptList.last;
        if (lastMonthData is Map<String, dynamic> &&
            lastMonthData.containsKey('departmentStats') &&
            lastMonthData['departmentStats'] is List) {
          final deptList = lastMonthData['departmentStats'] as List;
          for (var dept in deptList) {
            if (dept is Map<String, dynamic>) {
              final deptName = dept['department'] as String? ?? '未知部门';
              departmentStats[deptName] = DepartmentSalaryStats(
                department: deptName,
                employeeCount:
                    dept['employeeCount'] as int? ?? dept['count'] as int? ?? 0,
                averageNetSalary:
                    (dept['averageNetSalary'] as num? ??
                            dept['average'] as num? ??
                            0)
                        .toDouble(),
                totalNetSalary:
                    (dept['totalNetSalary'] as num? ??
                            dept['total'] as num? ??
                            0)
                        .toDouble(),
                year: lastMonthData['year'] as int? ?? DateTime.now().year,
                month: lastMonthData['month'] as int? ?? DateTime.now().month,
                maxSalary:
                    (dept['maxSalary'] as num? ?? dept['max'] as num? ?? 0)
                        .toDouble(),
                minSalary:
                    (dept['minSalary'] as num? ?? dept['min'] as num? ?? 0)
                        .toDouble(),
              );
            }
          }
        }
      } else {
        // 查找当前月份的部门统计数据
        for (var monthlyData in monthlyDeptList) {
          if (monthlyData is Map<String, dynamic> &&
              monthlyData['year'] == item['year'] &&
              monthlyData['month'] == item['month']) {
            if (monthlyData.containsKey('departmentStats') &&
                monthlyData['departmentStats'] is List) {
              final deptList = monthlyData['departmentStats'] as List;
              for (var dept in deptList) {
                if (dept is Map<String, dynamic>) {
                  final deptName = dept['department'] as String? ?? '未知部门';
                  departmentStats[deptName] = DepartmentSalaryStats(
                    department: deptName,
                    employeeCount:
                        dept['employeeCount'] as int? ??
                        dept['count'] as int? ??
                        0,
                    averageNetSalary:
                        (dept['averageNetSalary'] as num? ??
                                dept['average'] as num? ??
                                0)
                            .toDouble(),
                    totalNetSalary:
                        (dept['totalNetSalary'] as num? ??
                                dept['total'] as num? ??
                                0)
                            .toDouble(),
                    year: item['year'] as int? ?? DateTime.now().year,
                    month: item['month'] as int? ?? DateTime.now().month,
                    maxSalary:
                        (dept['maxSalary'] as num? ?? dept['max'] as num? ?? 0)
                            .toDouble(),
                    minSalary:
                        (dept['minSalary'] as num? ?? dept['min'] as num? ?? 0)
                            .toDouble(),
                  );
                }
              }
              // 找到对应月份的数据后就跳出循环
              break;
            }
          }
        }
      }
    }

    // 如果没有找到每月部门统计数据，则尝试从聚合的departmentStats字段中提取
    if (departmentStats.isEmpty &&
        analysisData.containsKey('departmentStats') &&
        analysisData['departmentStats'] is List) {
      final deptList = analysisData['departmentStats'] as List;
      for (var dept in deptList) {
        if (dept is Map<String, dynamic>) {
          final deptName = dept['department'] as String? ?? '未知部门';
          departmentStats[deptName] = DepartmentSalaryStats(
            department: deptName,
            employeeCount:
                dept['count'] as int? ?? dept['employee_count'] as int? ?? 0,
            averageNetSalary:
                (dept['average'] as num? ?? dept['average_salary'] as num? ?? 0)
                    .toDouble(),
            totalNetSalary:
                (dept['total'] as num? ?? dept['total_salary'] as num? ?? 0)
                    .toDouble(),
            year: item['year'] as int? ?? DateTime.now().year,
            month: item['month'] as int? ?? DateTime.now().month,
            maxSalary: (dept['max'] as num? ?? dept['max_salary'] as num? ?? 0)
                .toDouble(),
            minSalary: (dept['min'] as num? ?? dept['min_salary'] as num? ?? 0)
                .toDouble(),
          );
        } else if (dept is DepartmentSalaryStats) {
          departmentStats[dept.department] = dept;
        }
      }
    }

    return departmentStats;
  }

  /// 提取薪资区间统计信息
  Map<String, SalaryRangeStats> _extractSalaryRangeStats(
    Map<String, dynamic> analysisData,
    Map<String, dynamic> item,
  ) {
    final salaryRangeStats = <String, SalaryRangeStats>{};

    // 首先尝试从每月薪资区间数据中提取
    if (analysisData.containsKey('salaryRangesPerMonth') &&
        analysisData['salaryRangesPerMonth'] is List) {
      final monthlySalaryRanges = analysisData['salaryRangesPerMonth'] as List;

      // 如果item为空，使用最后一个月的数据
      if (item.isEmpty && monthlySalaryRanges.isNotEmpty) {
        final lastMonthData = monthlySalaryRanges.last;
        if (lastMonthData is Map<String, dynamic> &&
            lastMonthData.containsKey('salaryRanges') &&
            lastMonthData['salaryRanges'] is List) {
          final rangeList = lastMonthData['salaryRanges'] as List;
          for (var range in rangeList) {
            if (range is Map<String, dynamic>) {
              final rangeName = range['range'] as String? ?? '未知区间';
              salaryRangeStats[rangeName] = SalaryRangeStats(
                range: rangeName,
                employeeCount: range['employeeCount'] as int? ?? 0,
                totalSalary: (range['totalSalary'] as num? ?? 0).toDouble(),
                averageSalary: (range['averageSalary'] as num? ?? 0).toDouble(),
                year: lastMonthData['year'] as int? ?? DateTime.now().year,
                month: lastMonthData['month'] as int? ?? DateTime.now().month,
              );
            }
          }
        }
      } else {
        // 查找当前月份的薪资区间数据
        for (var monthlyData in monthlySalaryRanges) {
          if (monthlyData is Map<String, dynamic> &&
              monthlyData['year'] == item['year'] &&
              monthlyData['month'] == item['month']) {
            if (monthlyData.containsKey('salaryRanges') &&
                monthlyData['salaryRanges'] is List) {
              final rangeList = monthlyData['salaryRanges'] as List;
              for (var range in rangeList) {
                if (range is Map<String, dynamic>) {
                  final rangeName = range['range'] as String? ?? '未知区间';
                  salaryRangeStats[rangeName] = SalaryRangeStats(
                    range: rangeName,
                    employeeCount: range['employeeCount'] as int? ?? 0,
                    totalSalary: (range['totalSalary'] as num? ?? 0).toDouble(),
                    averageSalary: (range['averageSalary'] as num? ?? 0)
                        .toDouble(),
                    year:
                        range['year'] as int? ??
                        item['year'] as int? ??
                        DateTime.now().year,
                    month:
                        range['month'] as int? ??
                        item['month'] as int? ??
                        DateTime.now().month,
                  );
                }
              }
              // 找到对应月份的数据后就跳出循环
              break;
            }
          }
        }
      }
    }

    // 如果没有找到每月薪资区间数据，则尝试从聚合的salaryRanges字段中提取
    if (salaryRangeStats.isEmpty) {
      final aggregatedRanges = _getAggregatedSalaryRanges(analysisData);
      for (var range in aggregatedRanges) {
        if (range is Map<String, dynamic>) {
          final rangeName = range['range'] as String? ?? '未知区间';
          salaryRangeStats[rangeName] = SalaryRangeStats(
            range: rangeName,
            employeeCount:
                range['employeeCount'] as int? ?? range['count'] as int? ?? 0,
            totalSalary:
                (range['totalSalary'] as num? ?? range['total'] as num? ?? 0)
                    .toDouble(),
            averageSalary:
                (range['averageSalary'] as num? ??
                        range['average'] as num? ??
                        0)
                    .toDouble(),
            year: item['year'] as int? ?? DateTime.now().year,
            month: item['month'] as int? ?? DateTime.now().month,
          );
        } else if (range is SalaryRangeStats) {
          salaryRangeStats[range.range] = range;
        }
      }
    }

    return salaryRangeStats;
  }

  /// 提取员工信息
  List<MinimalEmployeeInfo> _extractWorkers(
    Map<String, dynamic> analysisData,
    Map<String, dynamic> item,
  ) {
    final workers = <MinimalEmployeeInfo>[];

    // 如果analysisData包含workers字段
    if (analysisData.containsKey('workers') &&
        analysisData['workers'] is List) {
      final workerList = analysisData['workers'] as List;
      for (var worker in workerList) {
        if (worker is Map<String, dynamic>) {
          workers.add(
            MinimalEmployeeInfo(
              name: worker['name'] as String? ?? '未知员工',
              department: worker['department'] as String? ?? '未知部门',
            ),
          );
        } else if (worker is MinimalEmployeeInfo) {
          workers.add(worker);
        }
      }
    }

    return workers;
  }

  /// 将analysisData转换为MultiMonthComparisonData
  MultiMonthComparisonData _convertToMultiMonthComparisonData(
    Map<String, dynamic> analysisData,
  ) {
    // 从analysisData中提取多月比较数据
    // 这里需要根据实际的数据结构进行转换
    final monthlyComparisons = <MonthlyComparisonData>[];

    // 如果analysisData包含monthlyData字段
    if (analysisData.containsKey('monthlyData') &&
        analysisData['monthlyData'] is List) {
      final monthlyDataList = analysisData['monthlyData'] as List;
      for (var item in monthlyDataList) {
        if (item is Map<String, dynamic>) {
          // 构造MonthlyComparisonData对象
          monthlyComparisons.add(
            MonthlyComparisonData(
              year: item['year'] as int? ?? DateTime.now().year,
              month: item['month'] as int? ?? DateTime.now().month,
              employeeCount: item['employeeCount'] as int? ?? 0,
              totalSalary: (item['totalSalary'] as num? ?? 0).toDouble(),
              averageSalary: (item['averageSalary'] as num? ?? 0).toDouble(),
              highestSalary: (item['highestSalary'] as num? ?? 0).toDouble(),
              lowestSalary: (item['lowestSalary'] as num? ?? 0).toDouble(),
              departmentStats: _extractDepartmentStats(analysisData, item),
              salaryRangeStats: _extractSalaryRangeStats(analysisData, item),
              workers: _extractWorkers(analysisData, item),
            ),
          );
        }
      }
    }

    // 如果没有monthlyData字段，使用聚合数据创建一个默认的
    if (monthlyComparisons.isEmpty) {
      monthlyComparisons.add(
        MonthlyComparisonData(
          year: DateTime.now().year,
          month: DateTime.now().month,
          employeeCount: analysisData['totalEmployees'] as int? ?? 0,
          totalSalary: (analysisData['totalSalary'] as num? ?? 0).toDouble(),
          averageSalary: (analysisData['averageSalary'] as num? ?? 0)
              .toDouble(),
          highestSalary: (analysisData['highestSalary'] as num? ?? 0)
              .toDouble(),
          lowestSalary: (analysisData['lowestSalary'] as num? ?? 0).toDouble(),
          departmentStats: _extractDepartmentStats(analysisData, {}),
          salaryRangeStats: _extractSalaryRangeStats(analysisData, {}),
          workers: _extractWorkers(analysisData, {}),
        ),
      );
    }

    // 确定startDate和endDate
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    if (monthlyComparisons.isNotEmpty) {
      // 按时间排序
      monthlyComparisons.sort((a, b) {
        if (a.year != b.year) return a.year.compareTo(b.year);
        return a.month.compareTo(b.month);
      });

      final firstMonth = monthlyComparisons.first;
      final lastMonth = monthlyComparisons.last;

      startDate = DateTime(firstMonth.year, firstMonth.month);
      endDate = DateTime(lastMonth.year, lastMonth.month);
    }

    return MultiMonthComparisonData(
      monthlyComparisons: monthlyComparisons,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 获取每月部门详情数据
  List<Map<String, dynamic>> _getDepartmentDetailsPerMonth(
    Map<String, dynamic> analysisData,
  ) {
    final departmentDetailsPerMonth = <Map<String, dynamic>>[];

    if (analysisData.containsKey('departmentStatsPerMonth') &&
        analysisData['departmentStatsPerMonth'] is List) {
      final monthlyDeptList = analysisData['departmentStatsPerMonth'] as List;

      for (var monthlyData in monthlyDeptList) {
        if (monthlyData is Map<String, dynamic> &&
            monthlyData.containsKey('departmentStats') &&
            monthlyData['departmentStats'] is List) {
          final deptList = monthlyData['departmentStats'] as List;
          final formattedDeptData = <Map<String, dynamic>>[];

          for (var dept in deptList) {
            if (dept is Map<String, dynamic>) {
              formattedDeptData.add({
                'department': dept['department'] as String? ?? '未知部门',
                'employeeCount': dept['employeeCount'] as int? ?? 0,
                'averageSalary': (dept['averageNetSalary'] as num? ?? 0)
                    .toDouble(),
                'totalSalary': (dept['totalNetSalary'] as num? ?? 0).toDouble(),
                'year': dept['year'] as int? ?? DateTime.now().year,
                'month': dept['month'] as int? ?? DateTime.now().month,
              });
            }
          }

          departmentDetailsPerMonth.add({
            'month': '${monthlyData['year']}年${monthlyData['month']}月',
            'year': monthlyData['year'],
            'monthNum': monthlyData['month'],
            'departmentStats': formattedDeptData,
          });
        }
      }
    }

    return departmentDetailsPerMonth;
  }

  /// 获取最后一个月的部门统计数据
  List<Map<String, dynamic>>? _getLastMonthDepartmentStats(
    Map<String, dynamic> analysisData,
  ) {
    if (analysisData.containsKey('departmentStatsPerMonth') &&
        analysisData['departmentStatsPerMonth'] is List) {
      final monthlyDeptList = analysisData['departmentStatsPerMonth'] as List;

      if (monthlyDeptList.isNotEmpty) {
        // 按时间排序，获取最后一个月的数据
        final sortedMonthlyData =
            List<Map<String, dynamic>>.from(monthlyDeptList)..sort((a, b) {
              final yearA = a['year'] as int? ?? 0;
              final yearB = b['year'] as int? ?? 0;
              if (yearA != yearB) return yearA.compareTo(yearB);
              final monthA = a['month'] as int? ?? 0;
              final monthB = b['month'] as int? ?? 0;
              return monthA.compareTo(monthB);
            });

        final lastMonthData = sortedMonthlyData.last;
        if (lastMonthData.containsKey('departmentStats') &&
            lastMonthData['departmentStats'] is List) {
          final deptList = lastMonthData['departmentStats'] as List;
          return deptList.map<Map<String, dynamic>>((dept) {
            if (dept is Map<String, dynamic>) {
              return {
                'department': dept['department'] as String? ?? '未知部门',
                'employeeCount': dept['employeeCount'] as int? ?? 0,
                'averageSalary': (dept['averageNetSalary'] as num? ?? 0)
                    .toDouble(),
                'totalSalary': (dept['totalNetSalary'] as num? ?? 0).toDouble(),
                'year': dept['year'] as int? ?? DateTime.now().year,
                'month': dept['month'] as int? ?? DateTime.now().month,
              };
            }
            return <String, dynamic>{};
          }).toList();
        }
      }
    }

    return null;
  }
}

String _generateEmployeeDetails(Map<String, dynamic> analysisData) {
  final buffer = StringBuffer();

  logger.info('生成员工详情数据... ${analysisData['comparisonData']}');

  // 获取多月比较数据
  if (analysisData.containsKey('comparisonData') &&
      analysisData['comparisonData'] is MultiMonthComparisonData) {
    final comparisonData =
        analysisData['comparisonData'] as MultiMonthComparisonData;

    // 按时间排序月度数据
    final sortedMonthlyData =
        List<MonthlyComparisonData>.from(comparisonData.monthlyComparisons)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.month.compareTo(b.month);
          });

    buffer.write('本期员工分布情况：');

    // 展示每个月的员工数据（连续文本格式）
    for (int i = 0; i < sortedMonthlyData.length; i++) {
      final monthlyData = sortedMonthlyData[i];

      if (i > 0) {
        buffer.write('；');
      }

      buffer.write(
        '${monthlyData.year}年${monthlyData.month}月共有员工${monthlyData.employeeCount}人',
      );

      // 展示各部门员工分布
      if (monthlyData.departmentStats.isNotEmpty) {
        buffer.write('，其中');
        final deptEntries = monthlyData.departmentStats.entries.toList();
        for (int j = 0; j < deptEntries.length; j++) {
          final dept = deptEntries[j];
          buffer.write('${dept.key}${dept.value.employeeCount}人');
          if (j < deptEntries.length - 1) {
            buffer.write('、');
          }
        }
      }
    }

    // 计算员工变动情况并按部门和岗位分类
    final Map<String, List<MinimalEmployeeInfo>> newEmployeesByDept = {};
    final Map<String, List<MinimalEmployeeInfo>> resignedEmployeesByDept = {};

    for (int i = 1; i < sortedMonthlyData.length; i++) {
      final currentMonth = sortedMonthlyData[i];
      final previousMonth = sortedMonthlyData[i - 1];

      final currentWorkerSet = currentMonth.workers.toSet();
      final previousWorkerSet = previousMonth.workers.toSet();

      final newEmployees = currentWorkerSet
          .difference(previousWorkerSet)
          .toList();
      final resignedEmployees = previousWorkerSet
          .difference(currentWorkerSet)
          .toList();

      // 按部门分类新入职员工
      for (var employee in newEmployees) {
        if (!newEmployeesByDept.containsKey(employee.department)) {
          newEmployeesByDept[employee.department] = [];
        }
        newEmployeesByDept[employee.department]!.add(employee);
      }

      // 按部门分类离职员工
      for (var employee in resignedEmployees) {
        if (!resignedEmployeesByDept.containsKey(employee.department)) {
          resignedEmployeesByDept[employee.department] = [];
        }
        resignedEmployeesByDept[employee.department]!.add(employee);
      }
    }

    // 计算总数
    int totalNewEmployees = 0;
    newEmployeesByDept.forEach(
      (_, employees) => totalNewEmployees += employees.length,
    );

    int totalResignedEmployees = 0;
    resignedEmployeesByDept.forEach(
      (_, employees) => totalResignedEmployees += employees.length,
    );

    if (totalNewEmployees > 0 || totalResignedEmployees > 0) {
      buffer.write('。期间员工变动情况：');

      // 描述新入职员工（按部门和岗位）
      if (totalNewEmployees > 0) {
        buffer.write('新入职$totalNewEmployees人（');
        int deptCount = 0;
        newEmployeesByDept.forEach((dept, employees) {
          if (deptCount > 0) {
            buffer.write('；');
          }
          buffer.write('$dept${employees.length}人');

          // 由于 MinimalEmployeeInfo 类没有岗位信息，这里只按部门统计

          deptCount++;
        });
        buffer.write('）');
      }

      // 描述离职员工（按部门和岗位）
      if (totalResignedEmployees > 0) {
        if (totalNewEmployees > 0) {
          buffer.write('，');
        }

        buffer.write('离职$totalResignedEmployees人（');
        int deptCount = 0;
        resignedEmployeesByDept.forEach((dept, employees) {
          if (deptCount > 0) {
            buffer.write('；');
          }
          buffer.write('$dept${employees.length}人');

          // 由于 MinimalEmployeeInfo 类没有岗位信息，这里只按部门统计

          deptCount++;
        });
        buffer.write('）');
      }

      buffer.write('。');
    }
  } else {
    // 如果没有比较数据，使用基础统计
    final totalUniqueEmployees =
        analysisData['totalUniqueEmployees'] as int? ?? 0;
    final totalEmployees = analysisData['totalEmployees'] as int? ?? 0;
    buffer.write('本期共涉及 $totalUniqueEmployees 名员工（发放工资 $totalEmployees 人次）');
  }

  return buffer.toString();
}

String _generatePayrollInfo(Map<String, dynamic> jsonData) {
  // 使用 jsonData['key_param'] 中的发薪信息内容
  if (jsonData.containsKey('key_param') && jsonData['key_param'] is String) {
    return jsonData['key_param'] as String;
  }

  // 如果没有 key_param，从其他字段构建发薪信息
  final keyMetrics = jsonData['key_metrics'] as Map<String, dynamic>? ?? {};
  final currentPeriod =
      keyMetrics['current_period'] as Map<String, dynamic>? ?? {};

  final totalSalary = currentPeriod['total_salary'] as num? ?? 0;
  final averageSalary = currentPeriod['average_salary'] as num? ?? 0;
  final totalEmployees = currentPeriod['total_employees'] as int? ?? 0;

  return '本期发放工资 $totalEmployees 人次，工资总额为 ${totalSalary.toStringAsFixed(2)} 元，平均工资为 ${averageSalary.toStringAsFixed(2)} 元';
}

/// 计算两个日期之间的月份数
int _calculateMonthCount(DateTime startTime, DateTime endTime) {
  final years = endTime.year - startTime.year;
  final months = endTime.month - startTime.month;
  return years * 12 + months + 1; // +1 因为包含起始和结束月份
}

/// 为多月报告生成专门的 AI 分析提示
///
/// 这个方法创建一个针对多月数据的提示，帮助 AI 更好地理解和分析多月数据的趋势和变化
String _generateMultiMonthAIPrompt(
  String basePrompt,
  Map<String, dynamic> analysisData,
  DateTime startTime,
  DateTime endTime,
) {
  // 计算报告涵盖的月份数
  final monthCount = _calculateMonthCount(startTime, endTime);

  // 提取月度趋势数据
  final employeeCountTrend = analysisData.containsKey('employeeCountPerMonth')
      ? _extractTrendDescription(analysisData['employeeCountPerMonth'], '员工数量')
      : '';

  final averageSalaryTrend = analysisData.containsKey('averageSalaryPerMonth')
      ? _extractTrendDescription(analysisData['averageSalaryPerMonth'], '平均工资')
      : '';

  final totalSalaryTrend = analysisData.containsKey('totalSalaryPerMonth')
      ? _extractTrendDescription(analysisData['totalSalaryPerMonth'], '工资总额')
      : '';

  // 提取部门变化数据
  final departmentChanges =
      analysisData.containsKey('departmentMonthOverMonthData')
      ? _extractDepartmentChanges(analysisData['departmentMonthOverMonthData'])
      : '';

  // 构建增强的提示
  final enhancedPrompt =
      '''
$basePrompt

【多月分析补充信息】
- 分析周期：从 ${startTime.year}年${startTime.month}月 到 ${endTime.year}年${endTime.month}月，共计 $monthCount 个月
- 员工数量趋势：$employeeCountTrend
- 平均工资趋势：$averageSalaryTrend
- 工资总额趋势：$totalSalaryTrend
- 部门变化情况：$departmentChanges

请在分析中特别关注多月数据的趋势变化、周期性波动、异常点，以及各指标之间的相关性。
''';

  return enhancedPrompt;
}

/// 从趋势数据中提取描述
String _extractTrendDescription(List<dynamic> trendData, String metricName) {
  if (trendData.isEmpty) return '无数据';

  // 按时间排序
  final sortedData = List<Map<String, dynamic>>.from(trendData)
    ..sort((a, b) {
      final yearA = a['year'] as int? ?? 0;
      final yearB = b['year'] as int? ?? 0;
      if (yearA != yearB) return yearA.compareTo(yearB);

      final monthA = a['monthNum'] as int? ?? 0;
      final monthB = b['monthNum'] as int? ?? 0;
      return monthA.compareTo(monthB);
    });

  // 提取关键指标
  final buffer = StringBuffer();
  String valueKey;

  if (metricName == '员工数量') {
    valueKey = 'employeeCount';
  } else if (metricName == '平均工资') {
    valueKey = 'averageSalary';
  } else if (metricName == '工资总额') {
    valueKey = 'totalSalary';
  } else {
    valueKey = '';
  }

  if (valueKey.isEmpty) return '无数据';

  // 计算变化率
  for (int i = 1; i < sortedData.length; i++) {
    final current = sortedData[i][valueKey] as num? ?? 0;
    final previous = sortedData[i - 1][valueKey] as num? ?? 0;

    if (previous > 0) {
      final changeRate = ((current - previous) / previous * 100)
          .toStringAsFixed(2);
      final month = sortedData[i]['month'] as String? ?? '未知';

      if (i == 1) {
        buffer.write('$month $metricName ${current.toStringAsFixed(2)}');
      } else {
        final direction = current > previous ? '上升' : '下降';
        buffer.write(
          '，$month $metricName ${current.toStringAsFixed(2)}（$direction $changeRate%）',
        );
      }
    }
  }

  return buffer.toString();
}

/// 提取部门变化数据
String _extractDepartmentChanges(List<dynamic> departmentChanges) {
  if (departmentChanges.isEmpty) return '无数据';

  final buffer = StringBuffer();
  int count = 0;

  for (var change in departmentChanges) {
    if (change is Map<String, dynamic>) {
      final dept = change['department'] as String? ?? '未知部门';
      final empChange = change['employee_count_change'] as int? ?? 0;
      final salaryChange = change['average_salary_change'] as num? ?? 0.0;

      if (count > 0) buffer.write('，');

      buffer.write('$dept 部门人数变化 ${empChange > 0 ? '+' : ''}$empChange 人');
      buffer.write(
        '，平均工资变化 ${salaryChange > 0 ? '+' : ''}${salaryChange.toStringAsFixed(2)} 元',
      );

      count++;
      if (count >= 3) break; // 只显示前3个部门的变化
    }
  }

  if (departmentChanges.length > 3) {
    buffer.write('，等');
  }

  return buffer.toString();
}
