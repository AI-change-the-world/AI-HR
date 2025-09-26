// src/services/multi_month/enhanced_multi_month_report_generator_new.dart

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
import 'package:salary_report/src/isar/salary_list.dart';

/// 增强版多月报告生成器 - 重构简化版
class EnhancedMultiMonthReportGenerator implements EnhancedReportGenerator {
  final MultiMonthChartGenerationService _chartService;
  final MultiMonthDocxWriterService _docxService;
  final DataAnalysisService _analysisService;
  final ReportService _reportService;
  final AISummaryService _aiSummaryService;

  EnhancedMultiMonthReportGenerator({
    MultiMonthChartGenerationService? chartService,
    MultiMonthDocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
    AISummaryService? aiSummaryService,
  }) : _chartService = chartService ?? MultiMonthChartGenerationService(),
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

      // 1. 生成多月趋势数据 - 核心分析要点
      final trendAnalysisData = await _generateTrendAnalysisData(
        startTime,
        endTime,
      );

      // 2. 生成环比/同比数据 - 对比分析
      final comparisonData = await _generateComparisonData(startTime, endTime);

      // 3. 生成结构变化数据 - 薪资结构分析
      final structureAnalysisData = await _generateStructureAnalysisData(
        startTime,
        endTime,
      );

      // 4. 生成个体变化数据 - 员工变动分析
      final individualAnalysisData = await _generateIndividualAnalysisData(
        startTime,
        endTime,
      );

      // 5. 生成异常波动分析数据
      final anomalyAnalysisData = await _generateAnomalyAnalysisData(
        startTime,
        endTime,
      );

      // 6. 构建薪资结构数据
      final salaryStructureData = _createSalaryStructureData(
        analysisData.containsKey('salarySummary')
            ? analysisData['salarySummary'] as Map<String, dynamic>
            : null,
      );

      final departmentDetailsPerMonth = _getDepartmentDetailsPerMonth(
        analysisData,
      );

      // 7. 生成图表
      final chartImages = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: _convertToSalaryRangeMap(
          analysisData['salaryRanges'] ?? [],
        ),
        salaryStructureData: salaryStructureData,
        employeeCountPerMonth: trendAnalysisData['employeeCountPerMonth'],
        averageSalaryPerMonth: trendAnalysisData['averageSalaryPerMonth'],
        totalSalaryPerMonth: trendAnalysisData['totalSalaryPerMonth'],
        departmentDetailsPerMonth:
            trendAnalysisData['departmentDetailsPerMonth'],
        lastMonthDepartmentStats: null,
        departmentStatsPerMonth: _convertDepartmentDetailsToChartFormat(
          departmentDetailsPerMonth,
        ),
      );

      // 7.1. 生成薪资结构堆叠百分比柱状图
      final salaryStructureStackedChart = await _chartService
          .generateSalaryStructureStackedChart(
            structureAnalysisData['salaryCompositionTrend']
                    as List<Map<String, dynamic>>? ??
                [],
          );

      chartImages.salaryStructureStackedChart = salaryStructureStackedChart;

      // 8. 创建报告内容模型
      final reportContent = await _createReportContentModel(
        analysisData: analysisData,
        trendData: trendAnalysisData,
        comparisonData: comparisonData,
        structureData: structureAnalysisData,
        individualData: individualAnalysisData,
        anomalyData: anomalyAnalysisData,
        startTime: startTime,
        endTime: endTime,
      );

      // 9. 写入报告文件
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: chartImages,
      );

      // 10. 添加报告记录到数据库
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

  /// 生成趋势变化数据
  Future<Map<String, dynamic>> _generateTrendAnalysisData(
    DateTime startTime,
    DateTime endTime,
  ) async {
    // 1. 总工资支出的趋势（按月汇总）
    final totalSalaryTrend = <Map<String, dynamic>>[];

    // 2. 人均工资的趋势
    final averageSalaryTrend = <Map<String, dynamic>>[];

    // 3. 部门工资支出趋势
    final departmentTrend = <Map<String, dynamic>>[];

    // 4. 各类补贴、绩效工资随时间的变化
    final allowanceTrend = <Map<String, dynamic>>[];

    // 按月遍历，获取数据
    DateTime currentMonth = DateTime(startTime.year, startTime.month);
    final endMonth = DateTime(endTime.year, endTime.month);

    while (currentMonth.isBefore(endMonth) ||
        currentMonth.isAtSameMomentAs(endMonth)) {
      // 获取当月数据
      final monthlyData = await _analysisService.getMonthlySalaryData(
        currentMonth.year,
        currentMonth.month,
      );

      if (monthlyData != null) {
        // 员工数量趋势
        final employeeCountForMonth = departmentTrend
            .where(
              (dept) =>
                  dept['year'] == currentMonth.year &&
                  dept['monthNum'] == currentMonth.month,
            )
            .fold<int>(0, (sum, dept) => sum + (dept['employeeCount'] as int));

        totalSalaryTrend.add({
          'month': '${currentMonth.year}年${currentMonth.month}月',
          'year': currentMonth.year,
          'monthNum': currentMonth.month,
          'totalSalary': monthlyData.summaryData['税前工资'] ?? 0.0,
          'employeeCount': employeeCountForMonth,
        });

        // 人均工资趋势
        averageSalaryTrend.add({
          'month': '${currentMonth.year}年${currentMonth.month}月',
          'year': currentMonth.year,
          'monthNum': currentMonth.month,
          'averageSalary': _calculateAverageSalary(monthlyData.records),
        });

        // 部门工资支出趋势
        final deptStats = await _analysisService.getDepartmentSalaryStats(
          year: currentMonth.year,
          month: currentMonth.month,
        );

        for (final dept in deptStats) {
          departmentTrend.add({
            'month': '${currentMonth.year}年${currentMonth.month}月',
            'year': currentMonth.year,
            'monthNum': currentMonth.month,
            'department': dept.department,
            'totalSalary': dept.totalNetSalary,
            'averageSalary': dept.averageNetSalary,
            'employeeCount': dept.employeeCount,
          });
        }

        // 薪资构成趋势（基本工资、绩效工资、补贴等）
        final salarySummary = await _analysisService.getSalarySummaryData(
          year: currentMonth.year,
          month: currentMonth.month,
        );

        if (salarySummary != null) {
          allowanceTrend.add({
            'month': '${currentMonth.year}年${currentMonth.month}月',
            'year': currentMonth.year,
            'monthNum': currentMonth.month,
            'basicSalary': salarySummary['基本工资'] ?? 0.0,
            'performanceSalary': salarySummary['绩效工资'] ?? 0.0,
            'allowance': salarySummary['补贴工资'] ?? 0.0,
            'mealAllowance': salarySummary['饭补'] ?? 0.0,
          });
        }
      }

      // 移动到下一个月
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      if (currentMonth.month > 12) {
        currentMonth = DateTime(currentMonth.year + 1, 1);
      }
    }

    return {
      'totalSalaryPerMonth': totalSalaryTrend,
      'averageSalaryPerMonth': averageSalaryTrend,
      'departmentDetailsPerMonth': departmentTrend,
      'allowanceTrend': allowanceTrend,
      'employeeCountPerMonth': totalSalaryTrend.map((data) {
        return {
          'month': data['month'],
          'year': data['year'],
          'monthNum': data['monthNum'],
          'employeeCount': data['employeeCount'],
        };
      }).toList(),
    };
  }

  /// 生成环比/同比数据
  Future<Map<String, dynamic>> _generateComparisonData(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final departmentMoM = <Map<String, dynamic>>[];
    final departmentYoY = <Map<String, dynamic>>[];
    final positionMoM = <Map<String, dynamic>>[];
    final positionYoY = <Map<String, dynamic>>[];

    // 按月遍历，获取环比同比数据
    DateTime currentMonth = DateTime(startTime.year, startTime.month);
    final endMonth = DateTime(endTime.year, endTime.month);

    while (currentMonth.isBefore(endMonth) ||
        currentMonth.isAtSameMomentAs(endMonth)) {
      // 获取所有部门
      final deptStats = await _analysisService.getDepartmentSalaryStats(
        year: currentMonth.year,
        month: currentMonth.month,
      );

      for (final dept in deptStats) {
        // 部门环比数据
        final deptMoMData = await _analysisService
            .getDepartmentMonthOverMonthChange(
              year: currentMonth.year,
              month: currentMonth.month,
              department: dept.department,
            );
        if (deptMoMData.isNotEmpty) {
          departmentMoM.add({
            'month': '${currentMonth.year}年${currentMonth.month}月',
            'department': dept.department,
            ...deptMoMData,
          });
        }

        // 部门同比数据
        final deptYoYData = await _analysisService
            .getDepartmentYearOverYearChange(
              year: currentMonth.year,
              month: currentMonth.month,
              department: dept.department,
            );
        if (deptYoYData.isNotEmpty) {
          departmentYoY.add({
            'month': '${currentMonth.year}年${currentMonth.month}月',
            'department': dept.department,
            ...deptYoYData,
          });
        }
      }

      // 获取所有岗位
      final positionStats = await _analysisService.getPositionSalaryStats(
        year: currentMonth.year,
        month: currentMonth.month,
      );

      for (final position in positionStats) {
        // 岗位环比数据
        final positionMoMData = await _analysisService
            .getPositionMonthOverMonthChange(
              year: currentMonth.year,
              month: currentMonth.month,
              position: position.position,
            );
        if (positionMoMData.isNotEmpty) {
          positionMoM.add({
            'month': '${currentMonth.year}年${currentMonth.month}月',
            'position': position.position,
            ...positionMoMData,
          });
        }

        // 岗位同比数据
        final positionYoYData = await _analysisService
            .getPositionYearOverYearChange(
              year: currentMonth.year,
              month: currentMonth.month,
              position: position.position,
            );
        if (positionYoYData.isNotEmpty) {
          positionYoY.add({
            'month': '${currentMonth.year}年${currentMonth.month}月',
            'position': position.position,
            ...positionYoYData,
          });
        }
      }

      // 移动到下一个月
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      if (currentMonth.month > 12) {
        currentMonth = DateTime(currentMonth.year + 1, 1);
      }
    }

    return {
      'departmentMonthOverMonthData': departmentMoM,
      'departmentYearOverYearData': departmentYoY,
      'positionMonthOverMonthData': positionMoM,
      'positionYearOverYearData': positionYoY,
    };
  }

  /// 生成结构变化数据
  Future<Map<String, dynamic>> _generateStructureAnalysisData(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final salaryCompositionTrend = <Map<String, dynamic>>[];
    final departmentProportionTrend = <Map<String, dynamic>>[];

    DateTime currentMonth = DateTime(startTime.year, startTime.month);
    final endMonth = DateTime(endTime.year, endTime.month);

    while (currentMonth.isBefore(endMonth) ||
        currentMonth.isAtSameMomentAs(endMonth)) {
      // 薪资构成变化 - 使用正确的字段名称
      final salarySummary = await _analysisService.getSalarySummaryData(
        year: currentMonth.year,
        month: currentMonth.month,
      );

      if (salarySummary != null) {
        // 计算各项薪资的具体数值和比例
        final basicSalary =
            (num.tryParse(salarySummary['基本工资'].toString()) ?? 0).toDouble();
        final positionSalary =
            (num.tryParse(salarySummary['岗位工资'].toString()) ?? 0).toDouble();
        final performanceSalary =
            (num.tryParse(salarySummary['绩效工资'].toString()) ?? 0).toDouble();
        final allowanceSalary =
            (num.tryParse(salarySummary['补贴工资'].toString()) ?? 0).toDouble();
        final mealAllowance =
            (num.tryParse(salarySummary['饭补'].toString()) ?? 0).toDouble();
        final computerAllowance =
            (num.tryParse(salarySummary['电脑补贴等'].toString()) ?? 0).toDouble();

        final totalSalary =
            basicSalary +
            positionSalary +
            performanceSalary +
            allowanceSalary +
            mealAllowance +
            computerAllowance;

        if (totalSalary > 0) {
          salaryCompositionTrend.add({
            'month': '${currentMonth.year}年${currentMonth.month}月',
            'year': currentMonth.year,
            'monthNum': currentMonth.month,
            // 具体数值
            'basicSalaryAmount': basicSalary,
            'positionSalaryAmount': positionSalary,
            'performanceSalaryAmount': performanceSalary,
            'allowanceSalaryAmount': allowanceSalary,
            'mealAllowanceAmount': mealAllowance,
            'computerAllowanceAmount': computerAllowance,
            'totalAmount': totalSalary,
            // 比例数据
            'basicSalaryRatio': basicSalary / totalSalary,
            'positionSalaryRatio': positionSalary / totalSalary,
            'performanceSalaryRatio': performanceSalary / totalSalary,
            'allowanceSalaryRatio': allowanceSalary / totalSalary,
            'mealAllowanceRatio': mealAllowance / totalSalary,
            'computerAllowanceRatio': computerAllowance / totalSalary,
          });
        }
      }

      // 部门工资占比变化
      final deptStats = await _analysisService.getDepartmentSalaryStats(
        year: currentMonth.year,
        month: currentMonth.month,
      );

      final totalDeptSalary = deptStats.fold<double>(
        0.0,
        (sum, dept) => sum + dept.totalNetSalary,
      );

      if (totalDeptSalary > 0) {
        for (final dept in deptStats) {
          departmentProportionTrend.add({
            'month': '${currentMonth.year}年${currentMonth.month}月',
            'year': currentMonth.year,
            'monthNum': currentMonth.month,
            'department': dept.department,
            'amount': dept.totalNetSalary,
            'proportion': dept.totalNetSalary / totalDeptSalary,
          });
        }
      }

      // 移动到下一个月
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      if (currentMonth.month > 12) {
        currentMonth = DateTime(currentMonth.year + 1, 1);
      }
    }

    return {
      'salaryCompositionTrend': salaryCompositionTrend,
      'departmentProportionTrend': departmentProportionTrend,
    };
  }

  /// 生成个体变化数据
  Future<Map<String, dynamic>> _generateIndividualAnalysisData(
    DateTime startTime,
    DateTime endTime,
  ) async {
    // 获取多月比较数据来分析员工变动
    final comparisonData = await _analysisService.getMultiMonthComparisonData(
      startTime.year,
      startTime.month,
      endTime.year,
      endTime.month,
    );

    if (comparisonData == null) {
      return {
        'employeeChanges': <Map<String, dynamic>>[],
        'salaryChanges': <Map<String, dynamic>>[],
        'newEmployeeAnalysis': <Map<String, dynamic>>[],
      };
    }

    final employeeChanges = <Map<String, dynamic>>[];
    final salaryChanges = <Map<String, dynamic>>[];
    final newEmployeeAnalysis = <Map<String, dynamic>>[];

    // 分析员工变动情况
    for (int i = 1; i < comparisonData.monthlyComparisons.length; i++) {
      final current = comparisonData.monthlyComparisons[i];
      final previous = comparisonData.monthlyComparisons[i - 1];

      // 员工变动分析
      final currentEmployees = current.workers.map((w) => w.name).toSet();
      final previousEmployees = previous.workers.map((w) => w.name).toSet();

      final newEmployees = currentEmployees.difference(previousEmployees);
      final leftEmployees = previousEmployees.difference(currentEmployees);

      employeeChanges.add({
        'month': '${current.year}年${current.month}月',
        'newEmployees': newEmployees.toList(),
        'leftEmployees': leftEmployees.toList(),
        'netChange': newEmployees.length - leftEmployees.length,
      });

      // 新员工薪资水平分析
      if (newEmployees.isNotEmpty) {
        // 这里可以进一步分析新员工的薪资水平与整体均值的对比
        newEmployeeAnalysis.add({
          'month': '${current.year}年${current.month}月',
          'newEmployeeCount': newEmployees.length,
          'averageSalary': current.averageSalary,
          'monthlyAverageSalary': current.averageSalary,
        });
      }
    }

    return {
      'employeeChanges': employeeChanges,
      'salaryChanges': salaryChanges,
      'newEmployeeAnalysis': newEmployeeAnalysis,
    };
  }

  /// 生成异常波动分析数据
  Future<Map<String, dynamic>> _generateAnomalyAnalysisData(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final anomalies = <Map<String, dynamic>>[];

    DateTime currentMonth = DateTime(startTime.year, startTime.month);
    final endMonth = DateTime(endTime.year, endTime.month);

    while (currentMonth.isBefore(endMonth) ||
        currentMonth.isAtSameMomentAs(endMonth)) {
      // 检测部门工资异常波动
      final deptStats = await _analysisService.getDepartmentSalaryStats(
        year: currentMonth.year,
        month: currentMonth.month,
      );

      for (final dept in deptStats) {
        // 获取部门环比数据检测异常
        final momData = await _analysisService
            .getDepartmentMonthOverMonthChange(
              year: currentMonth.year,
              month: currentMonth.month,
              department: dept.department,
            );

        logger.info('部门${dept.department}的环比数据：$momData');

        if (momData.isNotEmpty &&
            momData.containsKey('month_over_month_change') &&
            momData['month_over_month_change'] != null) {
          final changeData =
              momData['month_over_month_change'] as Map<String, dynamic>;
          final avgSalaryChangePercent =
              (changeData['average_salary_change_percent'] as num?)
                  ?.toDouble() ??
              0.0;

          // 如果平均工资变化超过20%，认为是异常波动
          if (avgSalaryChangePercent.abs() > 20) {
            anomalies.add({
              'month': '${currentMonth.year}年${currentMonth.month}月',
              'type': 'department_salary_anomaly',
              'department': dept.department,
              'changePercent': avgSalaryChangePercent,
              'description':
                  '${dept.department}部门平均工资${avgSalaryChangePercent > 0 ? '上升' : '下降'}${avgSalaryChangePercent.abs().toStringAsFixed(2)}%',
            });
          }
        }
      }

      // 移动到下一个月
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      if (currentMonth.month > 12) {
        currentMonth = DateTime(currentMonth.year + 1, 1);
      }
    }

    return {'anomalies': anomalies};
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

    // 遍历薪资结构字段
    salaryStructureFields.forEach((key, value) {
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

  /// 创建报告内容模型
  Future<MultiMonthReportContentModel> _createReportContentModel({
    required Map<String, dynamic> analysisData,
    required Map<String, dynamic> trendData,
    required Map<String, dynamic> comparisonData,
    required Map<String, dynamic> structureData,
    required Map<String, dynamic> individualData,
    required Map<String, dynamic> anomalyData,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    String reportTime;
    if (startTime.month == endTime.month && startTime.year == endTime.year) {
      reportTime = '${startTime.year}年${startTime.month}月';
    } else {
      reportTime =
          '${startTime.year}年${startTime.month}月 - ${endTime.year}年${endTime.month}月';
    }

    // 构建部门统计数据（聚合）
    final departmentStats = <DepartmentSalaryStats>[];
    if (trendData.containsKey('departmentDetailsPerMonth')) {
      final deptData = trendData['departmentDetailsPerMonth'] as List;
      final deptMap = <String, List<Map<String, dynamic>>>{};

      // 按部门分组
      for (final data in deptData) {
        if (data is Map<String, dynamic>) {
          final dept = data['department'] as String;
          if (!deptMap.containsKey(dept)) {
            deptMap[dept] = [];
          }
          deptMap[dept]!.add(data);
        }
      }

      // 聚合计算
      deptMap.forEach((deptName, dataList) {
        final totalSalary = dataList.fold<double>(
          0.0,
          (sum, data) => sum + (data['totalSalary'] as num).toDouble(),
        );
        final totalEmployees = dataList.fold<int>(
          0,
          (sum, data) => sum + (data['employeeCount'] as int),
        );

        departmentStats.add(
          DepartmentSalaryStats(
            department: deptName,
            employeeCount: totalEmployees,
            totalNetSalary: totalSalary,
            averageNetSalary: totalEmployees > 0
                ? totalSalary / totalEmployees
                : 0.0,
            year: startTime.year,
            month: startTime.month,
            maxSalary: 0.0, // 可以进一步计算
            minSalary: 0.0, // 可以进一步计算
          ),
        );
      });
    }

    // 生成AI分析内容
    final trendAnalysisSummary = await _generateTrendAnalysisSummary(
      trendData,
      comparisonData,
    );
    final structureAnalysisSummary = await _generateStructureAnalysisSummary(
      structureData,
    );
    final anomalyAnalysisSummary = await _generateAnomalyAnalysisSummary(
      anomalyData,
    );

    // 计算总体数据
    final totalSalaryData =
        trendData['totalSalaryPerMonth'] as List<Map<String, dynamic>>? ?? [];
    final averageSalaryData =
        trendData['averageSalaryPerMonth'] as List<Map<String, dynamic>>? ?? [];
    final employeeCountData =
        trendData['employeeCountPerMonth'] as List<Map<String, dynamic>>? ?? [];

    // 计算累计数据
    final totalSalarySum = totalSalaryData.fold<double>(
      0.0,
      (sum, data) =>
          sum + (num.tryParse(data['totalSalary'].toString()) ?? 0).toDouble(),
    );

    final totalEmployeeCount = employeeCountData.isNotEmpty
        ? num.tryParse(
                employeeCountData.last['employeeCount'].toString(),
              )?.toInt() ??
              0
        : departmentStats.fold<int>(0, (sum, dept) => sum + dept.employeeCount);

    final averageSalaryValue = averageSalaryData.isNotEmpty
        ? averageSalaryData.fold<double>(
                0.0,
                (sum, data) =>
                    sum +
                    (num.tryParse(data['averageSalary'].toString()) ?? 0)
                        .toDouble(),
              ) /
              averageSalaryData.length
        : (totalEmployeeCount > 0
              ? totalSalarySum / totalEmployeeCount / totalSalaryData.length
              : 0.0);

    // 计算增长率
    final totalSalaryGrowthRate = _calculateGrowthRate(
      totalSalaryData
          .map(
            (d) => (num.tryParse(d['totalSalary'].toString()) ?? 0).toDouble(),
          )
          .toList(),
    );

    final averageSalaryGrowthRate = _calculateGrowthRate(
      averageSalaryData
          .map(
            (d) =>
                (num.tryParse(d['averageSalary'].toString()) ?? 0).toDouble(),
          )
          .toList(),
    );

    // 计算薪资结构比例
    final salaryStructureRatios = _calculateSalaryStructureRatios(
      trendData['allowanceTrend'] as List<Map<String, dynamic>>? ?? [],
    );

    // 生成薪资排名
    final salaryRankings = await _generateSalaryRankings(departmentStats);

    // 生成薪资结构建议
    final salaryStructureAdvice = await _generateSalaryStructureAdvice(
      structureData,
      salaryStructureRatios,
    );

    return MultiMonthReportContentModel(
      reportTitle: '多月工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime: reportTime,
      startTime: '${startTime.year}年${startTime.month}月',
      endTime: '${endTime.year}年${endTime.month}月',
      compareLast: '多月期间趋势分析',
      totalEmployees: totalEmployeeCount,
      totalSalary: totalSalarySum,
      averageSalary: averageSalaryValue,
      departmentCount: departmentStats.length,
      employeeCount: totalEmployeeCount,
      employeeDetails: await _generateEmployeeDetails(individualData),
      payrollInfo: _generatePayrollInfo(trendData),
      departmentDetails: _generateDepartmentDetails(departmentStats),
      salaryRangeDescription: await _generateSalaryRangeDescription({
        'trendData': trendData,
        'salaryRanges': analysisData['salaryRanges'],
      }),
      salaryRangeFeatureSummary: trendAnalysisSummary,
      departmentSalaryAnalysis: structureAnalysisSummary,
      keySalaryPoint: anomalyAnalysisSummary,
      salaryRankings: salaryRankings,
      salaryOrder: _generateSalaryOrder(departmentStats),
      basicSalaryRate: salaryStructureRatios['basicSalaryRate'] ?? 0.7,
      performanceSalaryRate:
          salaryStructureRatios['performanceSalaryRate'] ?? 0.3,
      salaryStructure: _generateSalaryStructureDescription(structureData),
      salaryStructureAdvice: salaryStructureAdvice,
      salaryStructureData: _createSalaryStructureData(
        analysisData.containsKey('salarySummary')
            ? analysisData['salarySummary'] as Map<String, dynamic>
            : null,
      ),
      departmentStats: departmentStats,
      // 多月专用字段
      employeeCountPerMonth:
          trendData['employeeCountPerMonth'] as List<Map<String, dynamic>>?,
      averageSalaryPerMonth:
          trendData['averageSalaryPerMonth'] as List<Map<String, dynamic>>?,
      totalSalaryPerMonth:
          trendData['totalSalaryPerMonth'] as List<Map<String, dynamic>>?,
      departmentDetailsPerMonth:
          trendData['departmentDetailsPerMonth'] as List<Map<String, dynamic>>?,
      departmentMonthOverMonthData:
          comparisonData['departmentMonthOverMonthData']
              as List<Map<String, dynamic>>?,
      departmentYearOverYearData:
          comparisonData['departmentYearOverYearData']
              as List<Map<String, dynamic>>?,
      positionMonthOverMonthData:
          comparisonData['positionMonthOverMonthData']
              as List<Map<String, dynamic>>?,
      positionYearOverYearData:
          comparisonData['positionYearOverYearData']
              as List<Map<String, dynamic>>?,
      monthCount: _calculateMonthCount(startTime, endTime),
      totalSalaryGrowthRate: totalSalaryGrowthRate,
      averageSalaryGrowthRate: averageSalaryGrowthRate,
      trendAnalysisSummary: trendAnalysisSummary,
    );
  }

  /// 计算平均工资
  double _calculateAverageSalary(List<SalaryListRecord> records) {
    if (records.isEmpty) return 0.0;

    double totalSalary = 0.0;
    int validCount = 0;

    for (final record in records) {
      if (record.netSalary != null) {
        final salaryStr = record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '');
        final salary = double.tryParse(salaryStr) ?? 0.0;
        if (salary > 0) {
          totalSalary += salary;
          validCount++;
        }
      }
    }

    return validCount > 0 ? totalSalary / validCount : 0.0;
  }

  /// 生成趋势分析总结
  Future<String> _generateTrendAnalysisSummary(
    Map<String, dynamic> trendData,
    Map<String, dynamic> comparisonData,
  ) async {
    final totalSalaryData =
        trendData['totalSalaryPerMonth'] as List<Map<String, dynamic>>? ?? [];
    final averageSalaryData =
        trendData['averageSalaryPerMonth'] as List<Map<String, dynamic>>? ?? [];
    final departmentData =
        trendData['departmentDetailsPerMonth'] as List<Map<String, dynamic>>? ??
        [];

    // 先判断数据充分性
    if (totalSalaryData.isEmpty && averageSalaryData.isEmpty) {
      return '在对多月薪资趋势进行分析后发现，由于数据采集期间较短，暂无法形成有效的趋势分析结论。建议在累积更多月份数据后再进行深入的趋势分析，以获得更准确的变化特征和发展趋势。';
    }

    // 整理总工资数据
    final totalSalaryTrend = totalSalaryData.isNotEmpty
        ? totalSalaryData
              .map(
                (d) =>
                    '${d['month']}总薪资${(num.tryParse(d['totalSalary'].toString()) ?? 0).toStringAsFixed(0)}元',
              )
              .join('，')
        : '暂无总薪资趋势数据';

    // 整理人均工资数据
    final averageSalaryTrend = averageSalaryData.isNotEmpty
        ? averageSalaryData
              .map(
                (d) =>
                    '${d['month']}人均薪资${(num.tryParse(d['averageSalary'].toString()) ?? 0).toStringAsFixed(0)}元',
              )
              .join('，')
        : '暂无人均薪资趋势数据';

    // 统计部门数量
    final departmentCount = departmentData.isNotEmpty
        ? departmentData.map((d) => d['department']).toSet().length
        : 0;

    final prompt =
        '''
作为一名专业的HR分析师，请你基于以下具体数据撰写一段专业的薪资趋势分析总结：

数据基础：
- 总工资支出趋势：$totalSalaryTrend
- 人均工资趋势：$averageSalaryTrend
- 部门数量：$departmentCount个部门
- 环比同比变化情况数据已获取

分析要求：
1. 必须使用上述提供的具体数据进行分析，不得虚构数据
2. 必须使用专业、严谨的HR分析语言
3. 必须使用中文标点符号（逗号、顿号、句号等）
4. 必须覆盖总薪资趋势、人均薪资趋势、部门变化、关键发现四个方面
5. 禁止使用markdown格式和换行符，输出一段连续文字

请用报告风格的语言，简洁严谨地总结趋势特点和关键发现。
''';

    final result = await _aiSummaryService.getAnswer(prompt);

    return result;
  }

  /// 生成结构分析总结
  Future<String> _generateStructureAnalysisSummary(
    Map<String, dynamic> structureData,
  ) async {
    final salaryComposition =
        structureData['salaryCompositionTrend']
            as List<Map<String, dynamic>>? ??
        [];
    final departmentProportion =
        structureData['departmentProportionTrend']
            as List<Map<String, dynamic>>? ??
        [];

    // 先判断数据充分性
    if (salaryComposition.isEmpty && departmentProportion.isEmpty) {
      return '在对多月薪资结构进行分析后发现，由于数据采集期间较短，暂无法形成有效的结构分析结论。建议在累积更多月份数据后再进行深入的结构分析，以获得更准确的结构变化特征。';
    }

    // 整理薪资构成数据
    final salaryCompositionSummary = salaryComposition.isNotEmpty
        ? '共${salaryComposition.length}个月份的数据，包括基本工资、岗位工资、绩效工资、补贴工资、饭补、电脑补贴等的比例变化'
        : '暂无薪资构成数据';

    // 整理部门占比数据
    final departmentProportionSummary = departmentProportion.isNotEmpty
        ? '共${departmentProportion.map((d) => d['department']).toSet().length}个部门的工资占比数据'
        : '暂无部门占比数据';

    // 获取最新月份的具体数据作为示例
    final latestMonthData = salaryComposition.isNotEmpty
        ? salaryComposition.last
        : null;

    final latestMonthExample = latestMonthData != null
        ? '以${latestMonthData['month']}为例，基本工资占比${((num.tryParse(latestMonthData['basicSalaryRatio'].toString()) ?? 0) * 100).toStringAsFixed(1)}%，绩效工资占比${((num.tryParse(latestMonthData['performanceSalaryRatio'].toString()) ?? 0) * 100).toStringAsFixed(1)}%'
        : '暂无具体月份示例';

    final prompt =
        '''
作为一名专业的HR分析师，请你基于以下具体数据撰写一段专业的薪资结构分析总结：

数据基础：
- 薪资构成比例变化：$salaryCompositionSummary
- 部门工资占比变化：$departmentProportionSummary
- 最新月份示例：$latestMonthExample

分析要求：
1. 必须使用上述提供的具体数据进行分析，不得虚构数据
2. 必须使用专业、严谨的HR分析语言
3. 必须使用中文标点符号（逗号、顿号、句号等）
4. 必须覆盖薪资构成变化、部门占比变化、合理性评估三个方面
5. 禁止使用markdown格式和换行符，输出一段连续文字

请用报告风格的语言，简洁严谨地分析结构变化特点。
''';

    final result = await _aiSummaryService.getAnswer(prompt);

    return result;
  }

  /// 生成异常分析总结
  Future<String> _generateAnomalyAnalysisSummary(
    Map<String, dynamic> anomalyData,
  ) async {
    final anomalies =
        anomalyData['anomalies'] as List<Map<String, dynamic>>? ?? [];

    if (anomalies.isEmpty) {
      return '在对多月薪资数据进行异常检测后发现，整体薪资波动保持在合理范围内，未发现明显的异常波动现象。各部门薪资变化相对稳定，月度环比波动基本控制在正常区间，体现出公司薪酬管理的稳定性和规范性。';
    }

    // 整理异常情况数据
    final anomalyDescriptions = anomalies
        .map((a) => a['description'] as String? ?? '未知异常')
        .where((desc) => desc != '未知异常')
        .toList();

    final anomalyCount = anomalies.length;
    final anomalyTypeCount = anomalies
        .map((a) => a['type'] as String? ?? 'unknown')
        .toSet()
        .length;

    final prompt =
        '''
作为一名专业的HR分析师，请你基于以下具体数据撰写一段专业的薪资异常分析报告：

数据基础：
- 检测到异常情况数量：$anomalyCount个
- 异常类型数量：$anomalyTypeCount种
- 具体异常情况：${anomalyDescriptions.join('；')}

分析要求：
1. 必须使用上述提供的具体数据进行分析，不得虚构数据
2. 必须使用专业、严谨的HR分析语言
3. 必须使用中文标点符号（逗号、顿号、句号等）
4. 必须覆盖异常情况描述、可能原因分析、关注建议三个方面
5. 禁止使用markdown格式和换行符，输出一段连续文字

请用报告风格的语言，简洁严谨地分析异常情况及其影响。
''';

    final result = await _aiSummaryService.getAnswer(prompt);

    return result;
  }

  /// 生成员工详情
  /// 生成员工详情（报告风格）
  Future<String> _generateEmployeeDetails(
    Map<String, dynamic> individualData,
  ) async {
    final employeeChanges =
        individualData['employeeChanges'] as List<Map<String, dynamic>>? ?? [];

    if (employeeChanges.isEmpty) {
      return '本期员工结构整体保持稳定，各部门未出现显著人员变动。';
    }

    final List<String> monthDescriptions = [];

    for (final change in employeeChanges) {
      final month = change['month'] as String;
      final newEmployees = change['newEmployees'] as List<dynamic>? ?? [];
      final leftEmployees = change['leftEmployees'] as List<dynamic>? ?? [];
      final netChange = change['netChange'] as int;

      final buffer = StringBuffer();
      buffer.write('$month，');

      if (newEmployees.isEmpty && leftEmployees.isEmpty) {
        buffer.write('人员保持稳定，无明显变动。');
      } else {
        // 新入职
        if (newEmployees.isNotEmpty) {
          final deptText = await _formatEmployeesByDepartment(
            newEmployees.cast<String>(),
            month,
          );
          buffer.write('共有${newEmployees.length}人新入职');
          if (deptText.isNotEmpty) buffer.write('，主要分布在$deptText');
          buffer.write('；');
        }

        // 离职
        if (leftEmployees.isNotEmpty) {
          final deptText = await _formatEmployeesByDepartment(
            leftEmployees.cast<String>(),
            month,
          );
          buffer.write('共有${leftEmployees.length}人离职');
          if (deptText.isNotEmpty) buffer.write('，涉及部门为$deptText');
          buffer.write('；');
        }

        // 净变化
        if (netChange > 0) {
          buffer.write('整体人员净增加$netChange人。');
        } else if (netChange < 0) {
          buffer.write('整体人员净减少${netChange.abs()}人。');
        } else {
          buffer.write('整体人员规模保持不变。');
        }
      }

      monthDescriptions.add(buffer.toString());
    }

    return monthDescriptions.join(' ');
  }

  /// 将员工按部门统计，生成自然语言描述
  Future<String> _formatEmployeesByDepartment(
    List<String> employeeNames,
    String month,
  ) async {
    final departmentStats = await _getEmployeeDepartmentStats(
      employeeNames,
      month,
    );
    if (departmentStats.isEmpty) return '';

    final parts = departmentStats.entries
        .map((e) => '${e.key}${e.value}人')
        .toList();
    return parts.join('，');
  }

  /// 添加新员工部门分析
  Future<void> _appendNewEmployeesByDepartment(
    StringBuffer buffer,
    List<dynamic> newEmployees,
    String month,
  ) async {
    if (newEmployees.isEmpty) return;

    // 按部门分组统计新员工（这里需要从实际数据中获取部门信息）
    final departmentStats = await _getEmployeeDepartmentStats(
      newEmployees.cast<String>(),
      month,
    );

    if (departmentStats.isEmpty) {
      buffer.write('共${newEmployees.length}人\n');
      return;
    }

    final totalCount = departmentStats.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    buffer.write('共$totalCount人，');

    final deptEntries = departmentStats.entries.toList();
    for (int i = 0; i < deptEntries.length; i++) {
      final entry = deptEntries[i];
      buffer.write('${entry.key}${entry.value}人');
      if (i < deptEntries.length - 1) buffer.write('，');
    }
    buffer.write('\n');
  }

  /// 添加离职员工部门分析
  Future<void> _appendLeftEmployeesByDepartment(
    StringBuffer buffer,
    List<dynamic> leftEmployees,
    String month,
  ) async {
    if (leftEmployees.isEmpty) return;

    // 按部门分组统计离职员工
    final departmentStats = await _getEmployeeDepartmentStats(
      leftEmployees.cast<String>(),
      month,
    );

    if (departmentStats.isEmpty) {
      buffer.write('共${leftEmployees.length}人\n');
      return;
    }

    final totalCount = departmentStats.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    buffer.write('共$totalCount人，');

    final deptEntries = departmentStats.entries.toList();
    for (int i = 0; i < deptEntries.length; i++) {
      final entry = deptEntries[i];
      buffer.write('${entry.key}${entry.value}人');
      if (i < deptEntries.length - 1) buffer.write('，');
    }
    buffer.write('\n');
  }

  /// 获取员工部门统计信息
  Future<Map<String, int>> _getEmployeeDepartmentStats(
    List<String> employeeNames,
    String month,
  ) async {
    final departmentStats = <String, int>{};

    // 解析月份信息
    final monthMatch = RegExp(r'(\d{4})年(\d{1,2})月').firstMatch(month);
    if (monthMatch == null) return departmentStats;

    final year = int.parse(monthMatch.group(1)!);
    final monthNum = int.parse(monthMatch.group(2)!);

    // 获取该月的工资数据来确定员工部门
    final monthlyData = await _analysisService.getMonthlySalaryData(
      year,
      monthNum,
    );
    if (monthlyData == null) return departmentStats;

    // 统计每个员工的部门
    for (final employeeName in employeeNames) {
      for (final record in monthlyData.records) {
        if (record.name == employeeName && record.department != null) {
          final dept = record.department!;
          departmentStats[dept] = (departmentStats[dept] ?? 0) + 1;
          break;
        }
      }
    }

    return departmentStats;
  }

  /// 生成发薪信息
  String _generatePayrollInfo(Map<String, dynamic> trendData) {
    final totalSalaryData =
        trendData['totalSalaryPerMonth'] as List<Map<String, dynamic>>? ?? [];
    if (totalSalaryData.isEmpty) {
      return '暂无发薪信息。';
    }

    final totalAmount = totalSalaryData.fold<double>(
      0.0,
      (sum, data) =>
          sum + (num.tryParse(data['totalSalary'].toString()) ?? 0).toDouble(),
    );
    return '本期累计发放工资总额${totalAmount.toStringAsFixed(2)}元。';
  }

  /// 生成部门详情
  String _generateDepartmentDetails(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    if (departmentStats.isEmpty) {
      return '暂无部门统计数据。';
    }

    final buffer = StringBuffer();
    buffer.write('各部门情况：');

    for (final dept in departmentStats) {
      buffer.write('${dept.department}部门${dept.employeeCount}人，');
      buffer.write('工资总额${dept.totalNetSalary.toStringAsFixed(2)}元，');
      buffer.write('平均工资${dept.averageNetSalary.toStringAsFixed(2)}元；');
    }

    return buffer.toString();
  }

  /// 生成薪资排序
  String _generateSalaryOrder(List<DepartmentSalaryStats> departmentStats) {
    if (departmentStats.isEmpty) {
      return '暂无部门薪资排名数据。';
    }

    final sortedDepartments = List<DepartmentSalaryStats>.from(departmentStats)
      ..sort((a, b) => b.averageNetSalary.compareTo(a.averageNetSalary));

    final buffer = StringBuffer();
    buffer.write('部门平均薪资排名：');

    for (int i = 0; i < sortedDepartments.length; i++) {
      final dept = sortedDepartments[i];
      buffer.write(
        '第${i + 1}名${dept.department}(${dept.averageNetSalary.toStringAsFixed(2)}元)',
      );
      if (i < sortedDepartments.length - 1) {
        buffer.write('，');
      }
    }

    return buffer.toString();
  }

  /// 计算月份数量
  int _calculateMonthCount(DateTime startTime, DateTime endTime) {
    final years = endTime.year - startTime.year;
    final months = endTime.month - startTime.month;
    return years * 12 + months + 1;
  }

  /// 计算增长率
  double _calculateGrowthRate(List<double> values) {
    if (values.length < 2) return 0.0;

    final first = values.first;
    final last = values.last;

    if (first == 0) return 0.0;

    return ((last - first) / first) * 100;
  }

  /// 计算薪资结构比例
  Map<String, double> _calculateSalaryStructureRatios(
    List<Map<String, dynamic>> allowanceTrend,
  ) {
    if (allowanceTrend.isEmpty) {
      return {
        'basicSalaryRate': 0.7,
        'performanceSalaryRate': 0.3,
        'allowanceRate': 0.0,
      };
    }

    // 计算所有月份的平均比例
    double totalBasic = 0.0;
    double totalPerformance = 0.0;
    double totalAllowance = 0.0;
    double totalSalary = 0.0;

    for (final trend in allowanceTrend) {
      final basic = (num.tryParse(trend['basicSalary'].toString()) ?? 0)
          .toDouble();
      final performance =
          (num.tryParse(trend['performanceSalary'].toString()) ?? 0).toDouble();
      final allowance = (num.tryParse(trend['allowance'].toString()) ?? 0)
          .toDouble();

      totalBasic += basic;
      totalPerformance += performance;
      totalAllowance += allowance;
      totalSalary += basic + performance + allowance;
    }

    if (totalSalary == 0) {
      return {
        'basicSalaryRate': 0.7,
        'performanceSalaryRate': 0.3,
        'allowanceRate': 0.0,
      };
    }

    return {
      'basicSalaryRate': totalBasic / totalSalary,
      'performanceSalaryRate': totalPerformance / totalSalary,
      'allowanceRate': totalAllowance / totalSalary,
    };
  }

  /// 生成薪资排名
  Future<String> _generateSalaryRankings(
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    if (departmentStats.isEmpty) {
      return '暂无部门薪资排名数据。';
    }

    final sortedDepartments = List<DepartmentSalaryStats>.from(departmentStats)
      ..sort((a, b) => b.averageNetSalary.compareTo(a.averageNetSalary));

    final buffer = StringBuffer();
    buffer.write('部门薪资排名情况：\n');

    for (int i = 0; i < sortedDepartments.length; i++) {
      final dept = sortedDepartments[i];
      buffer.write(
        '第${i + 1}名: ${dept.department}部门，平均薪资${dept.averageNetSalary.toStringAsFixed(2)}元，',
      );
      buffer.write('总薪资${dept.totalNetSalary.toStringAsFixed(2)}元；\n');
    }

    return buffer.toString();
  }

  /// 生成薪资结构建议
  Future<String> _generateSalaryStructureAdvice(
    Map<String, dynamic> structureData,
    Map<String, double> salaryStructureRatios,
  ) async {
    final basicRate = salaryStructureRatios['basicSalaryRate'] ?? 0.0;
    final performanceRate =
        salaryStructureRatios['performanceSalaryRate'] ?? 0.0;
    final allowanceRate = salaryStructureRatios['allowanceRate'] ?? 0.0;

    // 判断数据充分性
    if (basicRate == 0.0 && performanceRate == 0.0 && allowanceRate == 0.0) {
      return '在对多月薪资结构进行分析后发现，由于数据采集期间较短或薪资结构数据不够充分，暂无法形成有效的薪资结构优化建议。建议在累积更多月份的薪资构成数据后，再进行深度的薪资结构分析和优化建议制定。';
    }

    final salaryComposition =
        structureData['salaryCompositionTrend']
            as List<Map<String, dynamic>>? ??
        [];
    final dataMonthCount = salaryComposition.length;

    final prompt =
        '''
作为一名专业的HR分析师，请你基于以下具体数据撰写一段专业的薪资结构优化建议：

数据基础：
- 数据覆盖月份：$dataMonthCount个月
- 基本工资占比：${(basicRate * 100).toStringAsFixed(1)}%
- 绩效工资占比：${(performanceRate * 100).toStringAsFixed(1)}%
- 补贴占比：${(allowanceRate * 100).toStringAsFixed(1)}%
- 结构数据样本量：$dataMonthCount个月份数据

分析要求：
1. 必须使用上述提供的具体数据进行分析，不得虚构数据
2. 必须使用专业、严谨的HR分析语言
3. 必须使用中文标点符号（逗号、顿号、句号等）
4. 必须覆盖结构合理性评估、优化方向建议、实施建议三个方面
5. 禁止使用markdown格式和换行符，输出一段连续文字

请用报告风格的语言，简洁严谨地提出薪资结构优化建议。
''';

    final result = await _aiSummaryService.getAnswer(prompt);

    return result;
  }

  /// 生成薪资区间描述
  /// 生成薪资区间自然语言描述
  /// 生成薪资区间自然语言描述
  Future<String> _generateSalaryRangeDescription(
    Map<String, dynamic> analysisData,
  ) async {
    final buffer = StringBuffer();

    // 逐月分析
    final monthlyText = await _buildMonthlyRangeNarrative(analysisData);

    // 部门分析
    final departmentText = await _buildDepartmentRangeNarrative(analysisData);

    // AI总结
    final aiAnalysis = await _generateRangeDistributionInsights(analysisData);

    buffer.write('在多月的薪资区间观察中，$monthlyText；');
    buffer.write('从部门维度来看，$departmentText。');
    buffer.write('综合来看，$aiAnalysis');

    return buffer.toString();
  }

  /// 构建逐月薪资区间的自然语言描述（报告风格）
  Future<String> _buildMonthlyRangeNarrative(
    Map<String, dynamic> analysisData,
  ) async {
    final trendData = analysisData['trendData'] as Map<String, dynamic>? ?? {};
    final totalSalaryData =
        trendData['totalSalaryPerMonth'] as List<Map<String, dynamic>>? ?? [];

    if (totalSalaryData.isEmpty) {
      return '尚未形成有效的逐月分布情况';
    }

    final List<String> parts = [];

    for (final monthData in totalSalaryData) {
      final month = monthData['month'] as String? ?? '未知月份';
      final year =
          num.tryParse(monthData['year'].toString())?.toInt() ??
          DateTime.now().year;
      final monthNum =
          num.tryParse(monthData['monthNum'].toString())?.toInt() ?? 1;

      final monthlyRanges = await _analysisService.getSalaryRangeAggregation(
        year,
        monthNum,
      );

      if (monthlyRanges.isEmpty) {
        parts.add('$month暂无有效数据');
      } else {
        final totalEmployees = monthlyRanges.fold<int>(
          0,
          (sum, range) => sum + range.employeeCount,
        );

        // 如果只有一个区间且覆盖全部人员 → 用更正式的表述
        if (monthlyRanges.length == 1 &&
            monthlyRanges.first.employeeCount == totalEmployees) {
          parts.add(
            '$month共有$totalEmployees人，工资主要集中在${monthlyRanges.first.range}，分布较为单一',
          );
        } else {
          final rangeTexts = monthlyRanges
              .map((range) {
                final percentage = totalEmployees > 0
                    ? (range.employeeCount / totalEmployees * 100)
                          .toStringAsFixed(1)
                    : '0.0';
                return '${range.range}区间范围内共有${range.employeeCount}人，占比$percentage%';
              })
              .join('；');
          parts.add('$month共有$totalEmployees人，其中$rangeTexts');
        }
      }
    }

    return parts.join('；');
  }

  /// 构建部门薪资区间的自然语言描述（报告风格）
  Future<String> _buildDepartmentRangeNarrative(
    Map<String, dynamic> analysisData,
  ) async {
    final trendData = analysisData['trendData'] as Map<String, dynamic>? ?? {};
    final departmentData =
        trendData['departmentDetailsPerMonth'] as List<Map<String, dynamic>>? ??
        [];

    if (departmentData.isEmpty) {
      return '各部门暂未形成可对比的薪资分布';
    }

    final departmentMap = <String, List<Map<String, dynamic>>>{};
    for (final data in departmentData) {
      final dept = data['department'] as String? ?? '未知部门';
      departmentMap.putIfAbsent(dept, () => []).add(data);
    }

    final List<String> parts = [];
    final Map<String, List<String>> levelMap = {
      '高薪资水平': [],
      '中等薪资水平': [],
      '基础薪资水平': [],
    };

    for (final entry in departmentMap.entries) {
      final dept = entry.key;
      final deptDataList = entry.value;

      final avgSalaries = deptDataList
          .map(
            (data) => (num.tryParse(data['averageSalary'].toString()) ?? 0)
                .toDouble(),
          )
          .where((salary) => salary > 0)
          .toList();

      if (avgSalaries.isEmpty) continue;

      final minSalary = avgSalaries.reduce((a, b) => a < b ? a : b);
      final maxSalary = avgSalaries.reduce((a, b) => a > b ? a : b);
      final avgSalary =
          avgSalaries.reduce((a, b) => a + b) / avgSalaries.length;

      String level;
      if (avgSalary >= 15000) {
        level = '高薪资水平';
      } else if (avgSalary >= 8000) {
        level = '中等薪资水平';
      } else {
        level = '基础薪资水平';
      }

      // 报告风格：避免区间重复写法
      String rangeText;
      if (minSalary.toStringAsFixed(0) == maxSalary.toStringAsFixed(0)) {
        rangeText = '平均薪资约为${avgSalary.toStringAsFixed(0)}元';
      } else {
        rangeText =
            '平均薪资区间约在${minSalary.toStringAsFixed(0)}至${maxSalary.toStringAsFixed(0)}元，月均${avgSalary.toStringAsFixed(0)}元左右';
      }

      parts.add('$dept$rangeText');
      levelMap[level]?.add(dept);
    }

    // 合并同一水平部门
    final List<String> summaryParts = [];
    levelMap.forEach((level, depts) {
      if (depts.isNotEmpty) {
        summaryParts.add('${depts.join("、")}整体处于$level');
      }
    });

    return '${parts.join("；")}；${summaryParts.join("；")}';
  }

  /// 生成薪资区间分布洞察
  Future<String> _generateRangeDistributionInsights(
    Map<String, dynamic> analysisData,
  ) async {
    final trendData = analysisData['trendData'] as Map<String, dynamic>? ?? {};
    final totalSalaryData =
        trendData['totalSalaryPerMonth'] as List<Map<String, dynamic>>? ?? [];
    final departmentData =
        trendData['departmentDetailsPerMonth'] as List<Map<String, dynamic>>? ??
        [];

    // 先判断是否有数据，避免大模型缺乏数据进行分析
    if (totalSalaryData.isEmpty && departmentData.isEmpty) {
      return '在对多月薪资数据进行分析后发现，由于数据采集期间较短或数据不充分，暂无法形成有效的薪资区间分布分析。建议在累积更多月份数据后再进行深度分析，以获得更准确的薪资区间分布特征和优化建议。';
    }

    // 整理月度薪资数据（只包含有效数据）
    final validMonthlyData = totalSalaryData
        .where(
          (data) =>
              (num.tryParse(data['totalSalary']?.toString() ?? '0') ?? 0) > 0,
        )
        .toList();

    final monthlyDataSummary = validMonthlyData.isNotEmpty
        ? validMonthlyData
              .map(
                (data) =>
                    '${data['month']}总薪资${(num.tryParse(data['totalSalary'].toString()) ?? 0).toStringAsFixed(0)}元',
              )
              .join('，')
        : '暂无有效月度薪资数据';

    // 整理部门薪资数据（只包含有效数据）
    final departmentMap = <String, List<double>>{};
    for (final data in departmentData) {
      final dept = data['department'] as String? ?? '未知部门';
      final avgSalary =
          (num.tryParse(data['averageSalary']?.toString() ?? '0') ?? 0)
              .toDouble();
      if (avgSalary > 0 && dept != '未知部门') {
        departmentMap.putIfAbsent(dept, () => []).add(avgSalary);
      }
    }

    final departmentSummary = departmentMap.isNotEmpty
        ? departmentMap.entries
              .map((entry) {
                final dept = entry.key;
                final salaries = entry.value;
                final avgSalary =
                    salaries.reduce((a, b) => a + b) / salaries.length;
                return '$dept平均薪资${avgSalary.toStringAsFixed(0)}元';
              })
              .join('，')
        : '暂无有效部门薪资数据';

    // 构建专业报告格式的prompt
    final prompt =
        '''
作为一名专业的HR分析师，请你基于以下具体数据撰写一段专业的薪资区间分布分析报告：

数据基础：
- 月度薪资情况：$monthlyDataSummary
- 部门薪资分布：$departmentSummary

参考报告模板：
在对多月薪资数据进行分析后发现，整体薪资区间分布较为集中，大部分员工集中在5000至7000元区间，体现出公司目前以基础薪资为主的薪酬结构。从部门维度看，研发部薪资水平略高于其他部门，具备一定的技术岗位溢价特征；赛事运营中心、人事部及地推部的薪资水平相对接近，整体处于基础薪资水平，差异化不明显，显示出非核心部门在薪酬上的均衡性。薪资区间的合理性总体可接受，但高薪区间人数比例偏低，可能影响公司对高端人才的吸引力。在薪资结构优化方面，建议逐步拉开不同层级之间的差距，增加绩效和激励型薪酬的占比，以形成更合理的薪资梯度。同时，在人才梯队建设上，应在保持基础岗位稳定性的前提下，加大对关键岗位和高潜人才的薪酬倾斜，既能增强核心人员的留任动力，也有助于建立更加健康和可持续的人才发展体系。

分析要求：
1. 必须使用上述提供的具体数据进行分析，不得虚构数据
2. 必须使用专业、严谨的HR分析语言
3. 必须使用中文标点符号（逗号、顿号、句号等）
4. 必须覆盖薪资区间分布、部门差异、优化建议、人才梯队四个方面
5. 禁止使用markdown格式和换行符，输出一段连续文字

请基于以上要求生成分析报告。
''';

    final result = await _aiSummaryService.getAnswer(prompt);

    return result;
  }

  /// 生成薪资结构描述
  String _generateSalaryStructureDescription(
    Map<String, dynamic> structureData,
  ) {
    final salaryComposition =
        structureData['salaryCompositionTrend'] as List? ?? [];

    if (salaryComposition.isEmpty) {
      return '在多月的薪资结构观察中，尚未形成可供分析的数据。';
    }

    final buffer = StringBuffer();
    buffer.write('在多月的薪资结构分析中，');

    final List<String> monthDescriptions = [];

    for (final monthData in salaryComposition) {
      final month = monthData['month'] as String;
      final totalAmount =
          (num.tryParse(monthData['totalAmount'].toString()) ?? 0).toDouble();

      // 收集各类工资项
      final items = <String>[];

      void addItem(String label, double amount, double ratio) {
        if (amount > 0) {
          items.add(
            '$label${amount.toStringAsFixed(2)}元，占比${(ratio * 100).toStringAsFixed(1)}%',
          );
        }
      }

      addItem(
        '基本工资',
        (num.tryParse(monthData['basicSalaryAmount'].toString()) ?? 0)
            .toDouble(),
        (num.tryParse(monthData['basicSalaryRatio'].toString()) ?? 0)
            .toDouble(),
      );
      addItem(
        '岗位工资',
        (num.tryParse(monthData['positionSalaryAmount'].toString()) ?? 0)
            .toDouble(),
        (num.tryParse(monthData['positionSalaryRatio'].toString()) ?? 0)
            .toDouble(),
      );
      addItem(
        '绩效工资',
        (num.tryParse(monthData['performanceSalaryAmount'].toString()) ?? 0)
            .toDouble(),
        (num.tryParse(monthData['performanceSalaryRatio'].toString()) ?? 0)
            .toDouble(),
      );
      addItem(
        '补贴',
        (num.tryParse(monthData['allowanceSalaryAmount'].toString()) ?? 0)
            .toDouble(),
        (num.tryParse(monthData['allowanceSalaryRatio'].toString()) ?? 0)
            .toDouble(),
      );
      addItem(
        '饭补',
        (num.tryParse(monthData['mealAllowanceAmount'].toString()) ?? 0)
            .toDouble(),
        (num.tryParse(monthData['mealAllowanceRatio'].toString()) ?? 0)
            .toDouble(),
      );
      addItem(
        '电脑补贴等',
        (num.tryParse(monthData['computerAllowanceAmount'].toString()) ?? 0)
            .toDouble(),
        (num.tryParse(monthData['computerAllowanceRatio'].toString()) ?? 0)
            .toDouble(),
      );

      final detail = items.isNotEmpty ? '其中${items.join('，')}' : '未见明显构成差异';
      monthDescriptions.add(
        '$month总薪资${totalAmount.toStringAsFixed(2)}元，$detail。',
      );
    }

    buffer.write(monthDescriptions.join(' '));
    return buffer.toString();
  }

  /// 获取每月部门详情数据
  List<Map<String, dynamic>> _getDepartmentDetailsPerMonth(
    Map<String, dynamic> analysisData,
  ) {
    final departmentDetailsPerMonth = <Map<String, dynamic>>[];

    logger.info(
      "获取每月部门详情数据  ${analysisData.containsKey('departmentStatsPerMonth')}  ${analysisData['departmentStatsPerMonth'].runtimeType}",
    );

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

  /// 将部门详情数据转换为图表所需格式
  List<Map<String, dynamic>>? _convertDepartmentDetailsToChartFormat(
    List<Map<String, dynamic>> departmentDetailsPerMonth,
  ) {
    if (departmentDetailsPerMonth.isEmpty) return null;

    final List<Map<String, dynamic>> chartData = [];

    for (var monthData in departmentDetailsPerMonth) {
      final departments =
          monthData['departmentStats'] as List<Map<String, dynamic>>;
      chartData.add({
        'year': monthData['year'],
        'month': monthData['monthNum'],
        'departments': departments
            .map(
              (dept) => {
                'department': dept['department'],
                'employeeCount': dept['employeeCount'],
              },
            )
            .toList(),
      });
    }

    logger.info('chartData: $chartData');

    return chartData;
  }
}
