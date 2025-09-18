import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/pages/visualization/report/salary_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart'; // 添加这一行导入
import 'package:toastification/toastification.dart';
// 添加数据库导入
// 添加riverpod导入

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
    required this.dataAnalysisService, // 添加数据服务参数
  });

  final int year;
  final int month;
  final int endYear;
  final int endMonth;
  final List<DepartmentSalaryStats> departmentStats;
  final List<AttendanceStats> attendanceStats;
  final LeaveRatioStats? leaveRatioStats;
  final DataAnalysisService dataAnalysisService; // 添加数据服务字段

  @override
  State<MultiMonthAnalysisPage> createState() => _MultiMonthAnalysisPageState();
}

class _MultiMonthAnalysisPageState extends State<MultiMonthAnalysisPage> {
  late Map<String, dynamic> _analysisData;
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  List<LeaveRatioStats> _monthlyLeaveRatioStats = []; // 添加每月请假比例统计数据
  bool _isLoading = true; // 添加加载状态

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
        reportType: ReportType.multiMonth, // 添加这一行来指定报告类型
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
}
