// src/services/yearly/chart_generation_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/yearly/yearly_report_models.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:ui' as ui;

class YearlyChartGenerationService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<YearlyReportChartImages> generateAllCharts({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required List<Map<String, dynamic>> salaryRanges,
    List<Map<String, dynamic>>? salaryStructureData, // 薪资结构数据
    // 年度报告专用图表数据
    List<Map<String, dynamic>>? employeeCountPerMonth,
    List<Map<String, dynamic>>? averageSalaryPerMonth,
    List<Map<String, dynamic>>? totalSalaryPerMonth,
    List<Map<String, dynamic>>? departmentDetailsPerMonth,
    List<Map<String, dynamic>>? lastMonthDepartmentStats,
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
    final departmentChartImage = await _generateDepartmentDetailsChart(
      departmentStats,
    );

    final salaryRangeChartImage = await _generateSalaryRangeChart(salaryRanges);
    final salaryStructureChartImage =
        salaryStructureData != null && salaryStructureData.isNotEmpty
        ? await _generateSalaryStructureChart(salaryStructureData)
        : null;

    // 3. Generate yearly monthly charts
    final employeeCountPerMonthChartImage =
        employeeCountPerMonth != null && employeeCountPerMonth.isNotEmpty
        ? await _generateEmployeeCountPerMonthChart(employeeCountPerMonth)
        : null;

    final averageSalaryPerMonthChartImage =
        averageSalaryPerMonth != null && averageSalaryPerMonth.isNotEmpty
        ? await _generateAverageSalaryPerMonthChart(averageSalaryPerMonth)
        : null;

    final totalSalaryPerMonthChartImage =
        totalSalaryPerMonth != null && totalSalaryPerMonth.isNotEmpty
        ? await _generateTotalSalaryPerMonthChart(totalSalaryPerMonth)
        : null;

    final departmentDetailsPerMonthChartImage =
        departmentDetailsPerMonth != null && departmentDetailsPerMonth.isNotEmpty
        ? await _generateDepartmentDetailsPerMonthChart(departmentDetailsPerMonth)
        : null;

    return YearlyReportChartImages(
      mainChart: mainChartImage,
      departmentDetailsChart: departmentChartImage,
      salaryRangeChart: salaryRangeChartImage,
      salaryStructureChart: salaryStructureChartImage, // 薪资结构饼图
      employeeCountPerMonthChart: employeeCountPerMonthChartImage,
      averageSalaryPerMonthChart: averageSalaryPerMonthChartImage,
      totalSalaryPerMonthChart: totalSalaryPerMonthChartImage,
      departmentDetailsPerMonthChart: departmentDetailsPerMonthChartImage,
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

  /// 生成每月员工数量图表
  Future<Uint8List?> _generateEmployeeCountPerMonthChart(
    List<Map<String, dynamic>> data,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '年度每月员工数量趋势'),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: data,
            xValueMapper: (d, _) => '${d['monthNum']}月',
            yValueMapper: (d, _) => d['employeeCount'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每月平均工资图表
  Future<Uint8List?> _generateAverageSalaryPerMonthChart(
    List<Map<String, dynamic>> data,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '年度每月平均工资趋势'),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: data,
            xValueMapper: (d, _) => '${d['monthNum']}月',
            yValueMapper: (d, _) => d['averageSalary'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每月总工资图表
  Future<Uint8List?> _generateTotalSalaryPerMonthChart(
    List<Map<String, dynamic>> data,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '年度每月工资总额趋势'),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          ColumnSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: data,
            xValueMapper: (d, _) => '${d['monthNum']}月',
            yValueMapper: (d, _) => d['totalSalary'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每月部门详情图表
  Future<Uint8List?> _generateDepartmentDetailsPerMonthChart(
    List<Map<String, dynamic>> data,
  ) async {
    // 这里简化处理，生成一个部门月度对比图表
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '年度各月部门人员分布'),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          ColumnSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: data,
            xValueMapper: (d, _) => '${d['monthNum']}月',
            yValueMapper: (d, _) => (d['departmentStats'] as List).length,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
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
