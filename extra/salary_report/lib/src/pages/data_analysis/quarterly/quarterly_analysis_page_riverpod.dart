import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/components/monthly_employee_changes_component.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';

import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/services/enhanced_report_generator_factory.dart';
import 'package:salary_report/src/services/report_types.dart';
import 'package:salary_report/src/services/quarterly/enhanced_quarterly_report_generator.dart';
import 'package:salary_report/src/rust/api/simple.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart';
import 'package:salary_report/src/common/toast.dart';
import 'package:salary_report/src/components/single_quarter/quarterly_department_stats_component.dart';
import 'package:salary_report/src/providers/quarterly_analysis_provider.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart'
    as multi_month;
import 'package:salary_report/src/services/global_analysis_models.dart';

class QuarterlyAnalysisPageRiverpod extends ConsumerStatefulWidget {
  const QuarterlyAnalysisPageRiverpod({
    super.key,
    required this.year,
    required this.quarter,
  });

  final int year;
  final int quarter;

  @override
  ConsumerState<QuarterlyAnalysisPageRiverpod> createState() =>
      _QuarterlyAnalysisPageRiverpodState();
}

class _QuarterlyAnalysisPageRiverpodState
    extends ConsumerState<QuarterlyAnalysisPageRiverpod> {
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  late QuarterParams _quarterParams;

  // 添加截图相关变量
  final GlobalKey repaintKey = GlobalKey();
  final ScrollController controller = ScrollController();
  late ScrollableStitcher screenshotUtil;

  @override
  void initState() {
    super.initState();
    _quarterParams = QuarterParams(year: widget.year, quarter: widget.quarter);
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

  /// 生成工资报告 - 使用统一的多期间报告生成器
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

      // 使用统一的季度报告生成器
      final generator = EnhancedQuarterlyReportGenerator();

      // 基础分析数据，让生成器自己处理数据聚合
      final analysisData = <String, dynamic>{
        'reportType': 'quarterly',
        'periodInfo': {'year': widget.year, 'quarter': widget.quarter},
      };

      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: [],
        analysisData: analysisData,
        attendanceStats: [],
        previousMonthData: null,
        year: widget.year,
        month: widget.quarter,
        isMultiMonth: false,
        startTime: startTime,
        endTime: endTime,
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
    } catch (e, s) {
      logger.severe("生成报告时发生错误 $s");

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
      beep();
    }
  }

  late ReportService reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    final keyMetricsState = ref.watch(keyMetricsProvider(_quarterParams));
    final previousQuarterState = ref.watch(
      previousQuarterStateProvider(_quarterParams),
    );
    final employeeChangesState = ref.watch(
      employeeChangesProvider(_quarterParams),
    );
    final departmentStatsState = ref.watch(
      departmentStatsProvider(_quarterParams),
    );
    final attendanceStatsState = ref.watch(
      attendanceStatsProvider(_quarterParams),
    );

    // 检查是否所有数据都已加载完成
    final bool isLoading =
        keyMetricsState is AsyncLoading ||
        previousQuarterState is AsyncLoading ||
        employeeChangesState is AsyncLoading ||
        departmentStatsState is AsyncLoading ||
        attendanceStatsState is AsyncLoading;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.year}年第${widget.quarter}季度 工资分析')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 检查是否有错误
    final bool hasError =
        keyMetricsState is AsyncError ||
        previousQuarterState is AsyncError ||
        employeeChangesState is AsyncError ||
        departmentStatsState is AsyncError ||
        attendanceStatsState is AsyncError;

    if (hasError) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.year}年第${widget.quarter}季度 工资分析')),
        body: Center(
          child: Text('加载数据时发生错误，请重试', style: TextStyle(color: Colors.red)),
        ),
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
          SizedBox(width: 8),
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
                    _buildPreviousQuarterSection(previousQuarterState),

                    // 关键指标卡片
                    _buildKeyMetricsSection(keyMetricsState),

                    const SizedBox(height: 24),

                    // 每月员工变动情况
                    _buildEmployeeChangesSection(employeeChangesState),

                    const SizedBox(height: 24),

                    // 月度分解
                    _buildMonthlyBreakdownSection(keyMetricsState),

                    const SizedBox(height: 24),

                    // 月度工资趋势图表
                    _buildMonthlySalaryTrendSection(keyMetricsState),

                    const SizedBox(height: 24),

                    // 季度部门统计
                    _buildDepartmentStatsSection(departmentStatsState),

                    const SizedBox(height: 24),

                    // 考勤统计
                    _buildAttendanceStatsSection(attendanceStatsState),
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

  bool allIsZero(Map<String, dynamic> data) {
    return data.entries.any(
      (entry) => entry.key != "quarter" && entry.value != 0,
    );
  }

  // 构建上一季度数据部分
  Widget _buildPreviousQuarterSection(
    AsyncValue<PreviousQuarterState> previousQuarterState,
  ) {
    return previousQuarterState.when(
      data: (state) {
        logger.info("lastQuarterData  ${state.previousQuarterData}");
        if (state.previousQuarterData == null ||
            allIsZero(state.previousQuarterData!)) {
          return const SizedBox.shrink(); // 如果没有上一季度数据，不显示任何内容
        }

        final previousQuarterData = state.previousQuarterData!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '上一季度对比  ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        '${previousQuarterData['year']}年第${previousQuarterData['quarter']}季度基本情况',
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
                  previousQuarterData['totalEmployees'].toString(),
                  Icons.people,
                ),
                _buildStatCard(
                  '总人数',
                  previousQuarterData['totalUniqueEmployees'].toString(),
                  Icons.group,
                ),
                _buildStatCard(
                  '工资总额',
                  '${previousQuarterData['totalSalary'].toStringAsFixed(2)}元',
                  Icons.account_balance_wallet,
                ),
                _buildStatCard(
                  '平均工资',
                  '${previousQuarterData['averageSalary'].toStringAsFixed(2)}元',
                  Icons.trending_up,
                ),
                _buildStatCard(
                  '最高工资',
                  '${previousQuarterData['highestSalary'].toStringAsFixed(2)}元',
                  Icons.arrow_upward,
                ),
                _buildStatCard(
                  '最低工资',
                  '${previousQuarterData['lowestSalary'].toStringAsFixed(2)}元',
                  Icons.arrow_downward,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, stackTrace) => const SizedBox.shrink(),
    );
  }

  // 构建关键指标部分
  Widget _buildKeyMetricsSection(
    AsyncValue<multi_month.KeyMetricsState> keyMetricsState,
  ) {
    return keyMetricsState.when(
      data: (state) {
        if (state is! QuarterlyKeyMetricsState || (state).quarterData == null) {
          return const Center(child: Text('暂无关键指标数据'));
        }

        final quarterData = (state).quarterData!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  '总人次',
                  quarterData['totalEmployees'].toString(),
                  Icons.people,
                ),
                _buildStatCard(
                  '总人数',
                  quarterData['totalUniqueEmployees'].toString(),
                  Icons.group,
                ),
                _buildStatCard(
                  '季度工资总额',
                  '${quarterData['totalSalary'].toStringAsFixed(2)}元',
                  Icons.account_balance_wallet,
                ),
                _buildStatCard(
                  '季度平均工资',
                  '${quarterData['averageSalary'].toStringAsFixed(2)}元',
                  Icons.trending_up,
                ),
                _buildStatCard(
                  '最高工资',
                  '${quarterData['highestSalary'].toStringAsFixed(2)}元',
                  Icons.arrow_upward,
                ),
                _buildStatCard(
                  '最低工资',
                  '${quarterData['lowestSalary'].toStringAsFixed(2)}元',
                  Icons.arrow_downward,
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载关键指标失败: $error')),
    );
  }

  // 构建员工变动部分
  Widget _buildEmployeeChangesSection(
    AsyncValue<multi_month.DepartmentChangesState> employeeChangesState,
  ) {
    return employeeChangesState.when(
      data: (state) {
        if (state.comparisonData?.monthlyComparisons == null ||
            state.comparisonData!.monthlyComparisons.isEmpty) {
          return const Center(child: Text('暂无员工变动数据'));
        }

        // 转换数据格式为组件需要的格式
        final monthlyChanges = <Map<String, dynamic>>[];
        final comparisons = state.comparisonData!.monthlyComparisons;
        for (int i = 1; i < comparisons.length; i++) {
          final prev = comparisons[i - 1];
          final curr = comparisons[i];
          // 假设 prev.employees 和 curr.employees 是 List<MinimalEmployeeInfo>
          final prevEmployees = prev.workers;
          final currEmployees = curr.workers;
          final newEmployees = currEmployees
              .where(
                (e) => !prevEmployees.any(
                  (p) => p.name == e.name && p.department == e.department,
                ),
              )
              .toList();
          final resignedEmployees = prevEmployees
              .where(
                (p) => !currEmployees.any(
                  (e) => e.name == p.name && e.department == p.department,
                ),
              )
              .toList();
          final netChange = currEmployees.length - prevEmployees.length;
          monthlyChanges.add({
            'month': curr.month,
            'employeeCount': curr.employeeCount,
            'newEmployees': newEmployees,
            'resignedEmployees': resignedEmployees,
            'netChange': netChange,
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '每月员工变动情况',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            MonthlyEmployeeChangesComponent(monthlyChanges: monthlyChanges),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载员工变动数据失败: $error')),
    );
  }

  // 构建月度分解部分
  Widget _buildMonthlyBreakdownSection(
    AsyncValue<multi_month.KeyMetricsState> keyMetricsState,
  ) {
    return keyMetricsState.when(
      data: (state) {
        if (state.monthlyData == null || state.monthlyData!.isEmpty) {
          return const Center(child: Text('暂无月度分解数据'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            '平均工资',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '员工数',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...state.monthlyData!.map<Widget>((data) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: Text('${data.month}月')),
                            Expanded(
                              child: Text(
                                '${data.totalSalary.toStringAsFixed(2)}元',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${data.averageSalary.toStringAsFixed(2)}元',
                              ),
                            ),
                            Expanded(
                              child: Text(data.employeeCount.toString()),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载月度分解数据失败: $error')),
    );
  }

  // 构建月度工资趋势图表部分
  Widget _buildMonthlySalaryTrendSection(
    AsyncValue<multi_month.KeyMetricsState> keyMetricsState,
  ) {
    return keyMetricsState.when(
      data: (state) {
        if (state.monthlyData == null || state.monthlyData!.isEmpty) {
          return const Center(child: Text('暂无月度趋势数据'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '月度工资趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(16.0),
                child: MonthlySalaryTrendChart(
                  monthlyData: state.monthlyData!
                      .map(
                        (month) => {
                          'month': month.month,
                          'monthLabel': '${month.month}月',
                          'totalSalary': month.totalSalary,
                          'averageSalary': month.averageSalary,
                          'employeeCount': month.employeeCount,
                          'highestSalary': month.highestSalary,
                          'lowestSalary': month.lowestSalary,
                        },
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载月度趋势数据失败: $error')),
    );
  }

  // 构建部门统计部分
  Widget _buildDepartmentStatsSection(
    AsyncValue<multi_month.DepartmentStatsState> departmentStatsState,
  ) {
    return departmentStatsState.when(
      data: (state) {
        if (state.monthlyData == null || state.monthlyData!.isEmpty) {
          return const Center(child: Text('暂无部门统计数据'));
        }

        // 从月度数据中提取部门统计
        final departmentStats = state.monthlyData!
            .expand((month) => month.departmentStats.values)
            .toList();

        return QuarterlyDepartmentStatsCard(
          year: widget.year,
          quarter: widget.quarter,
          departmentStats: departmentStats,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载部门统计数据失败: $error')),
    );
  }

  // 构建考勤统计部分
  Widget _buildAttendanceStatsSection(
    AsyncValue<multi_month.AttendanceStatsState> attendanceStatsState,
  ) {
    return attendanceStatsState.when(
      data: (state) {
        if (state.attendanceData == null || state.attendanceData!.isEmpty) {
          return const Center(child: Text('暂无考勤统计数据'));
        }

        // 按月份分组显示考勤数据
        final groupedAttendanceStats = state.attendanceData!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    // 按月份分组显示考勤数据
                    ...groupedAttendanceStats.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key}考勤统计',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AttendancePagination(attendanceStats: entry.value),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载考勤统计数据失败: $error')),
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
