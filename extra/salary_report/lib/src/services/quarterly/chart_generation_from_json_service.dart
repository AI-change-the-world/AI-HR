// src/services/quarterly/chart_generation_from_json_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;

/// 季度报告从JSON数据生成图表的服务
class QuarterlyChartGenerationFromJsonService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// 生成所有图表
  Future<ReportChartImagesFromJson> generateAllChartsFromJson({
    required Map<String, dynamic> jsonData,
  }) async {
    // 1. 生成部门统计图表
    Uint8List? departmentChartImage = await _generateDepartmentChart(
      jsonData['department_stats_chart_data'] as List<dynamic>,
    );

    // 2. 生成薪资区间分布图表
    Uint8List? salaryRangeChartImage = await _generateSalaryRangeChart(
      jsonData['salary_ranges_chart_data'] as List<dynamic>,
    );

    // 3. 生成工资最高员工图表
    Uint8List? topEmployeesChartImage = await _generateTopEmployeesChart(
      jsonData['top_employees_chart_data'] as List<dynamic>,
    );

    // 4. 生成考勤统计图表
    Uint8List? attendanceChartImage = await _generateAttendanceChart(
      jsonData['attendance_stats_chart_data'] as List<dynamic>,
    );

    // 5. 生成部门薪资区间联合统计图表
    Uint8List? departmentSalaryRangeChartImage =
        await _generateDepartmentSalaryRangeChart(
          jsonData['department_salary_ranges_chart_data'] as List<dynamic>,
        );

    return ReportChartImagesFromJson(
      departmentChart: departmentChartImage,
      salaryRangeChart: salaryRangeChartImage,
      topEmployeesChart: topEmployeesChartImage,
      attendanceChart: attendanceChartImage,
      departmentSalaryRangeChart: departmentSalaryRangeChartImage,
    );
  }

  /// 生成部门统计图表
  Future<Uint8List?> _generateDepartmentChart(
    List<dynamic> departmentData,
  ) async {
    if (departmentData.isEmpty) return null;

    // 转换数据格式
    final List<DepartmentChartData> chartData = departmentData
        .map(
          (data) => DepartmentChartData(
            department: data['department'] as String,
            employeeCount: data['employee_count'] as int,
            totalSalary: (data['total_salary'] as num).toDouble(),
            averageSalary: (data['average_salary'] as num).toDouble(),
          ),
        )
        .toList();

    final chartWidget = _buildChartContainer(
      SfCircularChart(
        title: ChartTitle(text: '部门人员详情'),
        legend: Legend(isVisible: true),
        series: <CircularSeries<DepartmentChartData, String>>[
          PieSeries<DepartmentChartData, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: chartData,
            xValueMapper: (data, _) => data.department,
            yValueMapper: (data, _) => data.employeeCount,
            dataLabelMapper: (data, _) =>
                '${data.department}\n${data.employeeCount}人',
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );

    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成薪资区间分布图表
  Future<Uint8List?> _generateSalaryRangeChart(
    List<dynamic> salaryRangeData,
  ) async {
    if (salaryRangeData.isEmpty) return null;

    // 转换数据格式
    final List<SalaryRangeChartData> chartData = salaryRangeData
        .map(
          (data) => SalaryRangeChartData(
            range: data['range'] as String,
            count: data['count'] as int,
            total: (data['total'] as num).toDouble(),
          ),
        )
        .toList();

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '工资区间分布'),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(minimum: 0),
        series: <CartesianSeries<SalaryRangeChartData, String>>[
          ColumnSeries<SalaryRangeChartData, String>(
            animationDelay: 0,
            animationDuration: 0,
            dataSource: chartData,
            xValueMapper: (data, _) => data.range,
            yValueMapper: (data, _) => data.count,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );

    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成工资最高员工图表
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

  /// 生成考勤统计图表
  Future<Uint8List?> _generateAttendanceChart(
    List<dynamic> attendanceData,
  ) async {
    if (attendanceData.isEmpty) return null;

    // 转换数据格式
    final List<AttendanceChartData> chartData = attendanceData
        .map(
          (data) => AttendanceChartData(
            name: data['name'] as String,
            department: data['department'] as String,
            sickLeaveDays: (data['sick_leave_days'] as num).toDouble(),
            leaveDays: (data['leave_days'] as num).toDouble(),
            absenceCount: (data['absence_count'] as num).toDouble(),
            truancyDays: (data['truancy_days'] as num).toDouble(),
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

  /// 截图Widget为图像
  Future<Uint8List> _captureWidgetAsImage(Widget widget) async {
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

  /// 构建图表容器
  Widget _buildChartContainer(Widget chart) {
    return Container(
      width: 800,
      height: 600,
      color: Colors.white,
      child: chart,
    );
  }
}

/// 图表数据模型
class DepartmentChartData {
  final String department;
  final int employeeCount;
  final double totalSalary;
  final double averageSalary;

  DepartmentChartData({
    required this.department,
    required this.employeeCount,
    required this.totalSalary,
    required this.averageSalary,
  });
}

class SalaryRangeChartData {
  final String range;
  final int count;
  final double total;

  SalaryRangeChartData({
    required this.range,
    required this.count,
    required this.total,
  });
}

class EmployeeSalaryChartData {
  final String name;
  final double netSalary;

  EmployeeSalaryChartData({required this.name, required this.netSalary});
}

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

class DepartmentSalaryRangePoint {
  final String range;
  final int employeeCount;

  DepartmentSalaryRangePoint({
    required this.range,
    required this.employeeCount,
  });
}

/// 从JSON生成的图表图像集合
class ReportChartImagesFromJson {
  final Uint8List? departmentChart;
  final Uint8List? salaryRangeChart;
  final Uint8List? topEmployeesChart;
  final Uint8List? attendanceChart;
  final Uint8List? departmentSalaryRangeChart;

  ReportChartImagesFromJson({
    this.departmentChart,
    this.salaryRangeChart,
    this.topEmployeesChart,
    this.attendanceChart,
    this.departmentSalaryRangeChart,
  });
}
