// src/services/trend_analysis_chart_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;
import 'global_analysis_models.dart';

/// 趋势分析图表生成服务
class TrendAnalysisChartService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// 生成月度薪资变化趋势图表
  Future<Uint8List?> generateMonthlySalaryTrendChart(
    List<MonthlySalaryChange> monthlyChanges,
  ) async {
    if (monthlyChanges.isEmpty) return null;

    // 转换数据格式
    final List<MonthlySalaryTrendData> chartData = monthlyChanges
        .map(
          (data) => MonthlySalaryTrendData(
            period: '${data.year}-${data.month.toString().padLeft(2, '0')}',
            totalSalary: data.totalSalary,
            averageSalary: data.averageSalary,
            employeeCount: data.employeeCount,
          ),
        )
        .toList();

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '月度薪资变化趋势'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(
          name: 'salary',
          title: AxisTitle(text: '薪资（元）'),
          minimum: 0,
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'employee',
            title: AxisTitle(text: '员工数'),
            opposedPosition: true,
            minimum: 0,
          ),
        ],
        series: <CartesianSeries>[
          LineSeries<MonthlySalaryTrendData, String>(
            name: '总薪资',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.totalSalary,
            yAxisName: 'salary',
            markerSettings: const MarkerSettings(isVisible: true),
          ),
          LineSeries<MonthlySalaryTrendData, String>(
            name: '平均薪资',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.averageSalary,
            yAxisName: 'salary',
            markerSettings: const MarkerSettings(isVisible: true),
          ),
          ColumnSeries<MonthlySalaryTrendData, String>(
            name: '员工数',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.employeeCount,
            yAxisName: 'employee',
            opacity: 0.7,
          ),
        ],
      ),
    );

    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成月度员工变化趋势图表
  Future<Uint8List?> generateMonthlyEmployeeTrendChart(
    List<EmployeeChange> employeeChanges,
  ) async {
    if (employeeChanges.isEmpty) return null;

    // 转换数据格式
    final List<MonthlyEmployeeTrendData> chartData = employeeChanges
        .map(
          (data) => MonthlyEmployeeTrendData(
            period: '${data.year}-${data.month.toString().padLeft(2, '0')}',
            totalEmployees: data.totalEmployeeCount,
            newEmployees: data.newEmployeeCount,
            leftEmployees: data.leftEmployeeCount,
            turnoverRate: data.turnoverRate,
          ),
        )
        .toList();

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '月度员工变化趋势'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(
          name: 'count',
          title: AxisTitle(text: '员工数'),
          minimum: 0,
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'rate',
            title: AxisTitle(text: '离职率（%）'),
            opposedPosition: true,
            minimum: 0,
          ),
        ],
        series: <CartesianSeries>[
          ColumnSeries<MonthlyEmployeeTrendData, String>(
            name: '总员工数',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.totalEmployees,
            yAxisName: 'count',
          ),
          ColumnSeries<MonthlyEmployeeTrendData, String>(
            name: '新增员工',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.newEmployees,
            yAxisName: 'count',
            color: Colors.green,
          ),
          ColumnSeries<MonthlyEmployeeTrendData, String>(
            name: '离职员工',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.leftEmployees,
            yAxisName: 'count',
            color: Colors.red,
          ),
          LineSeries<MonthlyEmployeeTrendData, String>(
            name: '离职率',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.turnoverRate,
            yAxisName: 'rate',
            markerSettings: const MarkerSettings(isVisible: true),
            color: Colors.orange,
          ),
        ],
      ),
    );

    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成季度薪资变化趋势图表
  Future<Uint8List?> generateQuarterlySalaryTrendChart(
    List<QuarterlySalaryChange> quarterlyChanges,
  ) async {
    if (quarterlyChanges.isEmpty) return null;

    // 转换数据格式
    final List<QuarterlySalaryTrendData> chartData = quarterlyChanges
        .map(
          (data) => QuarterlySalaryTrendData(
            period: '${data.year}年第${data.quarter}季度',
            totalSalary: data.totalSalary,
            averageSalary: data.averageSalary,
            employeeCount: data.employeeCount,
            totalSalaryChange: data.totalSalaryChange,
            averageSalaryChange: data.averageSalaryChange,
          ),
        )
        .toList();

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '季度薪资变化趋势'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: NumericAxis(
          name: 'salary',
          title: AxisTitle(text: '薪资（元）'),
          minimum: 0,
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'change',
            title: AxisTitle(text: '变化量（元）'),
            opposedPosition: true,
          ),
        ],
        series: <CartesianSeries>[
          ColumnSeries<QuarterlySalaryTrendData, String>(
            name: '总薪资',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.totalSalary,
            yAxisName: 'salary',
          ),
          ColumnSeries<QuarterlySalaryTrendData, String>(
            name: '平均薪资',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.averageSalary,
            yAxisName: 'salary',
            color: Colors.blue,
          ),
          LineSeries<QuarterlySalaryTrendData, String>(
            name: '总薪资变化',
            dataSource: chartData.where((d) => d.totalSalaryChange != null).toList(),
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.totalSalaryChange,
            yAxisName: 'change',
            markerSettings: const MarkerSettings(isVisible: true),
            color: Colors.green,
          ),
          LineSeries<QuarterlySalaryTrendData, String>(
            name: '平均薪资变化',
            dataSource: chartData.where((d) => d.averageSalaryChange != null).toList(),
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.averageSalaryChange,
            yAxisName: 'change',
            markerSettings: const MarkerSettings(isVisible: true),
            color: Colors.orange,
          ),
        ],
      ),
    );

    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成年度薪资变化趋势图表
  Future<Uint8List?> generateYearlySalaryTrendChart(
    List<YearlySalaryChange> yearlyChanges,
  ) async {
    if (yearlyChanges.isEmpty) return null;

    // 转换数据格式
    final List<YearlySalaryTrendData> chartData = yearlyChanges
        .map(
          (data) => YearlySalaryTrendData(
            period: '${data.year}年',
            totalSalary: data.totalSalary,
            averageSalary: data.averageSalary,
            highestSalary: data.highestSalary,
            lowestSalary: data.lowestSalary,
            employeeCount: data.employeeCount,
            averageEmployeeCount: data.averageEmployeeCount,
          ),
        )
        .toList();

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '年度薪资变化趋势'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          name: 'salary',
          title: AxisTitle(text: '薪资（元）'),
          minimum: 0,
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'employee',
            title: AxisTitle(text: '员工数'),
            opposedPosition: true,
            minimum: 0,
          ),
        ],
        series: <CartesianSeries>[
          ColumnSeries<YearlySalaryTrendData, String>(
            name: '平均总薪资',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.totalSalary,
            yAxisName: 'salary',
          ),
          ColumnSeries<YearlySalaryTrendData, String>(
            name: '平均薪资',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.averageSalary,
            yAxisName: 'salary',
            color: Colors.blue,
          ),
          LineSeries<YearlySalaryTrendData, String>(
            name: '最高薪资',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.highestSalary,
            yAxisName: 'salary',
            markerSettings: const MarkerSettings(isVisible: true),
            color: Colors.green,
          ),
          LineSeries<YearlySalaryTrendData, String>(
            name: '最低薪资',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.lowestSalary,
            yAxisName: 'salary',
            markerSettings: const MarkerSettings(isVisible: true),
            color: Colors.red,
          ),
          ColumnSeries<YearlySalaryTrendData, String>(
            name: '平均员工数',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.averageEmployeeCount,
            yAxisName: 'employee',
            opacity: 0.7,
            color: Colors.purple,
          ),
        ],
      ),
    );

    return await _captureWidgetAsImage(chartWidget);
  }

  /// 生成年度员工变化趋势图表
  Future<Uint8List?> generateYearlyEmployeeTrendChart(
    List<YearlyEmployeeChange> yearlyChanges,
  ) async {
    if (yearlyChanges.isEmpty) return null;

    // 转换数据格式
    final List<YearlyEmployeeTrendData> chartData = yearlyChanges
        .map(
          (data) => YearlyEmployeeTrendData(
            period: '${data.year}年',
            totalEmployees: data.totalEmployeeCount,
            newEmployees: data.newEmployeeCount,
            leftEmployees: data.leftEmployeeCount,
            continuousEmployees: data.continuousEmployees.length,
            averageEmployeeCount: data.averageEmployeeCount,
            turnoverRate: data.turnoverRate,
          ),
        )
        .toList();

    final chartWidget = _buildChartContainer(
      SfCartesianChart(
        title: ChartTitle(text: '年度员工变化趋势'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          name: 'count',
          title: AxisTitle(text: '员工数'),
          minimum: 0,
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'rate',
            title: AxisTitle(text: '离职率（%）'),
            opposedPosition: true,
            minimum: 0,
          ),
        ],
        series: <CartesianSeries>[
          ColumnSeries<YearlyEmployeeTrendData, String>(
            name: '年末员工数',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.totalEmployees,
            yAxisName: 'count',
          ),
          ColumnSeries<YearlyEmployeeTrendData, String>(
            name: '新增员工',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.newEmployees,
            yAxisName: 'count',
            color: Colors.green,
          ),
          ColumnSeries<YearlyEmployeeTrendData, String>(
            name: '离职员工',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.leftEmployees,
            yAxisName: 'count',
            color: Colors.red,
          ),
          ColumnSeries<YearlyEmployeeTrendData, String>(
            name: '持续在职员工',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.continuousEmployees,
            yAxisName: 'count',
            color: Colors.blue,
          ),
          LineSeries<YearlyEmployeeTrendData, String>(
            name: '离职率',
            dataSource: chartData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.turnoverRate,
            yAxisName: 'rate',
            markerSettings: const MarkerSettings(isVisible: true),
            color: Colors.orange,
          ),
        ],
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
      width: 1000,
      height: 600,
      color: Colors.white,
      child: chart,
    );
  }
}

/// 图表数据模型
class MonthlySalaryTrendData {
  final String period;
  final double totalSalary;
  final double averageSalary;
  final int employeeCount;

  MonthlySalaryTrendData({
    required this.period,
    required this.totalSalary,
    required this.averageSalary,
    required this.employeeCount,
  });
}

class MonthlyEmployeeTrendData {
  final String period;
  final int totalEmployees;
  final int newEmployees;
  final int leftEmployees;
  final double turnoverRate;

  MonthlyEmployeeTrendData({
    required this.period,
    required this.totalEmployees,
    required this.newEmployees,
    required this.leftEmployees,
    required this.turnoverRate,
  });
}

class QuarterlySalaryTrendData {
  final String period;
  final double totalSalary;
  final double averageSalary;
  final int employeeCount;
  final double? totalSalaryChange;
  final double? averageSalaryChange;

  QuarterlySalaryTrendData({
    required this.period,
    required this.totalSalary,
    required this.averageSalary,
    required this.employeeCount,
    this.totalSalaryChange,
    this.averageSalaryChange,
  });
}

class YearlySalaryTrendData {
  final String period;
  final double totalSalary;
  final double averageSalary;
  final double highestSalary;
  final double lowestSalary;
  final int employeeCount;
  final double averageEmployeeCount;

  YearlySalaryTrendData({
    required this.period,
    required this.totalSalary,
    required this.averageSalary,
    required this.highestSalary,
    required this.lowestSalary,
    required this.employeeCount,
    required this.averageEmployeeCount,
  });
}

class YearlyEmployeeTrendData {
  final String period;
  final int totalEmployees;
  final int newEmployees;
  final int leftEmployees;
  final int continuousEmployees;
  final double averageEmployeeCount;
  final double turnoverRate;

  YearlyEmployeeTrendData({
    required this.period,
    required this.totalEmployees,
    required this.newEmployees,
    required this.leftEmployees,
    required this.continuousEmployees,
    required this.averageEmployeeCount,
    required this.turnoverRate,
  });
}

/// 趋势分析图表图像集合
class TrendAnalysisChartImages {
  final Uint8List? monthlySalaryTrendChart;
  final Uint8List? monthlyEmployeeTrendChart;
  final Uint8List? quarterlySalaryTrendChart;
  final Uint8List? yearlySalaryTrendChart;
  final Uint8List? yearlyEmployeeTrendChart;

  TrendAnalysisChartImages({
    this.monthlySalaryTrendChart,
    this.monthlyEmployeeTrendChart,
    this.quarterlySalaryTrendChart,
    this.yearlySalaryTrendChart,
    this.yearlyEmployeeTrendChart,
  });
}