import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/pages/visualization/report/salary_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart'; // 添加截图导入
import 'package:salary_report/src/common/toast.dart'; // 添加Toast导入

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
  late Map<String, dynamic> _analysisData;
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  bool _isLoading = true;
  late DataAnalysisService _salaryDataService;
  List<DepartmentSalaryStats> _departmentStats = [];
  List<AttendanceStats> _attendanceStats = [];
  List<LeaveRatioStats> _leaveRatioStatsList = []; // 存储每个月的请假统计数据
  LeaveRatioStats? _quarterlyLeaveRatioStats; // 存储季度平均值
  List<Map<String, dynamic>> _monthlyData = []; // 存储每月数据用于图表展示
  List<SalaryRangeStats> _salaryRanges = []; // 薪资区间统计数据
  List<DepartmentSalaryRangeStats> _departmentSalaryRangeStats =
      []; // 部门薪资区间统计数据
  Map<String, dynamic>? _previousQuarterData; // 上一季度数据

  // 添加截图相关变量
  final GlobalKey repaintKey = GlobalKey();
  final ScrollController controller = ScrollController();
  late ScrollableStitcher screenshotUtil;

  @override
  void initState() {
    super.initState();
    _salaryDataService = DataAnalysisService(IsarDatabase());
    _initAnalysisData();
    // 初始化截图工具
    screenshotUtil = ScrollableStitcher(
      repaintBoundaryKey: repaintKey,
      scrollController: controller,
    );
  }

  @override
  void dispose() {
    controller.dispose(); // 释放滚动控制器
    super.dispose();
  }

  void _initAnalysisData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 计算当前季度的起始和结束月份
      final startMonth = (widget.quarter - 1) * 3 + 1;
      final endMonth = startMonth + 2;

      // 获取上一季度的数据
      await _fetchPreviousQuarterData();

      // 获取整个季度的部门统计数据
      final departmentStats = await _salaryDataService.getDepartmentAggregation(
        widget.year,
        startMonth, // 使用季度起始月份获取数据
        // 移除不存在的endMonth参数
      );

      // 获取考勤统计数据（获取季度内所有月份的考勤数据）
      final attendanceStats = <AttendanceStats>[];
      for (int month = startMonth; month <= endMonth; month++) {
        final monthAttendance = await _salaryDataService
            .getMonthlyAttendanceStats(year: widget.year, month: month);
        attendanceStats.addAll(monthAttendance);
      }

      // 获取请假比例统计数据（获取季度内所有月份的请假数据）
      final List<LeaveRatioStats> leaveRatioStatsList = [];
      for (int month = startMonth; month <= endMonth; month++) {
        final monthlyLeaveRatioStats = await _salaryDataService
            .getLeaveRatioStats(year: widget.year, month: month);
        // 只添加有有效数据的月份（总员工数大于0）
        if (monthlyLeaveRatioStats.totalEmployees > 0) {
          leaveRatioStatsList.add(monthlyLeaveRatioStats);
        }
      }

      // 合并所有月份的数据来计算季度平均值
      double totalSickLeaveRatio = 0;
      double totalLeaveRatio = 0;
      int totalEmployeeCount = 0;
      int validMonths = 0;

      for (var stats in leaveRatioStatsList) {
        // 只统计有有效数据的月份
        if (stats.totalEmployees > 0) {
          totalSickLeaveRatio += stats.sickLeaveRatio;
          totalLeaveRatio += stats.leaveRatio;
          totalEmployeeCount += stats.totalEmployees;
          validMonths++;
        }
      }

      final leaveRatioStats = LeaveRatioStats(
        sickLeaveRatio: validMonths > 0 ? totalSickLeaveRatio / validMonths : 0,
        leaveRatio: validMonths > 0 ? totalLeaveRatio / validMonths : 0,
        totalEmployees: validMonths > 0
            ? (totalEmployeeCount / validMonths).round()
            : 0,
        year: widget.year,
        month: startMonth,
      );

      // 获取每月详细数据用于图表展示和对比
      final monthlyData = <Map<String, dynamic>>[];
      final List<Map<String, dynamic>> departmentComparisonData = [];
      double totalSalary = 0;
      int totalEmployees = 0;
      double highestSalary = 0;
      double lowestSalary = double.infinity;

      for (int month = startMonth; month <= endMonth; month++) {
        // 获取每月的部门统计数据
        final monthlyDepartmentStats = await _salaryDataService
            .getDepartmentAggregation(widget.year, month);

        // 计算每月的关键指标
        double monthlyTotalSalary = 0;
        int monthlyTotalEmployees = 0;
        double monthlyHighestSalary = 0;
        double monthlyLowestSalary = double.infinity;

        for (var stat in monthlyDepartmentStats) {
          monthlyTotalSalary += stat.totalNetSalary;
          monthlyTotalEmployees += stat.employeeCount;

          if (stat.averageNetSalary > monthlyHighestSalary) {
            monthlyHighestSalary = stat.averageNetSalary;
          }

          if (stat.averageNetSalary < monthlyLowestSalary) {
            monthlyLowestSalary = stat.averageNetSalary;
          }
        }

        if (monthlyLowestSalary == double.infinity) {
          monthlyLowestSalary = 0;
        }

        double monthlyAverageSalary = monthlyTotalEmployees > 0
            ? monthlyTotalSalary / monthlyTotalEmployees
            : 0;

        monthlyData.add({
          'month': '$month月',
          'totalSalary': monthlyTotalSalary,
          'averageSalary': monthlyAverageSalary,
          'employeeCount': monthlyTotalEmployees,
          'highestSalary': monthlyHighestSalary,
          'lowestSalary': monthlyLowestSalary,
        });

        totalSalary += monthlyTotalSalary;
        totalEmployees += monthlyTotalEmployees;

        if (monthlyHighestSalary > highestSalary) {
          highestSalary = monthlyHighestSalary;
        }

        if (monthlyLowestSalary < lowestSalary) {
          lowestSalary = monthlyLowestSalary;
        }

        // 为每月的部门统计数据创建对比数据
        for (var stat in monthlyDepartmentStats) {
          departmentComparisonData.add({
            'year': widget.year,
            'month': month,
            'department': stat.department,
            'salary': stat.totalNetSalary,
            'average': stat.averageNetSalary,
            'employeeCount': stat.employeeCount,
          });
        }
      }

      if (lowestSalary == double.infinity) {
        lowestSalary = 0;
      }

      double averageSalary = totalEmployees > 0
          ? totalSalary / totalEmployees
          : 0;

      // 获取季度的薪资区间分布数据（获取每个月的数据）
      final List<SalaryRangeStats> salaryRanges = [];
      for (int month = startMonth; month <= endMonth; month++) {
        final monthlySalaryRanges = await _salaryDataService
            .getSalaryRangeAggregation(widget.year, month);
        salaryRanges.addAll(monthlySalaryRanges);
      }

      // 获取季度的部门和薪资范围联合统计数据（获取每个月的数据）
      final List<DepartmentSalaryRangeStats> departmentSalaryRangeStats = [];
      for (int month = startMonth; month <= endMonth; month++) {
        final monthlyDepartmentSalaryRangeStats = await _salaryDataService
            .getDepartmentSalaryRangeAggregation(widget.year, month);
        departmentSalaryRangeStats.addAll(monthlyDepartmentSalaryRangeStats);
      }

      // 更新本地状态
      setState(() {
        _departmentStats = departmentStats;
        _attendanceStats = attendanceStats;
        _leaveRatioStatsList = leaveRatioStatsList; // 存储每个月的请假统计数据
        _quarterlyLeaveRatioStats = leaveRatioStats; // 存储季度平均值
        _monthlyData = monthlyData;
        _salaryRanges = salaryRanges;
        _departmentSalaryRangeStats = departmentSalaryRangeStats;
      });

      setState(() {
        _analysisData = {
          'totalEmployees': totalEmployees,
          'totalSalary': totalSalary,
          'averageSalary': averageSalary,
          'highestSalary': highestSalary,
          'lowestSalary': lowestSalary,
          'monthlyBreakdown': monthlyData,
          'departmentComparison': departmentComparisonData,
          'salaryRanges': salaryRanges,
          'departmentSalaryRangeStats': departmentSalaryRangeStats,
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

  /// 获取上一季度的数据
  Future<void> _fetchPreviousQuarterData() async {
    try {
      // 计算上一季度的年份和季度
      int previousYear = widget.year;
      int previousQuarter = widget.quarter - 1;

      if (previousQuarter == 0) {
        // 如果是第一季度，上一季度就是去年的第四季度
        previousYear = widget.year - 1;
        previousQuarter = 4;
      }

      // 计算上一季度的起始月份
      final startMonth = (previousQuarter - 1) * 3 + 1;

      // 获取上一季度的部门统计数据
      final previousDepartmentStats = await _salaryDataService
          .getDepartmentAggregation(previousYear, startMonth);

      if (previousDepartmentStats.isNotEmpty) {
        // 计算上一季度的总员工数和总工资
        int totalEmployees = 0;
        double totalSalary = 0;

        for (var stat in previousDepartmentStats) {
          totalEmployees += stat.employeeCount;
          totalSalary += stat.totalNetSalary;
        }

        final averageSalary = totalEmployees > 0
            ? totalSalary / totalEmployees
            : 0;

        setState(() {
          _previousQuarterData = {
            'year': previousYear,
            'quarter': previousQuarter,
            'totalEmployees': totalEmployees,
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
          };
        });
      }
    } catch (e) {
      print('获取上一季度数据失败: $e');
      // 不处理错误，因为这是可选的数据显示
    }
  }

  /// 生成工资报告
  Future<void> _generateSalaryReport() async {
    try {
      setState(() {
        _isGeneratingReport = true;
      });

      // 确定开始和结束时间
      final startMonth = (widget.quarter - 1) * 3 + 1;
      final endMonth = startMonth + 2;
      final startTime = DateTime(widget.year, startMonth);
      final endTime = DateTime(widget.year, endMonth);

      final generator = SalaryReportGenerator();
      final reportPath = await generator.generateReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: _departmentStats,
        analysisData: _analysisData,
        endTime: endTime,
        year: widget.year,
        month: widget.quarter,
        isMultiMonth: false,
        startTime: startTime,
        reportType: ReportType.singleQuarter, // 明确指定报告类型为季度报告
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

  late ReportService reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.year}年第${widget.quarter}季度 工资分析')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final title = '${widget.year}年第${widget.quarter}季度 工资分析';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.screenshot_monitor),
            onPressed: () async {
              final file = await screenshotUtil.captureAndSave(
                filename: '${DateTime.now().millisecondsSinceEpoch}.png',
                fromTop: true, // 若希望从顶部开始截，true；否则从当前滚动开始
                overlap: 80.0, // dp 单位的重叠量
                waitForPaint: 300, // 每次滚动等待渲染时间（毫秒）
                cropLeft: 10,
                cropRight: 10,
                background: const Color.fromARGB(255, 147, 212, 243),
              );
              if (file != null) {
                ToastUtils.success(null, title: "长截图保存到: ${file.path}");
                reportService.addReportRecord(
                  file.path,
                  reportSaveFormat: ReportSaveFormat.image,
                );
                return;
              }
              ToastUtils.error(null, title: "长截图失败");
            },
            tooltip: '截图报告',
          ),
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
          RepaintBoundary(
            key: repaintKey,
            child: SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 上一季度数据展示（如果存在）
                    if (_previousQuarterData != null) ...[
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '上一季度对比  ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${_previousQuarterData!['year']}年第${_previousQuarterData!['quarter']}季度基本情况',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatCard(
                            '总人次',
                            _previousQuarterData!['totalEmployees'].toString(),
                            Icons.people,
                          ),
                          _buildStatCard(
                            '工资总额',
                            '¥${_previousQuarterData!['totalSalary'].toStringAsFixed(2)}',
                            Icons.account_balance_wallet,
                          ),
                          _buildStatCard(
                            '平均工资',
                            '¥${_previousQuarterData!['averageSalary'].toStringAsFixed(2)}',
                            Icons.trending_up,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 关键指标卡片
                    const Text(
                      '季度关键指标',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildStatCard(
                          '季度工资总额',
                          '¥${_analysisData['totalSalary'].toStringAsFixed(2)}',
                          Icons.account_balance_wallet,
                        ),
                        _buildStatCard(
                          '季度平均工资',
                          '¥${_analysisData['averageSalary'].toStringAsFixed(2)}',
                          Icons.trending_up,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 月度分解
                    const Text(
                      '月度分解',
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
                                    '月份',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '工资总额',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '平均工资',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '员工数',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            ..._analysisData['monthlyBreakdown'].map<Widget>((
                              data,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(data['month'])),
                                    Expanded(
                                      child: Text(
                                        '¥${data['totalSalary'].toStringAsFixed(2)}',
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '¥${data['averageSalary'].toStringAsFixed(2)}',
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data['employeeCount'].toString(),
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

                    // 月度工资趋势图表
                    const Text(
                      '月度工资趋势',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Container(
                        height: 300,
                        padding: const EdgeInsets.all(16.0),
                        child: MonthlySalaryTrendChart(
                          monthlyData: _monthlyData,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 部门对比
                    const Text(
                      '部门对比',
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
                                    '月份',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '部门',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '工资总额',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '平均工资',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '员工数',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            ..._analysisData['departmentComparison'].map<
                              Widget
                            >((dept) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${dept['year']}-${dept['month'].toString().padLeft(2, '0')}',
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(dept['department']),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '¥${dept['salary'].toStringAsFixed(2)}',
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '¥${dept['average'].toStringAsFixed(2)}',
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        dept['employeeCount'].toString(),
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
                                    '月份',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '薪资区间',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '人数',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '工资总额',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '平均工资',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                        Expanded(
                                          child: Text(
                                            '${range.year}-${range.month.toString().padLeft(2, '0')}',
                                          ),
                                        ),
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
                                }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 部门和薪资区间联合统计
                    const Text(
                      '各部门薪资区间分布',
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
                                    '月份',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '部门',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '薪资区间',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '人数',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '工资总额',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '平均工资',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                          child: Text(
                                            '${deptRange.year}-${deptRange.month.toString().padLeft(2, '0')}',
                                          ),
                                        ),
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
                                }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 考勤统计
                    const Text(
                      '考勤统计',
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
                            // 按月份分组显示考勤数据
                            ..._groupAttendanceStatsByMonth(
                              _attendanceStats,
                            ).entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key}月考勤统计',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AttendancePagination(
                                    attendanceStats: entry.value,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
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

  // 按月份分组考勤统计数据
  Map<int, List<AttendanceStats>> _groupAttendanceStatsByMonth(
    List<AttendanceStats> stats,
  ) {
    final grouped = <int, List<AttendanceStats>>{};

    for (var stat in stats) {
      if (stat.month != null) {
        final month = stat.month!;
        if (!grouped.containsKey(month)) {
          grouped[month] = [];
        }
        grouped[month]!.add(stat);
      }
    }

    return grouped;
  }

  // 构建请假比例统计的行数据
  List<Widget> _buildLeaveRatioStatsRows(LeaveRatioStats? leaveRatioStats) {
    if (leaveRatioStats == null) return [];

    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${leaveRatioStats.year ?? widget.year}-${leaveRatioStats.month.toString().padLeft(2, '0')}',
              ),
            ),
            const Expanded(child: Text('总员工数')),
            Expanded(child: Text(leaveRatioStats.totalEmployees.toString())),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${leaveRatioStats.year ?? widget.year}-${leaveRatioStats.month.toString().padLeft(2, '0')}',
              ),
            ),
            const Expanded(child: Text('平均病假天数/人')),
            Expanded(
              child: Text(leaveRatioStats.sickLeaveRatio.toStringAsFixed(2)),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${leaveRatioStats.year ?? widget.year}-${leaveRatioStats.month.toString().padLeft(2, '0')}',
              ),
            ),
            const Expanded(child: Text('平均事假天数/人')),
            Expanded(
              child: Text(leaveRatioStats.leaveRatio.toStringAsFixed(2)),
            ),
          ],
        ),
      ),
    ];
  }
}
