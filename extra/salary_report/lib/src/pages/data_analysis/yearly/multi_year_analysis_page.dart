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
import 'package:salary_report/src/rust/api/simple.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/components/monthly_employee_changes_component.dart'; // 导入月度员工变化组件
import 'package:salary_report/src/services/monthly_analysis_service.dart'; // 导入月度分析服务
import 'package:salary_report/src/isar/database.dart'; // 导入数据库
import 'package:salary_report/src/services/multi_year/enhanced_multi_year_report_generator.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 截图并保存
      ToastUtils.info(context, title: "当前，多年度报告模块正在开发中，部分功能尚不稳定，请见谅。");
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
      final startTime = DateTime(widget.year);
      final endTime = DateTime(widget.endYear);

      // 使用现有的多年度报告生成器
      final generator = EnhancedMultiYearReportGenerator();

      // 基础分析数据，让生成器自己处理数据聚合
      final analysisData = <String, dynamic>{
        'reportType': 'multiYear',
        'periodInfo': {'startYear': widget.year, 'endYear': widget.endYear},
      };

      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: [],
        analysisData: analysisData,
        attendanceStats: [],
        previousMonthData: null,
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
      beep();
    }
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
            tooltip: '生成多年度报告',
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

  /// 将月度数据聚合为年度数据（用于图表显示）
  List<Map<String, dynamic>> _aggregateMonthlyToYearlyForCharts(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<int, List<MonthlyComparisonData>> yearlyGroups = {};

    // 按年份分组月度数据
    for (var monthData in monthlyData) {
      final year = monthData.year;

      if (!yearlyGroups.containsKey(year)) {
        yearlyGroups[year] = [];
      }
      yearlyGroups[year]!.add(monthData);
    }

    // 将分组后的数据聚合为年度数据
    return yearlyGroups.entries
        .map((entry) {
          final year = entry.key;
          final months = entry.value;

          if (months.isEmpty) return null;

          // 聚合年度数据
          int totalEmployeeCount = 0; // 总人次（所有月份的人数累加）
          double totalSalary = 0.0; // 总工资
          double highestSalary = 0.0; // 最高工资
          double lowestSalary = double.infinity; // 最低工资

          // 收集所有月份的员工（去重）
          final Set<MinimalEmployeeInfo> allWorkers = {};

          // 聚合部门统计数据
          final Map<String, DepartmentSalaryStats> aggregatedDepartmentStats =
              {};
          final Map<String, List<DepartmentSalaryStats>> deptMonthlyData = {};

          for (var monthData in months) {
            // 累加人次
            totalEmployeeCount += monthData.employeeCount;

            // 收集部门数据
            monthData.departmentStats.forEach((deptName, stat) {
              if (!deptMonthlyData.containsKey(deptName)) {
                deptMonthlyData[deptName] = [];
              }
              deptMonthlyData[deptName]!.add(stat);

              totalSalary += stat.totalNetSalary;

              if (stat.maxSalary > highestSalary) {
                highestSalary = stat.maxSalary;
              }
              if (stat.minSalary < lowestSalary && stat.minSalary > 0) {
                lowestSalary = stat.minSalary;
              }
            });

            // 收集所有员工（去重）
            allWorkers.addAll(monthData.workers);
          }

          if (lowestSalary == double.infinity) {
            lowestSalary = 0;
          }

          // 真实人数（去重后）
          final totalemployeecountActual = allWorkers.length;

          // 平均工资
          final averageSalary = totalemployeecountActual > 0
              ? totalSalary / totalemployeecountActual
              : 0.0;

          // 聚合每个部门的年度数据
          deptMonthlyData.forEach((deptName, monthlyStats) {
            double deptTotalNetSalary = 0.0;
            int maxEmployeeCount = 0;
            double maxSalary = 0;
            double minSalary = double.infinity;

            for (var stat in monthlyStats) {
              deptTotalNetSalary += stat.totalNetSalary;
              if (stat.employeeCount > maxEmployeeCount) {
                maxEmployeeCount = stat.employeeCount;
              }
              if (stat.maxSalary > maxSalary) {
                maxSalary = stat.maxSalary;
              }
              if (stat.minSalary < minSalary && stat.minSalary > 0) {
                minSalary = stat.minSalary;
              }
            }

            if (minSalary == double.infinity) {
              minSalary = 0;
            }

            final averageNetSalary = maxEmployeeCount > 0
                ? deptTotalNetSalary / maxEmployeeCount
                : 0.0;

            aggregatedDepartmentStats[deptName] = DepartmentSalaryStats(
              department: deptName,
              totalNetSalary: deptTotalNetSalary,
              averageNetSalary: averageNetSalary,
              employeeCount: maxEmployeeCount,
              year: year,
              month: months.first.month,
              maxSalary: maxSalary,
              minSalary: minSalary,
            );
          });

          return {
            'year': year,
            'employeeCount': totalEmployeeCount, // 总人次
            'totalEmployeeCount': totalemployeecountActual, // 总人数（去重）
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
            'highestSalary': highestSalary,
            'lowestSalary': lowestSalary,
            'departmentStats': aggregatedDepartmentStats,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));
  }

  /// 构建图表部分
  Widget _buildChartSection(AsyncValue<ChartDataState> chartDataState) {
    return chartDataState.when(
      data: (chartData) {
        if (chartData.comparisonData == null) {
          return const Center(child: Text('暂无数据'));
        }

        // 将月度数据聚合为年度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        final yearlyAggregatedData = _aggregateMonthlyToYearlyForCharts(
          sortedMonthlyData,
        );

        final List<Map<String, dynamic>> employeeCountPerYear = [];
        final List<Map<String, dynamic>> averageSalaryPerYear = [];
        final List<Map<String, dynamic>> totalSalaryPerYear = [];
        final List<Map<String, dynamic>> result = [];

        for (var yearlyData in yearlyAggregatedData) {
          final year = yearlyData['year'] as int;
          final employeeCount = yearlyData['employeeCount'] as int;
          final totalEmployeeCount = yearlyData['totalEmployeeCount'] as int;
          final totalSalary = yearlyData['totalSalary'] as double;
          final averageSalary = yearlyData['averageSalary'] as double;
          final departmentStats =
              yearlyData['departmentStats']
                  as Map<String, DepartmentSalaryStats>;

          employeeCountPerYear.add({
            'year': '$year年',
            'yearNum': year,
            'employeeCount': totalEmployeeCount, // 使用去重后的真实人数
          });

          averageSalaryPerYear.add({
            'year': '$year年',
            'yearNum': year,
            'averageSalary': averageSalary,
          });

          totalSalaryPerYear.add({
            'year': '$year年',
            'yearNum': year,
            'totalSalary': totalSalary,
          });

          final yearLabel = '$year年';

          // 构建部门数据映射
          final departmentData = <String, double>{};
          departmentStats.forEach((deptName, stat) {
            departmentData[deptName] = stat.averageNetSalary;
            logger.info('====> $deptName: ${stat.averageNetSalary}');
          });

          result.add({'year': yearLabel, 'departments': departmentData});
        }

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

        // 将月度数据聚合为年度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        final yearlyAggregatedData = _aggregateMonthlyToYearlyForCharts(
          sortedMonthlyData,
        );

        final List<Map<String, dynamic>> employeeCountPerYear = [];

        for (var yearlyData in yearlyAggregatedData) {
          final year = yearlyData['year'] as int;
          final totalEmployeeCount = yearlyData['totalEmployeeCount'] as int;

          employeeCountPerYear.add({
            'year': '$year年',
            'yearNum': year,
            'employeeCount': totalEmployeeCount,
          });
        }

        return YearlyEmployeeCountChart(yearlyData: employeeCountPerYear);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  // 添加聚合方法（与主页面相同）
  List<Map<String, dynamic>> _aggregateMonthlyToYearlyForCharts(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<int, List<MonthlyComparisonData>> yearlyGroups = {};

    for (var monthData in monthlyData) {
      final year = monthData.year;
      if (!yearlyGroups.containsKey(year)) {
        yearlyGroups[year] = [];
      }
      yearlyGroups[year]!.add(monthData);
    }

    return yearlyGroups.entries
        .map((entry) {
          final year = entry.key;
          final months = entry.value;
          if (months.isEmpty) return null;

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
            'totalEmployeeCount': totalemployeecountActual,
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));
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

        // 将月度数据聚合为年度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        final yearlyAggregatedData = _aggregateMonthlyToYearlyForCharts(
          sortedMonthlyData,
        );

        List<Map<String, dynamic>> averageSalaryPerYear = [];

        for (var yearlyData in yearlyAggregatedData) {
          final year = yearlyData['year'] as int;
          final averageSalary = yearlyData['averageSalary'] as double;

          averageSalaryPerYear.add({
            'year': '$year年',
            'yearNum': year,
            'averageSalary': averageSalary,
          });
        }

        logger.info('averageSalaryPerYear: $averageSalaryPerYear');

        return YearlyAverageSalaryChart(yearlyData: averageSalaryPerYear);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  // 添加聚合方法（与主页面相同）
  List<Map<String, dynamic>> _aggregateMonthlyToYearlyForCharts(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<int, List<MonthlyComparisonData>> yearlyGroups = {};

    for (var monthData in monthlyData) {
      final year = monthData.year;
      if (!yearlyGroups.containsKey(year)) {
        yearlyGroups[year] = [];
      }
      yearlyGroups[year]!.add(monthData);
    }

    return yearlyGroups.entries
        .map((entry) {
          final year = entry.key;
          final months = entry.value;
          if (months.isEmpty) return null;

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
            'totalEmployeeCount': totalemployeecountActual,
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));
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

        // 将月度数据聚合为年度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        final yearlyAggregatedData = _aggregateMonthlyToYearlyForCharts(
          sortedMonthlyData,
        );

        final List<Map<String, dynamic>> totalSalaryPerYear = [];

        for (var yearlyData in yearlyAggregatedData) {
          final year = yearlyData['year'] as int;
          final totalSalary = yearlyData['totalSalary'] as double;

          totalSalaryPerYear.add({
            'year': '$year年',
            'yearNum': year,
            'totalSalary': totalSalary,
          });
        }

        return YearlyTotalSalaryChart(yearlyData: totalSalaryPerYear);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('加载数据失败: $error')),
    );
  }

  // 添加聚合方法（与主页面相同）
  List<Map<String, dynamic>> _aggregateMonthlyToYearlyForCharts(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<int, List<MonthlyComparisonData>> yearlyGroups = {};

    for (var monthData in monthlyData) {
      final year = monthData.year;
      if (!yearlyGroups.containsKey(year)) {
        yearlyGroups[year] = [];
      }
      yearlyGroups[year]!.add(monthData);
    }

    return yearlyGroups.entries
        .map((entry) {
          final year = entry.key;
          final months = entry.value;
          if (months.isEmpty) return null;

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
            'totalEmployeeCount': totalemployeecountActual,
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));
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

        // 将月度数据聚合为年度数据
        final sortedMonthlyData =
            List<MonthlyComparisonData>.from(
              chartData.comparisonData!.monthlyComparisons,
            )..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.month.compareTo(b.month);
            });

        final yearlyAggregatedData = _aggregateMonthlyToYearlyForCharts(
          sortedMonthlyData,
        );

        final List<Map<String, dynamic>> result = [];

        for (var yearlyData in yearlyAggregatedData) {
          final year = yearlyData['year'] as int;
          final departmentStats =
              yearlyData['departmentStats']
                  as Map<String, DepartmentSalaryStats>;
          final yearLabel = '$year年';

          // 构建部门数据映射
          final departmentData = <String, double>{};
          departmentStats.forEach((deptName, stat) {
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

  // 添加聚合方法（包含部门统计）
  List<Map<String, dynamic>> _aggregateMonthlyToYearlyForCharts(
    List<MonthlyComparisonData> monthlyData,
  ) {
    final Map<int, List<MonthlyComparisonData>> yearlyGroups = {};

    for (var monthData in monthlyData) {
      final year = monthData.year;
      if (!yearlyGroups.containsKey(year)) {
        yearlyGroups[year] = [];
      }
      yearlyGroups[year]!.add(monthData);
    }

    return yearlyGroups.entries
        .map((entry) {
          final year = entry.key;
          final months = entry.value;
          if (months.isEmpty) return null;

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
            double maxSalary = 0;
            double minSalary = double.infinity;

            for (var stat in monthlyStats) {
              totalNetSalary += stat.totalNetSalary;
              if (stat.employeeCount > maxEmployeeCount) {
                maxEmployeeCount = stat.employeeCount;
              }
              if (stat.maxSalary > maxSalary) {
                maxSalary = stat.maxSalary;
              }
              if (stat.minSalary < minSalary && stat.minSalary > 0) {
                minSalary = stat.minSalary;
              }
            }

            if (minSalary == double.infinity) {
              minSalary = 0;
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
              maxSalary: maxSalary,
              minSalary: minSalary,
            );
          });

          return {'year': year, 'departmentStats': aggregatedDepartmentStats};
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));
  }
}
