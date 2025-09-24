import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart';
import 'package:salary_report/src/providers/multi_month_trend_analysis_provider.dart';
import 'package:salary_report/src/components/multi_month/monthly_key_metrics_component.dart';
import 'package:salary_report/src/components/multi_month/monthly_department_stats_component.dart';
import 'package:salary_report/src/components/multi_month/monthly_attendance_stats_component.dart';
import 'package:salary_report/src/components/multi_month/department_changes_component.dart';
import 'package:salary_report/src/components/multi_month/department_position_trend_analysis_component.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart';
import 'package:salary_report/src/common/toast.dart';

// 简化状态管理，使用局部状态优化渲染性能
class MultiMonthAnalysisPage extends ConsumerStatefulWidget {
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
  ConsumerState<MultiMonthAnalysisPage> createState() =>
      _MultiMonthAnalysisPageState();
}

class _MultiMonthAnalysisPageState
    extends ConsumerState<MultiMonthAnalysisPage> {
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  late DateRangeParams _dateRangeParams;

  // 添加截图相关变量
  final GlobalKey repaintKey = GlobalKey();
  final ScrollController controller = ScrollController();
  late ScrollableStitcher screenshotUtil;

  @override
  void initState() {
    super.initState();
    _dateRangeParams = DateRangeParams(
      startYear: widget.year,
      startMonth: widget.month,
      endYear: widget.endYear,
      endMonth: widget.endMonth,
    );
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

  @override
  Widget build(BuildContext context) {
    // 创建用于趋势分析的参数
    final trendParams = DateRangeParams(
      startYear: widget.year,
      startMonth: widget.month,
      endYear: widget.endYear,
      endMonth: widget.endMonth,
    );

    final title =
        '${widget.year}年${widget.month.toString().padLeft(2, '0')}月 - '
        '${widget.endYear}年${widget.endMonth.toString().padLeft(2, '0')}月 工资分析';

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
                    // 每月关键指标（分页显示）
                    const Text(
                      '每月关键指标',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MonthlyKeyMetricsComponent(params: _dateRangeParams),

                    const SizedBox(height: 24),

                    // 每月部门统计（分页显示）
                    const Text(
                      '每月部门统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MonthlyDepartmentStatsComponent(params: _dateRangeParams),

                    const SizedBox(height: 24),

                    // 部门人数变化说明
                    const Text(
                      '部门人数变化说明',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DepartmentChangesComponent(params: _dateRangeParams),

                    const SizedBox(height: 24),

                    // 每月考勤统计（分页显示）
                    const Text(
                      '每月考勤统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MonthlyAttendanceStatsComponent(params: _dateRangeParams),

                    const SizedBox(height: 24),

                    // // 每月请假比例统计（分页显示）
                    // const Text(
                    //   '每月请假比例统计',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                    // MonthlyLeaveRatioStatsComponent(params: _dateRangeParams),
                    // const SizedBox(height: 24),

                    // 每月人数变化趋势图
                    const Text(
                      '每月人数变化趋势',
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
                        child: MonthlyEmployeeCountChartComponent(
                          params: _dateRangeParams,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 每月平均薪资变化趋势图
                    const Text(
                      '每月平均薪资变化趋势',
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
                        child: MonthlyAverageSalaryChartComponent(
                          params: _dateRangeParams,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 每月总工资变化趋势图
                    const Text(
                      '每月总工资变化趋势',
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
                        child: MonthlyTotalSalaryChartComponent(
                          params: _dateRangeParams,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 各部门平均薪资趋势图
                    const Text(
                      '各部门平均薪资趋势',
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
                        child: MultiMonthDepartmentSalaryChartComponent(
                          params: _dateRangeParams,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 部门和岗位趋势分析（新增）
                    const Text(
                      '部门和岗位趋势分析',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DepartmentPositionTrendAnalysisComponent(
                      params: trendParams,
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

  /// 生成工资报告
  Future<void> _generateSalaryReport() async {
    try {
      setState(() {
        _isGeneratingReport = true;
      });

      // 确定开始和结束时间
      final startTime = DateTime(widget.year, widget.month);
      final endTime = DateTime(widget.endYear, widget.endMonth);

      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.multiMonth,
      );

      // 获取分析数据
      final keyMetricsState = ref.read(keyMetricsProvider(_dateRangeParams));
      final departmentStatsState = ref.read(
        departmentStatsProvider(_dateRangeParams),
      );
      final attendanceStatsState = ref.read(
        attendanceStatsProvider(_dateRangeParams),
      );
      final leaveRatioStatsState = ref.read(
        leaveRatioStatsProvider(_dateRangeParams),
      );
      final departmentChangesState = ref.read(
        departmentChangesProvider(_dateRangeParams),
      );
      final chartDataState = ref.read(chartDataProvider(_dateRangeParams));

      // 创建用于趋势分析的参数
      final trendParams = DateRangeParams(
        startYear: widget.year,
        startMonth: widget.month,
        endYear: widget.endYear,
        endMonth: widget.endMonth,
      );
      final trendAnalysisState = ref.read(
        trendAnalysisProvider(trendParams),
      ); // 添加趋势分析数据

      // 获取部门统计数据
      List<DepartmentSalaryStats> departmentStats = [];
      if (departmentStatsState is AsyncData &&
          departmentStatsState.value?.monthlyData != null) {
        // 合并所有月份的部门统计数据
        final departmentStatsMap = <String, DepartmentSalaryStats>{};

        for (var monthlyData in departmentStatsState.value!.monthlyData!) {
          monthlyData.departmentStats.forEach((deptName, stat) {
            if (departmentStatsMap.containsKey(deptName)) {
              final existingStat = departmentStatsMap[deptName]!;
              departmentStatsMap[deptName] = DepartmentSalaryStats(
                department: deptName,
                employeeCount: existingStat.employeeCount + stat.employeeCount,
                totalNetSalary:
                    existingStat.totalNetSalary + stat.totalNetSalary,
                averageNetSalary:
                    (existingStat.totalNetSalary + stat.totalNetSalary) /
                    (existingStat.employeeCount + stat.employeeCount),
                year: stat.year,
                month: stat.month,
                maxSalary: stat.maxSalary > existingStat.maxSalary
                    ? stat.maxSalary
                    : existingStat.maxSalary,
                minSalary: stat.minSalary < existingStat.minSalary
                    ? stat.minSalary
                    : existingStat.minSalary,
              );
            } else {
              departmentStatsMap[deptName] = stat;
            }
          });
        }

        departmentStats = departmentStatsMap.values.toList();
      }

      // 获取考勤统计数据
      List<AttendanceStats> attendanceStats = [];
      if (attendanceStatsState is AsyncData &&
          attendanceStatsState.value?.attendanceData != null) {
        // 合并所有月份的考勤统计数据
        attendanceStatsState.value!.attendanceData!.forEach((month, stats) {
          attendanceStats.addAll(stats);
        });
      }

      final analysisData = _prepareAnalysisData(
        keyMetricsState,
        departmentStatsState,
        attendanceStatsState,
        leaveRatioStatsState,
        departmentChangesState,
        chartDataState,
      );

      logger.info('analysisData     $analysisData');

      // 准备同比环比分析数据
      List<Map<String, dynamic>> departmentMonthOverMonthData = [];
      List<Map<String, dynamic>> departmentYearOverYearData = [];
      List<Map<String, dynamic>> positionMonthOverMonthData = [];
      List<Map<String, dynamic>> positionYearOverYearData = [];

      if (trendAnalysisState is AsyncData && trendAnalysisState.value != null) {
        departmentMonthOverMonthData =
            trendAnalysisState.value!.departmentMonthOverMonthData;
        departmentYearOverYearData =
            trendAnalysisState.value!.departmentYearOverYearData;
        positionMonthOverMonthData =
            trendAnalysisState.value!.positionMonthOverMonthData;
        positionYearOverYearData =
            trendAnalysisState.value!.positionYearOverYearData;
      }

      // 将同比环比数据添加到analysisData中
      analysisData['departmentMonthOverMonthData'] =
          departmentMonthOverMonthData;
      analysisData['departmentYearOverYearData'] = departmentYearOverYearData;
      analysisData['positionMonthOverMonthData'] = positionMonthOverMonthData;
      analysisData['positionYearOverYearData'] = positionYearOverYearData;

      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: departmentStats,
        analysisData: analysisData,
        attendanceStats: attendanceStats,
        previousMonthData: null, // 多月报告不需要上月数据
        year: widget.year,
        month: widget.month,
        isMultiMonth: true,
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
    }
  }

  /// 准备分析数据用于报告生成
  Map<String, dynamic> _prepareAnalysisData(
    AsyncValue<KeyMetricsState> keyMetricsState,
    AsyncValue<DepartmentStatsState> departmentStatsState,
    AsyncValue<AttendanceStatsState> attendanceStatsState,
    AsyncValue<LeaveRatioStatsState> leaveRatioStatsState,
    AsyncValue<DepartmentChangesState> departmentChangesState,
    AsyncValue<ChartDataState> chartDataState,
  ) {
    // 保存每月的详细数据而不是聚合数据
    final List<Map<String, dynamic>> monthlyDataList = [];

    // 从关键指标状态中获取数据
    if (keyMetricsState is AsyncData &&
        keyMetricsState.value?.monthlyData != null) {
      // 按时间排序月度数据
      final sortedMonthlyData =
          List<MonthlyComparisonData>.from(keyMetricsState.value!.monthlyData!)
            ..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

      for (var monthlyData in sortedMonthlyData) {
        // 为每个月份创建详细数据记录
        monthlyDataList.add({
          'year': monthlyData.year,
          'month': monthlyData.month,
          'employeeCount': monthlyData.employeeCount,
          'totalSalary': monthlyData.totalSalary,
          'averageSalary': monthlyData.averageSalary,
          'highestSalary': monthlyData.highestSalary,
          'lowestSalary': monthlyData.lowestSalary,
          'salaryRangeStats': monthlyData.salaryRangeStats,
          'departmentStats': monthlyData.departmentStats,
          'workers': monthlyData.workers,
        });
      }
    }

    // 获取部门统计数据（保留每月详细数据）
    List<Map<String, dynamic>> departmentStatsPerMonth = [];
    if (departmentStatsState is AsyncData &&
        departmentStatsState.value?.monthlyData != null) {
      // 按时间排序月度数据
      final sortedMonthlyData =
          List<MonthlyComparisonData>.from(
            departmentStatsState.value!.monthlyData!,
          )..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.month.compareTo(b.month);
          });

      for (var monthlyData in sortedMonthlyData) {
        final departmentData = <Map<String, dynamic>>[];
        monthlyData.departmentStats.forEach((deptName, stat) {
          departmentData.add({
            'department': stat.department,
            'employeeCount': stat.employeeCount,
            'totalNetSalary': stat.totalNetSalary,
            'averageNetSalary': stat.averageNetSalary,
            'year': stat.year,
            'month': stat.month,
            'maxSalary': stat.maxSalary,
            'minSalary': stat.minSalary,
          });
        });

        departmentStatsPerMonth.add({
          'year': monthlyData.year,
          'month': monthlyData.month,
          'departmentStats': departmentData,
        });
      }
    }

    // 获取薪资区间统计数据（保留每月详细数据）
    List<Map<String, dynamic>> salaryRangesPerMonth = [];
    if (keyMetricsState is AsyncData &&
        keyMetricsState.value?.monthlyData != null) {
      // 按时间排序月度数据
      final sortedMonthlyData =
          List<MonthlyComparisonData>.from(keyMetricsState.value!.monthlyData!)
            ..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

      for (var monthlyData in sortedMonthlyData) {
        final salaryRangeData = <Map<String, dynamic>>[];
        monthlyData.salaryRangeStats.forEach((rangeName, stat) {
          salaryRangeData.add({
            'range': stat.range,
            'employeeCount': stat.employeeCount,
            'totalSalary': stat.totalSalary,
            'averageSalary': stat.averageSalary,
            'year': stat.year,
            'month': stat.month,
          });
        });

        salaryRangesPerMonth.add({
          'year': monthlyData.year,
          'month': monthlyData.month,
          'salaryRanges': salaryRangeData,
        });
      }
    }

    // 获取考勤统计数据（保留每月详细数据）
    List<Map<String, dynamic>> attendanceStatsPerMonth = [];
    if (attendanceStatsState is AsyncData &&
        attendanceStatsState.value?.attendanceData != null) {
      // 获取所有月份并按时间排序
      final months = attendanceStatsState.value!.attendanceData!.keys.toList()
        ..sort((a, b) {
          final dateA = DateTime.parse("$a-01");
          final dateB = DateTime.parse("$b-01");
          return dateA.compareTo(dateB);
        });

      for (var monthKey in months) {
        final stats = attendanceStatsState.value!.attendanceData![monthKey]!;
        logger.info('获取考勤数据: $monthKey');
        final date = DateTime.parse('$monthKey-01');

        final attendanceData = <Map<String, dynamic>>[];
        for (var stat in stats) {
          attendanceData.add({
            'name': stat.name,
            'department': stat.department,
            'sickLeaveDays': stat.sickLeaveDays,
            'leaveDays': stat.leaveDays,
            'absenceCount': stat.absenceCount,
            'truancyDays': stat.truancyDays,
            'year': stat.year,
            'month': stat.month,
          });
        }

        attendanceStatsPerMonth.add({
          'year': date.year,
          'month': date.month,
          'attendanceStats': attendanceData,
        });
      }
    }

    return {
      'monthlyData': monthlyDataList, // 保存每月详细数据
      'departmentStatsPerMonth': departmentStatsPerMonth, // 保存每月部门统计数据
      'salaryRangesPerMonth': salaryRangesPerMonth, // 保存每月薪资区间统计数据
      'attendanceStatsPerMonth': attendanceStatsPerMonth, // 保存每月考勤统计数据
    };
  }

  late ReportService reportService = ReportService();
}

// 每月人数变化趋势图组件
class MonthlyEmployeeCountChartComponent extends ConsumerWidget {
  final DateRangeParams params;

  const MonthlyEmployeeCountChartComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        final List<Map<String, dynamic>> employeeCountPerMonth = [];

        // 按时间排序月度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        for (var monthlyComparison in sortedMonthlyData) {
          // 月度数据没有去重概念，直接使用employeeCount作为总人次
          int totalEmployees = monthlyComparison.employeeCount;

          employeeCountPerMonth.add({
            'month': '${monthlyComparison.year}年${monthlyComparison.month}月',
            'year': monthlyComparison.year,
            'monthNum': monthlyComparison.month,
            'employeeCount': totalEmployees,
          });
        }

        // 按时间排序
        employeeCountPerMonth.sort((a, b) {
          if (a['year'] != b['year']) {
            return (a['year'] as int).compareTo(b['year'] as int);
          }
          return (a['monthNum'] as int).compareTo(b['monthNum'] as int);
        });

        return MonthlyEmployeeCountChart(monthlyData: employeeCountPerMonth);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}

// 每月平均薪资变化趋势图组件
class MonthlyAverageSalaryChartComponent extends ConsumerWidget {
  final DateRangeParams params;

  const MonthlyAverageSalaryChartComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        List<Map<String, dynamic>> averageSalaryPerMonth = [];

        // 按时间排序月度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        for (var monthlyComparison in sortedMonthlyData) {
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

        logger.info('averageSalaryPerMonth: $averageSalaryPerMonth');

        return MonthlyAverageSalaryChart(monthlyData: averageSalaryPerMonth);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}

// 每月总工资变化趋势图组件
class MonthlyTotalSalaryChartComponent extends ConsumerWidget {
  final DateRangeParams params;

  const MonthlyTotalSalaryChartComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        final List<Map<String, dynamic>> totalSalaryPerMonth = [];

        // 按时间排序月度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        for (var monthlyComparison in sortedMonthlyData) {
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

        return MonthlyTotalSalaryChart(monthlyData: totalSalaryPerMonth);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}

// 各部门平均薪资趋势图组件
class MultiMonthDepartmentSalaryChartComponent extends ConsumerWidget {
  final DateRangeParams params;

  const MultiMonthDepartmentSalaryChartComponent({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        final List<Map<String, dynamic>> result = [];

        // 按时间排序月度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        for (var monthlyData in sortedMonthlyData) {
          final monthLabel = '${monthlyData.year}年${monthlyData.month}月';

          // 构建部门数据映射
          final departmentData = <String, double>{};
          monthlyData.departmentStats.forEach((deptName, stat) {
            // 确保使用正确的部门统计数据
            departmentData[deptName] = stat.averageNetSalary;
          });

          result.add({'month': monthLabel, 'departments': departmentData});
        }

        logger.info('MultiMonthDepartmentSalaryChartComponent: $result');

        return MultiMonthDepartmentSalaryChart(departmentMonthlyData: result);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}
