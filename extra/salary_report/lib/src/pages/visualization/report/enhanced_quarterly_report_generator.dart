// src/report/enhanced_quarterly_report_generator.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/services/quarterly/quarterly.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';

/// 增强版季度报告生成器
class EnhancedQuarterlyReportGenerator implements EnhancedReportGenerator {
  final QuarterlyChartGenerationService _chartService;
  final QuarterlyChartGenerationFromJsonService _jsonChartService;
  final QuarterlyDocxWriterService _docxService;
  final DataAnalysisService _analysisService;
  final ReportService _reportService;
  final AISummaryService _aiSummaryService;

  EnhancedQuarterlyReportGenerator({
    QuarterlyChartGenerationService? chartService,
    QuarterlyChartGenerationFromJsonService? jsonChartService,
    QuarterlyDocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
    AISummaryService? aiSummaryService,
  }) : _chartService = chartService ?? QuarterlyChartGenerationService(),
       _jsonChartService =
           jsonChartService ?? QuarterlyChartGenerationFromJsonService(),
       _docxService = docxService ?? QuarterlyDocxWriterService(),
       _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService(),
       _aiSummaryService = aiSummaryService ?? AISummaryService();

  /// 生成包含描述和图表的增强版季度报告
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
      logger.info('Starting enhanced quarterly salary report generation...');

      // 1. 生成JSON格式的分析数据
      final jsonString =
          QuarterlyAnalysisJsonConverter.convertAnalysisDataToJson(
            analysisData: analysisData,
            departmentStats: departmentStats,
            attendanceStats: attendanceStats,
            previousQuarterData: previousMonthData,
            year: year,
            quarter: (month - 1) ~/ 3 + 1, // 根据月份计算季度
          );

      // 2. 解析JSON数据
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // 优化季度数据处理
      final optimizedAnalysisData = _optimizeQuarterlyData(analysisData);

      // 3. 生成图表图像（从UI）
      final chartImagesFromUI = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: _convertToSalaryRangeMap(
          analysisData['salaryRanges'] as List<dynamic>,
        ),
      );

      // 4. 生成图表图像（从JSON数据）
      final chartImagesFromJson = await _jsonChartService
          .generateAllChartsFromJson(jsonData: jsonData);

      // 5. 创建组合图表图像集合
      final combinedChartImages = QuarterlyReportChartImages(
        mainChart: chartImagesFromUI.mainChart,
        departmentDetailsChart: chartImagesFromJson.departmentChart,
        salaryRangeChart: chartImagesFromJson.salaryRangeChart,
        salaryStructureChart: null, // 可以从jsonData中提取薪资结构数据来生成
      );

      // 6. 创建报告内容模型
      final reportContent = await _createReportContentModel(
        jsonData,
        optimizedAnalysisData,
        startTime,
        endTime,
      );

      logger.info('Report content model created. $reportContent');

      // 7. 写入报告文件
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: combinedChartImages,
      );

      // 8. 添加报告记录到数据库
      await _reportService.addReportRecord(reportPath);

      logger.info('Enhanced quarterly report generation complete: $reportPath');

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe(
        'Fatal error during enhanced quarterly report generation: $e',
        e,
        stackTrace,
      );
      logger.severe(
        'Fatal error during enhanced quarterly report generation: $e',
      );
      logger.severe(
        'Fatal error during enhanced quarterly report generation: $stackTrace',
      );
      rethrow;
    }
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
          '${monthlyData.year}年${monthlyData.month}月发放工资${monthlyData.employeeCount}人次',
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

  /// 创建报告内容模型
  Future<QuarterlyReportContentModel> _createReportContentModel(
    Map<String, dynamic> jsonData,
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // 从JSON数据中提取关键信息来构建报告内容模型
    final keyMetrics = jsonData['key_metrics'] as Map<String, dynamic>;

    logger.info('keyMetrics data $keyMetrics');

    final currentMonthMetrics =
        keyMetrics['current_quarter'] as Map<String, dynamic>;

    // 获取部门统计信息
    final departmentStats = analysisData['departmentStats'] as List<dynamic>;

    // 获取薪资区间信息
    final salaryRanges = analysisData['salaryRanges'] as List<dynamic>;

    // 构建薪资结构数据
    final salaryStructureData = <Map<String, dynamic>>[];
    if (analysisData.containsKey('salarySummary')) {
      final salarySummary =
          analysisData['salarySummary'] as Map<String, dynamic>;
      salarySummary.forEach((key, value) {
        if (value is num) {
          salaryStructureData.add({'category': key, 'value': value.toDouble()});
        }
      });
    }

    // 转换部门统计数据为 DepartmentSalaryStats 列表，用于 AI 分析
    final deptStatsList = departmentStats.map((dept) {
      if (dept is Map<String, dynamic>) {
        return DepartmentSalaryStats(
          department: dept['department'] as String,
          employeeCount: dept['count'] as int,
          averageNetSalary: (dept['average'] as num).toDouble(),
          totalNetSalary: (dept['total'] as num).toDouble(),
          year: DateTime.now().year,
          month: DateTime.now().month,
          maxSalary: dept.containsKey('max')
              ? (dept['max'] as num).toDouble()
              : 0.0,
          minSalary: dept.containsKey('min')
              ? (dept['min'] as num).toDouble()
              : 0.0,
        );
      }
      return dept as DepartmentSalaryStats;
    }).toList();

    // 转换薪资区间数据为 AI 分析所需的格式
    final salaryRangesForAI = salaryRanges.map<Map<String, int>>((range) {
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

    // 获取月度数据
    final monthlyData =
        analysisData['monthlyBreakdown'] as List<dynamic>? ?? [];

    // 获取员工变动数据
    final employeeChanges =
        analysisData['monthlyEmployeeChanges'] as List<dynamic>? ?? [];

    // 获取上季度数据
    final previousQuarterData =
        analysisData['previousQuarterData'] as Map<String, dynamic>? ?? {};

    // 生成季度工资总额分析的增强提示
    final totalSalary = (currentMonthMetrics['total_salary'] as num).toDouble();
    final previousQuarterTotalSalary =
        previousQuarterData.containsKey('totalSalary')
        ? (previousQuarterData['totalSalary'] as num).toDouble()
        : 0.0;

    final basePromptForTotalSalary =
        '''
请分析以下季度工资总额数据：
- 本季度工资总额：${totalSalary.toStringAsFixed(2)}元
- 上季度工资总额：${previousQuarterTotalSalary.toStringAsFixed(2)}元
- 环比变化率：${previousQuarterTotalSalary > 0 ? ((totalSalary - previousQuarterTotalSalary) / previousQuarterTotalSalary * 100).toStringAsFixed(2) : "无法计算"}%

请撰写一段关于季度工资总额的分析，包括总体趋势、月度波动原因、与上季度的对比分析，以及可能的影响因素。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
''';

    final enhancedPromptForTotalSalary = _generateQuarterlyAIPrompt(
      basePromptForTotalSalary,
      analysisData,
      startTime,
      endTime,
    );

    logger.info('enhancedPromptForTotalSalary $enhancedPromptForTotalSalary');

    final quarterTotalSalaryAnalysis = await _aiSummaryService.getAnswer(
      enhancedPromptForTotalSalary,
    );

    // 生成季度平均工资分析
    final averageSalary = (currentMonthMetrics['average_salary'] as num)
        .toDouble();
    final previousQuarterAverageSalary =
        previousQuarterData.containsKey('averageSalary')
        ? (previousQuarterData['averageSalary'] as num).toDouble()
        : 0.0;
    final quarterAverageSalaryAnalysis = await _aiSummaryService
        .generateQuarterlyAverageSalaryAnalysis(
          averageSalary,
          previousQuarterAverageSalary,
          List<Map<String, dynamic>>.from(monthlyData),
          deptStatsList,
        );

    // 生成季度员工数量分析
    final totalEmployees = currentMonthMetrics['total_employees'] as int;
    final uniqueEmployees =
        currentMonthMetrics['total_unique_employees'] as int;
    final previousQuarterTotalEmployees =
        previousQuarterData.containsKey('totalEmployees')
        ? previousQuarterData['totalEmployees'] as int
        : 0;
    final quarterEmployeeCountAnalysis = await _aiSummaryService
        .generateQuarterlyEmployeeCountAnalysis(
          totalEmployees,
          uniqueEmployees,
          previousQuarterTotalEmployees,
          List<Map<String, dynamic>>.from(monthlyData),
          List<Map<String, dynamic>>.from(employeeChanges),
        );

    // 生成季度工资构成分析
    final quarterlySalaryCompositionAnalysis = await _aiSummaryService
        .generateQuarterlySalaryCompositionAnalysis(salaryStructureData);

    // 生成季度环比变化分析
    final currentQuarterData = {
      'year': startTime.year,
      'quarter': (startTime.month - 1) ~/ 3 + 1,
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'totalEmployees': totalEmployees,
    };
    final quarterMoMChangeAnalysis = await _aiSummaryService
        .generateQuarterlyMoMChangeAnalysis(
          currentQuarterData,
          previousQuarterData.isNotEmpty ? previousQuarterData : null,
        );

    // 生成薪资区间特征总结
    final salaryRangeFeatureSummary = await _aiSummaryService
        .generateSalaryRangeFeatureSummary(salaryRangesForAI, deptStatsList);

    // 生成部门工资分析
    final departmentSalaryAnalysis = await _aiSummaryService
        .generateDepartmentSalaryAnalysis(deptStatsList);

    // 生成关键薪资点分析
    final keySalaryPoint = await _aiSummaryService.generateKeySalaryPoint(
      deptStatsList,
      salaryRangesForAI,
    );

    // 生成薪资结构优化建议
    final salaryStructureAdvice = await _aiSummaryService
        .generateSalaryStructureAdvice(
          employeeDetails: jsonData['key_param'] as String,
          departmentDetails: _generateDepartmentDetails(departmentStats),
          salaryRange: _generateSalaryRangeDescription(salaryRanges),
          salaryRangeFeature: salaryRangeFeatureSummary.isNotEmpty
              ? salaryRangeFeatureSummary
              : '暂无薪资区间特征数据',
        );

    // 使用 AI 生成的季度分析内容构建综合分析
    // 注意：这里不再单独构建综合分析，而是在各个字段中直接使用对应的分析结果

    String reportTime;
    if (startTime.month == endTime.month && startTime.year == endTime.year) {
      reportTime = '${startTime.year}年${startTime.month}月';
    } else {
      reportTime =
          '${startTime.year}年${startTime.month}月 - '
          '${endTime.year}年${endTime.month}月';
    }

    return QuarterlyReportContentModel(
      reportTitle: '季度工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime: reportTime,
      startTime: '${startTime.year}年${startTime.month}月',
      endTime: '${endTime.year}年${endTime.month}月',
      compareLast: quarterMoMChangeAnalysis.isNotEmpty
          ? quarterMoMChangeAnalysis
          : '与上季度对比',
      totalEmployees: totalEmployees,
      totalSalary: totalSalary,
      averageSalary: averageSalary,
      departmentCount: departmentStats.length,
      employeeCount: uniqueEmployees,
      employeeDetails: quarterEmployeeCountAnalysis.isNotEmpty
          ? quarterEmployeeCountAnalysis
          : jsonData['key_param'] as String,
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
      basicSalaryRate: 0.7,
      performanceSalaryRate: 0.3,
      salaryStructure: quarterlySalaryCompositionAnalysis.isNotEmpty
          ? quarterlySalaryCompositionAnalysis
          : '薪资结构分析',
      salaryStructureAdvice: salaryStructureAdvice.isNotEmpty
          ? salaryStructureAdvice
          : '薪资结构优化建议',
      salaryStructureData: salaryStructureData,
      departmentStats: deptStatsList,
    );
  }

  /// 生成部门详情描述
  String _generateDepartmentDetails(List<dynamic> departmentStats) {
    final buffer = StringBuffer();
    buffer.writeln('本季度内共有${departmentStats.length}个部门：');
    for (var dept in departmentStats) {
      if (dept is Map<String, dynamic>) {
        buffer.writeln(
          '- ${dept['department']}部门：${dept['count']}人，工资总额${(dept['total'] as num).toStringAsFixed(2)}元，平均工资${(dept['average'] as num).toStringAsFixed(2)}元',
        );
      }
    }
    return buffer.toString();
  }

  /// 生成薪资区间描述
  String _generateSalaryRangeDescription(List<dynamic> salaryRanges) {
    final buffer = StringBuffer();
    buffer.writeln('薪资区间分布情况：');
    for (var range in salaryRanges) {
      if (range is SalaryRangeStats) {
        buffer.writeln(
          '- ${range.range}：${range.employeeCount}人，工资总额${range.totalSalary.toStringAsFixed(2)}元，平均工资${range.averageSalary.toStringAsFixed(2)}元',
        );
      } else if (range is Map<String, dynamic>) {
        buffer.writeln(
          '- ${range['range']}：${range['employee_count']}人，工资总额${(range['total_salary'] as num).toStringAsFixed(2)}元，平均工资${(range['average_salary'] as num).toStringAsFixed(2)}元',
        );
      }
    }
    return buffer.toString();
  }

  /// 为季度报告生成专门的 AI 分析提示
  ///
  /// 这个方法创建一个针对季度数据的提示，帮助 AI 更好地理解和分析季度数据的趋势和变化
  String _generateQuarterlyAIPrompt(
    String basePrompt,
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime,
  ) {
    // 计算季度
    final quarter = (startTime.month - 1) ~/ 3 + 1;

    // 提取月度趋势数据
    final monthlyData =
        analysisData['monthlyBreakdown'] as List<dynamic>? ?? [];
    final monthlyTrend = _extractMonthlyTrend(monthlyData);

    // 提取部门数据
    final departmentStats =
        analysisData['departmentStats'] as List<dynamic>? ?? [];
    final departmentTrend = _extractDepartmentTrend(departmentStats);

    // 提取员工变动数据
    final employeeChanges =
        analysisData['monthlyEmployeeChanges'] as List<dynamic>? ?? [];
    final employeeChangeTrend = _extractEmployeeChangeTrend(employeeChanges);

    // 构建增强的提示
    final enhancedPrompt =
        '''
$basePrompt

【季度分析补充信息】
- 分析周期：${startTime.year}年第$quarter季度（${startTime.month}月至${endTime.month}月）
- 月度趋势：$monthlyTrend
- 部门情况：$departmentTrend
- 员工变动：$employeeChangeTrend

请在分析中特别关注季度内的趋势变化、部门间差异、员工流动与薪资的关系，以及与上季度的对比分析。
''';

    return enhancedPrompt;
  }

  /// 提取月度趋势数据
  String _extractMonthlyTrend(List<dynamic> monthlyData) {
    if (monthlyData.isEmpty) return '无数据';

    final buffer = StringBuffer();

    for (int i = 0; i < monthlyData.length; i++) {
      final data = monthlyData[i] as Map<String, dynamic>;
      final month = data['month'] as String? ?? '未知月份';
      final totalSalary = data['totalSalary'] as num? ?? 0;
      final averageSalary = data['averageSalary'] as num? ?? 0;
      final employeeCount = data['employeeCount'] as int? ?? 0;

      if (i > 0) buffer.write('，');
      buffer.write(
        '$month 工资总额 ${totalSalary.toStringAsFixed(2)}元，平均工资 ${averageSalary.toStringAsFixed(2)}元，员工数 $employeeCount 人',
      );
    }

    return buffer.toString();
  }

  /// 提取部门趋势数据
  String _extractDepartmentTrend(List<dynamic> departmentStats) {
    if (departmentStats.isEmpty) return '无数据';

    final buffer = StringBuffer();
    int count = 0;

    for (var dept in departmentStats) {
      if (dept is Map<String, dynamic>) {
        final department = dept['department'] as String? ?? '未知部门';
        final employeeCount = dept['count'] as int? ?? 0;
        final averageSalary = (dept['average'] as num? ?? 0).toDouble();

        if (count > 0) buffer.write('，');
        buffer.write(
          '$department 部门 $employeeCount 人，平均工资 ${averageSalary.toStringAsFixed(2)}元',
        );

        count++;
        if (count >= 5) {
          buffer.write('，等');
          break;
        }
      }
    }

    return buffer.toString();
  }

  /// 提取员工变动趋势
  String _extractEmployeeChangeTrend(List<dynamic> employeeChanges) {
    if (employeeChanges.isEmpty) return '无数据';

    final buffer = StringBuffer();

    for (int i = 0; i < employeeChanges.length; i++) {
      final change = employeeChanges[i] as Map<String, dynamic>;
      final month = change['month'] as int? ?? 0;
      final newEmployees = change['newEmployees'] as List<dynamic>? ?? [];
      final resignedEmployees =
          change['resignedEmployees'] as List<dynamic>? ?? [];

      if (i > 0) buffer.write('，');
      buffer.write(
        '$month月 新入职 ${newEmployees.length}人，离职 ${resignedEmployees.length}人',
      );
    }

    return buffer.toString();
  }

  /// 优化季度数据处理
  ///
  /// 这个方法处理季度数据，确保数据格式一致，并处理可能的缺失值
  Map<String, dynamic> _optimizeQuarterlyData(
    Map<String, dynamic> analysisData,
  ) {
    final optimizedData = Map<String, dynamic>.from(analysisData);

    // 确保月度数据存在且格式一致
    if (!optimizedData.containsKey('monthlyBreakdown') ||
        optimizedData['monthlyBreakdown'] == null) {
      optimizedData['monthlyBreakdown'] = <Map<String, dynamic>>[];
    }

    // 确保部门统计数据存在且格式一致
    if (!optimizedData.containsKey('departmentStats') ||
        optimizedData['departmentStats'] == null) {
      optimizedData['departmentStats'] = <Map<String, dynamic>>[];
    }

    // 确保员工变动数据存在且格式一致
    if (!optimizedData.containsKey('monthlyEmployeeChanges') ||
        optimizedData['monthlyEmployeeChanges'] == null) {
      optimizedData['monthlyEmployeeChanges'] = <Map<String, dynamic>>[];
    }

    // 确保上季度数据存在且格式一致
    if (!optimizedData.containsKey('previousQuarterData') ||
        optimizedData['previousQuarterData'] == null) {
      optimizedData['previousQuarterData'] = <String, dynamic>{};
    }

    // 确保薪资结构数据存在且格式一致
    if (!optimizedData.containsKey('salarySummary') ||
        optimizedData['salarySummary'] == null) {
      optimizedData['salarySummary'] = <String, dynamic>{};
    }

    return optimizedData;
  }
}
