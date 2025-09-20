import 'package:flutter/material.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:intl/intl.dart';

class DepartmentSalaryChart extends StatelessWidget {
  final List<DepartmentSalaryStats> departmentStats;

  const DepartmentSalaryChart({super.key, required this.departmentStats});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: ChartTitle(text: '各部门工资占比'),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      series: <CircularSeries<DepartmentSalaryStats, String>>[
        PieSeries<DepartmentSalaryStats, String>(
          dataSource: departmentStats,
          xValueMapper: (DepartmentSalaryStats data, _) => data.department,
          yValueMapper: (DepartmentSalaryStats data, _) => data.totalNetSalary,
          dataLabelMapper: (DepartmentSalaryStats data, _) =>
              '${data.department}\n¥${data.totalNetSalary.toStringAsFixed(0)}',
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }
}

class MonthlySalaryTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const MonthlySalaryTrendChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '月度工资趋势'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(numberFormat: NumberFormat.simpleCurrency()),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: monthlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['month'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              data['salary'] as double,
          name: '工资总额',
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }
}

class MultiMonthDepartmentSalaryChart extends StatelessWidget {
  final List<Map<String, dynamic>> departmentMonthlyData;

  const MultiMonthDepartmentSalaryChart({
    super.key,
    required this.departmentMonthlyData,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '各部门月度工资趋势'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(numberFormat: NumberFormat.simpleCurrency()),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: _getDepartmentSeries(),
    );
  }

  List<LineSeries<Map<String, dynamic>, String>> _getDepartmentSeries() {
    // 获取所有部门名称
    final departments = <String>{};
    for (var data in departmentMonthlyData) {
      if (data['departments'] is Map<String, dynamic>) {
        departments.addAll((data['departments'] as Map<String, dynamic>).keys);
      }
    }

    // 为每个部门创建一个系列
    final series = <LineSeries<Map<String, dynamic>, String>>[];
    final colors = [
      Colors.lightBlue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    int colorIndex = 0;
    for (var department in departments) {
      final departmentData = <Map<String, dynamic>>[];
      for (var data in departmentMonthlyData) {
        final month = data['month'] as String;
        final deptData = data['departments'] as Map<String, dynamic>;
        departmentData.add({
          'month': month,
          'salary': deptData[department] as double? ?? 0,
          'department': department,
        });
      }

      series.add(
        LineSeries<Map<String, dynamic>, String>(
          name: department,
          dataSource: departmentData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['month'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              data['salary'] as double,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          color: colors[colorIndex % colors.length],
        ),
      );

      colorIndex++;
    }

    return series;
  }
}

/// 每月人数变化图表
class MonthlyEmployeeCountChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const MonthlyEmployeeCountChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '每月人数变化'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: monthlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['month'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              data['employeeCount'] as int,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }
}

/// 每月平均薪资变化图表
class MonthlyAverageSalaryChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const MonthlyAverageSalaryChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '每月平均薪资变化'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(numberFormat: NumberFormat.simpleCurrency()),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: monthlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['month'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              data['averageSalary'] as double,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }
}

/// 每月总工资变化图表
class MonthlyTotalSalaryChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const MonthlyTotalSalaryChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '每月总工资变化'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(numberFormat: NumberFormat.simpleCurrency()),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: monthlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['month'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              data['totalSalary'] as double,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }
}
