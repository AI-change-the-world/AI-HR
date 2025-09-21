import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: SalaryChartExample())),
    );
  }
}

class SalaryChartExample extends StatelessWidget {
  const SalaryChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final salaryRanges = {'5000-6000': 26}; // 你的数据
    final chartData = salaryRanges.entries
        .map((e) => {'range': e.key, 'count': e.value})
        .toList();

    print('chartData: $chartData');

    return SizedBox(
      width: 800,
      height: 600,
      child: SfCartesianChart(
        title: ChartTitle(text: '工资区间分布'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        legend: Legend(isVisible: true),
        series: [
          ColumnSeries<Map<String, dynamic>, String>(
            animationDuration: 0,
            animationDelay: 0,
            dataSource: chartData,
            xValueMapper: (d, _) => d['range'] as String,
            yValueMapper: (d, _) => d['count'] as num,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            // 强制颜色，便于确认是否渲染
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
