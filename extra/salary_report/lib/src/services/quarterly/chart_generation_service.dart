// src/services/quarterly/chart_generation_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/quarterly/quarterly_report_models.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:ui' as ui;

class QuarterlyChartGenerationService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<QuarterlyReportChartImages> generateAllCharts({
    required GlobalKey previewContainerKey,
    required Map<String, int> departmentStats,
    required List<Map<String, dynamic>> salaryRanges,
    List<Map<String, dynamic>>? salaryStructureData, // 薪资结构数据
    List<Map<String, dynamic>>? departmentStatsPerMonth, // 多月部门数据
    List<AttendanceStats>? attendanceStats, // 考勤统计数据
    List<Map<String, dynamic>>? departmentSalaryRangeData, // 部门薪资区间数据
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
      departmentStatsPerMonth: departmentStatsPerMonth,
    );

    logger.info('Generating salaryStructureData $salaryStructureData');

    final salaryRangeChartImage = await _generateSalaryRangeChart(salaryRanges);
    final salaryStructureChartImage =
        salaryStructureData != null && salaryStructureData.isNotEmpty
        ? await _generateSalaryStructureChart(salaryStructureData)
        : null;

    // 生成考勤统计图表
    final attendanceChartImage =
        attendanceStats != null && attendanceStats.isNotEmpty
        ? await _generateAttendanceChart(attendanceStats)
        : null;

    // 生成部门薪资区间联合统计图表
    final departmentSalaryRangeChartImage =
        departmentSalaryRangeData != null &&
            departmentSalaryRangeData.isNotEmpty
        ? await _generateDepartmentSalaryRangeChart(departmentSalaryRangeData)
        : null;

    return QuarterlyReportChartImages(
      mainChart: mainChartImage,
      departmentDetailsChart: departmentChartImage,
      salaryRangeChart: salaryRangeChartImage,
      salaryStructureChart: salaryStructureChartImage,
      attendanceChart: attendanceChartImage,
      departmentSalaryRangeChart: departmentSalaryRangeChartImage,
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
    Map<String, int> stats, {
    List<Map<String, dynamic>>? departmentStatsPerMonth,
  }) async {
    logger.info(
      'Generating department details chart  departmentStatsPerMonth  $departmentStatsPerMonth',
    );

    // 如果有多月数据，使用多月数据生成图表
    if (departmentStatsPerMonth != null && departmentStatsPerMonth.isNotEmpty) {
      return _generateMultiMonthDepartmentChart(departmentStatsPerMonth);
    }

    final stats_ = stats.entries.toList();

    // 否则使用原有的单月数据
    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '部门人员详情(以最后一个月为准)'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
          title: AxisTitle(text: '部门'),
        ),
        primaryYAxis: NumericAxis(minimum: 0, title: AxisTitle(text: '人数')),
        series: <ColumnSeries<MapEntry, String>>[
          ColumnSeries<MapEntry, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: stats_,
            xValueMapper: (stat, _) => stat.key,
            yValueMapper: (stat, _) => stat.value,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            name: '人员数量',
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

  /// 生成考勤统计图表
  Future<Uint8List?> _generateAttendanceChart(
    List<AttendanceStats> attendanceStats,
  ) async {
    if (attendanceStats.isEmpty) return null;

    // 转换数据格式
    final List<AttendanceChartData> chartData = attendanceStats
        .map(
          (data) => AttendanceChartData(
            name: data.name,
            department: data.department,
            sickLeaveDays: data.sickLeaveDays,
            leaveDays: data.leaveDays,
            absenceCount: data.absenceCount.toDouble(),
            truancyDays: data.truancyDays.toDouble(),
          ),
        )
        .toList();

    // 创建多个系列： sick leave, leave, absence, truancy
    final seriesList = <CartesianSeries<AttendanceChartData, String>>[
      ColumnSeries<AttendanceChartData, String>(
        name: '病假天数',
        dataSource: chartData,
        xValueMapper: (data, _) => data.name,
        yValueMapper: (data, _) => data.sickLeaveDays,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      ),
      ColumnSeries<AttendanceChartData, String>(
        name: '请假天数',
        dataSource: chartData,
        xValueMapper: (data, _) => data.name,
        yValueMapper: (data, _) => data.leaveDays,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      ),
      ColumnSeries<AttendanceChartData, String>(
        name: '缺勤次数',
        dataSource: chartData,
        xValueMapper: (data, _) => data.name,
        yValueMapper: (data, _) => data.absenceCount,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      ),
      ColumnSeries<AttendanceChartData, String>(
        name: '旷工天数',
        dataSource: chartData,
        xValueMapper: (data, _) => data.name,
        yValueMapper: (data, _) => data.truancyDays,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      ),
    ];

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '考勤统计'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(minimum: 0),
        series: seriesList,
      ),
    );

    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成部门薪资区间联合统计图表
  Future<Uint8List?> _generateDepartmentSalaryRangeChart(
    List<Map<String, dynamic>> departmentSalaryRangeData,
  ) async {
    if (departmentSalaryRangeData.isEmpty) return null;

    // 为每个部门创建数据系列
    final seriesList = <CartesianSeries<dynamic, String>>[];
    final allRanges = <String>{};

    // 收集所有薪资区间
    for (var deptData in departmentSalaryRangeData) {
      if (deptData.containsKey('salary_ranges')) {
        final salaryRanges = deptData['salary_ranges'] as List<dynamic>;
        for (var range in salaryRanges) {
          if (range is Map<String, dynamic> &&
              range.containsKey('salary_range')) {
            allRanges.add(range['salary_range'] as String);
          }
        }
      }
    }

    // 为每个部门创建系列
    for (var deptData in departmentSalaryRangeData) {
      if (deptData.containsKey('department') &&
          deptData.containsKey('salary_ranges')) {
        final department = deptData['department'] as String;
        final salaryRanges = deptData['salary_ranges'] as List<dynamic>;

        // 创建该部门的薪资区间数据
        final List<DepartmentSalaryRangePoint> deptRangeData = [];
        for (var rangeName in allRanges) {
          // 查找该部门在此薪资区间的员工数
          var employeeCount = 0;
          for (var range in salaryRanges) {
            if (range is Map<String, dynamic> &&
                range.containsKey('salary_range') &&
                range['salary_range'] == rangeName &&
                range.containsKey('employee_count')) {
              employeeCount = range['employee_count'] as int;
              break;
            }
          }
          deptRangeData.add(
            DepartmentSalaryRangePoint(
              range: rangeName,
              employeeCount: employeeCount,
            ),
          );
        }

        seriesList.add(
          ColumnSeries<DepartmentSalaryRangePoint, String>(
            name: department,
            dataSource: deptRangeData,
            xValueMapper: (data, _) => data.range,
            yValueMapper: (data, _) => data.employeeCount,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
        );
      }
    }

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '各部门薪资区间分布'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
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

/// 考勤图表数据模型
class AttendanceChartData {
  final String name;
  final String department;
  final double sickLeaveDays;
  final double leaveDays;
  final double absenceCount;
  final double truancyDays;

  AttendanceChartData({
    required this.name,
    required this.department,
    required this.sickLeaveDays,
    required this.leaveDays,
    required this.absenceCount,
    required this.truancyDays,
  });
}

/// 部门薪资区间数据点
class DepartmentSalaryRangePoint {
  final String range;
  final int employeeCount;

  DepartmentSalaryRangePoint({
    required this.range,
    required this.employeeCount,
  });
}
