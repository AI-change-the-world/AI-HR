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
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/isar/salary_list.dart';
import 'package:salary_report/src/utils/multi_month_analysis_json_converter.dart';

/// 增强版多月报告生成器
class EnhancedMultiMonthReportGenerator implements EnhancedReportGenerator {
  final MultiMonthChartGenerationService _chartService;
  final MultiMonthChartGenerationFromJsonService _jsonChartService;
  final MultiMonthDocxWriterService _docxService;
  final DataAnalysisService _analysisService;
  final ReportService _reportService;

  EnhancedMultiMonthReportGenerator({
    MultiMonthChartGenerationService? chartService,
    MultiMonthChartGenerationFromJsonService? jsonChartService,
    MultiMonthDocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
  }) : _chartService = chartService ?? MultiMonthChartGenerationService(),
       _jsonChartService =
           jsonChartService ?? MultiMonthChartGenerationFromJsonService(),
       _docxService = docxService ?? MultiMonthDocxWriterService(),
       _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService();

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

      // 4. 构建薪资结构数据
      final salaryStructureData = _createSalaryStructureData(
        analysisData.containsKey('salarySummary')
            ? analysisData['salarySummary'] as Map<String, dynamic>
            : null,
      );

      logger.info(
        'analysisData["salaryRanges"] data: ${_getAggregatedSalaryRanges(analysisData).runtimeType}',
      );

      // 4. 生成图表图像（从UI）
      final chartImagesFromUI = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: _convertToSalaryRangeMap(
          _getAggregatedSalaryRanges(analysisData),
        ),
        salaryStructureData: salaryStructureData, // 添加薪资结构数据
      );

      // 5. 生成图表图像（从JSON数据）
      final chartImagesFromJson = await _jsonChartService
          .generateAllChartsFromJson(jsonData: jsonData);

      // 6. 创建组合图表图像集合
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
      final reportContent = _createReportContentModel(
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

    // 遍历 salarySummary，提取薪资结构相关字段
    salarySummary.forEach((key, value) {
      if (salaryStructureFields.containsKey(key)) {
        salaryStructureData.add({
          'category': key,
          'value': double.tryParse(value.toString()) ?? 0.0,
        });
      }
    });

    return salaryStructureData;
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

  MultiMonthReportContentModel _createReportContentModel(
    Map<String, dynamic> jsonData,
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime,
  ) {
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
      employeeDetails: jsonData['key_param'] as String,
      departmentDetails: _generateDepartmentDetails(departmentStats),
      salaryRangeDescription: _generateSalaryRangeDescription(salaryRanges),
      salaryRangeFeatureSummary: '薪资区间特征总结',
      departmentSalaryAnalysis: '部门工资分析',
      keySalaryPoint: '关键工资点',
      salaryRankings: "",
      basicSalaryRate: 0.7,
      performanceSalaryRate: 0.3,
      salaryStructure: salaryStructureDescription, // 使用生成的薪资结构描述
      salaryStructureAdvice: '薪资结构优化建议',
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

  /// 计算月份数量
  int _calculateMonthCount(DateTime startTime, DateTime endTime) {
    final years = endTime.year - startTime.year;
    final months = endTime.month - startTime.month;
    return years * 12 + months + 1; // +1 因为包含起始和结束月份
  }

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

  /// 生成薪资结构的自然语言描述
  String _generateSalaryStructureDescription(
    List<Map<String, dynamic>> salaryStructureData,
  ) {
    if (salaryStructureData.isEmpty) {
      return '暂无薪资结构数据。';
    }

    final buffer = StringBuffer();
    buffer.write('薪资结构分析如下：');

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
        if (item is Map<String, dynamic>) {
          return {
            'month': '${item['year']}年${item['month']}月',
            'year': item['year'],
            'monthNum': item['month'],
            'averageSalary': item['average_salary'],
          };
        }
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
        if (item is Map<String, dynamic>) {
          return {
            'month': '${item['year']}年${item['month']}月',
            'year': item['year'],
            'monthNum': item['month'],
            'totalSalary': item['total_salary'],
          };
        }
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

    // 如果没有monthlyData字段，创建一个默认的
    if (monthlyComparisons.isEmpty) {
      monthlyComparisons.add(
        MonthlyComparisonData(
          year: analysisData['year'] as int? ?? DateTime.now().year,
          month: analysisData['month'] as int? ?? DateTime.now().month,
          employeeCount: analysisData['totalEmployees'] as int? ?? 0,
          totalSalary: (analysisData['totalSalary'] as num? ?? 0).toDouble(),
          averageSalary: (analysisData['averageSalary'] as num? ?? 0)
              .toDouble(),
          highestSalary: (analysisData['highestSalary'] as num? ?? 0)
              .toDouble(),
          lowestSalary: (analysisData['lowestSalary'] as num? ?? 0).toDouble(),
          departmentStats: _extractDepartmentStats(analysisData, {
            'year': analysisData['year'],
            'month': analysisData['month'],
          }),
          salaryRangeStats: _extractSalaryRangeStats(analysisData, {
            'year': analysisData['year'],
            'month': analysisData['month'],
          }),
          workers: _extractWorkers(analysisData, {
            'year': analysisData['year'],
            'month': analysisData['month'],
          }),
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
}
