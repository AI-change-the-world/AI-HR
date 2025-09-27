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
import 'package:salary_report/src/rust/api/simple.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/services/multi_quarter/enhanced_multi_quarter_report_generator.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 截图并保存
      ToastUtils.info(context, title: "当前，多季度报告模块正在开发中，部分功能尚不稳定，请见谅。");
    });
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
      final endMonth = (widget.endQuarter - 1) * 3 + 3;
      final startTime = DateTime(widget.year, startMonth);
      final endTime = DateTime(widget.endYear, endMonth);

      // 使用统一的多季度报告生成器
      final generator = EnhancedMultiQuarterReportGenerator();

      // 基础分析数据，让生成器自己处理数据聚合
      final analysisData = <String, dynamic>{
        'reportType': 'multiQuarter',
        'periodInfo': {
          'startYear': widget.year,
          'startQuarter': widget.quarter,
          'endYear': widget.endYear,
          'endQuarter': widget.endQuarter,
        },
      };

      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: [],
        analysisData: analysisData,
        attendanceStats: [],
        previousMonthData: null,
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
      beep();
    }
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
            tooltip: '生成多季度报告',
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

        // 将月度数据聚合为季度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        final quarterlyAggregatedData = _aggregateMonthlyToQuarterly(
          sortedMonthlyData,
        );

        final List<Map<String, dynamic>> employeeCountPerQuarter = [];

        for (var quarterlyData in quarterlyAggregatedData) {
          final year = quarterlyData['year'] as int;
          final quarter = quarterlyData['quarter'] as int;
          final totalEmployeeCount = quarterlyData['totalEmployeeCount'] as int;

          employeeCountPerQuarter.add({
            'quarter': '$year年第$quarter季度',
            'year': year,
            'quarterNum': quarter,
            'employeeCount': totalEmployeeCount,
          });
        }

        return QuarterlyEmployeeCountChart(
          quarterlyData: employeeCountPerQuarter,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  /// 将月度数据聚合为季度数据
  List<Map<String, dynamic>> _aggregateMonthlyToQuarterly(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<String, List<MonthlyComparisonData>> quarterlyGroups = {};

    for (var monthData in monthlyData) {
      final quarter = _getQuarter(monthData.month);
      final quarterKey = '${monthData.year}-Q$quarter';

      if (!quarterlyGroups.containsKey(quarterKey)) {
        quarterlyGroups[quarterKey] = [];
      }
      quarterlyGroups[quarterKey]!.add(monthData);
    }

    return quarterlyGroups.entries
        .map((entry) {
          final quarterKey = entry.key;
          final months = entry.value;
          if (months.isEmpty) return null;

          final year = months.first.year;
          final quarter = _getQuarter(months.first.month);

          final Set<MinimalEmployeeInfo> allWorkers = {};
          double totalSalary = 0.0;

          for (var monthData in months) {
            allWorkers.addAll(monthData.workers);
            monthData.departmentStats.forEach((deptName, stat) {
              totalSalary += stat.totalNetSalary;
            });
          }

          final totalemployeecountActual = allWorkers.length;
          final averageSalary = totalemployeecountActual > 0
              ? totalSalary / totalemployeecountActual
              : 0.0;

          return {
            'year': year,
            'quarter': quarter,
            'totalEmployeeCount': totalemployeecountActual,
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) {
        if (a['year'] != b['year']) {
          return (a['year'] as int).compareTo(b['year'] as int);
        }
        return (a['quarter'] as int).compareTo(b['quarter'] as int);
      });
  }

  /// 根据月份计算季度
  int _getQuarter(int month) {
    return ((month - 1) ~/ 3) + 1;
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

        // 将月度数据聚合为季度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        final quarterlyAggregatedData = _aggregateMonthlyToQuarterly(
          sortedMonthlyData,
        );

        List<Map<String, dynamic>> averageSalaryPerQuarter = [];

        for (var quarterlyData in quarterlyAggregatedData) {
          final year = quarterlyData['year'] as int;
          final quarter = quarterlyData['quarter'] as int;
          final averageSalary = quarterlyData['averageSalary'] as double;

          averageSalaryPerQuarter.add({
            'quarter': '$year年第$quarter季度',
            'year': year,
            'quarterNum': quarter,
            'averageSalary': averageSalary,
          });
        }

        logger.info('averageSalaryPerQuarter: $averageSalaryPerQuarter');

        return QuarterlyAverageSalaryChart(
          quarterlyData: averageSalaryPerQuarter,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  /// 将月度数据聚合为季度数据
  List<Map<String, dynamic>> _aggregateMonthlyToQuarterly(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<String, List<MonthlyComparisonData>> quarterlyGroups = {};

    for (var monthData in monthlyData) {
      final quarter = _getQuarter(monthData.month);
      final quarterKey = '${monthData.year}-Q$quarter';

      if (!quarterlyGroups.containsKey(quarterKey)) {
        quarterlyGroups[quarterKey] = [];
      }
      quarterlyGroups[quarterKey]!.add(monthData);
    }

    return quarterlyGroups.entries
        .map((entry) {
          final quarterKey = entry.key;
          final months = entry.value;
          if (months.isEmpty) return null;

          final year = months.first.year;
          final quarter = _getQuarter(months.first.month);

          final Set<MinimalEmployeeInfo> allWorkers = {};
          double totalSalary = 0.0;

          for (var monthData in months) {
            allWorkers.addAll(monthData.workers);
            monthData.departmentStats.forEach((deptName, stat) {
              totalSalary += stat.totalNetSalary;
            });
          }

          final totalemployeecountActual = allWorkers.length;
          final averageSalary = totalemployeecountActual > 0
              ? totalSalary / totalemployeecountActual
              : 0.0;

          return {
            'year': year,
            'quarter': quarter,
            'totalEmployeeCount': totalemployeecountActual,
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) {
        if (a['year'] != b['year']) {
          return (a['year'] as int).compareTo(b['year'] as int);
        }
        return (a['quarter'] as int).compareTo(b['quarter'] as int);
      });
  }

  /// 根据月份计算季度
  int _getQuarter(int month) {
    return ((month - 1) ~/ 3) + 1;
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

        // 将月度数据聚合为季度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        final quarterlyAggregatedData = _aggregateMonthlyToQuarterly(
          sortedMonthlyData,
        );

        final List<Map<String, dynamic>> totalSalaryPerQuarter = [];

        for (var quarterlyData in quarterlyAggregatedData) {
          final year = quarterlyData['year'] as int;
          final quarter = quarterlyData['quarter'] as int;
          final totalSalary = quarterlyData['totalSalary'] as double;

          totalSalaryPerQuarter.add({
            'quarter': '$year年第$quarter季度',
            'year': year,
            'quarterNum': quarter,
            'totalSalary': totalSalary,
          });
        }

        return QuarterlyTotalSalaryChart(quarterlyData: totalSalaryPerQuarter);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  /// 将月度数据聚合为季度数据
  List<Map<String, dynamic>> _aggregateMonthlyToQuarterly(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<String, List<MonthlyComparisonData>> quarterlyGroups = {};

    for (var monthData in monthlyData) {
      final quarter = _getQuarter(monthData.month);
      final quarterKey = '${monthData.year}-Q$quarter';

      if (!quarterlyGroups.containsKey(quarterKey)) {
        quarterlyGroups[quarterKey] = [];
      }
      quarterlyGroups[quarterKey]!.add(monthData);
    }

    return quarterlyGroups.entries
        .map((entry) {
          final quarterKey = entry.key;
          final months = entry.value;
          if (months.isEmpty) return null;

          final year = months.first.year;
          final quarter = _getQuarter(months.first.month);

          final Set<MinimalEmployeeInfo> allWorkers = {};
          double totalSalary = 0.0;

          for (var monthData in months) {
            allWorkers.addAll(monthData.workers);
            monthData.departmentStats.forEach((deptName, stat) {
              totalSalary += stat.totalNetSalary;
            });
          }

          final totalemployeecountActual = allWorkers.length;
          final averageSalary = totalemployeecountActual > 0
              ? totalSalary / totalemployeecountActual
              : 0.0;

          return {
            'year': year,
            'quarter': quarter,
            'totalEmployeeCount': totalemployeecountActual,
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) {
        if (a['year'] != b['year']) {
          return (a['year'] as int).compareTo(b['year'] as int);
        }
        return (a['quarter'] as int).compareTo(b['quarter'] as int);
      });
  }

  /// 根据月份计算季度
  int _getQuarter(int month) {
    return ((month - 1) ~/ 3) + 1;
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

        // 将月度数据聚合为季度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        final quarterlyAggregatedData =
            _aggregateMonthlyToQuarterlyWithDepartments(sortedMonthlyData);

        final List<Map<String, dynamic>> result = [];

        for (var quarterlyData in quarterlyAggregatedData) {
          final year = quarterlyData['year'] as int;
          final quarter = quarterlyData['quarter'] as int;
          final departmentStats =
              quarterlyData['departmentStats']
                  as Map<String, DepartmentSalaryStats>;
          final quarterLabel = '$year年第$quarter季度';

          final departmentData = <String, double>{};
          departmentStats.forEach((deptName, stat) {
            departmentData[deptName] = stat.averageNetSalary;
          });

          result.add({'quarter': quarterLabel, 'departments': departmentData});
        }

        return MultiQuarterDepartmentSalaryChart(
          departmentQuarterlyData: result,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  /// 将月度数据聚合为季度数据（包含部门统计）
  List<Map<String, dynamic>> _aggregateMonthlyToQuarterlyWithDepartments(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<String, List<MonthlyComparisonData>> quarterlyGroups = {};

    for (var monthData in monthlyData) {
      final quarter = _getQuarter(monthData.month);
      final quarterKey = '${monthData.year}-Q$quarter';

      if (!quarterlyGroups.containsKey(quarterKey)) {
        quarterlyGroups[quarterKey] = [];
      }
      quarterlyGroups[quarterKey]!.add(monthData);
    }

    return quarterlyGroups.entries
        .map((entry) {
          final quarterKey = entry.key;
          final months = entry.value;
          if (months.isEmpty) return null;

          final year = months.first.year;
          final quarter = _getQuarter(months.first.month);

          // 聚合部门统计数据
          final Map<String, DepartmentSalaryStats> aggregatedDepartmentStats =
              {};
          final Map<String, List<DepartmentSalaryStats>> deptMonthlyData = {};

          for (var monthData in months) {
            monthData.departmentStats.forEach((deptName, stat) {
              if (!deptMonthlyData.containsKey(deptName)) {
                deptMonthlyData[deptName] = [];
              }
              deptMonthlyData[deptName]!.add(stat);
            });
          }

          deptMonthlyData.forEach((deptName, monthlyStats) {
            double totalNetSalary = 0.0;
            int maxEmployeeCount = 0;

            for (var stat in monthlyStats) {
              totalNetSalary += stat.totalNetSalary;
              if (stat.employeeCount > maxEmployeeCount) {
                maxEmployeeCount = stat.employeeCount;
              }
            }

            final averageNetSalary = maxEmployeeCount > 0
                ? totalNetSalary / maxEmployeeCount
                : 0.0;

            aggregatedDepartmentStats[deptName] = DepartmentSalaryStats(
              department: deptName,
              totalNetSalary: totalNetSalary,
              averageNetSalary: averageNetSalary,
              employeeCount: maxEmployeeCount,
              year: year,
              month: months.first.month,
              maxSalary: 0,
              minSalary: 0,
            );
          });

          return {
            'year': year,
            'quarter': quarter,
            'departmentStats': aggregatedDepartmentStats,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) {
        if (a['year'] != b['year']) {
          return (a['year'] as int).compareTo(b['year'] as int);
        }
        return (a['quarter'] as int).compareTo(b['quarter'] as int);
      });
  }

  /// 根据月份计算季度
  int _getQuarter(int month) {
    return ((month - 1) ~/ 3) + 1;
  }
}
