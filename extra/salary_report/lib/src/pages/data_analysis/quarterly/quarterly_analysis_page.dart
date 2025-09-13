import 'package:flutter/material.dart';

class QuarterlyAnalysisPage extends StatefulWidget {
  const QuarterlyAnalysisPage({
    super.key,
    required this.year,
    required this.quarter,
  });

  final int year;
  final int quarter;

  @override
  State<QuarterlyAnalysisPage> createState() => _QuarterlyAnalysisPageState();
}

class _QuarterlyAnalysisPageState extends State<QuarterlyAnalysisPage> {
  // 模拟数据
  final Map<String, dynamic> _analysisData = {
    'totalEmployees': 45,
    'totalSalary': 1524000.00,
    'averageSalary': 11289.00,
    'highestSalary': 25000.00,
    'lowestSalary': 6500.00,
    'monthlyBreakdown': [
      {'month': '7月', 'salary': 508000.00, 'employees': 45},
      {'month': '8月', 'salary': 504000.00, 'employees': 45},
      {'month': '9月', 'salary': 512000.00, 'employees': 45},
    ],
    'departmentComparison': [
      {'department': '技术部', 'salary': 607500.00, 'average': 13500.00},
      {'department': '销售部', 'salary': 576000.00, 'average': 12800.00},
      {'department': '人事部', 'salary': 171000.00, 'average': 9500.00},
      {'department': '财务部', 'salary': 210600.00, 'average': 11800.00},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.year}年第${widget.quarter}季度 工资分析')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 关键指标卡片
              const Text(
                '季度关键指标',
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

              // 月度分解
              const Text(
                '月度分解',
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
                            child: Text(
                              '月份',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '工资总额',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '人数',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      ..._analysisData['monthlyBreakdown'].map<Widget>((
                        monthData,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(child: Text(monthData['month'])),
                              Expanded(child: Text('¥${monthData['salary']}')),
                              Expanded(
                                child: Text(monthData['employees'].toString()),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 部门对比
              const Text(
                '部门对比',
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
                              '工资总额',
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
                      ..._analysisData['departmentComparison'].map<Widget>((
                        dept,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(dept['department']),
                              ),
                              Expanded(child: Text('¥${dept['salary']}')),
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
                  child: const Text('部门工资对比图表'),
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
