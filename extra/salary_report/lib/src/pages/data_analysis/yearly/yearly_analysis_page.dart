import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/pages/visualization/report/salary_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:toastification/toastification.dart';

class YearlyAnalysisPage extends StatefulWidget {
  const YearlyAnalysisPage({
    super.key,
    required this.year,
    this.departmentStats = const [],
    this.attendanceStats = const [],
    this.leaveRatioStats,
    this.isMultiYear = false,
    this.endYear,
  });

  final int year;
  final List<DepartmentSalaryStats> departmentStats;
  final List<AttendanceStats> attendanceStats;
  final LeaveRatioStats? leaveRatioStats;
  final bool isMultiYear;
  final int? endYear;

  @override
  State<YearlyAnalysisPage> createState() => _YearlyAnalysisPageState();
}

class _YearlyAnalysisPageState extends State<YearlyAnalysisPage> {
  late Map<String, dynamic> _analysisData;
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;

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

    // 模拟月度趋势数据（实际应用中应该从数据中计算）
    final monthlyTrendData = [
      {'month': '1月', 'salary': totalSalary * 0.08},
      {'month': '2月', 'salary': totalSalary * 0.07},
      {'month': '3月', 'salary': totalSalary * 0.09},
      {'month': '4月', 'salary': totalSalary * 0.08},
      {'month': '5月', 'salary': totalSalary * 0.09},
      {'month': '6月', 'salary': totalSalary * 0.08},
      {'month': '7月', 'salary': totalSalary * 0.08},
      {'month': '8月', 'salary': totalSalary * 0.08},
      {'month': '9月', 'salary': totalSalary * 0.09},
      {'month': '10月', 'salary': totalSalary * 0.09},
      {'month': '11月', 'salary': totalSalary * 0.09},
      {'month': '12月', 'salary': totalSalary * 0.10},
    ];

    _analysisData = {
      'totalEmployees': totalEmployees,
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
      'monthlyTrend': monthlyTrendData,
    };
  }

  /// 生成工资报告
  Future<void> _generateSalaryReport() async {
    try {
      setState(() {
        _isGeneratingReport = true;
      });

      // 确定开始和结束时间
      final startTime = DateTime(widget.year, 1);
      final endTime = widget.isMultiYear && widget.endYear != null
          ? DateTime(widget.endYear!, 12)
          : DateTime(widget.year, 12);

      final generator = SalaryReportGenerator();
      final reportPath = await generator.generateReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: widget.departmentStats,
        analysisData: _analysisData,
        endTime: endTime,
        year: widget.year,
        month: 0, // 年度报告没有月份
        isMultiMonth: widget.isMultiYear,
        startTime: startTime,
        reportType: ReportType.annual, // 明确指定报告类型为年度报告
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
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReport = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isMultiYear
        ? '${widget.year}年-${widget.endYear}年 工资分析'
        : '${widget.year}年 工资分析';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isGeneratingReport ? null : _generateSalaryReport,
            tooltip: '生成报告',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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

                  // 月度趋势图
                  const Text(
                    '月度趋势',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16.0),
                      child: MonthlySalaryTrendChart(
                        monthlyData: _analysisData['monthlyTrend'],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 部门工资对比
                  const Text(
                    '部门工资对比',
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
                          ...widget.departmentStats.map<Widget>((stat) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: Text(stat.department),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '¥${stat.totalNetSalary.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '¥${stat.averageNetSalary.toStringAsFixed(2)}',
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '数值',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                  ],
                ],
              ),
            ),
          ),
          if (_isGeneratingReport)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: LoadingIndicator(
                        indicatorType: Indicator.pacman,
                        colors: [Colors.lightBlue],
                        strokeWidth: 2,
                        backgroundColor: Colors.white,
                        pathBackgroundColor: Colors.black,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('正在生成报告...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: SizedBox(
        width: 150,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateMultiYearData() {
    // 生成多一年的数据用于演示
    final currentYearData =
        _analysisData['monthlyTrend'] as List<Map<String, dynamic>>;
    final nextYearData = currentYearData
        .map(
          (item) => {
            'month': '${item['month']}+1Y',
            'salary': (item['salary'] as double) * 1.1,
          },
        )
        .toList();

    return [...currentYearData, ...nextYearData];
  }
}
