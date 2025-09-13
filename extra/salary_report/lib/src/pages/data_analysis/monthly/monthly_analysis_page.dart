import 'package:flutter/material.dart';

class MonthlyAnalysisPage extends StatefulWidget {
  const MonthlyAnalysisPage({
    super.key,
    required this.year,
    required this.month,
  });

  final int year;
  final int month;

  @override
  State<MonthlyAnalysisPage> createState() => _MonthlyAnalysisPageState();
}

class _MonthlyAnalysisPageState extends State<MonthlyAnalysisPage> {
  // 模拟数据
  final Map<String, dynamic> _analysisData = {
    'totalEmployees': 45,
    'totalSalary': 504000.00,
    'averageSalary': 11200.00,
    'highestSalary': 25000.00,
    'lowestSalary': 6500.00,
    'departmentStats': [
      {'department': '技术部', 'count': 15, 'average': 13500.00},
      {'department': '销售部', 'count': 12, 'average': 12800.00},
      {'department': '人事部', 'count': 8, 'average': 9500.00},
      {'department': '财务部', 'count': 10, 'average': 11800.00},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.year}年${widget.month.toString().padLeft(2, '0')}月 工资分析',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 关键指标卡片
              const Text(
                '关键指标',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard(
                    '总人数',
                    _analysisData['totalEmployees'].toString(),
                    Icons.people,
                  ),
                  _buildStatCard(
                    '工资总额',
                    '¥${_analysisData['totalSalary']}',
                    Icons.account_balance_wallet,
                  ),
                  _buildStatCard(
                    '平均工资',
                    '¥${_analysisData['averageSalary']}',
                    Icons.trending_up,
                  ),
                  _buildStatCard(
                    '最高工资',
                    '¥${_analysisData['highestSalary']}',
                    Icons.arrow_upward,
                  ),
                  _buildStatCard(
                    '最低工资',
                    '¥${_analysisData['lowestSalary']}',
                    Icons.arrow_downward,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 部门统计
              const Text(
                '各部门统计',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '部门',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '人数',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '平均工资',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      ..._analysisData['departmentStats'].map<Widget>((dept) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Text(dept['department']),
                              ),
                              Expanded(child: Text(dept['count'].toString())),
                              Expanded(child: Text('¥${dept['average']}')),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 图表展示区域（占位符）
              const Text(
                '图表分析',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const Text('工资分布图表'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
