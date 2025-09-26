// src/services/multi_year/chart_generation_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/multi_year/multi_year_report_models.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:ui' as ui;

class MultiYearChartGenerationService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<MultiYearReportChartImages> generateAllCharts({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required List<Map<String, dynamic>> salaryRanges,
    List<Map<String, dynamic>>? salaryStructureData, // 薪资结构数据
    // 多年报告专用图表数据
    List<Map<String, dynamic>>? employeeCountPerYear, // 每年人数变化数据
    List<Map<String, dynamic>>? averageSalaryPerYear, // 每年平均薪资变化数据
    List<Map<String, dynamic>>? totalSalaryPerYear, // 每年总工资变化数据
    List<Map<String, dynamic>>? departmentDetailsPerYear, // 每年各部门详情数据
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

    // 3. 生成多年报告专用图表
    Uint8List? employeeCountPerYearChart;
    Uint8List? averageSalaryPerYearChart;
    Uint8List? totalSalaryPerYearChart;
    Uint8List? departmentDetailsPerYearChart;

    if (employeeCountPerYear != null && employeeCountPerYear.isNotEmpty) {
      employeeCountPerYearChart = await _generateEmployeeCountPerYearChart(
        employeeCountPerYear,
      );
    }

    if (averageSalaryPerYear != null && averageSalaryPerYear.isNotEmpty) {
      averageSalaryPerYearChart = await _generateAverageSalaryPerYearChart(
        averageSalaryPerYear,
      );
    }

    if (totalSalaryPerYear != null && totalSalaryPerYear.isNotEmpty) {
      totalSalaryPerYearChart = await _generateTotalSalaryPerYearChart(
        totalSalaryPerYear,
      );
    }

    if (departmentDetailsPerYear != null &&
        departmentDetailsPerYear.isNotEmpty) {
      departmentDetailsPerYearChart =
          await _generateDepartmentDetailsPerYearChart(
            departmentDetailsPerYear,
          );
    }

    return MultiYearReportChartImages(
      mainChart: mainChartImage,
      departmentDetailsChart: departmentChartImage,
      salaryRangeChart: salaryRangeChartImage,
      salaryStructureChart: salaryStructureChartImage, // 薪资结构饼图
      // 多年报告专用图表
      employeeCountPerYearChart: employeeCountPerYearChart, // 每年人数变化图表
      averageSalaryPerYearChart: averageSalaryPerYearChart, // 每年平均薪资变化图表
      totalSalaryPerYearChart: totalSalaryPerYearChart, // 每年总工资变化图表
      departmentDetailsPerYearChart: departmentDetailsPerYearChart, // 每年各部门详情图表
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

  /// 生成每年人数变化图表
  Future<Uint8List?> _generateEmployeeCountPerYearChart(
    List<Map<String, dynamic>> employeeCountPerYear,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '每年人数变化'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: employeeCountPerYear,
            xValueMapper: (d, _) => d['year'].toString(),
            yValueMapper: (d, _) => d['employeeCount'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每年平均薪资变化图表
  Future<Uint8List?> _generateAverageSalaryPerYearChart(
    List<Map<String, dynamic>> averageSalaryPerYear,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '每年平均薪资变化'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: averageSalaryPerYear,
            xValueMapper: (d, _) => d['year'].toString(),
            yValueMapper: (d, _) => d['averageSalary'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每年总工资变化图表
  Future<Uint8List?> _generateTotalSalaryPerYearChart(
    List<Map<String, dynamic>> totalSalaryPerYear,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '每年总工资变化'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: totalSalaryPerYear,
            xValueMapper: (d, _) => d['year'].toString(),
            yValueMapper: (d, _) => d['totalSalary'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每年各部门详情图表
  Future<Uint8List?> _generateDepartmentDetailsPerYearChart(
    List<Map<String, dynamic>> departmentDetailsPerYear,
  ) async {
    // 提取所有部门名称
    final departments = <String>{};
    for (var yearData in departmentDetailsPerYear) {
      if (yearData.containsKey('departments')) {
        final deptList = yearData['departments'] as List<dynamic>;
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
      for (var yearData in departmentDetailsPerYear) {
        if (yearData.containsKey('departments')) {
          final deptList = yearData['departments'] as List<dynamic>;
          for (var dept in deptList) {
            if (dept is Map<String, dynamic> &&
                dept.containsKey('department') &&
                dept['department'] == department) {
              departmentData.add({
                'year': yearData['year'].toString(),
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
            xValueMapper: (d, _) => d['year'],
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
