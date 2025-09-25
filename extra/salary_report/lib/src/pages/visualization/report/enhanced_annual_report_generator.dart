// src/report/enhanced_annual_report_generator.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/services/yearly/yearly.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';
import 'package:salary_report/src/isar/salary_list.dart';

/// 增强版年度报告生成器
class EnhancedAnnualReportGenerator implements EnhancedReportGenerator {
  final YearlyChartGenerationService _chartService;
  final YearlyChartGenerationFromJsonService _jsonChartService;
  final YearlyDocxWriterService _docxService;
  final ReportService _reportService;
  final AISummaryService _aiSummaryService;

  EnhancedAnnualReportGenerator({
    YearlyChartGenerationService? chartService,
    YearlyChartGenerationFromJsonService? jsonChartService,
    YearlyDocxWriterService? docxService,
    ReportService? reportService,
    AISummaryService? aiSummaryService,
  }) : _chartService = chartService ?? YearlyChartGenerationService(),
       _jsonChartService =
           jsonChartService ?? YearlyChartGenerationFromJsonService(),
       _docxService = docxService ?? YearlyDocxWriterService(),
       _reportService = reportService ?? ReportService(),
       _aiSummaryService = aiSummaryService ?? AISummaryService();

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
      logger.info('Starting enhanced annual salary report generation...');

      // 1. 生成JSON格式的分析数据
      // 需要将analysisData转换为年度比较数据
      final yearlyComparisonData = _convertToYearlyComparisonData(
        analysisData,
      );

      final jsonString = YearlyAnalysisJsonConverter.convertAnalysisDataToJson(
        analysisData: <String, dynamic>{
          'monthlyComparisons': yearlyComparisonData.monthlyComparisons,
          'startDate': yearlyComparisonData.startDate,
          'endDate': yearlyComparisonData.endDate,
          'monthlySummary': analysisData['monthlySummary'] ?? {},
        },
        departmentStats: departmentStats,
        attendanceStats: attendanceStats,
        previousYearData: previousMonthData,
        year: year,
      );

      // 2. 解析JSON数据
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // 3. 生成自然语言报告
      final naturalLanguageReport =
          YearlyAnalysisJsonConverter.generateYearlyNaturalLanguageReport(
            yearlyData: yearlyComparisonData,
            attendanceStats: attendanceStats,
            year: year,
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

      // 5. 获取年度图表数据
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

      // 6. 生成图表图像（从UI）
      final chartImagesFromUI = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: _convertToSalaryRangeMap(
          _getAggregatedSalaryRanges(analysisData),
        ),
        salaryStructureData: salaryStructureData,
        // 年度报告专用图表数据
        employeeCountPerMonth: employeeCountPerMonth,
        averageSalaryPerMonth: averageSalaryPerMonth,
        totalSalaryPerMonth: totalSalaryPerMonth,
        departmentDetailsPerMonth: departmentDetailsPerMonth,
        lastMonthDepartmentStats: lastMonthDepartmentStats,
      );

      // 7. 生成图表图像（从JSON数据）
      final chartImagesFromJson = await _jsonChartService
          .generateAllChartsFromJson(jsonData: jsonData);

      // 8. 创建组合图表图像集合
      final combinedChartImages = YearlyReportChartImages(
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
        // 新增年度同比环比对比图表
        departmentYearOverYearChart:
            chartImagesFromJson.departmentYearOverYearChart,
        positionYearOverYearChart:
            chartImagesFromJson.positionYearOverYearChart,
      );

      logger.info('analysisData analysisData analysisData: $analysisData');

      // 9. 创建报告内容模型
      final reportContent = await _createReportContentModel(
        jsonData,
        analysisData,
        startTime,
        endTime,
      );

      // 10. 写入报告文件
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: combinedChartImages,
      );

      // 11. 添加报告记录到数据库
      await _reportService.addReportRecord(reportPath);

      logger.info('Enhanced annual report generation complete: $reportPath');

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe(
        'Fatal error during enhanced annual report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 创建薪资结构数据
  /// 支持年度数据聚合，处理不同类型的值
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
      '税前工资': '税前工资',
      '个人养老': '个人养老',
      '个人医疗': '个人医疗',
      '个人失业': '个人失业',
      '个人公积金': '个人公积金',
      '当月个人所得税': '当月个人所得税',
      '税后应实发': '税后应实发',
    };

    // 创建一个Map来存储聚合后的数据
    final Map<String, double> aggregatedData = {};

    // 初始化聚合数据
    salaryStructureFields.forEach((key, _) {
      aggregatedData[key] = 0.0;
    });

    // 记录处理的月份数，用于计算平均值
    int monthCount = 0;

    // 遍历 salarySummary，处理年度数据
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
      } else if (monthData is num) {
        // 如果直接是数值，且key是薪资结构字段
        if (salaryStructureFields.containsKey(monthKey)) {
          aggregatedData[monthKey] = monthData.toDouble();
          if (monthCount == 0) monthCount = 1; // 确保至少有一个月的数据
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

  /// 将analysisData转换为年度比较数据
  MultiMonthComparisonData _convertToYearlyComparisonData(
    Map<String, dynamic> analysisData,
  ) {
    // 从analysisData中提取年度比较数据
    final monthlyComparisons = <MonthlyComparisonData>[];

    // 如果analysisData包含monthlyComparisons字段
    if (analysisData.containsKey('monthlyComparisons') &&
        analysisData['monthlyComparisons'] is List) {
      final monthlyDataList = analysisData['monthlyComparisons'] as List;
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

    // 如果没有monthlyComparisons字段，使用聚合数据创建默认的
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

  Future<YearlyReportContentModel> _createReportContentModel(
    Map<String, dynamic> jsonData,
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // 从JSON数据中提取关键信息来构建报告内容模型
    final keyMetrics = jsonData['key_metrics'] as Map<String, dynamic>;
    final currentYearMetrics =
        keyMetrics['current_year'] as Map<String, dynamic>? ??
        keyMetrics['current_month'] as Map<String, dynamic>;

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
    final totalSalaryGrowthRate = 0.08; // 8% 示例值
    final averageSalaryGrowthRate = 0.05; // 5% 示例值

    String reportTime;
    if (startTime.year == endTime.year) {
      reportTime = '${startTime.year}年';
    } else {
      reportTime = '${startTime.year}年 - ${endTime.year}年';
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

    // 为年度报告创建增强的 AI 分析提示
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

    // 使用增强的年度分析提示
    final enhancedSalaryRangePrompt = _generateYearlyAIPrompt(
      basePromptForSalaryRange,
      analysisData,
      startTime,
      endTime,
    );

    final enhancedDeptAnalysisPrompt = _generateYearlyAIPrompt(
      basePromptForDeptAnalysis,
      analysisData,
      startTime,
      endTime,
    );

    final enhancedKeySalaryPointPrompt = _generateYearlyAIPrompt(
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

    return YearlyReportContentModel(
      reportTitle: '年度工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime: reportTime,
      startTime: '${startTime.year}年',
      endTime: '${endTime.year}年',
      compareLast: '与上年对比',
      totalEmployees: currentYearMetrics['total_employees'] as int,
      totalSalary: (currentYearMetrics['total_salary'] as num).toDouble(),
      averageSalary: (currentYearMetrics['average_salary'] as num).toDouble(),
      departmentCount: departmentStats.length,
      employeeCount: currentYearMetrics['total_unique_employees'] as int? ??
          currentYearMetrics['total_employees'] as int,
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
      salaryRankings: _generateSalaryRankings(analysisData),
      salaryOrder: _generateSalaryOrder(deptStatsList),
      basicSalaryRate: 0.7,
      performanceSalaryRate: 0.3,
      salaryStructure: salaryStructureDescription, // 使用生成的薪资结构描述
      salaryStructureAdvice: salaryStructureAdvice.isNotEmpty
          ? salaryStructureAdvice
          : '薪资结构优化建议',
      salaryStructureData: salaryStructureData,
      departmentStats: deptStatsList,
      // 年度报告专用字段
      employeeCountPerMonth: _extractEmployeeCountPerMonth(jsonData),
      averageSalaryPerMonth: _extractAverageSalaryPerMonth(jsonData),
      totalSalaryPerMonth: _extractTotalSalaryPerMonth(jsonData),
      departmentDetailsPerMonth: _extractDepartmentDetailsPerMonth(jsonData),
      // 年度同比环比对比专用字段
      departmentYearOverYearData:
          analysisData['departmentYearOverYearData']
              as List<Map<String, dynamic>>?,
      positionYearOverYearData:
          analysisData['positionYearOverYearData']
              as List<Map<String, dynamic>>?,
      // 年度报告特有字段
      monthCount: monthCount,
      totalSalaryGrowthRate: totalSalaryGrowthRate,
      averageSalaryGrowthRate: averageSalaryGrowthRate,
      trendAnalysisSummary: _generateYearlyTrendAnalysisSummary(analysisData),
    );
  }

  /// 生成部门详情描述
  String _generateDepartmentDetails(List<dynamic> departmentStats) {
    final buffer = StringBuffer();
    buffer.writeln('本年度内共有${departmentStats.length}个部门：');
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

  /// 生成工资排名描述
  String _generateSalaryRankings(Map<String, dynamic> analysisData) {
    final buffer = StringBuffer();

    // 最高工资员工
    final topEmployees = analysisData['topSalaryEmployees'] as List<dynamic>;
    if (topEmployees.isNotEmpty) {
      buffer.writeln('工资最高的员工：');
      for (var i = 0; i < topEmployees.length && i < 5; i++) {
        final employee = topEmployees[i];
        if (employee is SalaryListRecord) {
          buffer.writeln(
            '- ${employee.name}（${employee.department}）：¥${employee.netSalary}',
          );
        } else if (employee is Map<String, dynamic>) {
          buffer.writeln(
            '- ${employee['name']}（${employee['department']}）：¥${employee['net_salary']}',
          );
        }
      }
    }

    // 最低工资员工
    final bottomEmployees =
        analysisData['bottomSalaryEmployees'] as List<dynamic>;
    if (bottomEmployees.isNotEmpty) {
      buffer.writeln('工资最低的员工：');
      for (var i = 0; i < bottomEmployees.length && i < 5; i++) {
        final employee = bottomEmployees[i];
        if (employee is SalaryListRecord) {
          buffer.writeln(
            '- ${employee.name}（${employee.department}）：¥${employee.netSalary}',
          );
        } else if (employee is Map<String, dynamic>) {
          buffer.writeln(
            '- ${employee['name']}（${employee['department']}）：¥${employee['net_salary']}',
          );
        }
      }
    }

    return buffer.toString();
  }

  /// 生成年度趋势分析总结
  String _generateYearlyTrendAnalysisSummary(Map<String, dynamic> analysisData) {
    final buffer = StringBuffer();
    buffer.writeln('年度趋势分析总结：');

    // 添加月度变化总结
    if (analysisData.containsKey('monthlyComparisons') &&
        analysisData['monthlyComparisons'] is List) {
      final monthlyData = analysisData['monthlyComparisons'] as List;
      if (monthlyData.isNotEmpty) {
        buffer.writeln('1. 月度变化：');
        for (var item in monthlyData) {
          if (item is Map<String, dynamic>) {
            final month = item['month'] as int? ?? 0;
            final totalSalary = item['totalSalary'] as num? ?? 0;
            final employeeCount = item['employeeCount'] as int? ?? 0;
            buffer.writeln(
              '   - $month月：工资总额${totalSalary.toStringAsFixed(2)}元，员工数$employeeCount人',
            );
          }
        }
      }
    }

    // 添加部门变化总结
    if (analysisData.containsKey('departmentStats') &&
        analysisData['departmentStats'] is List) {
      final deptStats = analysisData['departmentStats'] as List;
      if (deptStats.isNotEmpty) {
        buffer.writeln('2. 部门情况：');
        for (var dept in deptStats.take(3)) { // 只显示前3个部门
          if (dept is Map<String, dynamic>) {
            final deptName = dept['department'] as String? ?? '未知部门';
            final empCount = dept['employeeCount'] as int? ?? 0;
            final avgSalary = dept['averageNetSalary'] as num? ?? 0;
            buffer.writeln(
              '   - $deptName部门：$empCount人，平均工资${avgSalary.toStringAsFixed(2)}元',
            );
          }
        }
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
    buffer.write('本年度部门平均薪资排名（从高到低）：');

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

  /// 为年度报告生成专门的 AI 分析提示
  String _generateYearlyAIPrompt(
    String basePrompt,
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime,
  ) {
    // 提取月度趋势数据
    final monthlyData =
        analysisData['monthlyComparisons'] as List<dynamic>? ?? [];
    final monthlyTrend = _extractYearlyMonthlyTrend(monthlyData);

    // 提取部门数据
    final departmentStats =
        analysisData['departmentStats'] as List<dynamic>? ?? [];
    final departmentTrend = _extractYearlyDepartmentTrend(departmentStats);

    // 提取员工变动数据
    final employeeChanges =
        analysisData['monthlyEmployeeChanges'] as List<dynamic>? ?? [];
    final employeeChangeTrend = _extractYearlyEmployeeChangeTrend(employeeChanges);

    // 构建增强的提示
    final enhancedPrompt =
        '''
$basePrompt

【年度分析补充信息】
- 分析周期：${startTime.year}年度（1月至12月）
- 月度趋势：$monthlyTrend
- 部门情况：$departmentTrend
- 员工变动：$employeeChangeTrend

请在分析中特别关注年度内的趋势变化、季节性波动、部门间差异、员工流动与薪资的关系，以及与上年度的对比分析。
''';

    return enhancedPrompt;
  }

  /// 提取年度月度趋势数据
  String _extractYearlyMonthlyTrend(List<dynamic> monthlyData) {
    if (monthlyData.isEmpty) return '无数据';

    final buffer = StringBuffer();

    for (int i = 0; i < monthlyData.length; i++) {
      final data = monthlyData[i] as Map<String, dynamic>;
      final month = (data['month'] ?? '未知月份')?.toString();
      final totalSalary = data['totalSalary'] as num? ?? 0;
      final averageSalary = data['averageSalary'] as num? ?? 0;
      final employeeCount = data['employeeCount'] as int? ?? 0;

      if (i > 0) buffer.write('，');
      buffer.write(
        '$month月 工资总额 ${totalSalary.toStringAsFixed(2)}元，平均工资 ${averageSalary.toStringAsFixed(2)}元，员工数 $employeeCount 人',
      );
    }

    return buffer.toString();
  }

  /// 提取年度部门趋势数据
  String _extractYearlyDepartmentTrend(List<dynamic> departmentStats) {
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

  /// 提取年度员工变动趋势
  String _extractYearlyEmployeeChangeTrend(List<dynamic> employeeChanges) {
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
}

String _generateEmployeeDetails(Map<String, dynamic> analysisData) {
  final buffer = StringBuffer();

  logger.info('生成员工详情数据... ${analysisData['comparisonData']}');

  // 获取年度比较数据
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

    buffer.write('本年度员工分布情况：');

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
    buffer.write('本年度共涉及 $totalUniqueEmployees 名员工（发放工资 $totalEmployees 人次）');
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
      keyMetrics['current_year'] as Map<String, dynamic>? ??
      keyMetrics['current_month'] as Map<String, dynamic>? ?? {};

  final totalSalary = currentPeriod['total_salary'] as num? ?? 0;
  final averageSalary = currentPeriod['average_salary'] as num? ?? 0;
  final totalEmployees = currentPeriod['total_employees'] as int? ?? 0;

  return '本年度发放工资 $totalEmployees 人次，工资总额为 ${totalSalary.toStringAsFixed(2)} 元，平均工资为 ${averageSalary.toStringAsFixed(2)} 元';
}

/// 计算两个日期之间的月份数
int _calculateMonthCount(DateTime startTime, DateTime endTime) {
  final years = endTime.year - startTime.year;
  final months = endTime.month - startTime.month;
  return years * 12 + months + 1; // +1 因为包含起始和结束月份
}
