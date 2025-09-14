import 'package:flutter/material.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/components/salary_charts.dart';

class QuarterlyAnalysisPage extends StatefulWidget {
  const QuarterlyAnalysisPage({
    super.key,
    required this.year,
    required this.quarter,
    this.departmentStats = const [],
    this.attendanceStats = const [],
    this.leaveRatioStats,
    this.isMultiQuarter = false,
    this.endYear,
    this.endQuarter,
  });

  final int year;
  final int quarter;
  final List<DepartmentSalaryStats> departmentStats;
  final List<AttendanceStats> attendanceStats;
  final LeaveRatioStats? leaveRatioStats;
  final bool isMultiQuarter;
  final int? endYear;
  final int? endQuarter;

  @override
  State<QuarterlyAnalysisPage> createState() => _QuarterlyAnalysisPageState();
}

class _QuarterlyAnalysisPageState extends State<QuarterlyAnalysisPage> {
  late Map<String, dynamic> _analysisData;

  @override
  void initState() {
    super.initState();
    _initAnalysisData();
  }

  void _initAnalysisData() {
    // 计算总工资和平均工资
    double totalSalary = 0;
    int totalEmployees = 0;
    double highestSalary = 0;
    double lowestSalary = double.infinity;

    for (var stat in widget.departmentStats) {
      totalSalary += stat.totalNetSalary;
      totalEmployees += stat.employeeCount;

      if (stat.averageNetSalary > highestSalary) {
        highestSalary = stat.averageNetSalary;
      }

      if (stat.averageNetSalary < lowestSalary) {
        lowestSalary = stat.averageNetSalary;
      }
    }

    // 如果没有数据，设置默认值
    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }

    double averageSalary = totalEmployees > 0
        ? totalSalary / totalEmployees
        : 0;

    // 构建月度分解数据（实际应用中应该从数据中计算）
    final monthlyBreakdownData = <Map<String, dynamic>>[];
    final startMonth = (widget.quarter - 1) * 3 + 1;
    for (int i = 0; i < 3; i++) {
      final month = startMonth + i;
      final monthStr = '$month月';
      // 这里应该从实际数据中计算，但暂时使用估算值
      monthlyBreakdownData.add({
        'month': monthStr,
        'salary': totalSalary / 3,
        'employees': totalEmployees,
      });
    }

    // 构建部门对比数据
    final departmentComparisonData = widget.departmentStats.map((stat) {
      return {
        'department': stat.department,
        'salary': stat.totalNetSalary,
        'average': stat.averageNetSalary,
      };
    }).toList();

    _analysisData = {
      'totalEmployees': totalEmployees,
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
      'monthlyBreakdown': monthlyBreakdownData,
      'departmentComparison': departmentComparisonData,
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isMultiQuarter
        ? '${widget.year}年第${widget.quarter}季度-${widget.endYear}年第${widget.endQuarter}季度 工资分析'
        : '${widget.year}年第${widget.quarter}季度 工资分析';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                    '¥${_analysisData['totalSalary'].toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                  ),
                  _buildStatCard(
                    '平均工资',
                    '¥${_analysisData['averageSalary'].toStringAsFixed(2)}',
                    Icons.trending_up,
                  ),
                  _buildStatCard(
                    '最高工资',
                    '¥${_analysisData['highestSalary'].toStringAsFixed(2)}',
                    Icons.arrow_upward,
                  ),
                  _buildStatCard(
                    '最低工资',
                    '¥${_analysisData['lowestSalary'].toStringAsFixed(2)}',
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
                              Expanded(
                                child: Text(
                                  '¥${(monthData['salary'] as double).toStringAsFixed(2)}',
                                ),
                              ),
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
                              Expanded(
                                child: Text(
                                  '¥${(dept['salary'] as double).toStringAsFixed(2)}',
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '¥${(dept['average'] as double).toStringAsFixed(2)}',
                                ),
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

              // 考勤统计
              const Text(
                '考勤统计',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AttendancePagination(
                        attendanceStats: widget.attendanceStats,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 请假比例统计
              if (widget.leaveRatioStats != null) ...[
                const Text(
                  '请假比例统计',
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
                                '统计项',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '数值',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Expanded(child: Text('总员工数')),
                              Expanded(
                                child: Text(
                                  widget.leaveRatioStats!.totalEmployees
                                      .toString(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Expanded(child: Text('平均病假天数/人')),
                              Expanded(
                                child: Text(
                                  widget.leaveRatioStats!.sickLeaveRatio
                                      .toStringAsFixed(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Expanded(child: Text('平均事假天数/人')),
                              Expanded(
                                child: Text(
                                  widget.leaveRatioStats!.leaveRatio
                                      .toStringAsFixed(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 图表展示区域
              const Text(
                '图表分析',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(16.0),
                  child: widget.isMultiQuarter
                      ? Column(
                          children: [
                            Expanded(
                              child: MonthlySalaryTrendChart(
                                monthlyData: _generateMultiQuarterData(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: MultiMonthDepartmentSalaryChart(
                                departmentMonthlyData:
                                    _generateDepartmentQuarterlyData(),
                              ),
                            ),
                          ],
                        )
                      : DepartmentSalaryChart(
                          departmentStats: widget.departmentStats,
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

  List<Map<String, dynamic>> _generateMultiQuarterData() {
    // 这里应该从实际数据中生成多季度数据
    // 暂时使用模拟数据
    return [
      {'month': 'Q1', 'salary': 300000},
      {'month': 'Q2', 'salary': 350000},
      {'month': 'Q3', 'salary': 320000},
      {'month': 'Q4', 'salary': 380000},
    ];
  }

  List<Map<String, dynamic>> _generateDepartmentQuarterlyData() {
    // 这里应该从实际数据中生成各部门季度数据
    // 暂时使用模拟数据
    return [
      {
        'month': 'Q1',
        'departments': {'技术部': 150000, '销售部': 100000, '人事部': 50000},
      },
      {
        'month': 'Q2',
        'departments': {'技术部': 170000, '销售部': 120000, '人事部': 60000},
      },
      {
        'month': 'Q3',
        'departments': {'技术部': 160000, '销售部': 110000, '人事部': 50000},
      },
      {
        'month': 'Q4',
        'departments': {'技术部': 190000, '销售部': 130000, '人事部': 60000},
      },
    ];
  }
}
