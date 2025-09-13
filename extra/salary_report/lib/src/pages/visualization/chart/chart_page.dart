import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String _selectedChartType = 'bar';
  String _selectedDimension = 'department';

  // 模拟数据
  final List<_ChartData> _departmentData = [
    _ChartData('技术部', 13500, 15),
    _ChartData('销售部', 12800, 12),
    _ChartData('人事部', 9500, 8),
    _ChartData('财务部', 11800, 10),
  ];

  final List<_ChartData> _monthlyData = [
    _ChartData('1月', 11000, 45),
    _ChartData('2月', 10800, 44),
    _ChartData('3月', 11200, 45),
    _ChartData('4月', 11100, 45),
    _ChartData('5月', 11300, 46),
    _ChartData('6月', 11250, 45),
    _ChartData('7月', 11200, 45),
    _ChartData('8月', 11200, 45),
    _ChartData('9月', 11280, 45),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 移除AppBar，因为主布局已经提供了
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '数据可视化',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '图表展示与数据分析',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // 图表类型选择
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '图表类型',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        children: [
                          ChoiceChip(
                            label: const Text('柱状图'),
                            selected: _selectedChartType == 'bar',
                            selectedColor: Colors.lightBlue.shade200,
                            onSelected: (selected) {
                              setState(() {
                                _selectedChartType = 'bar';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('折线图'),
                            selected: _selectedChartType == 'line',
                            selectedColor: Colors.lightBlue.shade200,
                            onSelected: (selected) {
                              setState(() {
                                _selectedChartType = 'line';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('饼图'),
                            selected: _selectedChartType == 'pie',
                            selectedColor: Colors.lightBlue.shade200,
                            onSelected: (selected) {
                              setState(() {
                                _selectedChartType = 'pie';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 维度选择
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '分析维度',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        children: [
                          ChoiceChip(
                            label: const Text('部门对比'),
                            selected: _selectedDimension == 'department',
                            selectedColor: Colors.lightBlue.shade200,
                            onSelected: (selected) {
                              setState(() {
                                _selectedDimension = 'department';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('月度趋势'),
                            selected: _selectedDimension == 'monthly',
                            selectedColor: Colors.lightBlue.shade200,
                            onSelected: (selected) {
                              setState(() {
                                _selectedDimension = 'monthly';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 图表展示区域
              const Text(
                '数据图表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(16.0),
                  child: _buildChart(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_selectedDimension == 'department') {
      if (_selectedChartType == 'bar') {
        return SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(
            text: '各部门平均工资对比',
            textStyle: const TextStyle(color: Colors.lightBlue, fontSize: 16),
          ),
          series: [
            ColumnSeries<_ChartData, String>(
              dataSource: _departmentData,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.value,
              name: '平均工资',
              color: Colors.lightBlue,
            ),
          ],
        );
      } else if (_selectedChartType == 'line') {
        return SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(
            text: '各部门平均工资对比',
            textStyle: const TextStyle(color: Colors.lightBlue, fontSize: 16),
          ),
          series: [
            LineSeries<_ChartData, String>(
              dataSource: _departmentData,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.value,
              name: '平均工资',
              color: Colors.lightBlue,
            ),
          ],
        );
      } else {
        return SfCircularChart(
          title: ChartTitle(
            text: '各部门人数分布',
            textStyle: const TextStyle(color: Colors.lightBlue, fontSize: 16),
          ),
          series: <CircularSeries<_ChartData, String>>[
            PieSeries<_ChartData, String>(
              dataSource: _departmentData,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.count,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              pointColorMapper: (datum, index) => index == 0
                  ? Colors.lightBlue
                  : index == 1
                  ? Colors.lightBlue.shade300
                  : index == 2
                  ? Colors.lightBlue.shade200
                  : Colors.lightBlue.shade100,
            ),
          ],
        );
      }
    } else {
      if (_selectedChartType == 'bar') {
        return SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(
            text: '月度平均工资趋势',
            textStyle: const TextStyle(color: Colors.lightBlue, fontSize: 16),
          ),
          series: [
            ColumnSeries<_ChartData, String>(
              dataSource: _monthlyData,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.value,
              name: '平均工资',
              color: Colors.lightBlue,
            ),
          ],
        );
      } else if (_selectedChartType == 'line') {
        return SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(
            text: '月度平均工资趋势',
            textStyle: const TextStyle(color: Colors.lightBlue, fontSize: 16),
          ),
          series: [
            LineSeries<_ChartData, String>(
              dataSource: _monthlyData,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.value,
              name: '平均工资',
              color: Colors.lightBlue,
            ),
          ],
        );
      } else {
        return SfCircularChart(
          title: ChartTitle(
            text: '月度工资总额分布',
            textStyle: const TextStyle(color: Colors.lightBlue, fontSize: 16),
          ),
          series: <CircularSeries<_ChartData, String>>[
            PieSeries<_ChartData, String>(
              dataSource: _monthlyData,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.value,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              pointColorMapper: (datum, index) => index % 4 == 0
                  ? Colors.lightBlue
                  : index % 4 == 1
                  ? Colors.lightBlue.shade300
                  : index % 4 == 2
                  ? Colors.lightBlue.shade200
                  : Colors.lightBlue.shade100,
            ),
          ],
        );
      }
    }
  }
}

class _ChartData {
  final String category;
  final double value;
  final int count;

  _ChartData(this.category, this.value, this.count);
}
