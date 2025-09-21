import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/pages/visualization/report/salary_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/isar/salary_list.dart';

class MonthlyAnalysisPage extends StatefulWidget {
  const MonthlyAnalysisPage({
    super.key,
    required this.year,
    required this.month,
    this.isMultiMonth = false,
  });

  final int year;
  final int month;
  final bool isMultiMonth;

  @override
  State<MonthlyAnalysisPage> createState() => _MonthlyAnalysisPageState();
}

class _MonthlyAnalysisPageState extends State<MonthlyAnalysisPage> {
  late Map<String, dynamic> _analysisData;
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  bool _isLoading = true;
  late DataAnalysisService _salaryDataService;
  List<DepartmentSalaryStats> _departmentStats = [];
  List<AttendanceStats> _attendanceStats = [];
  LeaveRatioStats? _leaveRatioStats;

  @override
  void initState() {
    super.initState();
    _salaryDataService = DataAnalysisService(IsarDatabase());
    _initAnalysisData();
  }

  void _initAnalysisData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 使用DataAnalysisService获取数据
      final departmentStats = await _salaryDataService.getDepartmentAggregation(
        widget.year,
        widget.month,
      );

      // 获取考勤统计数据
      final attendanceStats = await _salaryDataService
          .getMonthlyAttendanceStats(year: widget.year, month: widget.month);

      // 获取请假比例统计数据
      final leaveRatioStats = await _salaryDataService.getLeaveRatioStats(
        year: widget.year,
        month: widget.month,
      );

      // 更新本地状态
      setState(() {
        _departmentStats = departmentStats;
        _attendanceStats = attendanceStats;
        _leaveRatioStats = leaveRatioStats;
      });

      // 计算总工资和平均工资
      double totalSalary = 0;
      int totalEmployees = 0;
      double highestSalary = 0;
      double lowestSalary = double.infinity;

      for (var stat in departmentStats) {
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
      final departmentStatsData = departmentStats.map((stat) {
        return {
          'department': stat.department,
          'count': stat.employeeCount,
          'average': stat.averageNetSalary,
          'total': stat.totalNetSalary,
        };
      }).toList();

      // 为单月情况准备月度数据
      final monthlyData = [
        {'month': '${widget.month}月', 'salary': totalSalary},
      ];

      // 计算薪资区间分布数据
      final salaryRanges = await _salaryDataService.getSalaryRangeAggregation(
        widget.year,
        widget.month,
      );

      // 计算部门和薪资范围联合统计数据
      final departmentSalaryRangeStats = await _salaryDataService
          .getDepartmentSalaryRangeAggregation(widget.year, widget.month);

      // 获取工资最高的前10名员工
      final topSalaryEmployees = await _salaryDataService.getTopSalaryEmployees(
        year: widget.year,
        month: widget.month,
        limit: 10,
      );

      // 获取工资最低的前10名员工
      final bottomSalaryEmployees = await _salaryDataService
          .getBottomSalaryEmployees(
            year: widget.year,
            month: widget.month,
            limit: 10,
          );

      // 获取工资汇总数据
      final salarySummary = await _salaryDataService.getSalarySummaryData(
        year: widget.year,
        month: widget.month,
      );

      setState(() {
        _analysisData = {
          'totalEmployees': totalEmployees,
          'totalSalary': totalSalary,
          'averageSalary': averageSalary,
          'highestSalary': highestSalary,
          'lowestSalary': lowestSalary,
          'departmentStats': departmentStatsData,
          'monthlyData': monthlyData,
          'salaryRanges': salaryRanges,
          'departmentSalaryRangeStats': departmentSalaryRangeStats,
          'topSalaryEmployees': topSalaryEmployees,
          'bottomSalaryEmployees': bottomSalaryEmployees,
          'salarySummary': salarySummary,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('获取分析数据失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 生成工资报告
  Future<void> _generateSalaryReport() async {
    try {
      setState(() {
        _isGeneratingReport = true;
      });

      // 确定开始和结束时间
      final startTime = DateTime(widget.year, widget.month);
      final endTime = widget.isMultiMonth
          ? DateTime(widget.year, widget.month)
          : DateTime(widget.year, widget.month);

      final generator = SalaryReportGenerator();
      final reportPath = await generator.generateReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: _departmentStats,
        analysisData: _analysisData,
        endTime: endTime,
        year: widget.year,
        month: widget.month,
        isMultiMonth: widget.isMultiMonth,
        startTime: startTime,
        reportType: ReportType.singleMonth,
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.year}年${widget.month.toString().padLeft(2, '0')}月 工资分析',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final title = widget.isMultiMonth
        ? '${widget.year}年${widget.month.toString().padLeft(2, '0')}月起 工资分析'
        : '${widget.year}年${widget.month.toString().padLeft(2, '0')}月 工资分析';

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

                  // 部门工资占比饼图
                  const Text(
                    '各部门工资占比',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16.0),
                      child: DepartmentSalaryChart(
                        departmentStats: _departmentStats,
                      ),
                    ),
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
                              Expanded(
                                child: Text(
                                  '工资总额',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          ..._analysisData['departmentStats'].map<Widget>((
                            dept,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: Text(dept['department']),
                                  ),
                                  Expanded(
                                    child: Text(dept['count'].toString()),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '¥${dept['average'].toStringAsFixed(2)}',
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '¥${dept['total'].toStringAsFixed(2)}',
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

                  // 薪资区间分布
                  const Text(
                    '薪资区间分布',
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
                                  '薪资区间',
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
                          ...(_analysisData['salaryRanges']
                                  as List<SalaryRangeStats>)
                              .map<Widget>((range) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(range.range)),
                                      Expanded(
                                        child: Text(
                                          range.employeeCount.toString(),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '¥${range.totalSalary.toStringAsFixed(2)}',
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '¥${range.averageSalary.toStringAsFixed(2)}',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 部门和薪资区间联合统计
                  const Text(
                    '各部门薪资区间分布',
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
                                  '薪资区间',
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
                          ...(_analysisData['departmentSalaryRangeStats']
                                  as List<DepartmentSalaryRangeStats>)
                              .map<Widget>((deptRange) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: Text(deptRange.department),
                                      ),
                                      Expanded(
                                        child: Text(deptRange.salaryRange),
                                      ),
                                      Expanded(
                                        child: Text(
                                          deptRange.employeeCount.toString(),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '¥${deptRange.totalSalary.toStringAsFixed(2)}',
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '¥${deptRange.averageSalary.toStringAsFixed(2)}',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 工资最高的员工
                  const Text(
                    '工资最高的员工（前10名）',
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
                                  '姓名',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '部门',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '职位',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '实发工资',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          ...(_analysisData['topSalaryEmployees'] as List)
                              .map<Widget>((record) {
                                // 确保类型正确
                                if (record is SalaryListRecord) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: Text(record.name ?? ''),
                                        ),
                                        Expanded(
                                          child: Text(record.department ?? ''),
                                        ),
                                        Expanded(
                                          child: Text(record.position ?? ''),
                                        ),
                                        Expanded(
                                          child: Text(record.netSalary ?? ''),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              })
                              .toList(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 工资最低的员工
                  const Text(
                    '工资最低的员工（前10名）',
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
                                  '姓名',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '部门',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '职位',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '实发工资',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          ...(_analysisData['bottomSalaryEmployees'] as List)
                              .map<Widget>((record) {
                                // 确保类型正确
                                if (record is SalaryListRecord) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: Text(record.name ?? ''),
                                        ),
                                        Expanded(
                                          child: Text(record.department ?? ''),
                                        ),
                                        Expanded(
                                          child: Text(record.position ?? ''),
                                        ),
                                        Expanded(
                                          child: Text(record.netSalary ?? ''),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              })
                              .toList(),
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
                            attendanceStats: _attendanceStats,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 请假比例统计
                  if (_leaveRatioStats != null) ...[
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
                                      _leaveRatioStats!.totalEmployees
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
                                      _leaveRatioStats!.sickLeaveRatio
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
                                      _leaveRatioStats!.leaveRatio
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
}
