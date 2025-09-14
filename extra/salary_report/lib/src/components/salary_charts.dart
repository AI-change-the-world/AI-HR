import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:intl/intl.dart';

class DepartmentSalaryChart extends StatelessWidget {
  final List<DepartmentSalaryStats> departmentStats;

  const DepartmentSalaryChart({super.key, required this.departmentStats});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: ChartTitle(text: '各部门工资占比'),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      series: <CircularSeries>[
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
      series: <CartesianSeries>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: monthlyData,
          xValueMapper: (Map<String, dynamic> data, _) => data['month'],
          yValueMapper: (Map<String, dynamic> data, _) => data['salary'],
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

  List<CartesianSeries> _getDepartmentSeries() {
    // 获取所有部门名称
    final departments = <String>{};
    for (var data in departmentMonthlyData) {
      if (data['departments'] is Map<String, double>) {
        departments.addAll((data['departments'] as Map<String, double>).keys);
      }
    }

    // 为每个部门创建一个系列
    final series = <CartesianSeries>[];
    for (var department in departments) {
      final departmentData = <Map<String, dynamic>>[];
      for (var data in departmentMonthlyData) {
        final month = data['month'];
        final deptData = data['departments'] as Map<String, double>;
        departmentData.add({
          'month': month,
          'salary': deptData[department] ?? 0,
        });
      }

      series.add(
        LineSeries<Map<String, dynamic>, String>(
          name: department,
          dataSource: departmentData,
          xValueMapper: (Map<String, dynamic> data, _) => data['month'],
          yValueMapper: (Map<String, dynamic> data, _) => data['salary'],
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      );
    }

    return series;
  }
}
