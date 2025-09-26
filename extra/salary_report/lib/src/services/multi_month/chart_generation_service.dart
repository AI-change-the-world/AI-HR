// src/services/multi_month/chart_generation_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/multi_month/multi_month_report_models.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:ui' as ui;

class MultiMonthChartGenerationService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<MultiMonthReportChartImages> generateAllCharts({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required List<Map<String, dynamic>> salaryRanges,
    List<Map<String, dynamic>>? salaryStructureData, // 薪资结构数据
    // 多月报告专用图表数据
    List<Map<String, dynamic>>? employeeCountPerMonth, // 每月人数变化数据
    List<Map<String, dynamic>>? averageSalaryPerMonth, // 每月平均薪资变化数据
    List<Map<String, dynamic>>? totalSalaryPerMonth, // 每月总工资变化数据
    List<Map<String, dynamic>>? departmentDetailsPerMonth, // 每月各部门详情数据
    List<Map<String, dynamic>>? lastMonthDepartmentStats, // 最后一个月部门统计数据（用于图表生成）
    List<Map<String, dynamic>>? departmentStatsPerMonth, // 多月部门数据
  }) async {
    // 1. Capture the existing chart from the UI
    Uint8List? mainChartImage;
    if (previewContainerKey.currentContext != null) {
      final boundary =
          previewContainerKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      mainChartImage = byteData?.buffer.asUint8List();
    }

    // 2. Generate other charts virtually
    // 对于多月报告，使用最后一个月的数据生成部门详情图表
    Uint8List? departmentChartImage;
    if (lastMonthDepartmentStats != null &&
        lastMonthDepartmentStats.isNotEmpty) {
      // 使用最后一个月的数据生成部门详情图表
      final lastMonthStats = lastMonthDepartmentStats.map((data) {
        return DepartmentSalaryStats(
          department: data['department'] as String,
          employeeCount: data['employeeCount'] as int,
          averageNetSalary: data['averageSalary'] as double,
          totalNetSalary: data['totalSalary'] as double,
          year: data['year'] as int? ?? 0,
          month: data['month'] as int? ?? 0,
        );
      }).toList();

      departmentChartImage = await _generateDepartmentDetailsChart(
        lastMonthStats,
      );
    } else {
      // 使用原有的部门统计数据
      departmentChartImage = await _generateDepartmentDetailsChart(
        departmentStats,
      );
    }

    final salaryRangeChartImage = await _generateSalaryRangeChart(salaryRanges);
    final salaryStructureChartImage =
        salaryStructureData != null && salaryStructureData.isNotEmpty
        ? await _generateSalaryStructureChart(salaryStructureData)
        : null;

    // 3. 生成多月报告专用图表
    Uint8List? employeeCountPerMonthChart;
    Uint8List? averageSalaryPerMonthChart;
    Uint8List? totalSalaryPerMonthChart;
    Uint8List? departmentDetailsPerMonthChart;

    if (departmentStatsPerMonth != null && departmentStatsPerMonth.isNotEmpty) {
      employeeCountPerMonthChart = await _generateMultiMonthDepartmentChart(
        departmentStatsPerMonth,
      );
    }

    if (averageSalaryPerMonth != null && averageSalaryPerMonth.isNotEmpty) {
      averageSalaryPerMonthChart = await _generateAverageSalaryPerMonthChart(
        averageSalaryPerMonth,
      );
    }

    if (totalSalaryPerMonth != null && totalSalaryPerMonth.isNotEmpty) {
      totalSalaryPerMonthChart = await _generateTotalSalaryPerMonthChart(
        totalSalaryPerMonth,
      );
    }

    if (departmentDetailsPerMonth != null &&
        departmentDetailsPerMonth.isNotEmpty) {
      departmentDetailsPerMonthChart =
          await _generateDepartmentDetailsPerMonthChart(
            departmentDetailsPerMonth,
          );
    }

    return MultiMonthReportChartImages(
      mainChart: mainChartImage,
      departmentDetailsChart: departmentChartImage,
      salaryRangeChart: salaryRangeChartImage,
      salaryStructureChart: salaryStructureChartImage, // 薪资结构饼图
      // 多月报告专用图表
      employeeCountPerMonthChart: employeeCountPerMonthChart, // 每月人数变化图表
      averageSalaryPerMonthChart: averageSalaryPerMonthChart, // 每月平均薪资变化图表
      totalSalaryPerMonthChart: totalSalaryPerMonthChart, // 每月总工资变化图表
      departmentDetailsPerMonthChart:
          departmentDetailsPerMonthChart, // 每月各部门详情图表
    );
  }

  Future<Uint8List> _captureWidgetAsImage(Widget widget) {
    return _screenshotController.captureFromWidget(
      RepaintBoundary(
        child: MediaQuery(
          data: MediaQueryData.fromView(
            ui.PlatformDispatcher.instance.views.first,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      ),
      delay: const Duration(milliseconds: 200),
      pixelRatio: 3.0,
    );
  }

  Future<Uint8List?> _generateDepartmentDetailsChart(
    List<DepartmentSalaryStats> stats,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCircularChart(
        title: ChartTitle(text: '部门人员详情'),
        legend: Legend(isVisible: true),
        series: <PieSeries<DepartmentSalaryStats, String>>[
          PieSeries<DepartmentSalaryStats, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: stats,
            xValueMapper: (stat, _) => stat.department,
            yValueMapper: (stat, _) => stat.employeeCount,
            dataLabelMapper: (stat, _) =>
                '${stat.department}\n${stat.employeeCount}人',
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  Future<Uint8List?> _generateSalaryRangeChart(
    List<Map<String, dynamic>> data,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '工资区间分布'),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          ColumnSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: data,
            xValueMapper: (d, _) => d['range'],
            yValueMapper: (d, _) => d['count'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成薪资结构饼图
  Future<Uint8List?> _generateSalaryStructureChart(
    List<Map<String, dynamic>> salaryStructureData,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCircularChart(
        title: ChartTitle(text: '薪资结构分析'),
        legend: Legend(isVisible: true),
        series: <PieSeries<Map<String, dynamic>, String>>[
          PieSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: salaryStructureData,
            xValueMapper: (data, _) => data['category'],
            yValueMapper: (data, _) => data['value'],
            dataLabelMapper: (data, _) =>
                '${data['category']}\n${data['value']}',
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成多月部门人员图表
  Future<Uint8List?> _generateMultiMonthDepartmentChart(
    List<Map<String, dynamic>> departmentStatsPerMonth,
  ) async {
    logger.info('生成多月部门人员图表');

    // 收集所有月份和部门
    final Set<String> allMonths = {};
    final Set<String> allDepartments = {};
    for (var monthData in departmentStatsPerMonth) {
      final monthLabel = '${monthData['year']}年${monthData['month']}月';
      allMonths.add(monthLabel);

      final departments =
          monthData['departments'] as List<Map<String, dynamic>>;
      for (var dept in departments) {
        allDepartments.add(dept['department'] as String);
      }
    }

    // 转换数据：每个部门生成一组 series 数据
    final Map<String, List<Map<String, dynamic>>> seriesData = {};
    for (var dept in allDepartments) {
      seriesData[dept] = [];
      for (var monthData in departmentStatsPerMonth) {
        final monthLabel = '${monthData['year']}年${monthData['month']}月';
        final departments =
            monthData['departments'] as List<Map<String, dynamic>>;
        final deptData = departments.firstWhere(
          (d) => d['department'] == dept,
          orElse: () => {'employeeCount': 0},
        );
        seriesData[dept]!.add({
          'month': monthLabel,
          'employeeCount': deptData['employeeCount'] ?? 0,
        });
      }
    }

    logger.info('seriesData: $seriesData');

    // 配置 series
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    int colorIndex = 0;

    final List<ColumnSeries<Map<String, dynamic>, String>> seriesList = [];
    for (var dept in allDepartments) {
      seriesList.add(
        ColumnSeries<Map<String, dynamic>, String>(
          animationDelay: 0,
          animationDuration: 0,
          dataSource: seriesData[dept]!,
          xValueMapper: (data, _) => data['month'],
          yValueMapper: (data, _) => data['employeeCount'],
          name: dept,
          color: colors[colorIndex % colors.length],

          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            builder:
                (
                  dynamic data,
                  dynamic point,
                  dynamic series,
                  int pointIndex,
                  int seriesIndex,
                ) {
                  // 自定义显示：人数 + 部门名
                  return Text(
                    '$dept (${data['employeeCount']})',
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  );
                },
          ),
        ),
      );
      colorIndex++;
    }

    // 生成图表
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '各月部门人员数量对比'),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom, // 显示在底部
          overflowMode: LegendItemOverflowMode.wrap, // 超出自动换行
        ),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
          title: AxisTitle(text: '月份'),
        ),
        primaryYAxis: NumericAxis(minimum: 0, title: AxisTitle(text: '人数')),
        series: seriesList,
      ),
    );

    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每月人数变化图表
  Future<Uint8List?> _generateEmployeeCountPerMonthChart(
    List<Map<String, dynamic>> employeeCountPerMonth,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '每月人数变化'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: employeeCountPerMonth,
            xValueMapper: (d, _) => d['month'],
            yValueMapper: (d, _) => d['employeeCount'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每月平均薪资变化图表
  Future<Uint8List?> _generateAverageSalaryPerMonthChart(
    List<Map<String, dynamic>> averageSalaryPerMonth,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '每月平均薪资变化'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: averageSalaryPerMonth,
            xValueMapper: (d, _) => d['month'],
            yValueMapper: (d, _) => d['averageSalary'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每月总工资变化图表
  Future<Uint8List?> _generateTotalSalaryPerMonthChart(
    List<Map<String, dynamic>> totalSalaryPerMonth,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '每月总工资变化'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: totalSalaryPerMonth,
            xValueMapper: (d, _) => d['month'],
            yValueMapper: (d, _) => num.tryParse(d['totalSalary'].toString()),
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每月各部门详情图表
  Future<Uint8List?> _generateDepartmentDetailsPerMonthChart(
    List<Map<String, dynamic>> departmentDetailsPerMonth,
  ) async {
    // 提取所有部门名称
    final departments = <String>{};
    for (var monthData in departmentDetailsPerMonth) {
      if (monthData.containsKey('departments')) {
        final deptList = monthData['departments'] as List<dynamic>;
        for (var dept in deptList) {
          if (dept is Map<String, dynamic> && dept.containsKey('department')) {
            departments.add(dept['department'] as String);
          }
        }
      }
    }

    // 为每个部门创建数据系列
    final seriesList = <LineSeries<Map<String, dynamic>, String>>[];
    for (var department in departments) {
      final departmentData = <Map<String, dynamic>>[];
      for (var monthData in departmentDetailsPerMonth) {
        if (monthData.containsKey('departments')) {
          final deptList = monthData['departments'] as List<dynamic>;
          for (var dept in deptList) {
            if (dept is Map<String, dynamic> &&
                dept.containsKey('department') &&
                dept['department'] == department) {
              departmentData.add({
                'month': monthData['month'],
                'averageSalary': dept['averageSalary'],
              });
              break;
            }
          }
        }
      }

      if (departmentData.isNotEmpty) {
        seriesList.add(
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            name: department,
            dataSource: departmentData,
            xValueMapper: (d, _) => d['month'],
            yValueMapper: (d, _) => d['averageSalary'],
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
        );
      }
    }

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '各部门平均薪资趋势'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: seriesList,
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  Widget _buildChartContainer(Widget chart) {
    return Container(
      width: 800,
      height: 600,
      color: Colors.white,
      child: chart,
    );
  }
}
