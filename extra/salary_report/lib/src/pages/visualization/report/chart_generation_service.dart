// src/report/services/chart_generation_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';

import 'dart:ui' as ui;

class ChartGenerationService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<ReportChartImages> generateAllCharts({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required Map<String, int> salaryRanges,
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

    return ReportChartImages(
      mainChart: mainChartImage,
      departmentDetailsChart: departmentChartImage,
      salaryRangeChart: salaryRangeChartImage,
    );
  }

  Future<Uint8List> _captureWidgetAsImage(Widget widget) {
    return _screenshotController.captureFromWidget(
      MediaQuery(
        data: MediaQueryData.fromView(WidgetsBinding.instance.window),
        child: Directionality(textDirection: TextDirection.ltr, child: widget),
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
    Map<String, int> salaryRanges,
  ) async {
    final data = salaryRanges.entries
        .map((e) => {'range': e.key, 'count': e.value})
        .toList();

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

  Widget _buildChartContainer(Widget chart) {
    return Container(
      width: 800,
      height: 600,
      color: Colors.white,
      child: chart,
    );
  }
}
