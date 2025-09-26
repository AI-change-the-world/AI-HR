// src/services/multi_quarter/chart_generation_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/multi_quarter/multi_quarter_report_models.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:ui' as ui;

class MultiQuarterChartGenerationService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<MultiQuarterReportChartImages> generateAllCharts({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required List<Map<String, dynamic>> salaryRanges,
    List<Map<String, dynamic>>? salaryStructureData, // 薪资结构数据
    // 多季度报告专用图表数据
    List<Map<String, dynamic>>? employeeCountPerQuarter, // 每季度人数变化数据
    List<Map<String, dynamic>>? averageSalaryPerQuarter, // 每季度平均薪资变化数据
    List<Map<String, dynamic>>? totalSalaryPerQuarter, // 每季度总工资变化数据
    List<Map<String, dynamic>>? departmentDetailsPerQuarter, // 每季度各部门详情数据
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

    // 3. 生成多季度报告专用图表
    Uint8List? employeeCountPerQuarterChart;
    Uint8List? averageSalaryPerQuarterChart;
    Uint8List? totalSalaryPerQuarterChart;
    Uint8List? departmentDetailsPerQuarterChart;

    if (employeeCountPerQuarter != null && employeeCountPerQuarter.isNotEmpty) {
      employeeCountPerQuarterChart =
          await _generateEmployeeCountPerQuarterChart(employeeCountPerQuarter);
    }

    if (averageSalaryPerQuarter != null && averageSalaryPerQuarter.isNotEmpty) {
      averageSalaryPerQuarterChart =
          await _generateAverageSalaryPerQuarterChart(averageSalaryPerQuarter);
    }

    if (totalSalaryPerQuarter != null && totalSalaryPerQuarter.isNotEmpty) {
      totalSalaryPerQuarterChart = await _generateTotalSalaryPerQuarterChart(
        totalSalaryPerQuarter,
      );
    }

    if (departmentDetailsPerQuarter != null &&
        departmentDetailsPerQuarter.isNotEmpty) {
      departmentDetailsPerQuarterChart =
          await _generateDepartmentDetailsPerQuarterChart(
            departmentDetailsPerQuarter,
          );
    }

    return MultiQuarterReportChartImages(
      mainChart: mainChartImage,
      departmentDetailsChart: departmentChartImage,
      salaryRangeChart: salaryRangeChartImage,
      salaryStructureChart: salaryStructureChartImage, // 薪资结构饼图
      // 多季度报告专用图表
      employeeCountPerQuarterChart: employeeCountPerQuarterChart, // 每季度人数变化图表
      averageSalaryPerQuarterChart: averageSalaryPerQuarterChart, // 每季度平均薪资变化图表
      totalSalaryPerQuarterChart: totalSalaryPerQuarterChart, // 每季度总工资变化图表
      departmentDetailsPerQuarterChart:
          departmentDetailsPerQuarterChart, // 每季度各部门详情图表
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

  /// 生成每季度人数变化图表
  Future<Uint8List?> _generateEmployeeCountPerQuarterChart(
    List<Map<String, dynamic>> employeeCountPerQuarter,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '每季度人数变化'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: employeeCountPerQuarter,
            xValueMapper: (d, _) => d['quarter'].toString(),
            yValueMapper: (d, _) => d['employeeCount'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每季度平均薪资变化图表
  Future<Uint8List?> _generateAverageSalaryPerQuarterChart(
    List<Map<String, dynamic>> averageSalaryPerQuarter,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '每季度平均薪资变化'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: averageSalaryPerQuarter,
            xValueMapper: (d, _) => d['quarter'].toString(),
            yValueMapper: (d, _) => d['averageSalary'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每季度总工资变化图表
  Future<Uint8List?> _generateTotalSalaryPerQuarterChart(
    List<Map<String, dynamic>> totalSalaryPerQuarter,
  ) async {
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '每季度总工资变化'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        series: [
          LineSeries<Map<String, dynamic>, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: totalSalaryPerQuarter,
            xValueMapper: (d, _) => d['quarter'].toString(),
            yValueMapper: (d, _) => d['totalSalary'],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成每季度各部门详情图表
  Future<Uint8List?> _generateDepartmentDetailsPerQuarterChart(
    List<Map<String, dynamic>> departmentDetailsPerQuarter,
  ) async {
    // 提取所有部门名称
    final departments = <String>{};
    for (var quarterData in departmentDetailsPerQuarter) {
      if (quarterData.containsKey('departments')) {
        final deptList = quarterData['departments'] as List<dynamic>;
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
      for (var quarterData in departmentDetailsPerQuarter) {
        if (quarterData.containsKey('departments')) {
          final deptList = quarterData['departments'] as List<dynamic>;
          for (var dept in deptList) {
            if (dept is Map<String, dynamic> &&
                dept.containsKey('department') &&
                dept['department'] == department) {
              departmentData.add({
                'quarter': quarterData['quarter'].toString(),
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
            xValueMapper: (d, _) => d['quarter'],
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
