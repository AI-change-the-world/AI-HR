// src/report/enhanced_monthly_report_generator.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/services/monthly/monthly.dart';
import 'package:salary_report/src/services/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/services/ai_summary_service.dart';

/// 增强版单月报告生成器
class EnhancedMonthlyReportGenerator implements EnhancedReportGenerator {
  final MonthlyChartGenerationService _chartService;
  final MonthlyDocxWriterService _docxService;
  final DataAnalysisService _analysisService;
  final ReportService _reportService;
  final AISummaryService _aiSummaryService;

  EnhancedMonthlyReportGenerator({
    MonthlyChartGenerationService? chartService,
    MonthlyDocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
    AISummaryService? aiSummaryService,
  }) : _chartService = chartService ?? MonthlyChartGenerationService(),
       _docxService = docxService ?? MonthlyDocxWriterService(),
       _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService(),
       _aiSummaryService = aiSummaryService ?? AISummaryService();

  /// 生成包含描述和图表的增强版单月报告
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
      logger.info('Starting enhanced monthly salary report generation...');

      // 1. 构建薪资结构数据
      final salaryStructureData = createSalaryStructureData(
        analysisData.containsKey('salarySummary')
            ? analysisData['salarySummary'] as Map<String, dynamic>
            : null,
      );

      // 2. 准备顶级员工数据
      final topEmployeesData = _prepareTopEmployeesData(analysisData);

      // 3. 准备部门薪资区间数据
      final departmentSalaryRangeData = _prepareDepartmentSalaryRangeData(
        analysisData,
      );

      // 4. 生成所有图表
      final chartImages = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: _convertToSalaryRangeMap(
          analysisData['salaryRanges'] as List<dynamic>,
        ),
        salaryStructureData: salaryStructureData,
        attendanceStats: attendanceStats,
        topEmployeesData: topEmployeesData,
        departmentSalaryRangeData: departmentSalaryRangeData,
      );

      // 5. 创建报告内容模型
      final reportContent = await _createReportContentModel(
        analysisData,
        startTime,
        endTime,
        previousMonthData: previousMonthData,
      );

      // 6. 写入报告文件
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: chartImages,
      );

      // 9. 添加报告记录到数据库
      await _reportService.addReportRecord(reportPath);

      logger.info('Enhanced monthly report generation complete: $reportPath');

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe(
        'Fatal error during enhanced monthly report generation: $e',
        e,
        stackTrace,
      );
      logger.severe(stackTrace);
      rethrow;
    }
  }

  /// 准备顶级员工数据
  @Deprecated("工资排名没有用，不要增加攀比心理")
  List<dynamic>? _prepareTopEmployeesData(Map<String, dynamic> analysisData) {
    if (!analysisData.containsKey('topSalaryEmployees')) return null;

    final topEmployees = analysisData['topSalaryEmployees'] as List<dynamic>;
    return topEmployees.map((employee) {
      if (employee is Map<String, dynamic>) {
        return {
          'name': employee['name'] ?? '',
          'net_salary':
              double.tryParse(
                employee['netSalary']?.toString().replaceAll(
                      RegExp(r'[^\d.-]'),
                      '',
                    ) ??
                    '0',
              ) ??
              0.0,
        };
      }
      return {'name': employee.toString(), 'net_salary': 0.0};
    }).toList();
  }

  /// 准备部门薪资区间数据
  List<dynamic>? _prepareDepartmentSalaryRangeData(
    Map<String, dynamic> analysisData,
  ) {
    if (!analysisData.containsKey('departmentSalaryRangeStats')) return null;

    final deptSalaryRangeStats =
        analysisData['departmentSalaryRangeStats'] as List<dynamic>;

    // 按部门分组数据
    final Map<String, List<Map<String, dynamic>>> departmentGroups = {};

    for (var stat in deptSalaryRangeStats) {
      if (stat is Map<String, dynamic>) {
        final department = stat['department'] as String? ?? '';
        final salaryRange = stat['salaryRange'] as String? ?? '';
        final employeeCount = stat['employeeCount'] as int? ?? 0;

        if (!departmentGroups.containsKey(department)) {
          departmentGroups[department] = [];
        }

        departmentGroups[department]!.add({
          'salary_range': salaryRange,
          'employee_count': employeeCount,
        });
      }
    }

    // 转换为所需格式
    return departmentGroups.entries.map((entry) {
      return {'department': entry.key, 'salary_ranges': entry.value};
    }).toList();
  }

  /// 创建薪资结构数据
  List<Map<String, dynamic>> createSalaryStructureData(
    Map<String, dynamic>? salarySummary,
  ) {
    logger.info('salarySummary  $salarySummary');

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
      // '税前工资': '税前工资',
      // '个人养老': '个人养老',
      // '个人医疗': '个人医疗',
      // '个人失业': '个人失业',
      // '个人公积金': '个人公积金',
      // '当月个人所得税': '当月个人所得税',
      // '税后应实发': '税后应实发',
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

  /// 创建报告内容模型
  Future<MonthlyReportContentModel> _createReportContentModel(
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime, {
    Map<String, dynamic>? previousMonthData,
  }) async {
    // 直接从analysisData中提取关键信息来构建报告内容模型

    // 获取部门统计信息
    final departmentStats = analysisData['departmentStats'] as List<dynamic>;

    // 获取薪资区间信息
    final salaryRanges = analysisData['salaryRanges'] as List<dynamic>;

    // 构建薪资结构数据
    final salaryStructureData = createSalaryStructureData(
      analysisData.containsKey('salarySummary')
          ? analysisData['salarySummary'] as Map<String, dynamic>
          : null,
    );

    logger.info('salaryStructureData  $salaryStructureData');

    // 生成薪资结构描述
    final salaryStructureDescription = generateSalaryStructureDescription(
      salaryStructureData,
    );

    logger.info('salaryStructureDescription   $salaryStructureDescription');

    String reportTime;
    if (startTime.month == endTime.month && startTime.year == endTime.year) {
      reportTime = '${startTime.year}年${startTime.month}月';
    } else {
      reportTime =
          '${startTime.year}年${startTime.month}月 - '
          '${endTime.year}年${endTime.month}月';
    }

    // 生成AI分析内容
    final salaryRangeFeatureSummary = await _aiSummaryService
        .generateSalaryRangeFeatureSummary(
          _convertToSalaryRangeMapForAI(salaryRanges),
          departmentStats
              .map((dept) => _convertToDepartmentSalaryStats(dept))
              .toList(),
        );

    final departmentSalaryAnalysis = await _aiSummaryService
        .generateDepartmentSalaryAnalysis(
          departmentStats
              .map((dept) => _convertToDepartmentSalaryStats(dept))
              .toList(),
        );

    final keySalaryPoint = await _aiSummaryService.generateKeySalaryPoint(
      departmentStats
          .map((dept) => _convertToDepartmentSalaryStats(dept))
          .toList(),
      _convertToSalaryRangeMapForAI(salaryRanges),
    );

    final salaryStructureAdvice = await _aiSummaryService
        .generateSalaryStructureAdvice(
          employeeDetails: analysisData["monthlySimpleDescription"],
          departmentDetails: _generateDepartmentDetails(departmentStats),
          salaryRange: _generateSalaryRangeDescription(salaryRanges),
          salaryRangeFeature: salaryRangeFeatureSummary.isNotEmpty
              ? salaryRangeFeatureSummary
              : '暂无薪资区间特征数据',
        );

    return MonthlyReportContentModel(
      reportTitle: '月度工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime: reportTime,
      startTime: '${startTime.year}年${startTime.month}月1日',
      endTime:
          '${endTime.year}年${endTime.month}月${getLastDayOfMonth(endTime.year, endTime.month)}日',
      compareLast: _generateKeyMetricsDescription(
        analysisData,
        previousMonthData,
      ),
      totalEmployees: analysisData['totalEmployees'] as int? ?? 0,
      totalSalary: (analysisData['totalSalary'] as num? ?? 0).toDouble(),
      averageSalary: (analysisData['averageSalary'] as num? ?? 0).toDouble(),
      departmentCount: departmentStats.length,
      employeeCount: analysisData['totalUniqueEmployees'] as int? ?? 0,
      employeeDetails: analysisData["monthlySimpleDescription"],
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
      salaryStructure: salaryStructureDescription, // 使用生成的薪资结构描述
      salaryStructureAdvice: salaryStructureAdvice.isNotEmpty
          ? salaryStructureAdvice
          : '薪资结构优化建议',
      salaryStructureData: salaryStructureData,
      departmentStats: departmentStats
          .map((dept) => _convertToDepartmentSalaryStats(dept))
          .toList(),
    );
  }

  int getLastDayOfMonth(int year, int month) {
    // DateTime(year, month + 1, 0) → 当月最后一天
    final lastDay = DateTime(year, month + 1, 0);
    return lastDay.day;
  }

  /// 生成部门详情描述
  String _generateDepartmentDetails(List<dynamic> departmentStats) {
    if (departmentStats.isEmpty) {
      return '本月暂无部门数据。';
    }

    final buffer = StringBuffer();
    buffer.write('本月共有${departmentStats.length}个部门，具体情况如下：');

    for (int i = 0; i < departmentStats.length; i++) {
      if (departmentStats[i] is Map<String, dynamic>) {
        final dept = departmentStats[i] as Map<String, dynamic>;
        buffer.write('${dept['department']}部门有${dept['count']}名员工，');
        buffer.write('工资总额为${(dept['total'] as num).toStringAsFixed(2)}元，');
        buffer.write('平均工资为${(dept['average'] as num).toStringAsFixed(2)}元');

        // 添加最高和最低工资信息
        if (dept.containsKey('max') || dept.containsKey('max_salary')) {
          final maxSalary =
              (dept['max'] as num? ?? dept['max_salary'] as num? ?? 0)
                  .toDouble();
          buffer.write('，最高工资为${maxSalary.toStringAsFixed(2)}元');
        }

        if (dept.containsKey('min') || dept.containsKey('min_salary')) {
          final minSalary =
              (dept['min'] as num? ?? dept['min_salary'] as num? ?? 0)
                  .toDouble();
          buffer.write('，最低工资为${minSalary.toStringAsFixed(2)}元');
        }
      } else if (departmentStats[i] is DepartmentSalaryStats) {
        final dept = departmentStats[i] as DepartmentSalaryStats;
        buffer.write('${dept.department}部门有${dept.employeeCount}名员工，');
        buffer.write('工资总额为${dept.totalNetSalary.toStringAsFixed(2)}元，');
        buffer.write('平均工资为${dept.averageNetSalary.toStringAsFixed(2)}元');
        buffer.write('，最高工资为${dept.maxSalary.toStringAsFixed(2)}元');
        buffer.write('，最低工资为${dept.minSalary.toStringAsFixed(2)}元');
      }

      if (i < departmentStats.length - 1) {
        buffer.write('；');
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 生成薪资区间描述
  String _generateSalaryRangeDescription(List<dynamic> salaryRanges) {
    if (salaryRanges.isEmpty) {
      return '暂无薪资区间分布数据。';
    }

    final buffer = StringBuffer();
    buffer.write('薪资区间分布情况如下：');

    for (int i = 0; i < salaryRanges.length; i++) {
      if (salaryRanges[i] is SalaryRangeStats) {
        final range = salaryRanges[i] as SalaryRangeStats;
        buffer.write('${range.range}区间有${range.employeeCount}名员工，');
        buffer.write('工资总额为${range.totalSalary.toStringAsFixed(2)}元，');
        buffer.write('平均工资为${range.averageSalary.toStringAsFixed(2)}元');
      } else if (salaryRanges[i] is Map<String, dynamic>) {
        final range = salaryRanges[i] as Map<String, dynamic>;
        buffer.write('${range['range']}区间有${range['employee_count']}名员工，');
        buffer.write(
          '工资总额为${(range['total_salary'] as num).toStringAsFixed(2)}元，',
        );
        buffer.write(
          '平均工资为${(range['average_salary'] as num).toStringAsFixed(2)}元',
        );
      }

      if (i < salaryRanges.length - 1) {
        buffer.write('；');
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 生成薪资结构的自然语言描述
  String generateSalaryStructureDescription(
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

  /// 将动态对象转换为DepartmentSalaryStats对象
  DepartmentSalaryStats _convertToDepartmentSalaryStats(dynamic dept) {
    if (dept is DepartmentSalaryStats) {
      return dept;
    } else if (dept is Map<String, dynamic>) {
      return DepartmentSalaryStats(
        department: dept['department'] as String? ?? '未知部门',
        employeeCount:
            dept['count'] as int? ?? dept['employee_count'] as int? ?? 0,
        averageNetSalary:
            (dept['average'] as num? ?? dept['average_salary'] as num? ?? 0)
                .toDouble(),
        totalNetSalary:
            (dept['total'] as num? ?? dept['total_salary'] as num? ?? 0)
                .toDouble(),
        year: dept['year'] as int? ?? DateTime.now().year,
        month: dept['month'] as int? ?? DateTime.now().month,
        maxSalary: (dept['max'] as num? ?? dept['max_salary'] as num? ?? 0)
            .toDouble(), // 添加最高工资
        minSalary: (dept['min'] as num? ?? dept['min_salary'] as num? ?? 0)
            .toDouble(), // 添加最低工资
      );
    } else {
      return DepartmentSalaryStats(
        department: '未知部门',
        employeeCount: 0,
        averageNetSalary: 0.0,
        totalNetSalary: 0.0,
        year: DateTime.now().year,
        month: DateTime.now().month,
        maxSalary: 0.0, // 添加最高工资
        minSalary: 0.0, // 添加最低工资
      );
    }
  }

  /// 生成部门和岗位薪资描述
  String _generateSalaryRankings(Map<String, dynamic> analysisData) {
    final buffer = StringBuffer();

    logger.info("生成部门薪资排名 ${analysisData['departmentStats']}");

    // 部门薪资排名
    if (analysisData.containsKey('departmentStats') &&
        analysisData['departmentStats'] is List<dynamic>) {
      final departmentStats = analysisData['departmentStats'] as List<dynamic>;
      if (departmentStats.isNotEmpty) {
        // 按平均工资排序
        final sortedDepartments = List<dynamic>.from(departmentStats);
        sortedDepartments.sort((a, b) {
          double avgSalaryA = 0, avgSalaryB = 0;

          if (a is Map<String, dynamic>) {
            avgSalaryA =
                (a['average'] as num? ?? a['average_salary'] as num? ?? 0)
                    .toDouble();
          } else if (a is DepartmentSalaryStats) {
            avgSalaryA = a.averageNetSalary;
          }

          if (b is Map<String, dynamic>) {
            avgSalaryB =
                (b['average'] as num? ?? b['average_salary'] as num? ?? 0)
                    .toDouble();
          } else if (b is DepartmentSalaryStats) {
            avgSalaryB = b.averageNetSalary;
          }

          return avgSalaryB.compareTo(avgSalaryA); // 降序排列
        });

        for (int i = 0; i < sortedDepartments.length && i < 5; i++) {
          final dept = sortedDepartments[i];
          String departmentName = '未知部门';
          double averageSalary = 0;
          int employeeCount = 0;
          double maxSalary = 0;
          double minSalary = 0;

          if (dept is Map<String, dynamic>) {
            departmentName = dept['department'] as String? ?? '未知部门';
            averageSalary =
                (dept['average'] as num? ?? dept['average_salary'] as num? ?? 0)
                    .toDouble();
            employeeCount =
                dept['count'] as int? ?? dept['employee_count'] as int? ?? 0;
            maxSalary = (dept['max'] as num? ?? dept['max_salary'] as num? ?? 0)
                .toDouble();
            minSalary = (dept['min'] as num? ?? dept['min_salary'] as num? ?? 0)
                .toDouble();
          } else if (dept is DepartmentSalaryStats) {
            departmentName = dept.department;
            averageSalary = dept.averageNetSalary;
            employeeCount = dept.employeeCount;
            maxSalary = dept.maxSalary;
            minSalary = dept.minSalary;
          }

          buffer.write(
            '$departmentName部门有$employeeCount名员工，平均工资为${averageSalary.toStringAsFixed(2)}元',
          );

          // 总是添加最高和最低工资信息
          buffer.write(
            '，最高工资为${maxSalary.toStringAsFixed(2)}元，最低工资为${minSalary.toStringAsFixed(2)}元',
          );

          if (i < sortedDepartments.length - 1 && i < 4) {
            buffer.write('；');
          }
        }
        buffer.write('。');
      }
    }

    // 岗位薪资情况（如果有岗位统计数据）
    if (analysisData.containsKey('positionStats') &&
        analysisData['positionStats'] is List<dynamic>) {
      final positionStats = analysisData['positionStats'] as List<dynamic>;
      if (positionStats.isNotEmpty) {
        buffer.write('各岗位薪资情况如下：');

        for (int i = 0; i < positionStats.length && i < 5; i++) {
          final position = positionStats[i];
          if (position is Map<String, dynamic>) {
            final positionName = position['position'] as String? ?? '未知岗位';
            final employeeCount = position['employeeCount'] as int? ?? 0;
            final averageSalary = (position['averageSalary'] as num? ?? 0)
                .toDouble();
            final totalSalary = (position['totalSalary'] as num? ?? 0)
                .toDouble();
            final maxSalary = (position['maxSalary'] as num? ?? 0).toDouble();
            final minSalary = (position['minSalary'] as num? ?? 0).toDouble();

            buffer.write(
              '$positionName岗位有$employeeCount名员工，平均工资为${averageSalary.toStringAsFixed(2)}元',
            );

            // 总是添加最高和最低工资信息
            buffer.write(
              '，最高工资为${maxSalary.toStringAsFixed(2)}元，最低工资为${minSalary.toStringAsFixed(2)}元',
            );

            buffer.write('，工资总额为${totalSalary.toStringAsFixed(2)}元');

            if (i < positionStats.length - 1 && i < 4) {
              buffer.write('；');
            }
          }
        }
        buffer.write('。');
      }
    }

    return buffer.toString();
  }

  /// 生成关键指标的自然语言描述（从MonthlyAnalysisJsonConverter整合）
  String _generateKeyMetricsDescription(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousMonthData,
  ) {
    logger.info("_generateKeyMetricsDescription $analysisData");

    final gini = analysisData['giniCoef'] as double? ?? 0.0;
    final lastGini = analysisData['lastMonthGiniCoef'] as double? ?? 0.0;

    final totalEmployees = analysisData['totalEmployees'] as int? ?? 0;
    final totalUniqueEmployees =
        analysisData['totalUniqueEmployees'] as int? ?? 0;
    final totalSalary = (analysisData['totalSalary'] as num? ?? 0).toDouble();
    final averageSalary = (analysisData['averageSalary'] as num? ?? 0)
        .toDouble();
    final highestSalary = (analysisData['highestSalary'] as num? ?? 0)
        .toDouble();
    final lowestSalary = (analysisData['lowestSalary'] as num? ?? 0).toDouble();

    final buffer = StringBuffer();
    buffer.write('本月共有员工$totalEmployees人，');
    buffer.write('工资总额为${totalSalary.toStringAsFixed(2)}元，');
    buffer.write('平均工资为${averageSalary.toStringAsFixed(2)}元，');
    buffer.write('最高工资为${highestSalary.toStringAsFixed(2)}元，');
    buffer.write('最低工资为${lowestSalary.toStringAsFixed(2)}元。');
    if (gini > 0) {
      buffer.write(analysisData['giniCoefDetails'] as String? ?? "");
    }

    if (previousMonthData != null) {
      final prevTotalSalary = (previousMonthData['totalSalary'] as num? ?? 0)
          .toDouble();
      final prevAverageSalary =
          (previousMonthData['averageSalary'] as num? ?? 0).toDouble();
      final prevHighestSalary =
          (previousMonthData['highestSalary'] as num? ?? 0).toDouble();
      final prevLowestSalary = (previousMonthData['lowestSalary'] as num? ?? 0)
          .toDouble();

      final totalSalaryChange = totalSalary - prevTotalSalary;
      final averageSalaryChange = averageSalary - prevAverageSalary;
      final highestSalaryChange = highestSalary - prevHighestSalary;
      final lowestSalaryChange = lowestSalary - prevLowestSalary;

      final totalSalaryChangePercent = prevTotalSalary > 0
          ? (totalSalaryChange / prevTotalSalary * 100).toStringAsFixed(2)
          : '0.00';
      final averageSalaryChangePercent = prevAverageSalary > 0
          ? (averageSalaryChange / prevAverageSalary * 100).toStringAsFixed(2)
          : '0.00';
      final highestSalaryChangePercent = prevHighestSalary > 0
          ? (highestSalaryChange / prevHighestSalary * 100).toStringAsFixed(2)
          : '0.00';
      final lowestSalaryChangePercent = prevLowestSalary > 0
          ? (lowestSalaryChange / prevLowestSalary * 100).toStringAsFixed(2)
          : '0.00';

      buffer.write(
        '与上月相比，工资总额${totalSalaryChange >= 0 ? "增加" : "减少"}${totalSalaryChange.abs().toStringAsFixed(2)}元($totalSalaryChangePercent%)，',
      );
      buffer.write(
        '平均工资${averageSalaryChange >= 0 ? "上升" : "下降"}${averageSalaryChange.abs().toStringAsFixed(2)}元($averageSalaryChangePercent%)，',
      );
      buffer.write(
        '最高工资${highestSalaryChange >= 0 ? "上升" : "下降"}${highestSalaryChange.abs().toStringAsFixed(2)}元($highestSalaryChangePercent%)，',
      );
      buffer.write(
        '最低工资${lowestSalaryChange >= 0 ? "上升" : "下降"}${lowestSalaryChange.abs().toStringAsFixed(2)}元($lowestSalaryChangePercent%)。',
      );
      if (lastGini > 0) {
        final diff = gini - lastGini;
        if (diff == 0) {
          buffer.write(" 与上月相比，GINI系数无变化。");
        } else {
          buffer.write(
            " 与上月相比，GINI系数${diff >= 0 ? "上升" : "下降"}${diff.abs().toStringAsFixed(2)}，",
          );
          buffer.write(diff > 0 ? "工资差距有所扩大。" : "工资差距有所缩小。");
        }
      }
    }

    return buffer.toString();
  }

  /// 生成考勤统计数据的自然语言描述（从MonthlyAnalysisJsonConverter整合）
  String _generateAttendanceStatsDescription(
    List<AttendanceStats> attendanceStats,
  ) {
    if (attendanceStats.isEmpty) {
      return '暂无考勤统计数据。';
    }

    final buffer = StringBuffer();
    buffer.write('考勤情况统计如下：');

    for (int i = 0; i < attendanceStats.length && i < 10; i++) {
      final stat = attendanceStats[i];
      buffer.write('${stat.name}(${stat.department})，');
      buffer.write('病假${stat.sickLeaveDays}天，');
      buffer.write('事假${stat.leaveDays}天，');
      buffer.write('缺勤${stat.absenceCount}次，');
      buffer.write('旷工${stat.truancyDays}天');
      if (i < attendanceStats.length - 1 && i < 9) {
        buffer.write('；');
      }
    }

    if (attendanceStats.length > 10) {
      buffer.write('；还有${attendanceStats.length - 10}条记录未显示');
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 生成员工变动情况的自然语言描述（从MonthlyAnalysisJsonConverter整合）
  String _generateEmployeeChangesDescription(
    Map<String, dynamic> analysisData,
    Map<String, dynamic>? previousMonthData,
  ) {
    if (previousMonthData == null ||
        !analysisData.containsKey('currentEmployees') ||
        !previousMonthData.containsKey('previousEmployees')) {
      return '无人员变动数据';
    }

    // 获取当前月和上月的员工列表
    final currentEmployees =
        analysisData['currentEmployees'] as List<MinimalEmployeeInfo>;
    final previousEmployees =
        previousMonthData['previousEmployees'] as List<MinimalEmployeeInfo>;

    // 创建员工标识集合（姓名+部门）
    final currentEmployeeSet = <String>{};
    final previousEmployeeSet = <String>{};

    // 构建当前月员工标识
    for (var emp in currentEmployees) {
      currentEmployeeSet.add('${emp.name}_${emp.department}');
    }

    // 构建上月员工标识
    for (var emp in previousEmployees) {
      previousEmployeeSet.add('${emp.name}_${emp.department}');
    }

    // 计算新增和离职员工
    final newEmployees = currentEmployeeSet.difference(previousEmployeeSet);
    final resignedEmployees = previousEmployeeSet.difference(
      currentEmployeeSet,
    );

    // 构建自然语言描述
    final buffer = StringBuffer();

    if (newEmployees.isEmpty && resignedEmployees.isEmpty) {
      buffer.write('本月无人员变动');
    } else {
      if (newEmployees.isNotEmpty) {
        buffer.write('本月新增${newEmployees.length}名员工');
        // 列出新增员工的姓名和部门
        final newEmployeeDetails = <String>[];
        for (var emp in currentEmployees) {
          final identifier = '${emp.name}_${emp.department}';
          if (newEmployees.contains(identifier) &&
              newEmployeeDetails.length < 5) {
            newEmployeeDetails.add('${emp.name}(${emp.department})');
          }
        }
        if (newEmployeeDetails.isNotEmpty) {
          buffer.write('，分别为${newEmployeeDetails.join('、')}');
        }
      }

      if (resignedEmployees.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write('；');
        buffer.write('本月离职${resignedEmployees.length}名员工');
        // 列出离职员工的姓名和部门
        final resignedEmployeeDetails = <String>[];
        for (var emp in previousEmployees) {
          final identifier = '${emp.name}_${emp.department}';
          if (resignedEmployees.contains(identifier) &&
              resignedEmployeeDetails.length < 5) {
            resignedEmployeeDetails.add('${emp.name}(${emp.department})');
          }
        }
        if (resignedEmployeeDetails.isNotEmpty) {
          buffer.write('，分别为${resignedEmployeeDetails.join('、')}');
        }
      }
    }

    return buffer.toString();
  }

  /// 生成工资最高员工的自然语言描述（从MonthlyAnalysisJsonConverter整合）
  String _generateTopEmployeesDescription(Map<String, dynamic> analysisData) {
    if (!analysisData.containsKey('topSalaryEmployees')) {
      return '暂无工资最高员工数据。';
    }

    final topEmployees = analysisData['topSalaryEmployees'] as List;

    if (topEmployees.isEmpty) {
      return '暂无工资最高员工数据。';
    }

    final buffer = StringBuffer();
    buffer.write('工资最高的员工有：');

    for (int i = 0; i < topEmployees.length && i < 5; i++) {
      final employee = topEmployees[i];
      if (employee is Map<String, dynamic>) {
        final name = employee['name'] as String? ?? '';
        final department = employee['department'] as String? ?? '';
        final salaryStr =
            employee['netSalary']?.toString().replaceAll(
              RegExp(r'[^\d.-]'),
              '',
            ) ??
            '0';
        final salary = double.tryParse(salaryStr) ?? 0;
        buffer.write('$name($department)，工资为${salary.toStringAsFixed(2)}元');
        if (i < topEmployees.length - 1 && i < 4) {
          buffer.write('；');
        }
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 生成工资最低员工的自然语言描述（从MonthlyAnalysisJsonConverter整合）
  @Deprecated("工资排名没有用，不要增加攀比心理")
  String _generateBottomEmployeesDescription(
    Map<String, dynamic> analysisData,
  ) {
    if (!analysisData.containsKey('bottomSalaryEmployees')) {
      return '暂无工资最低员工数据。';
    }

    final bottomEmployees = analysisData['bottomSalaryEmployees'] as List;

    if (bottomEmployees.isEmpty) {
      return '暂无工资最低员工数据。';
    }

    final buffer = StringBuffer();
    buffer.write('工资最低的员工有：');

    for (int i = 0; i < bottomEmployees.length && i < 5; i++) {
      final employee = bottomEmployees[i];
      if (employee is Map<String, dynamic>) {
        final name = employee['name'] as String? ?? '';
        final department = employee['department'] as String? ?? '';
        final salaryStr =
            employee['netSalary']?.toString().replaceAll(
              RegExp(r'[^\d.-]'),
              '',
            ) ??
            '0';
        final salary = double.tryParse(salaryStr) ?? 0;
        buffer.write('$name($department)，工资为${salary.toStringAsFixed(2)}元');
        if (i < bottomEmployees.length - 1 && i < 4) {
          buffer.write('；');
        }
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 生成完整的自然语言报告（从MonthlyAnalysisJsonConverter整合）
  String generateNaturalLanguageReport({
    required Map<String, dynamic> analysisData,
    required List<DepartmentSalaryStats> departmentStats,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousMonthData,
    required int year,
    required int month,
  }) {
    final buffer = StringBuffer();

    // 报告标题
    buffer.write('月度工资分析报告（$year年$month月）\n\n');

    // 关键参数
    buffer.write('一、基本情况\n');
    buffer.write(analysisData["monthlySimpleDescription"]);
    if (previousMonthData != null) {
      buffer.write(
        _generateEmployeeChangesDescription(analysisData, previousMonthData),
      );
    }
    buffer.write('\n\n');

    // 关键指标
    buffer.write('二、关键指标\n');
    buffer.write(
      _generateKeyMetricsDescription(analysisData, previousMonthData),
    );
    buffer.write('\n\n');

    // 部门统计
    buffer.write('三、部门统计\n');
    buffer.write(
      _generateDepartmentDetails(
        analysisData['departmentStats'] as List<dynamic>,
      ),
    );
    buffer.write('\n\n');

    // 薪资区间分布
    buffer.write('四、薪资区间分布\n');
    buffer.write(
      _generateSalaryRangeDescription(
        analysisData['salaryRanges'] as List<dynamic>,
      ),
    );
    buffer.write('\n\n');

    // 工资最高员工
    buffer.write('五、工资最高员工\n');
    buffer.write(_generateTopEmployeesDescription(analysisData));
    buffer.write('\n\n');

    // 工资最低员工
    buffer.write('六、工资最低员工\n');
    buffer.write(_generateBottomEmployeesDescription(analysisData));
    buffer.write('\n\n');

    // 考勤统计
    buffer.write('七、考勤统计\n');
    buffer.write(_generateAttendanceStatsDescription(attendanceStats));
    buffer.write('\n\n');

    return buffer.toString();
  }
}
