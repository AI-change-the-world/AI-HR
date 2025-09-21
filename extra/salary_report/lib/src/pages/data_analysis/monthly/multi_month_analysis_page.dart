import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart'; // 添加数据库导入
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
  });

  final int year;
  final int month;
  final int endYear;
  final int endMonth;

  @override
  State<MultiMonthAnalysisPage> createState() => _MultiMonthAnalysisPageState();
}

class _MultiMonthAnalysisPageState extends State<MultiMonthAnalysisPage> {
  late Map<String, dynamic> _analysisData;
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  bool _isLoading = true;
  late DataAnalysisService _salaryDataService; // 添加新的服务实例

  @override
  void initState() {
    super.initState();
    _salaryDataService = DataAnalysisService(IsarDatabase()); // 初始化服务
    _initAnalysisData();
  }

  void _initAnalysisData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 使用DataAnalysisService获取多月对比数据
      final comparisonData = await _salaryDataService
          .getMultiMonthComparisonData(
            widget.year,
            widget.month,
            widget.endYear,
            widget.endMonth,
          );

      if (comparisonData != null) {
        // 按月份分组部门统计数据
        final groupedDepartmentStats = _groupDepartmentStatsByMonth(
          comparisonData,
        );

        // 按月份分组考勤统计数据
        final groupedAttendanceStats = _groupAttendanceStatsByMonth(
          comparisonData,
        );

        // 按月份分组请假比例统计数据
        final groupedLeaveRatioStats = _groupLeaveRatioStatsByMonth(
          comparisonData,
        );

        // 计算每个月的关键指标
        final monthlyKeyMetrics = _calculateMonthlyKeyMetrics(comparisonData);

        // 构建整体统计数据（所有月份的汇总）
        final overallStats = _calculateOverallStats(comparisonData);

        // 为多月情况准备月度数据
        final monthlyData = _generateMonthlyData(comparisonData);

        // 计算每月人数变化数据（包含部门详情）
        final employeeCountPerMonth = _calculateEmployeeCountPerMonth(
          comparisonData,
        );

        // 计算每月平均薪资变化数据
        final averageSalaryPerMonth = _calculateAverageSalaryPerMonth(
          comparisonData,
        );

        // 计算每月总工资变化数据
        final totalSalaryPerMonth = _calculateTotalSalaryPerMonth(
          comparisonData,
        );

        // 计算每月各部门详情数据
        final departmentDetailsPerMonth = _calculateDepartmentDetailsPerMonth(
          comparisonData,
        );

        // 计算每月薪资区间分布数据
        final monthlySalaryRanges = _calculateMonthlySalaryRanges(
          comparisonData,
        );

        // 计算每月薪资排名数据
        final monthlySalaryRankings = _calculateMonthlySalaryRankings(
          comparisonData,
        );

        // 获取最后一个月的部门统计数据（用于图表生成）
        final lastMonthDepartmentStats = _getLastMonthDepartmentStats(
          comparisonData,
        );

        // 计算部门人数变化情况
        final departmentChanges = _calculateDepartmentChanges(comparisonData);

        setState(() {
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
            'departmentChanges': departmentChanges, // 部门人数变化情况
          };

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.severe('获取多月分析数据失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 按月份分组部门统计数据
  Map<String, List<Map<String, dynamic>>> _groupDepartmentStatsByMonth(
    MultiMonthComparisonData comparisonData,
  ) {
    final Map<String, List<Map<String, dynamic>>> monthlyStats = {};

    // 根据对比数据中的月度信息进行分组
    for (var monthlyData in comparisonData.monthlyComparisons) {
      final monthKey =
          '${monthlyData.year}-${monthlyData.month.toString().padLeft(2, '0')}';

      if (!monthlyStats.containsKey(monthKey)) {
        monthlyStats[monthKey] = [];
      }

      // 将部门统计数据转换为所需格式
      monthlyData.departmentStats.forEach((dept, stat) {
        monthlyStats[monthKey]!.add({
          'department': stat.department,
          'count': stat.employeeCount,
          'average': stat.averageNetSalary,
          'total': stat.totalNetSalary,
        });
      });
    }

    return monthlyStats;
  }

  /// 按月份分组考勤统计数据
  Map<String, List<AttendanceStats>> _groupAttendanceStatsByMonth(
    MultiMonthComparisonData comparisonData,
  ) {
    final Map<String, List<AttendanceStats>> monthlyAttendanceStats = {};

    // 这里需要从现有数据中获取考勤统计，暂时使用传入的数据
    // 实际应用中应该从数据库查询考勤数据
    for (var monthlyData in comparisonData.monthlyComparisons) {
      final monthKey =
          '${monthlyData.year}-${monthlyData.month.toString().padLeft(2, '0')}';

      if (!monthlyAttendanceStats.containsKey(monthKey)) {
        monthlyAttendanceStats[monthKey] = [];
      }

      // 这里应该从数据库查询实际的考勤数据
      // 暂时使用传入的数据
    }

    return monthlyAttendanceStats;
  }

  /// 按月份分组请假比例统计数据
  Map<String, LeaveRatioStats> _groupLeaveRatioStatsByMonth(
    MultiMonthComparisonData comparisonData,
  ) {
    final Map<String, LeaveRatioStats> monthlyLeaveRatioStats = {};

    // 根据对比数据中的月度信息进行分组
    for (var monthlyData in comparisonData.monthlyComparisons) {
      final monthKey =
          '${monthlyData.year}-${monthlyData.month.toString().padLeft(2, '0')}';

      // 创建LeaveRatioStats对象
      final leaveRatioStats = LeaveRatioStats(
        totalEmployees: monthlyData.employeeCount,
        sickLeaveRatio: 0.0, // 这些值需要从实际数据中获取
        leaveRatio: 0.0, // 这些值需要从实际数据中获取
        year: monthlyData.year,
        month: monthlyData.month,
      );

      // 由于每个月份只应该有一个请假比例统计，直接赋值即可
      monthlyLeaveRatioStats[monthKey] = leaveRatioStats;
    }

    return monthlyLeaveRatioStats;
  }

  /// 计算每月关键指标
  Map<String, Map<String, dynamic>> _calculateMonthlyKeyMetrics(
    MultiMonthComparisonData comparisonData,
  ) {
    final Map<String, Map<String, dynamic>> monthlyKeyMetrics = {};

    for (var monthlyData in comparisonData.monthlyComparisons) {
      final monthKey =
          '${monthlyData.year}-${monthlyData.month.toString().padLeft(2, '0')}';

      monthlyKeyMetrics[monthKey] = {
        'totalEmployees': monthlyData.employeeCount,
        'totalSalary': monthlyData.totalSalary,
        'averageSalary': monthlyData.averageSalary,
        'highestSalary': 0.0, // 需要从部门数据中计算
        'lowestSalary': 0.0, // 需要从部门数据中计算
      };
    }

    return monthlyKeyMetrics;
  }

  /// 计算整体统计数据
  Map<String, dynamic> _calculateOverallStats(
    MultiMonthComparisonData comparisonData,
  ) {
    int totalEmployees = 0;
    double totalSalary = 0;
    double highestSalary = 0;
    double lowestSalary = double.infinity;

    // 遍历所有月份的数据来计算整体统计
    for (var monthlyData in comparisonData.monthlyComparisons) {
      totalEmployees += monthlyData.employeeCount;
      totalSalary += monthlyData.totalSalary;

      // 这里需要从部门统计数据中获取最高和最低工资
      monthlyData.departmentStats.forEach((dept, stat) {
        if (stat.averageNetSalary > highestSalary) {
          highestSalary = stat.averageNetSalary;
        }

        if (stat.averageNetSalary < lowestSalary) {
          lowestSalary = stat.averageNetSalary;
        }
      });
    }

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
    MultiMonthComparisonData comparisonData,
  ) {
    final List<Map<String, dynamic>> monthlyData = [];

    // 填充月度数据
    for (var monthlyComparison in comparisonData.monthlyComparisons) {
      monthlyData.add({
        'month': '${monthlyComparison.year}年${monthlyComparison.month}月',
        'salary': monthlyComparison.totalSalary,
      });
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
        departmentStats: [],
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

                  // 部门人数变化说明
                  const Text(
                    '部门人数变化说明',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDepartmentChanges(),

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
                        monthlyData:
                            _analysisData['monthlyEmployeeCount']
                                as List<Map<String, dynamic>>,
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
                        monthlyData:
                            _analysisData['monthlyAverageSalary']
                                as List<Map<String, dynamic>>,
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
                        monthlyData:
                            _analysisData['monthlyTotalSalary']
                                as List<Map<String, dynamic>>,
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
    MultiMonthComparisonData comparisonData,
  ) {
    final List<Map<String, dynamic>> employeeCountPerMonth = [];

    for (var monthlyComparison in comparisonData.monthlyComparisons) {
      int totalEmployees = monthlyComparison.employeeCount;

      // 添加部门详情信息
      final departmentDetails = <Map<String, dynamic>>[];
      monthlyComparison.departmentStats.forEach((dept, stat) {
        departmentDetails.add({
          'department': stat.department,
          'count': stat.employeeCount,
          'average': stat.averageNetSalary,
          'total': stat.totalNetSalary,
        });
      });

      employeeCountPerMonth.add({
        'month': '${monthlyComparison.year}年${monthlyComparison.month}月',
        'year': monthlyComparison.year,
        'monthNum': monthlyComparison.month,
        'employeeCount': totalEmployees,
        'departments': departmentDetails, // 添加部门详情
      });
    }

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
    MultiMonthComparisonData comparisonData,
  ) {
    final List<Map<String, dynamic>> averageSalaryPerMonth = [];

    for (var monthlyComparison in comparisonData.monthlyComparisons) {
      final averageSalary = monthlyComparison.averageSalary;

      averageSalaryPerMonth.add({
        'month': '${monthlyComparison.year}年${monthlyComparison.month}月',
        'year': monthlyComparison.year,
        'monthNum': monthlyComparison.month,
        'averageSalary': averageSalary,
      });
    }

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
    MultiMonthComparisonData comparisonData,
  ) {
    final List<Map<String, dynamic>> totalSalaryPerMonth = [];

    for (var monthlyComparison in comparisonData.monthlyComparisons) {
      final totalSalary = monthlyComparison.totalSalary;

      totalSalaryPerMonth.add({
        'month': '${monthlyComparison.year}年${monthlyComparison.month}月',
        'year': monthlyComparison.year,
        'monthNum': monthlyComparison.month,
        'totalSalary': totalSalary,
      });
    }

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
    MultiMonthComparisonData comparisonData,
  ) {
    final List<Map<String, dynamic>> departmentDetailsPerMonth = [];

    for (var monthlyComparison in comparisonData.monthlyComparisons) {
      final monthData = {
        'month': '${monthlyComparison.year}年${monthlyComparison.month}月',
        'year': monthlyComparison.year,
        'monthNum': monthlyComparison.month,
        'departments': <Map<String, dynamic>>[],
      };

      monthlyComparison.departmentStats.forEach((dept, stat) {
        (monthData['departments'] as List<Map<String, dynamic>>).add({
          'department': stat.department,
          'employeeCount': stat.employeeCount,
          'averageSalary': stat.averageNetSalary,
          'totalSalary': stat.totalNetSalary,
        });
      });

      departmentDetailsPerMonth.add(monthData);
    }

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
    MultiMonthComparisonData comparisonData,
  ) {
    final List<Map<String, dynamic>> monthlySalaryRanges = [];

    for (var monthlyComparison in comparisonData.monthlyComparisons) {
      // 计算该月份的薪资区间分布
      final ranges = <String, int>{};
      monthlyComparison.departmentStats.forEach((dept, stat) {
        final salary = stat.averageNetSalary;
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
        ranges[range] = (ranges[range] ?? 0) + stat.employeeCount;
      });

      monthlySalaryRanges.add({
        'month': '${monthlyComparison.year}年${monthlyComparison.month}月',
        'year': monthlyComparison.year,
        'monthNum': monthlyComparison.month,
        'salaryRanges': ranges,
      });
    }

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
    MultiMonthComparisonData comparisonData,
  ) {
    final List<Map<String, dynamic>> monthlySalaryRankings = [];

    for (var monthlyComparison in comparisonData.monthlyComparisons) {
      // 按平均薪资排序
      final sortedDepts = <Map<String, dynamic>>[];
      monthlyComparison.departmentStats.forEach((dept, stat) {
        sortedDepts.add({
          'department': stat.department,
          'employeeCount': stat.employeeCount,
          'averageSalary': stat.averageNetSalary,
          'totalSalary': stat.totalNetSalary,
        });
      });

      sortedDepts.sort(
        (a, b) => (b['averageSalary'] as double).compareTo(
          a['averageSalary'] as double,
        ),
      );

      monthlySalaryRankings.add({
        'month': '${monthlyComparison.year}年${monthlyComparison.month}月',
        'year': monthlyComparison.year,
        'monthNum': monthlyComparison.month,
        'rankings': sortedDepts,
      });
    }

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
    MultiMonthComparisonData comparisonData,
  ) {
    if (comparisonData.monthlyComparisons.isEmpty) {
      return [];
    }

    // 获取最后一个月的数据
    final lastMonthData = comparisonData.monthlyComparisons.last;

    // 转换为图表所需格式
    final result = <Map<String, dynamic>>[];
    lastMonthData.departmentStats.forEach((dept, stat) {
      result.add({
        'department': stat.department,
        'employeeCount': stat.employeeCount,
        'averageSalary': stat.averageNetSalary,
        'totalSalary': stat.totalNetSalary,
      });
    });

    return result;
  }

  /// 计算部门人数变化情况
  Map<String, List<Map<String, dynamic>>> _calculateDepartmentChanges(
    MultiMonthComparisonData comparisonData,
  ) {
    final Map<String, List<Map<String, dynamic>>> departmentChanges = {};

    // 按时间顺序排列月份数据
    final sortedMonths =
        List<MonthlyComparisonData>.from(comparisonData.monthlyComparisons)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.month.compareTo(b.month);
          });

    // 遍历每个月份，比较与前一个月的部门人数变化
    for (int i = 0; i < sortedMonths.length; i++) {
      final currentMonth = sortedMonths[i];
      final monthKey =
          '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';

      if (!departmentChanges.containsKey(monthKey)) {
        departmentChanges[monthKey] = [];
      }

      // 如果不是第一个月份，比较与前一个月的变化
      if (i > 0) {
        final previousMonth = sortedMonths[i - 1];
        final currentDepartments = currentMonth.departmentStats;
        final previousDepartments = previousMonth.departmentStats;

        // 检查现有部门的人数变化
        currentDepartments.forEach((deptName, currentStat) {
          if (previousDepartments.containsKey(deptName)) {
            final previousStat = previousDepartments[deptName]!;
            final countChange =
                currentStat.employeeCount - previousStat.employeeCount;

            if (countChange != 0) {
              departmentChanges[monthKey]!.add({
                'department': deptName,
                'change': countChange,
                'type': 'change', // 人数变化
                'currentCount': currentStat.employeeCount,
                'previousCount': previousStat.employeeCount,
              });
            }
          } else {
            // 新增部门
            departmentChanges[monthKey]!.add({
              'department': deptName,
              'change': currentStat.employeeCount,
              'type': 'new', // 新增部门
              'currentCount': currentStat.employeeCount,
              'previousCount': 0,
            });
          }
        });

        // 检查消失的部门
        previousDepartments.forEach((deptName, previousStat) {
          if (!currentDepartments.containsKey(deptName)) {
            // 部门消失
            departmentChanges[monthKey]!.add({
              'department': deptName,
              'change': -previousStat.employeeCount,
              'type': 'removed', // 部门消失
              'currentCount': 0,
              'previousCount': previousStat.employeeCount,
            });
          }
        });
      } else {
        // 第一个月，记录所有部门为新增
        currentMonth.departmentStats.forEach((deptName, stat) {
          departmentChanges[monthKey]!.add({
            'department': deptName,
            'change': stat.employeeCount,
            'type': 'new', // 新增部门
            'currentCount': stat.employeeCount,
            'previousCount': 0,
          });
        });
      }
    }

    return departmentChanges;
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

  /// 构建部门人数变化说明
  Widget _buildDepartmentChanges() {
    final departmentChanges =
        _analysisData['departmentChanges']
            as Map<String, List<Map<String, dynamic>>>;

    // 检查是否有任何变化
    bool hasChanges = false;
    departmentChanges.forEach((month, changes) {
      if (changes.isNotEmpty) {
        hasChanges = true;
      }
    });

    if (!hasChanges) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '各部门人数在统计期间内无变化',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: departmentChanges.entries.map((entry) {
        final monthKey = entry.key;
        final changes = entry.value;

        if (changes.isEmpty) {
          return const SizedBox.shrink();
        }

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
                  '$year年$month月部门人数变化',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...changes.map<Widget>((change) {
                  final department = change['department'] as String;
                  final countChange = change['change'] as int;
                  final type = change['type'] as String;
                  final currentCount = change['currentCount'] as int;
                  final previousCount = change['previousCount'] as int;

                  String changeText;
                  Color changeColor;

                  if (type == 'new') {
                    changeText = '新增部门，当前人数：$currentCount';
                    changeColor = Colors.green;
                  } else if (type == 'removed') {
                    changeText = '部门消失，原有人数：$previousCount';
                    changeColor = Colors.red;
                  } else {
                    if (countChange > 0) {
                      changeText =
                          '人数增加 $countChange 人，从 $previousCount 人增加到 $currentCount 人';
                      changeColor = Colors.green;
                    } else {
                      changeText =
                          '人数减少 ${-countChange} 人，从 $previousCount 人减少到 $currentCount 人';
                      changeColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          type == 'new'
                              ? Icons.add_circle
                              : type == 'removed'
                              ? Icons.remove_circle
                              : countChange > 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: changeColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$department: $changeText',
                            style: TextStyle(color: changeColor),
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
}
