import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/pages/visualization/report/salary_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/providers/year_analysis_provider.dart';
import 'package:salary_report/src/components/multi_year/yearly_key_metrics_component.dart';
import 'package:salary_report/src/components/multi_year/yearly_department_stats_component.dart';
import 'package:salary_report/src/components/multi_year/yearly_attendance_stats_component.dart';
import 'package:salary_report/src/components/multi_year/yearly_leave_ratio_stats_component.dart';
import 'package:salary_report/src/components/multi_year/department_changes_component.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart'; // 添加截图导入
import 'package:salary_report/src/common/toast.dart'; // 添加Toast导入

// 多年分析页面
class MultiYearAnalysisPage extends ConsumerStatefulWidget {
  const MultiYearAnalysisPage({
    super.key,
    required this.year,
    required this.endYear,
  });

  final int year;
  final int endYear;

  @override
  ConsumerState<MultiYearAnalysisPage> createState() =>
      _MultiYearAnalysisPageState();
}

class _MultiYearAnalysisPageState extends ConsumerState<MultiYearAnalysisPage> {
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  late YearRangeParams _yearRangeParams;

  // 添加截图相关变量
  final GlobalKey repaintKey = GlobalKey();
  final ScrollController controller = ScrollController();
  late ScrollableStitcher screenshotUtil;

  @override
  void initState() {
    super.initState();
    _yearRangeParams = YearRangeParams(
      startYear: widget.year,
      endYear: widget.endYear,
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

  /// 生成工资报告
  Future<void> _generateSalaryReport() async {
    try {
      setState(() {
        _isGeneratingReport = true;
      });

      // 确定开始和结束时间
      final startTime = DateTime(widget.year);
      final endTime = DateTime(widget.endYear);

      final generator = SalaryReportGenerator();

      // 获取分析数据
      final keyMetricsState = ref.read(keyMetricsProvider(_yearRangeParams));
      final departmentStatsState = ref.read(
        departmentStatsProvider(_yearRangeParams),
      );
      final attendanceStatsState = ref.read(
        attendanceStatsProvider(_yearRangeParams),
      );
      final leaveRatioStatsState = ref.read(
        leaveRatioStatsProvider(_yearRangeParams),
      );
      final departmentChangesState = ref.read(
        departmentChangesProvider(_yearRangeParams),
      );
      final chartDataState = ref.read(chartDataProvider(_yearRangeParams));

      final analysisData = _prepareAnalysisData(
        keyMetricsState,
        departmentStatsState,
        attendanceStatsState,
        leaveRatioStatsState,
        departmentChangesState,
        chartDataState,
      );

      final reportPath = await generator.generateReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: [],
        analysisData: analysisData,
        endTime: endTime,
        year: widget.year,
        month: 0, // 年度报告没有月份
        isMultiMonth: true,
        startTime: startTime,
        reportType: ReportType.multiYear, // 明确指定报告类型
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

  /// 准备分析数据用于报告生成
  Map<String, dynamic> _prepareAnalysisData(
    AsyncValue<KeyMetricsState> keyMetricsState,
    AsyncValue<DepartmentStatsState> departmentStatsState,
    AsyncValue<AttendanceStatsState> attendanceStatsState,
    AsyncValue<LeaveRatioStatsState> leaveRatioStatsState,
    AsyncValue<DepartmentChangesState> departmentChangesState,
    AsyncValue<ChartDataState> chartDataState,
  ) {
    // 计算整体统计数据
    int totalEmployees = 0; // 总人次（不去重）
    int totalUniqueEmployees = 0; // 总人数（去重）
    double totalSalary = 0;
    double highestSalary = 0;
    double lowestSalary = double.infinity;

    // 从关键指标状态中获取数据
    if (keyMetricsState is AsyncData &&
        keyMetricsState.value?.yearlyData != null) {
      for (var yearlyData in keyMetricsState.value!.yearlyData!) {
        totalEmployees += yearlyData.employeeCount;
        totalSalary += yearlyData.totalSalary;
        // 累加去重后的员工数
        totalUniqueEmployees += yearlyData.totalEmployeeCount;

        yearlyData.departmentStats.forEach((dept, stat) {
          if (stat.averageNetSalary > highestSalary) {
            highestSalary = stat.averageNetSalary;
          }

          if (stat.averageNetSalary < lowestSalary) {
            lowestSalary = stat.averageNetSalary;
          }
        });
      }
    }

    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }

    final averageSalary = totalEmployees > 0 ? totalSalary / totalEmployees : 0;

    return {
      'totalEmployees': totalEmployees, // 总人次
      'totalUniqueEmployees': totalUniqueEmployees, // 总人数（去重）
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
    };
  }

  late ReportService reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    final title = '${widget.year}年 - ${widget.endYear}年 工资分析';

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
                    // 分页控制
                    _buildPaginationControls(),

                    const SizedBox(height: 24),

                    // 每年关键指标（分页显示）
                    const Text(
                      '每年关键指标',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    YearlyKeyMetricsComponent(params: _yearRangeParams),

                    const SizedBox(height: 24),

                    // 每年部门统计（分页显示）
                    const Text(
                      '每年部门统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    YearlyDepartmentStatsComponent(params: _yearRangeParams),

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
                    YearlyDepartmentChangesComponent(params: _yearRangeParams),

                    const SizedBox(height: 24),

                    // 每年考勤统计（分页显示）
                    const Text(
                      '每年考勤统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    YearlyAttendanceStatsComponent(params: _yearRangeParams),

                    const SizedBox(height: 24),

                    // 每年请假比例统计（分页显示）
                    const Text(
                      '每年请假比例统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    YearlyLeaveRatioStatsComponent(params: _yearRangeParams),

                    const SizedBox(height: 24),

                    // 每年人数变化趋势图
                    const Text(
                      '每年人数变化趋势',
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
                        child: YearlyEmployeeCountChartComponent(
                          params: _yearRangeParams,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 每年平均薪资变化趋势图
                    const Text(
                      '每年平均薪资变化趋势',
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
                        child: YearlyAverageSalaryChartComponent(
                          params: _yearRangeParams,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 每年总工资变化趋势图
                    const Text(
                      '每年总工资变化趋势',
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
                        child: YearlyTotalSalaryChartComponent(
                          params: _yearRangeParams,
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
                        child: MultiYearDepartmentSalaryChartComponent(
                          params: _yearRangeParams,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 分页控制
                    _buildPaginationControls(),
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

  /// 构建分页控制组件
  Widget _buildPaginationControls() {
    final keyMetricsState = ref.watch(keyMetricsProvider(_yearRangeParams));
    final paginationState = ref.watch(paginationProvider);

    return keyMetricsState.when(
      data: (keyMetrics) {
        if (keyMetrics.yearlyData == null) {
          return const SizedBox.shrink();
        }

        final totalYears = keyMetrics.yearlyData!.length;
        final totalPages = (totalYears / paginationState.itemsPerPage).ceil();

        if (totalPages <= 1) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: paginationState.currentPage > 0
                  ? () => ref.read(paginationProvider.notifier).previousPage()
                  : null,
            ),
            Text('${paginationState.currentPage + 1} / $totalPages'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: paginationState.currentPage < totalPages - 1
                  ? () => ref
                        .read(paginationProvider.notifier)
                        .nextPage(totalPages)
                  : null,
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

// 每年人数变化趋势图组件
class YearlyEmployeeCountChartComponent extends ConsumerWidget {
  final YearRangeParams params;

  const YearlyEmployeeCountChartComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        final List<Map<String, dynamic>> employeeCountPerYear = [];

        // 按时间排序年度数据
        final sortedYearlyData =
            List<YearlyComparisonData>.from(
              chartData.comparisonData!.yearlyComparisons,
            )..sort((a, b) {
              return a.year.compareTo(b.year);
            });

        for (var yearlyComparison in sortedYearlyData) {
          // 使用去重后的员工数量，而不是直接使用employeeCount
          int totalEmployees = yearlyComparison.totalEmployeeCount;

          employeeCountPerYear.add({
            'year': '${yearlyComparison.year}年',
            'yearNum': yearlyComparison.year,
            'employeeCount': totalEmployees,
          });
        }

        // 按时间排序
        employeeCountPerYear.sort((a, b) {
          return (a['yearNum'] as int).compareTo(b['yearNum'] as int);
        });

        return YearlyEmployeeCountChart(yearlyData: employeeCountPerYear);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}

// 每年平均薪资变化趋势图组件
class YearlyAverageSalaryChartComponent extends ConsumerWidget {
  final YearRangeParams params;

  const YearlyAverageSalaryChartComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        List<Map<String, dynamic>> averageSalaryPerYear = [];

        // 按时间排序年度数据
        final sortedYearlyData =
            List<YearlyComparisonData>.from(
              chartData.comparisonData!.yearlyComparisons,
            )..sort((a, b) {
              return a.year.compareTo(b.year);
            });

        for (var yearlyComparison in sortedYearlyData) {
          final averageSalary = yearlyComparison.averageSalary;

          averageSalaryPerYear.add({
            'year': '${yearlyComparison.year}年',
            'yearNum': yearlyComparison.year,
            'averageSalary': averageSalary,
          });
        }

        // 按时间排序
        averageSalaryPerYear.sort((a, b) {
          return (a['yearNum'] as int).compareTo(b['yearNum'] as int);
        });

        logger.info('averageSalaryPerYear: $averageSalaryPerYear');

        return YearlyAverageSalaryChart(yearlyData: averageSalaryPerYear);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}

// 每年总工资变化趋势图组件
class YearlyTotalSalaryChartComponent extends ConsumerWidget {
  final YearRangeParams params;

  const YearlyTotalSalaryChartComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        final List<Map<String, dynamic>> totalSalaryPerYear = [];

        // 按时间排序年度数据
        final sortedYearlyData =
            List<YearlyComparisonData>.from(
              chartData.comparisonData!.yearlyComparisons,
            )..sort((a, b) {
              return a.year.compareTo(b.year);
            });

        for (var yearlyComparison in sortedYearlyData) {
          final totalSalary = yearlyComparison.totalSalary;

          totalSalaryPerYear.add({
            'year': '${yearlyComparison.year}年',
            'yearNum': yearlyComparison.year,
            'totalSalary': totalSalary,
          });
        }

        // 按时间排序
        totalSalaryPerYear.sort((a, b) {
          return (a['yearNum'] as int).compareTo(b['yearNum'] as int);
        });

        return YearlyTotalSalaryChart(yearlyData: totalSalaryPerYear);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}

// 各部门平均薪资趋势图组件
class MultiYearDepartmentSalaryChartComponent extends ConsumerWidget {
  final YearRangeParams params;

  const MultiYearDepartmentSalaryChartComponent({
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

        // 按时间排序年度数据
        final sortedYearlyData =
            List<YearlyComparisonData>.from(
              chartData.comparisonData!.yearlyComparisons,
            )..sort((a, b) {
              return a.year.compareTo(b.year);
            });

        for (var yearlyData in sortedYearlyData) {
          final yearLabel = '${yearlyData.year}年';

          // 构建部门数据映射
          final departmentData = <String, double>{};
          yearlyData.departmentStats.forEach((deptName, stat) {
            // 确保使用正确的部门统计数据
            departmentData[deptName] = stat.averageNetSalary;
          });

          result.add({'year': yearLabel, 'departments': departmentData});
        }

        logger.info('MultiYearDepartmentSalaryChartComponent: $result');

        return MultiYearDepartmentSalaryChart(departmentYearlyData: result);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}
