import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/providers/multi_quarter_analysis_provider.dart';
import 'package:salary_report/src/components/multi_quarter/quarterly_key_metrics_component.dart';
import 'package:salary_report/src/components/multi_quarter/quarterly_department_stats_component.dart';
import 'package:salary_report/src/components/multi_quarter/quarterly_attendance_stats_component.dart';
import 'package:salary_report/src/components/multi_quarter/department_changes_component.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart'; // 添加截图导入
import 'package:salary_report/src/common/toast.dart'; // 添加Toast导入
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

// 多季度分析页面
class MultiQuarterAnalysisPage extends ConsumerStatefulWidget {
  const MultiQuarterAnalysisPage({
    super.key,
    required this.year,
    required this.quarter,
    required this.endYear,
    required this.endQuarter,
  });

  final int year;
  final int quarter;
  final int endYear;
  final int endQuarter;

  @override
  ConsumerState<MultiQuarterAnalysisPage> createState() =>
      _MultiQuarterAnalysisPageState();
}

class _MultiQuarterAnalysisPageState
    extends ConsumerState<MultiQuarterAnalysisPage> {
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  late QuarterRangeParams _quarterRangeParams;

  // 添加截图相关变量
  final GlobalKey repaintKey = GlobalKey();
  final ScrollController controller = ScrollController();
  late ScrollableStitcher screenshotUtil;

  @override
  void initState() {
    super.initState();
    _quarterRangeParams = QuarterRangeParams(
      startYear: widget.year,
      startQuarter: widget.quarter,
      endYear: widget.endYear,
      endQuarter: widget.endQuarter,
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
      final startMonth = (widget.quarter - 1) * 3 + 1;
      final endMonth = (widget.endQuarter - 1) * 3 + 3;
      final startTime = DateTime(widget.year, startMonth);
      final endTime = DateTime(widget.endYear, endMonth);

      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.multiQuarter,
      );

      // 获取分析数据
      final keyMetricsState = ref.read(keyMetricsProvider(_quarterRangeParams));
      final departmentStatsState = ref.read(
        departmentStatsProvider(_quarterRangeParams),
      );
      final attendanceStatsState = ref.read(
        attendanceStatsProvider(_quarterRangeParams),
      );
      final leaveRatioStatsState = ref.read(
        leaveRatioStatsProvider(_quarterRangeParams),
      );
      final departmentChangesState = ref.read(
        departmentChangesProvider(_quarterRangeParams),
      );
      final chartDataState = ref.read(chartDataProvider(_quarterRangeParams));

      // 获取部门统计数据
      List<DepartmentSalaryStats> departmentStats = [];
      if (departmentStatsState is AsyncData &&
          departmentStatsState.value?.quarterlyData != null) {
        // 合并所有季度的部门统计数据
        final departmentStatsMap = <String, DepartmentSalaryStats>{};

        for (var quarterlyData in departmentStatsState.value!.quarterlyData!) {
          quarterlyData.departmentStats.forEach((deptName, stat) {
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
        // 合并所有季度的考勤统计数据
        attendanceStatsState.value!.attendanceData!.forEach((quarter, stats) {
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

      analysisData['salarySummary'] = ref
          .read(coreDataProvider(_quarterRangeParams))
          .value!
          .monthlySummary;

      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: departmentStats,
        analysisData: analysisData,
        attendanceStats: attendanceStats,
        previousMonthData: null, // 多季度报告不需要上期数据
        year: widget.year,
        month: widget.quarter,
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
    final Set<String> uniqueEmployeeIds = <String>{}; // 用于去重统计员工数

    // 从关键指标状态中获取数据
    if (keyMetricsState is AsyncData &&
        keyMetricsState.value?.quarterlyData != null) {
      for (var quarterlyData in keyMetricsState.value!.quarterlyData!) {
        totalEmployees += quarterlyData.employeeCount;
        totalSalary += quarterlyData.totalSalary;

        // 累加去重后的员工数
        for (var worker in quarterlyData.workers) {
          final employeeId = '${worker.name}_${worker.department}';
          uniqueEmployeeIds.add(employeeId);
        }

        // 使用季度数据中的最高最低工资字段
        if (quarterlyData.highestSalary > highestSalary) {
          highestSalary = quarterlyData.highestSalary;
        }

        if (quarterlyData.lowestSalary < lowestSalary) {
          lowestSalary = quarterlyData.lowestSalary;
        }
      }
    }

    // 设置去重员工总数
    totalUniqueEmployees = uniqueEmployeeIds.length;

    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }

    final averageSalary = totalEmployees > 0 ? totalSalary / totalEmployees : 0;

    // 合并所有季度的薪资区间统计数据
    final salaryRangeStatsMap = <String, SalaryRangeStats>{};
    if (keyMetricsState is AsyncData &&
        keyMetricsState.value?.quarterlyData != null) {
      for (var quarterlyData in keyMetricsState.value!.quarterlyData!) {
        quarterlyData.salaryRangeStats.forEach((rangeName, stat) {
          if (salaryRangeStatsMap.containsKey(rangeName)) {
            final existingStat = salaryRangeStatsMap[rangeName]!;
            salaryRangeStatsMap[rangeName] = SalaryRangeStats(
              range: rangeName,
              employeeCount: existingStat.employeeCount + stat.employeeCount,
              totalSalary: existingStat.totalSalary + stat.totalSalary,
              averageSalary:
                  (existingStat.totalSalary + stat.totalSalary) /
                  (existingStat.employeeCount + stat.employeeCount),
              year: stat.year,
              month: stat.month,
            );
          } else {
            salaryRangeStatsMap[rangeName] = stat;
          }
        });
      }
    }

    // 将薪资区间统计数据转换为列表
    final salaryRanges = salaryRangeStatsMap.values.toList();

    return {
      'totalEmployees': totalEmployees, // 总人次
      'totalUniqueEmployees': totalUniqueEmployees, // 总人数（去重）
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
      'salaryRanges': salaryRanges, // 添加薪资区间数据
    };
  }

  late ReportService reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    final title =
        '${widget.year}年第${widget.quarter}季度 - '
        '${widget.endYear}年第${widget.endQuarter}季度 工资分析';

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
                    // 每季度关键指标（分页显示）
                    const Text(
                      '每季度关键指标',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QuarterlyKeyMetricsComponent(params: _quarterRangeParams),

                    const SizedBox(height: 24),

                    // 每季度部门统计（分页显示）
                    const Text(
                      '每季度部门统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QuarterlyDepartmentStatsComponent(
                      params: _quarterRangeParams,
                    ),

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
                    DepartmentChangesComponent(params: _quarterRangeParams),

                    const SizedBox(height: 24),

                    // 每季度考勤统计（分页显示）
                    const Text(
                      '每季度考勤统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QuarterlyAttendanceStatsComponent(
                      params: _quarterRangeParams,
                    ),

                    const SizedBox(height: 24),

                    // // 每季度请假比例统计（分页显示）
                    // const Text(
                    //   '每季度请假比例统计',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                    // QuarterlyLeaveRatioStatsComponent(
                    //   params: _quarterRangeParams,
                    // ),

                    // const SizedBox(height: 24),

                    // 每季度人数变化趋势图
                    const Text(
                      '每季度人数变化趋势',
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
                        child: QuarterlyEmployeeCountChartComponent(
                          params: _quarterRangeParams,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 每季度平均薪资变化趋势图
                    const Text(
                      '每季度平均薪资变化趋势',
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
                        child: QuarterlyAverageSalaryChartComponent(
                          params: _quarterRangeParams,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 每季度总工资变化趋势图
                    const Text(
                      '每季度总工资变化趋势',
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
                        child: QuarterlyTotalSalaryChartComponent(
                          params: _quarterRangeParams,
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
                        child: MultiQuarterDepartmentSalaryChartComponent(
                          params: _quarterRangeParams,
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
}

// 每季度人数变化趋势图组件
class QuarterlyEmployeeCountChartComponent extends ConsumerWidget {
  final QuarterRangeParams params;

  const QuarterlyEmployeeCountChartComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        final List<Map<String, dynamic>> employeeCountPerQuarter = [];

        // 按时间排序季度数据
        final sortedQuarterlyData =
            List<QuarterlyComparisonData>.from(
              chartData.comparisonData!.quarterlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.quarter.compareTo(b.quarter);
            });

        for (var quarterlyComparison in sortedQuarterlyData) {
          // 使用去重后的员工数量，而不是直接使用employeeCount
          int totalEmployees = quarterlyComparison.totalEmployeeCount;

          employeeCountPerQuarter.add({
            'quarter':
                '${quarterlyComparison.year}年第${quarterlyComparison.quarter}季度',
            'year': quarterlyComparison.year,
            'quarterNum': quarterlyComparison.quarter,
            'employeeCount': totalEmployees,
          });
        }

        // 按时间排序
        employeeCountPerQuarter.sort((a, b) {
          if (a['year'] != b['year']) {
            return (a['year'] as int).compareTo(b['year'] as int);
          }
          return (a['quarterNum'] as int).compareTo(b['quarterNum'] as int);
        });

        return QuarterlyEmployeeCountChart(
          quarterlyData: employeeCountPerQuarter,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}

// 每季度平均薪资变化趋势图组件
class QuarterlyAverageSalaryChartComponent extends ConsumerWidget {
  final QuarterRangeParams params;

  const QuarterlyAverageSalaryChartComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        List<Map<String, dynamic>> averageSalaryPerQuarter = [];

        // 按时间排序季度数据
        final sortedQuarterlyData =
            List<QuarterlyComparisonData>.from(
              chartData.comparisonData!.quarterlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.quarter.compareTo(b.quarter);
            });

        for (var quarterlyComparison in sortedQuarterlyData) {
          final averageSalary = quarterlyComparison.averageSalary;

          averageSalaryPerQuarter.add({
            'quarter':
                '${quarterlyComparison.year}年第${quarterlyComparison.quarter}季度',
            'year': quarterlyComparison.year,
            'quarterNum': quarterlyComparison.quarter,
            'averageSalary': averageSalary,
          });
        }

        // 按时间排序
        averageSalaryPerQuarter.sort((a, b) {
          if (a['year'] != b['year']) {
            return (a['year'] as int).compareTo(b['year'] as int);
          }
          return (a['quarterNum'] as int).compareTo(b['quarterNum'] as int);
        });

        logger.info('averageSalaryPerQuarter: $averageSalaryPerQuarter');

        return QuarterlyAverageSalaryChart(
          quarterlyData: averageSalaryPerQuarter,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}

// 每季度总工资变化趋势图组件
class QuarterlyTotalSalaryChartComponent extends ConsumerWidget {
  final QuarterRangeParams params;

  const QuarterlyTotalSalaryChartComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataState = ref.watch(chartDataProvider(params));

    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        final List<Map<String, dynamic>> totalSalaryPerQuarter = [];

        // 按时间排序季度数据
        final sortedQuarterlyData =
            List<QuarterlyComparisonData>.from(
              chartData.comparisonData!.quarterlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.quarter.compareTo(b.quarter);
            });

        for (var quarterlyComparison in sortedQuarterlyData) {
          final totalSalary = quarterlyComparison.totalSalary;

          totalSalaryPerQuarter.add({
            'quarter':
                '${quarterlyComparison.year}年第${quarterlyComparison.quarter}季度',
            'year': quarterlyComparison.year,
            'quarterNum': quarterlyComparison.quarter,
            'totalSalary': totalSalary,
          });
        }

        // 按时间排序
        totalSalaryPerQuarter.sort((a, b) {
          if (a['year'] != b['year']) {
            return (a['year'] as int).compareTo(b['year'] as int);
          }
          return (a['quarterNum'] as int).compareTo(b['quarterNum'] as int);
        });

        return QuarterlyTotalSalaryChart(quarterlyData: totalSalaryPerQuarter);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}

// 各部门平均薪资趋势图组件
class MultiQuarterDepartmentSalaryChartComponent extends ConsumerWidget {
  final QuarterRangeParams params;

  const MultiQuarterDepartmentSalaryChartComponent({
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

        // 按时间排序季度数据
        final sortedQuarterlyData =
            List<QuarterlyComparisonData>.from(
              chartData.comparisonData!.quarterlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.quarter.compareTo(b.quarter);
            });

        for (var quarterlyData in sortedQuarterlyData) {
          final quarterLabel =
              '${quarterlyData.year}年第${quarterlyData.quarter}季度';

          // 构建部门数据映射
          final departmentData = <String, double>{};
          quarterlyData.departmentStats.forEach((deptName, stat) {
            // 确保使用正确的部门统计数据
            departmentData[deptName] = stat.averageNetSalary;
          });

          result.add({'quarter': quarterLabel, 'departments': departmentData});
        }

        logger.info('MultiQuarterDepartmentSalaryChartComponent: $result');

        return MultiQuarterDepartmentSalaryChart(
          departmentQuarterlyData: result,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }
}
