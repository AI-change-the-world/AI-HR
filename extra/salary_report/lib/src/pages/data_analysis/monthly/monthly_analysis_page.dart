import 'package:flutter/material.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/pages/visualization/report/salary_report_generator.dart';
import 'package:flutter/rendering.dart';
import 'package:toastification/toastification.dart';

class MonthlyAnalysisPage extends StatefulWidget {
  const MonthlyAnalysisPage({
    super.key,
    required this.year,
    required this.month,
    this.departmentStats = const [],
    this.attendanceStats = const [],
    this.leaveRatioStats,
    this.isMultiMonth = false,
  });

  final int year;
  final int month;
  final List<DepartmentSalaryStats> departmentStats;
  final List<AttendanceStats> attendanceStats;
  final LeaveRatioStats? leaveRatioStats;
  final bool isMultiMonth;

  @override
  State<MonthlyAnalysisPage> createState() => _MonthlyAnalysisPageState();
}

class _MonthlyAnalysisPageState extends State<MonthlyAnalysisPage> {
  late Map<String, dynamic> _analysisData;
  final GlobalKey _chartContainerKey = GlobalKey();

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

    // 构建部门统计数据
    final departmentStatsData = widget.departmentStats.map((stat) {
      return {
        'department': stat.department,
        'count': stat.employeeCount,
        'average': stat.averageNetSalary,
      };
    }).toList();

    // 为单月情况准备月度数据
    final monthlyData = [
      {'month': '${widget.month}月', 'salary': totalSalary},
    ];

    _analysisData = {
      'totalEmployees': totalEmployees,
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
      'departmentStats': departmentStatsData,
      'monthlyData': monthlyData,
    };
  }

  /// 生成工资报告
  Future<void> _generateSalaryReport() async {
    try {
      final reportPath = await SalaryReportGenerator.generateSalaryReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: widget.departmentStats,
        attendanceStats: widget.attendanceStats,
        leaveRatioStats: widget.leaveRatioStats,
        year: widget.year,
        month: widget.month,
        isMultiMonth: widget.isMultiMonth,
        analysisData: _analysisData,
      );

      if (mounted) {
        toastification.show(
          context: context,
          title: const Text('报告生成成功'),
          description: Text('报告已保存到: $reportPath'),
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: const Text('报告生成失败'),
          description: Text('错误信息: $e'),
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isMultiMonth
        ? '${widget.year}年${widget.month.toString().padLeft(2, '0')}月起 工资分析'
        : '${widget.year}年${widget.month.toString().padLeft(2, '0')}月 工资分析';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generateSalaryReport,
            tooltip: '生成报告',
          ),
        ],
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
                              Expanded(
                                child: Text(
                                  '¥${dept['average'].toStringAsFixed(2)}',
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
              RepaintBoundary(
                key: _chartContainerKey,
                child: Card(
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.all(16.0),
                    child: widget.isMultiMonth
                        ? Column(
                            children: [
                              Expanded(
                                child: MonthlySalaryTrendChart(
                                  monthlyData: _generateMultiMonthData(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: MultiMonthDepartmentSalaryChart(
                                  departmentMonthlyData:
                                      _generateDepartmentMonthlyData(),
                                ),
                              ),
                            ],
                          )
                        : DepartmentSalaryChart(
                            departmentStats: widget.departmentStats,
                          ),
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

  List<Map<String, dynamic>> _generateMultiMonthData() {
    // 这里应该从实际数据中生成多月数据
    // 暂时使用模拟数据
    return [
      {'month': '1月', 'salary': 100000},
      {'month': '2月', 'salary': 120000},
      {'month': '3月', 'salary': 110000},
    ];
  }

  List<Map<String, dynamic>> _generateDepartmentMonthlyData() {
    // 这里应该从实际数据中生成各部门多月数据
    // 暂时使用模拟数据
    return [
      {
        'month': '1月',
        'departments': {'技术部': 50000, '销售部': 30000, '人事部': 20000},
      },
      {
        'month': '2月',
        'departments': {'技术部': 60000, '销售部': 35000, '人事部': 25000},
      },
      {
        'month': '3月',
        'departments': {'技术部': 55000, '销售部': 32000, '人事部': 23000},
      },
    ];
  }
}
