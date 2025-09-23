import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/providers/year_analysis_provider.dart';
import 'package:salary_report/src/components/multi_year/yearly_key_metrics_component.dart';
import 'package:salary_report/src/components/multi_year/yearly_department_stats_component.dart';
import 'package:salary_report/src/components/multi_year/yearly_attendance_stats_component.dart';
import 'package:salary_report/src/components/multi_year/yearly_leave_ratio_stats_component.dart';
import 'package:salary_report/src/components/multi_year/department_changes_component.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart'; // 添加截图导入
import 'package:salary_report/src/common/toast.dart'; // 添加Toast导入
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/components/monthly_employee_changes_component.dart'; // 导入月度员工变化组件
import 'package:salary_report/src/services/monthly_analysis_service.dart'; // 导入月度分析服务
import 'package:salary_report/src/isar/database.dart'; // 导入数据库
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

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

      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.multiYear,
      );

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

      // 获取部门统计数据
      List<DepartmentSalaryStats> departmentStats = [];
      if (departmentStatsState is AsyncData &&
          departmentStatsState.value?.yearlyData != null) {
        // 合并所有年的部门统计数据
        final departmentStatsMap = <String, DepartmentSalaryStats>{};

        for (var yearlyData in departmentStatsState.value!.yearlyData!) {
          yearlyData.departmentStats.forEach((deptName, stat) {
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
        // 合并所有年的考勤统计数据
        attendanceStatsState.value!.attendanceData!.forEach((year, stats) {
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

      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: departmentStats,
        analysisData: analysisData,
        attendanceStats: attendanceStats,
        previousMonthData: null, // 多年报告不需要上期数据
        year: widget.year,
        month: 0, // 年度报告没有月份
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

    // 合并所有年的薪资区间统计数据
    final salaryRangeStatsMap = <String, SalaryRangeStats>{};
    if (keyMetricsState is AsyncData &&
        keyMetricsState.value?.yearlyData != null) {
      for (var yearlyData in keyMetricsState.value!.yearlyData!) {
        yearlyData.salaryRangeStats.forEach((rangeName, stat) {
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
    final keyMetricsState = ref.watch(keyMetricsProvider(_yearRangeParams));
    final departmentStatsState = ref.watch(
      departmentStatsProvider(_yearRangeParams),
    );
    final attendanceStatsState = ref.watch(
      attendanceStatsProvider(_yearRangeParams),
    );
    final leaveRatioStatsState = ref.watch(
      leaveRatioStatsProvider(_yearRangeParams),
    );
    final departmentChangesState = ref.watch(
      departmentChangesProvider(_yearRangeParams),
    );
    final chartDataState = ref.watch(chartDataProvider(_yearRangeParams));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.year}年-${widget.endYear}年 工资分析'),
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
                    // 关键指标组件
                    YearlyKeyMetricsComponent(params: _yearRangeParams),
                    const SizedBox(height: 24),

                    // 每年员工变动情况（需要从服务中获取数据）
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _calculateYearlyEmployeeChanges(_yearRangeParams),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text('加载员工变动数据失败: ${snapshot.error}'),
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: Text('暂无员工变动数据')),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '每年员工变动情况',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            MonthlyEmployeeChangesComponent(
                              monthlyChanges: snapshot.data!,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // 部门统计组件
                    YearlyDepartmentStatsComponent(params: _yearRangeParams),
                    const SizedBox(height: 24),

                    // 考勤统计组件
                    YearlyAttendanceStatsComponent(params: _yearRangeParams),
                    const SizedBox(height: 24),

                    // 请假比例统计组件
                    YearlyLeaveRatioStatsComponent(params: _yearRangeParams),
                    const SizedBox(height: 24),

                    // 部门变化组件
                    YearlyDepartmentChangesComponent(params: _yearRangeParams),
                    const SizedBox(height: 24),

                    // 图表组件
                    _buildChartSection(chartDataState),
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

  /// 计算每年员工变动情况
  Future<List<Map<String, dynamic>>> _calculateYearlyEmployeeChanges(
    YearRangeParams params,
  ) async {
    try {
      final database = IsarDatabase();
      final monthlyService = MonthlyAnalysisService(database);
      final yearlyChanges = <Map<String, dynamic>>[];

      // 遍历年份范围
      for (int year = params.startYear; year <= params.endYear; year++) {
        // 获取该年的月度数据
        final monthlyData = <Map<String, dynamic>>[];

        // 获取每个月的员工数据
        for (int month = 1; month <= 12; month++) {
          final salaryData = await monthlyService.getMonthlySalaryData(
            year,
            month,
          );
          final employees = <MinimalEmployeeInfo>{};

          if (salaryData != null) {
            for (var record in salaryData.records) {
              if (record.name != null && record.department != null) {
                employees.add(
                  MinimalEmployeeInfo(
                    name: record.name!,
                    department: record.department!,
                  ),
                );
              }
            }
          }

          monthlyData.add({
            'monthKey': '$year-$month',
            'employees': employees,
            'employeeCount': employees.length,
          });
        }

        // 计算该年每个月的员工变化
        for (int i = 0; i < monthlyData.length; i++) {
          final currentMonthData = monthlyData[i];
          final currentMonthKey = currentMonthData['monthKey'] as String;
          final currentEmployees =
              currentMonthData['employees'] as Set<MinimalEmployeeInfo>;
          final currentEmployeeCount = currentMonthData['employeeCount'] as int;

          if (i > 0) {
            final previousMonthData = monthlyData[i - 1];
            final previousEmployees =
                previousMonthData['employees'] as Set<MinimalEmployeeInfo>;

            // 计算新入职和离职员工
            final newEmployees = currentEmployees
                .difference(previousEmployees)
                .toList();
            final resignedEmployees = previousEmployees
                .difference(currentEmployees)
                .toList();

            yearlyChanges.add({
              'month': int.parse(currentMonthKey.split('-')[1]),
              'year': int.parse(currentMonthKey.split('-')[0]),
              'employeeCount': currentEmployeeCount,
              'newEmployees': newEmployees,
              'resignedEmployees': resignedEmployees,
              'netChange': newEmployees.length - resignedEmployees.length,
            });
          } else {
            // 第一个月，没有前一个月数据进行比较
            yearlyChanges.add({
              'month': int.parse(currentMonthKey.split('-')[1]),
              'year': int.parse(currentMonthKey.split('-')[0]),
              'employeeCount': currentEmployeeCount,
              'newEmployees': <MinimalEmployeeInfo>[],
              'resignedEmployees': <MinimalEmployeeInfo>[],
              'netChange': 0,
            });
          }
        }
      }

      return yearlyChanges;
    } catch (e) {
      logger.severe('Error calculating yearly employee changes: $e');
      return [];
    }
  }

  /// 构建图表部分
  Widget _buildChartSection(AsyncValue<ChartDataState> chartDataState) {
    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        final List<Map<String, dynamic>> employeeCountPerYear = [];
        final List<Map<String, dynamic>> averageSalaryPerYear = [];
        final List<Map<String, dynamic>> totalSalaryPerYear = [];
        final List<Map<String, dynamic>> result = [];

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

          final averageSalary = yearlyComparison.averageSalary;

          averageSalaryPerYear.add({
            'year': '${yearlyComparison.year}年',
            'yearNum': yearlyComparison.year,
            'averageSalary': averageSalary,
          });

          final totalSalary = yearlyComparison.totalSalary;

          totalSalaryPerYear.add({
            'year': '${yearlyComparison.year}年',
            'yearNum': yearlyComparison.year,
            'totalSalary': totalSalary,
          });

          final yearLabel = '${yearlyComparison.year}年';

          // 构建部门数据映射
          final departmentData = <String, double>{};
          yearlyComparison.departmentStats.forEach((deptName, stat) {
            // 确保使用正确的部门统计数据
            departmentData[deptName] = stat.averageNetSalary;
          });

          result.add({'year': yearLabel, 'departments': departmentData});
        }

        // 按时间排序
        employeeCountPerYear.sort((a, b) {
          return (a['yearNum'] as int).compareTo(b['yearNum'] as int);
        });

        averageSalaryPerYear.sort((a, b) {
          return (a['yearNum'] as int).compareTo(b['yearNum'] as int);
        });

        totalSalaryPerYear.sort((a, b) {
          return (a['yearNum'] as int).compareTo(b['yearNum'] as int);
        });

        logger.info('averageSalaryPerYear: $averageSalaryPerYear');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '每年人数变化趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(16.0),
                child: YearlyEmployeeCountChart(
                  yearlyData: employeeCountPerYear,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              '每年平均薪资变化趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(16.0),
                child: YearlyAverageSalaryChart(
                  yearlyData: averageSalaryPerYear,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              '每年总工资变化趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(16.0),
                child: YearlyTotalSalaryChart(yearlyData: totalSalaryPerYear),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              '各部门平均薪资趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(16.0),
                child: MultiYearDepartmentSalaryChart(
                  departmentYearlyData: result,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
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
