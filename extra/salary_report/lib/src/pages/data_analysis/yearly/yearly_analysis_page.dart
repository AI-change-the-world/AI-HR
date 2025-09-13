import 'package:flutter/material.dart';

class YearlyAnalysisPage extends StatefulWidget {
  const YearlyAnalysisPage({super.key, required this.year});

  final int year;

  @override
  State<YearlyAnalysisPage> createState() => _YearlyAnalysisPageState();
}

class _YearlyAnalysisPageState extends State<YearlyAnalysisPage> {
  // 模拟数据
  final Map<String, dynamic> _analysisData = {
    'totalEmployees': 45,
    'totalSalary': 6048000.00,
    'averageSalary': 11200.00,
    'highestSalary': 25000.00,
    'lowestSalary': 6500.00,
    'monthlyTrend': [
      {'month': '1月', 'salary': 504000.00},
      {'month': '2月', 'salary': 480000.00},
      {'month': '3月', 'salary': 510000.00},
      {'month': '4月', 'salary': 505000.00},
      {'month': '5月', 'salary': 520000.00},
      {'month': '6月', 'salary': 515000.00},
      {'month': '7月', 'salary': 508000.00},
      {'month': '8月', 'salary': 504000.00},
      {'month': '9月', 'salary': 512000.00},
      {'month': '10月', 'salary': 518000.00},
      {'month': '11月', 'salary': 522000.00},
      {'month': '12月', 'salary': 530000.00},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.year}年 工资分析')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 关键指标卡片
              const Text(
                '年度关键指标',
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

              // 月度趋势图表
              const Text(
                '月度工资趋势',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Container(
                  height: 250,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('工资总额月度趋势'),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text('月度趋势折线图'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 季度对比
              const Text(
                '季度对比',
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
                              '季度',
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: Text('第一季度')),
                            Expanded(child: Text('¥1,494,000')),
                            Expanded(child: Text('¥11,067')),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: Text('第二季度')),
                            Expanded(child: Text('¥1,538,000')),
                            Expanded(child: Text('¥11,467')),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: Text('第三季度')),
                            Expanded(child: Text('¥1,524,000')),
                            Expanded(child: Text('¥11,289')),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: Text('第四季度')),
                            Expanded(child: Text('¥1,492,000')),
                            Expanded(child: Text('¥11,052')),
                          ],
                        ),
                      ),
                    ],
                  ),
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
