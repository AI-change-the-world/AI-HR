import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/pages/visualization/report/salary_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:toastification/toastification.dart';

import 'package:salary_report/src/components/salary_charts.dart';

class MultiMonthAnalysisPage extends StatefulWidget {
  const MultiMonthAnalysisPage({
    super.key,
    required this.year,
    required this.month,
    required this.endYear,
    required this.endMonth,
    this.departmentStats = const [],
    this.attendanceStats = const [],
    this.leaveRatioStats,
    required this.dataAnalysisService,
  });

  final int year;
  final int month;
  final int endYear;
  final int endMonth;
  final List<DepartmentSalaryStats> departmentStats;
  final List<AttendanceStats> attendanceStats;
  final LeaveRatioStats? leaveRatioStats;
  final DataAnalysisService dataAnalysisService;

  @override
  State<MultiMonthAnalysisPage> createState() => _MultiMonthAnalysisPageState();
}

class _MultiMonthAnalysisPageState extends State<MultiMonthAnalysisPage> {
  late Map<String, dynamic> _analysisData;
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  List<LeaveRatioStats> _monthlyLeaveRatioStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnalysisData();
  }

  void _initAnalysisData() async {
    // 获取每月部门统计数据
    List<DepartmentSalaryStats> monthlyDepartmentStats = [];
    try {
      monthlyDepartmentStats = await widget.dataAnalysisService
          .getMonthlyDepartmentSalaryStats(
            startYear: widget.year,
            startMonth: widget.month,
            endYear: widget.endYear,
            endMonth: widget.endMonth,
          );
    } catch (e) {
      logger.severe('获取每月部门统计数据失败: $e');
    }

    // 获取每月考勤统计数据
    List<AttendanceStats> monthlyAttendanceStats = [];
    try {
      monthlyAttendanceStats = await widget.dataAnalysisService
          .getMonthlyAttendanceStats(
            startYear: widget.year,
            startMonth: widget.month,
            endYear: widget.endYear,
            endMonth: widget.endMonth,
          );
    } catch (e) {
      logger.severe('获取每月考勤统计数据失败: $e');
    }

    // 获取每月请假比例统计数据
    List<LeaveRatioStats> monthlyLeaveRatioStats = [];
    try {
      monthlyLeaveRatioStats = await widget.dataAnalysisService
          .getMonthlyLeaveRatioStats(
            startYear: widget.year,
            startMonth: widget.month,
            endYear: widget.endYear,
            endMonth: widget.endMonth,
          );
    } catch (e) {
      logger.severe('获取每月请假比例统计数据失败: $e');
    }

    setState(() {
      // 按月份分组部门统计数据
      final groupedDepartmentStats = _groupDepartmentStatsByMonth(
        monthlyDepartmentStats,
      );

      // 按月份分组考勤统计数据
      final groupedAttendanceStats = _groupAttendanceStatsByMonth(
        monthlyAttendanceStats,
      );

      // 按月份分组请假比例统计数据
      final groupedLeaveRatioStats = _groupLeaveRatioStatsByMonth(
        monthlyLeaveRatioStats,
      );

      // 计算每个月的关键指标
      final monthlyKeyMetrics = _calculateMonthlyKeyMetrics(
        groupedDepartmentStats,
      );

      // 构建整体统计数据（所有月份的汇总）
      final overallStats = _calculateOverallStats(groupedDepartmentStats);

      // 为多月情况准备月度数据
      final monthlyData = _generateMonthlyData(monthlyDepartmentStats);

      // 计算每月人数变化数据（包含部门详情）
      final employeeCountPerMonth = _calculateEmployeeCountPerMonth(
        groupedDepartmentStats,
      );

      // 计算每月平均薪资变化数据
      final averageSalaryPerMonth = _calculateAverageSalaryPerMonth(
        groupedDepartmentStats,
      );

      // 计算每月总工资变化数据
      final totalSalaryPerMonth = _calculateTotalSalaryPerMonth(
        groupedDepartmentStats,
      );

      // 计算每月各部门详情数据
      final departmentDetailsPerMonth = _calculateDepartmentDetailsPerMonth(
        groupedDepartmentStats,
      );

      // 计算每月薪资区间分布数据
      final monthlySalaryRanges = _calculateMonthlySalaryRanges(
        groupedDepartmentStats,
      );

      // 计算每月薪资排名数据
      final monthlySalaryRankings = _calculateMonthlySalaryRankings(
        groupedDepartmentStats,
      );

      // 获取最后一个月的部门统计数据（用于图表生成）
      final lastMonthDepartmentStats = _getLastMonthDepartmentStats(
        groupedDepartmentStats,
      );

      _analysisData = {
        'monthlyDepartmentStats': groupedDepartmentStats, // 每月部门统计数据
        'monthlyAttendanceStats': groupedAttendanceStats, // 每月考勤统计数据
        'monthlyLeaveRatioStats': groupedLeaveRatioStats, // 每月请假比例统计数据
        'monthlyKeyMetrics': monthlyKeyMetrics, // 每月关键指标
        'overallStats': overallStats, // 整体统计数据
        'monthlyData': monthlyData, // 用于图表的月度数据
        'totalEmployees': overallStats['totalEmployees'],
        'totalSalary': overallStats['totalSalary'],
        'averageSalary': overallStats['averageSalary'],
        'highestSalary': overallStats['highestSalary'],
        'lowestSalary': overallStats['lowestSalary'],
        // 多月报告专用数据
        'monthlyEmployeeCount': employeeCountPerMonth, // 每月人数变化数据（包含部门详情）
        'monthlyAverageSalary': averageSalaryPerMonth, // 每月平均薪资变化数据
        'monthlyTotalSalary': totalSalaryPerMonth, // 每月总工资变化数据
        'monthlyDepartmentDetails': departmentDetailsPerMonth, // 每月各部门详情数据
        'monthlySalaryRanges': monthlySalaryRanges, // 每月薪资区间分布数据
        'monthlySalaryRankings': monthlySalaryRankings, // 每月薪资排名数据
        'lastMonthDepartmentStats':
            lastMonthDepartmentStats, // 最后一个月部门统计数据（用于图表）
      };

      _isLoading = false;
    });
  }

  /// 按月份分组部门统计数据
  Map<String, List<Map<String, dynamic>>> _groupDepartmentStatsByMonth(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    final Map<String, List<Map<String, dynamic>>> monthlyStats = {};

    // 根据部门统计数据中的年月信息进行分组
    for (var stat in departmentStats) {
      if (stat.year != null && stat.month != null) {
        final monthKey =
            '${stat.year}-${stat.month.toString().padLeft(2, '0')}';

        if (!monthlyStats.containsKey(monthKey)) {
          monthlyStats[monthKey] = [];
        }

        monthlyStats[monthKey]!.add({
          'department': stat.department,
          'count': stat.employeeCount,
          'average': stat.averageNetSalary,
          'total': stat.totalNetSalary,
        });
      }
    }

    return monthlyStats;
  }

  /// 按月份分组考勤统计数据
  Map<String, List<AttendanceStats>> _groupAttendanceStatsByMonth(
    List<AttendanceStats> attendanceStats,
  ) {
    final Map<String, List<AttendanceStats>> monthlyAttendanceStats = {};

    // 根据考勤统计数据中的年月信息进行分组
    for (var stat in attendanceStats) {
      if (stat.year != null && stat.month != null) {
        final monthKey =
            '${stat.year}-${stat.month.toString().padLeft(2, '0')}';

        if (!monthlyAttendanceStats.containsKey(monthKey)) {
          monthlyAttendanceStats[monthKey] = [];
        }

        monthlyAttendanceStats[monthKey]!.add(stat);
      }
    }

    return monthlyAttendanceStats;
  }

  /// 按月份分组请假比例统计数据
  Map<String, LeaveRatioStats> _groupLeaveRatioStatsByMonth(
    List<LeaveRatioStats> leaveRatioStats,
  ) {
    final Map<String, LeaveRatioStats> monthlyLeaveRatioStats = {};

    // 根据请假比例统计数据中的年月信息进行分组
    for (var stat in leaveRatioStats) {
      if (stat.year != null && stat.month != null) {
        final monthKey =
            '${stat.year}-${stat.month.toString().padLeft(2, '0')}';

        // 由于每个月份只应该有一个请假比例统计，直接赋值即可
        monthlyLeaveRatioStats[monthKey] = stat;
      }
    }

    return monthlyLeaveRatioStats;
  }

  /// 计算每月关键指标
  Map<String, Map<String, dynamic>> _calculateMonthlyKeyMetrics(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    final Map<String, Map<String, dynamic>> monthlyKeyMetrics = {};

    monthlyDepartmentStats.forEach((monthKey, departmentStats) {
      int totalEmployees = 0;
      double totalSalary = 0;
      double highestSalary = 0;
      double lowestSalary = double.infinity;

      for (var stat in departmentStats) {
        totalEmployees += stat['count'] as int;
        totalSalary += stat['total'] as double;

        if (stat['average'] as double > highestSalary) {
          highestSalary = stat['average'] as double;
        }

        if (stat['average'] as double < lowestSalary) {
          lowestSalary = stat['average'] as double;
        }
      }

      if (lowestSalary == double.infinity) {
        lowestSalary = 0;
      }

      final averageSalary = totalEmployees > 0
          ? totalSalary / totalEmployees
          : 0;

      monthlyKeyMetrics[monthKey] = {
        'totalEmployees': totalEmployees,
        'totalSalary': totalSalary,
        'averageSalary': averageSalary,
        'highestSalary': highestSalary,
        'lowestSalary': lowestSalary,
      };
    });

    return monthlyKeyMetrics;
  }

  /// 计算整体统计数据
  Map<String, dynamic> _calculateOverallStats(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    int totalEmployees = 0;
    double totalSalary = 0;
    double highestSalary = 0;
    double lowestSalary = double.infinity;

    // 遍历所有月份的数据来计算整体统计
    monthlyDepartmentStats.forEach((monthKey, departmentStats) {
      for (var stat in departmentStats) {
        totalEmployees += stat['count'] as int;
        totalSalary += stat['total'] as double;

        if (stat['average'] as double > highestSalary) {
          highestSalary = stat['average'] as double;
        }

        if (stat['average'] as double < lowestSalary) {
          lowestSalary = stat['average'] as double;
        }
      }
    });

    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }

    final averageSalary = totalEmployees > 0 ? totalSalary / totalEmployees : 0;

    return {
      'totalEmployees': totalEmployees,
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
    };
  }

  /// 生成多月数据（用于图表）
  List<Map<String, dynamic>> _generateMonthlyData(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    final List<Map<String, dynamic>> monthlyData = [];

    // 计算月份范围
    final startDate = DateTime(widget.year, widget.month);
    final endDate = DateTime(widget.endYear, widget.endMonth);

    // 按月分组统计数据
    final monthlyGroupedData = <String, double>{};

    // 根据部门统计数据中的年月信息进行分组
    for (var stat in departmentStats) {
      if (stat.year != null && stat.month != null) {
        final monthKey =
            '${stat.year}-${stat.month.toString().padLeft(2, '0')}';
        if (monthlyGroupedData.containsKey(monthKey)) {
          monthlyGroupedData[monthKey] =
              monthlyGroupedData[monthKey]! + stat.totalNetSalary;
        } else {
          monthlyGroupedData[monthKey] = stat.totalNetSalary;
        }
      }
    }

    // 填充月度数据
    DateTime currentDate = DateTime(startDate.year, startDate.month);
    while (currentDate.isBefore(endDate) ||
        (currentDate.year == endDate.year &&
            currentDate.month == endDate.month)) {
      final monthKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}';
      final salary = monthlyGroupedData[monthKey] ?? 0.0;

      monthlyData.add({
        'month': '${currentDate.year}年${currentDate.month}月',
        'salary': salary,
      });

      // 移动到下一个月
      if (currentDate.month == 12) {
        currentDate = DateTime(currentDate.year + 1, 1);
      } else {
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }
    }

    return monthlyData;
  }

  /// 生成工资报告
  Future<void> _generateSalaryReport() async {
    try {
      setState(() {
        _isGeneratingReport = true;
      });

      // 确定开始和结束时间
      final startTime = DateTime(widget.year, widget.month);
      final endTime = DateTime(widget.endYear, widget.endMonth);

      final generator = SalaryReportGenerator();
      final reportPath = await generator.generateReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: widget.departmentStats,
        analysisData: _analysisData,
        endTime: endTime,
        year: widget.year,
        month: widget.month,
        isMultiMonth: true,
        startTime: startTime,
        reportType: ReportType.multiMonth, // 明确指定报告类型
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
    // 如果还在加载数据，显示加载指示器
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.year}年${widget.month.toString().padLeft(2, '0')}月 - '
            '${widget.endYear}年${widget.endMonth.toString().padLeft(2, '0')}月 工资分析',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final title =
        '${widget.year}年${widget.month.toString().padLeft(2, '0')}月 - '
        '${widget.endYear}年${widget.endMonth.toString().padLeft(2, '0')}月 工资分析';

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
                  // 每月关键指标
                  const Text(
                    '每月关键指标',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMonthlyKeyMetrics(),

                  const SizedBox(height: 24),

                  // 每月部门统计
                  const Text(
                    '每月部门统计',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMonthlyDepartmentStats(),

                  const SizedBox(height: 24),

                  // 每月考勤统计
                  const Text(
                    '每月考勤统计',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMonthlyAttendanceStats(),

                  const SizedBox(height: 24),

                  // 每月请假比例统计
                  const Text(
                    '每月请假比例统计',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMonthlyLeaveRatioStats(),

                  const SizedBox(height: 24),

                  // 每月人数变化趋势图
                  const Text(
                    '每月人数变化趋势',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16.0),
                      child: MonthlyEmployeeCountChart(
                        monthlyData: _calculateEmployeeCountPerMonth(
                          _analysisData['monthlyDepartmentStats']
                              as Map<String, List<Map<String, dynamic>>>,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 每月平均薪资变化趋势图
                  const Text(
                    '每月平均薪资变化趋势',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16.0),
                      child: MonthlyAverageSalaryChart(
                        monthlyData: _calculateAverageSalaryPerMonth(
                          _analysisData['monthlyDepartmentStats']
                              as Map<String, List<Map<String, dynamic>>>,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 每月总工资变化趋势图
                  const Text(
                    '每月总工资变化趋势',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16.0),
                      child: MonthlyTotalSalaryChart(
                        monthlyData: _calculateTotalSalaryPerMonth(
                          _analysisData['monthlyDepartmentStats']
                              as Map<String, List<Map<String, dynamic>>>,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 各部门平均薪资趋势图
                  const Text(
                    '各部门平均薪资趋势',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16.0),
                      child: MultiMonthDepartmentSalaryChart(
                        departmentMonthlyData: _prepareDepartmentMonthlyData(
                          _analysisData['monthlyDepartmentStats']
                              as Map<String, List<Map<String, dynamic>>>,
                        ),
                      ),
                    ),
                  ),
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
                    // CircularProgressIndicator(),
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

  /// 构建每月关键指标展示
  Widget _buildMonthlyKeyMetrics() {
    final monthlyKeyMetrics =
        _analysisData['monthlyKeyMetrics'] as Map<String, Map<String, dynamic>>;

    return Column(
      children: monthlyKeyMetrics.entries.map((entry) {
        final monthKey = entry.key;
        final metrics = entry.value;

        // 解析月份信息
        final parts = monthKey.split('-');
        final year = parts[0];
        final month = parts[1];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$year年$month月',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // 使用与单月页面相同的布局方式
                Wrap(
                  children: [
                    _buildStatCard(
                      '总人数',
                      metrics['totalEmployees'].toString(),
                      Icons.people,
                    ),
                    _buildStatCard(
                      '工资总额',
                      '¥${metrics['totalSalary'].toStringAsFixed(2)}',
                      Icons.account_balance_wallet,
                    ),
                    _buildStatCard(
                      '平均工资',
                      '¥${metrics['averageSalary'].toStringAsFixed(2)}',
                      Icons.trending_up,
                    ),
                    _buildStatCard(
                      '最高工资',
                      '¥${metrics['highestSalary'].toStringAsFixed(2)}',
                      Icons.arrow_upward,
                    ),
                    _buildStatCard(
                      '最低工资',
                      '¥${metrics['lowestSalary'].toStringAsFixed(2)}',
                      Icons.arrow_downward,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建每月部门统计展示
  Widget _buildMonthlyDepartmentStats() {
    final monthlyDepartmentStats =
        _analysisData['monthlyDepartmentStats']
            as Map<String, List<Map<String, dynamic>>>;

    return Column(
      children: monthlyDepartmentStats.entries.map((entry) {
        final monthKey = entry.key;
        final departmentStats = entry.value;

        // 解析月份信息
        final parts = monthKey.split('-');
        final year = parts[0];
        final month = parts[1];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$year年$month月部门统计',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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
                ...departmentStats.map<Widget>((dept) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(dept['department'] as String),
                        ),
                        Expanded(
                          child: Text((dept['count'] as int).toString()),
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
        );
      }).toList(),
    );
  }

  /// 构建每月考勤统计展示
  Widget _buildMonthlyAttendanceStats() {
    final monthlyAttendanceStats =
        _analysisData['monthlyAttendanceStats']
            as Map<String, List<AttendanceStats>>;

    return Column(
      children: monthlyAttendanceStats.entries.map((entry) {
        final monthKey = entry.key;
        final attendanceStats = entry.value;

        // 解析月份信息
        final parts = monthKey.split('-');
        final year = parts[0];
        final month = parts[1];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$year年$month月考勤统计',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AttendancePagination(attendanceStats: attendanceStats),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建每月请假比例统计展示
  Widget _buildMonthlyLeaveRatioStats() {
    final monthlyLeaveRatioStats =
        _analysisData['monthlyLeaveRatioStats'] as Map<String, LeaveRatioStats>;

    return Column(
      children: monthlyLeaveRatioStats.entries.map((entry) {
        final monthKey = entry.key;
        final leaveRatioStats = entry.value;

        // 解析月份信息
        final parts = monthKey.split('-');
        final year = parts[0];
        final month = parts[1];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$year年$month月请假比例统计',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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
                        child: Text(leaveRatioStats.totalEmployees.toString()),
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
                          leaveRatioStats.sickLeaveRatio.toStringAsFixed(2),
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
                          leaveRatioStats.leaveRatio.toStringAsFixed(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建统计卡片（与单月页面保持一致）
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: SizedBox(
        width: 150, // 与单月页面保持一致
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

  /// 计算每月人数变化数据（包含部门详情）
  List<Map<String, dynamic>> _calculateEmployeeCountPerMonth(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    final List<Map<String, dynamic>> employeeCountPerMonth = [];

    monthlyDepartmentStats.forEach((monthKey, departmentStats) {
      int totalEmployees = 0;

      for (var stat in departmentStats) {
        totalEmployees += stat['count'] as int;
      }

      // 解析月份信息
      final parts = monthKey.split('-');
      final year = parts[0];
      final month = parts[1];

      // 添加部门详情信息
      employeeCountPerMonth.add({
        'month': '$year年$month月',
        'year': int.parse(year),
        'monthNum': int.parse(month),
        'employeeCount': totalEmployees,
        'departments': departmentStats, // 添加部门详情
      });
    });

    // 按时间排序
    employeeCountPerMonth.sort((a, b) {
      if (a['year'] != b['year']) {
        return (a['year'] as int).compareTo(b['year'] as int);
      }
      return (a['monthNum'] as int).compareTo(b['monthNum'] as int);
    });

    return employeeCountPerMonth;
  }

  /// 计算每月平均薪资变化数据
  List<Map<String, dynamic>> _calculateAverageSalaryPerMonth(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    final List<Map<String, dynamic>> averageSalaryPerMonth = [];

    monthlyDepartmentStats.forEach((monthKey, departmentStats) {
      int totalEmployees = 0;
      double totalSalary = 0;

      for (var stat in departmentStats) {
        totalEmployees += stat['count'] as int;
        totalSalary += stat['total'] as double;
      }

      final averageSalary = totalEmployees > 0
          ? totalSalary / totalEmployees
          : 0;

      // 解析月份信息
      final parts = monthKey.split('-');
      final year = parts[0];
      final month = parts[1];

      averageSalaryPerMonth.add({
        'month': '$year年$month月',
        'year': int.parse(year),
        'monthNum': int.parse(month),
        'averageSalary': averageSalary,
      });
    });

    // 按时间排序
    averageSalaryPerMonth.sort((a, b) {
      if (a['year'] != b['year']) {
        return (a['year'] as int).compareTo(b['year'] as int);
      }
      return (a['monthNum'] as int).compareTo(b['monthNum'] as int);
    });

    return averageSalaryPerMonth;
  }

  /// 计算每月总工资变化数据
  List<Map<String, dynamic>> _calculateTotalSalaryPerMonth(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    final List<Map<String, dynamic>> totalSalaryPerMonth = [];

    monthlyDepartmentStats.forEach((monthKey, departmentStats) {
      double totalSalary = 0;

      for (var stat in departmentStats) {
        totalSalary += stat['total'] as double;
      }

      // 解析月份信息
      final parts = monthKey.split('-');
      final year = parts[0];
      final month = parts[1];

      totalSalaryPerMonth.add({
        'month': '$year年$month月',
        'year': int.parse(year),
        'monthNum': int.parse(month),
        'totalSalary': totalSalary,
      });
    });

    // 按时间排序
    totalSalaryPerMonth.sort((a, b) {
      if (a['year'] != b['year']) {
        return (a['year'] as int).compareTo(b['year'] as int);
      }
      return (a['monthNum'] as int).compareTo(b['monthNum'] as int);
    });

    return totalSalaryPerMonth;
  }

  /// 计算每月各部门详情数据
  List<Map<String, dynamic>> _calculateDepartmentDetailsPerMonth(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    final List<Map<String, dynamic>> departmentDetailsPerMonth = [];

    monthlyDepartmentStats.forEach((monthKey, departmentStats) {
      // 解析月份信息
      final parts = monthKey.split('-');
      final year = parts[0];
      final month = parts[1];

      final monthData = {
        'month': '$year年$month月',
        'year': int.parse(year),
        'monthNum': int.parse(month),
        'departments': <Map<String, dynamic>>[],
      };

      for (var stat in departmentStats) {
        (monthData['departments'] as List<Map<String, dynamic>>).add({
          'department': stat['department'] as String,
          'employeeCount': stat['count'] as int,
          'averageSalary': stat['average'] as double,
          'totalSalary': stat['total'] as double,
        });
      }

      departmentDetailsPerMonth.add(monthData);
    });

    // 按时间排序
    departmentDetailsPerMonth.sort((a, b) {
      if (a['year'] != b['year']) {
        return (a['year'] as int).compareTo(b['year'] as int);
      }
      return (a['monthNum'] as int).compareTo(b['monthNum'] as int);
    });

    return departmentDetailsPerMonth;
  }

  /// 计算每月薪资区间分布数据
  List<Map<String, dynamic>> _calculateMonthlySalaryRanges(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    final List<Map<String, dynamic>> monthlySalaryRanges = [];

    monthlyDepartmentStats.forEach((monthKey, departmentStats) {
      // 计算该月份的薪资区间分布
      final ranges = <String, int>{};
      for (var stat in departmentStats) {
        final salary = stat['average'] as double;
        String range;
        if (salary < 3000) {
          range = '< 3000';
        } else if (salary < 4000) {
          range = '3000-4000';
        } else if (salary < 5000) {
          range = '4000-5000';
        } else if (salary < 6000) {
          range = '5000-6000';
        } else if (salary < 7000) {
          range = '6000-7000';
        } else if (salary < 8000) {
          range = '7000-8000';
        } else if (salary < 9000) {
          range = '8000-9000';
        } else if (salary < 10000) {
          range = '9000-10000';
        } else {
          range = '> 10000';
        }
        ranges[range] = (ranges[range] ?? 0) + (stat['count'] as int);
      }

      // 解析月份信息
      final parts = monthKey.split('-');
      final year = parts[0];
      final month = parts[1];

      monthlySalaryRanges.add({
        'month': '$year年$month月',
        'year': int.parse(year),
        'monthNum': int.parse(month),
        'salaryRanges': ranges,
      });
    });

    // 按时间排序
    monthlySalaryRanges.sort((a, b) {
      if (a['year'] != b['year']) {
        return (a['year'] as int).compareTo(b['year'] as int);
      }
      return (a['monthNum'] as int).compareTo(b['monthNum'] as int);
    });

    return monthlySalaryRanges;
  }

  /// 计算每月薪资排名数据
  List<Map<String, dynamic>> _calculateMonthlySalaryRankings(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    final List<Map<String, dynamic>> monthlySalaryRankings = [];

    monthlyDepartmentStats.forEach((monthKey, departmentStats) {
      // 按平均薪资排序
      final sortedDepts = List<Map<String, dynamic>>.from(departmentStats)
        ..sort(
          (a, b) => (b['average'] as double).compareTo(a['average'] as double),
        );

      // 解析月份信息
      final parts = monthKey.split('-');
      final year = parts[0];
      final month = parts[1];

      monthlySalaryRankings.add({
        'month': '$year年$month月',
        'year': int.parse(year),
        'monthNum': int.parse(month),
        'rankings': sortedDepts,
      });
    });

    // 按时间排序
    monthlySalaryRankings.sort((a, b) {
      if (a['year'] != b['year']) {
        return (a['year'] as int).compareTo(b['year'] as int);
      }
      return (a['monthNum'] as int).compareTo(b['monthNum'] as int);
    });

    return monthlySalaryRankings;
  }

  /// 获取最后一个月的部门统计数据（用于图表生成）
  List<Map<String, dynamic>> _getLastMonthDepartmentStats(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    if (monthlyDepartmentStats.isEmpty) {
      return [];
    }

    // 按时间排序，获取最后一个月的数据
    final sortedEntries = monthlyDepartmentStats.entries.toList()
      ..sort((a, b) {
        final aParts = a.key.split('-');
        final bParts = b.key.split('-');
        final aYear = int.parse(aParts[0]);
        final aMonth = int.parse(aParts[1]);
        final bYear = int.parse(bParts[0]);
        final bMonth = int.parse(bParts[1]);

        if (aYear != bYear) {
          return aYear.compareTo(bYear);
        }
        return aMonth.compareTo(bMonth);
      });

    // 获取最后一个月的数据
    final lastMonthEntry = sortedEntries.last;
    final departmentStats = lastMonthEntry.value;

    // 转换为图表所需格式
    return departmentStats.map((stat) {
      return {
        'department': stat['department'] as String,
        'employeeCount': stat['count'] as int,
        'averageSalary': stat['average'] as double,
        'totalSalary': stat['total'] as double,
      };
    }).toList();
  }

  /// 准备部门月度数据用于图表显示
  List<Map<String, dynamic>> _prepareDepartmentMonthlyData(
    Map<String, List<Map<String, dynamic>>> monthlyDepartmentStats,
  ) {
    final List<Map<String, dynamic>> result = [];

    monthlyDepartmentStats.forEach((monthKey, departmentStats) {
      // 解析月份信息
      final parts = monthKey.split('-');
      final year = parts[0];
      final month = parts[1];
      final monthLabel = '$year年$month月';

      // 构建部门数据映射
      final departmentData = <String, double>{};
      for (var stat in departmentStats) {
        departmentData[stat['department'] as String] =
            stat['average'] as double;
      }

      result.add({'month': monthLabel, 'departments': departmentData});
    });

    // 按时间排序
    result.sort((a, b) {
      final aParts = (a['month'] as String)
          .replaceAll('年', '-')
          .replaceAll('月', '')
          .split('-');
      final bParts = (b['month'] as String)
          .replaceAll('年', '-')
          .replaceAll('月', '')
          .split('-');
      final aYear = int.parse(aParts[0]);
      final aMonth = int.parse(aParts[1]);
      final bYear = int.parse(bParts[0]);
      final bMonth = int.parse(bParts[1]);

      if (aYear != bYear) {
        return aYear.compareTo(bYear);
      }
      return aMonth.compareTo(bMonth);
    });

    return result;
  }
}
