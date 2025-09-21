import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';

/// 部门工资占比饼图
class DepartmentSalaryChart extends StatelessWidget {
  final List<DepartmentSalaryStats> departmentStats;

  const DepartmentSalaryChart({super.key, required this.departmentStats});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: ChartTitle(text: '各部门工资占比'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries<DepartmentSalaryStats, String>>[
        PieSeries<DepartmentSalaryStats, String>(
          dataSource: departmentStats,
          xValueMapper: (DepartmentSalaryStats data, _) => data.department,
          yValueMapper: (DepartmentSalaryStats data, _) => data.totalNetSalary,
          dataLabelMapper: (DepartmentSalaryStats data, _) =>
              '${data.department}\n${NumberFormat.simpleCurrency(locale: 'zh_CN').format(data.totalNetSalary)}',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
          ),
          enableTooltip: true,
        ),
      ],
    );
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
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(locale: 'zh_CN'),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: monthlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['month'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              (data['averageSalary'] as num).toInt(),
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
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(locale: 'zh_CN'),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: monthlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['month'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              (data['totalSalary'] as double).toInt(),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }
}

/// 月度工资趋势图表
class MonthlySalaryTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const MonthlySalaryTrendChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '月度工资趋势'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(locale: 'zh_CN'),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: monthlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['month'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              (data['totalSalary'] as num?)?.toInt() ?? 0,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }
}

/// 多月部门工资趋势图表
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
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(locale: 'zh_CN'),
      ),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: _getDepartmentSeries(),
    );
  }

  List<LineSeries<Map<String, dynamic>, String>> _getDepartmentSeries() {
    // 统一收集所有部门
    final departments = <String>{};
    for (var data in departmentMonthlyData) {
      if (data['departments'] is Map<String, dynamic>) {
        (data['departments'] as Map<String, dynamic>).keys.forEach(
          departments.add,
        );
      }
    }

    final series = <LineSeries<Map<String, dynamic>, String>>[];
    // 添加更多颜色选项以适应部门较多的公司
    final colors = [
      Colors.lightBlue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.yellow,
      Colors.cyan,
      Colors.lime,
      Colors.amber,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.indigo,
      Colors.deepPurple,
      Colors.lightGreen,
      Colors.blue,
      Colors.redAccent,
    ];

    int colorIndex = 0;
    for (var department in departments) {
      final departmentData = <Map<String, dynamic>>[];

      for (var data in departmentMonthlyData) {
        final month = data['month'] as String;
        final deptData = data['departments'] as Map<String, dynamic>;

        // 转为int以提高性能
        final salary = ((deptData[department] as num?)?.toDouble() ?? 0.0)
            .toInt();

        departmentData.add({
          'month': month,
          'salary': salary,
          'department': department,
        });
      }

      series.add(
        LineSeries<Map<String, dynamic>, String>(
          name: department,
          dataSource: departmentData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['month'] as String,
          yValueMapper: (Map<String, dynamic> data, _) => data['salary'] as int,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          color: colors[colorIndex % colors.length], // 循环使用颜色
        ),
      );

      colorIndex++;
    }

    return series;
  }
}

/// 每季度人数变化图表
class QuarterlyEmployeeCountChart extends StatelessWidget {
  final List<Map<String, dynamic>> quarterlyData;

  const QuarterlyEmployeeCountChart({super.key, required this.quarterlyData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '每季度人数变化'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: quarterlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['quarter'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              data['employeeCount'] as int,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }
}

/// 每季度平均薪资变化图表
class QuarterlyAverageSalaryChart extends StatelessWidget {
  final List<Map<String, dynamic>> quarterlyData;

  const QuarterlyAverageSalaryChart({super.key, required this.quarterlyData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '每季度平均薪资变化'),
      primaryXAxis: CategoryAxis(
        // 用 quarterNum 排序更稳妥
        arrangeByIndex: true,
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(locale: 'zh_CN'),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          animationDuration: 0,
          animationDelay: 0,
          dataSource: quarterlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['quarter'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              (data['averageSalary'] as num).toInt(), // 转为int
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }
}

/// 每季度总工资变化图表
class QuarterlyTotalSalaryChart extends StatelessWidget {
  final List<Map<String, dynamic>> quarterlyData;

  const QuarterlyTotalSalaryChart({super.key, required this.quarterlyData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '每季度总工资变化'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(locale: 'zh_CN'),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: quarterlyData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['quarter'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              (data['totalSalary'] as double).toInt(), // 转为int
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }
}

/// 多季度部门工资趋势图表
class MultiQuarterDepartmentSalaryChart extends StatelessWidget {
  final List<Map<String, dynamic>> departmentQuarterlyData;

  const MultiQuarterDepartmentSalaryChart({
    super.key,
    required this.departmentQuarterlyData,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '各部门季度工资趋势'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(locale: 'zh_CN'),
      ),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: _getDepartmentSeries(),
    );
  }

  List<LineSeries<Map<String, dynamic>, String>> _getDepartmentSeries() {
    // 统一收集所有部门，去掉空格
    final departments = <String>{};
    for (var data in departmentQuarterlyData) {
      if (data['departments'] is Map<String, dynamic>) {
        (data['departments'] as Map<String, dynamic>).keys
            .map((e) => e.toString().trim()) // 去掉前后空格
            .forEach(departments.add);
      }
    }

    final series = <LineSeries<Map<String, dynamic>, String>>[];
    // 添加更多颜色选项以适应部门较多的公司
    final colors = [
      Colors.lightBlue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.yellow,
      Colors.cyan,
      Colors.lime,
      Colors.amber,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.indigo,
      Colors.deepPurple,
      Colors.lightGreen,
      Colors.blue,
      Colors.redAccent,
    ];

    int colorIndex = 0;
    for (var department in departments) {
      final departmentData = <Map<String, dynamic>>[];

      for (var data in departmentQuarterlyData) {
        final quarter = data['quarter'] as String;
        final deptData = data['departments'] as Map<String, dynamic>;

        // 尝试用 trim 后的 key 找数据
        final matchedKey = deptData.keys.firstWhere(
          (k) => k.toString().trim() == department,
          orElse: () => '',
        );
        // 转为int以提高性能
        final salary = ((deptData[matchedKey] as num?)?.toDouble() ?? 0.0)
            .toInt();

        departmentData.add({
          'quarter': quarter,
          'salary': salary,
          'department': department,
        });
      }

      series.add(
        LineSeries<Map<String, dynamic>, String>(
          name: department,
          dataSource: departmentData,
          xValueMapper: (Map<String, dynamic> data, _) =>
              data['quarter'] as String,
          yValueMapper: (Map<String, dynamic> data, _) =>
              data['salary'] as int, // 使用int类型
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          color: colors[colorIndex % colors.length], // 循环使用颜色
        ),
      );

      colorIndex++;
    }

    return series;
  }
}
