// src/services/monthly/chart_generation_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/monthly/monthly_report_models.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:ui' as ui;

class MonthlyChartGenerationService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<MonthlyReportChartImages> generateAllCharts({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required List<Map<String, dynamic>> salaryRanges,
    List<Map<String, dynamic>>? salaryStructureData, // 薪资结构数据
    List<AttendanceStats>? attendanceStats, // 考勤统计数据
    List<dynamic>? topEmployeesData, // 顶级员工数据
    List<dynamic>? departmentSalaryRangeData, // 部门薪资区间数据
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

    // 生成考勤统计图表
    final attendanceChartImage = attendanceStats != null && attendanceStats.isNotEmpty
        ? await _generateAttendanceChart(attendanceStats)
        : null;

    // 生成顶级员工图表
    final topEmployeesChartImage = topEmployeesData != null && topEmployeesData.isNotEmpty
        ? await _generateTopEmployeesChart(topEmployeesData)
        : null;

    // 生成部门薪资区间图表
    final departmentSalaryRangeChartImage = departmentSalaryRangeData != null && departmentSalaryRangeData.isNotEmpty
        ? await _generateDepartmentSalaryRangeChart(departmentSalaryRangeData)
        : null;

    return MonthlyReportChartImages(
      mainChart: mainChartImage,
      departmentDetailsChart: departmentChartImage,
      salaryRangeChart: salaryRangeChartImage,
      salaryStructureChart: salaryStructureChartImage,
      attendanceChart: attendanceChartImage,
      topEmployeesChart: topEmployeesChartImage,
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

  /// 生成顶级员工图表
  Future<Uint8List?> _generateTopEmployeesChart(
    List<dynamic> topEmployeesData,
  ) async {
    if (topEmployeesData.isEmpty) return null;

    // 转换数据格式
    final List<EmployeeSalaryChartData> chartData = topEmployeesData
        .map(
          (data) => EmployeeSalaryChartData(
            name: data['name'] as String,
            netSalary: (data['net_salary'] as num).toDouble(),
          ),
        )
        .toList();

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '工资最高的员工'),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(minimum: 0),
        series: <CartesianSeries<EmployeeSalaryChartData, String>>[
          ColumnSeries<EmployeeSalaryChartData, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: chartData,
            xValueMapper: (data, _) => data.name,
            yValueMapper: (data, _) => data.netSalary,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );

    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成部门薪资区间联合统计图表
  Future<Uint8List?> _generateDepartmentSalaryRangeChart(
    List<dynamic> departmentSalaryRangeData,
  ) async {
    if (departmentSalaryRangeData.isEmpty) return null;

    // 为每个部门创建数据系列
    final seriesList = <CartesianSeries<dynamic, String>>[];
    final allRanges = <String>{};

    // 收集所有薪资区间
    for (var deptData in departmentSalaryRangeData) {
      if (deptData is Map<String, dynamic> &&
          deptData.containsKey('salary_ranges')) {
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
      if (deptData is Map<String, dynamic> &&
          deptData.containsKey('department') &&
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

/// 员工薪资图表数据模型
class EmployeeSalaryChartData {
  final String name;
  final double netSalary;

  EmployeeSalaryChartData({required this.name, required this.netSalary});
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
