import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';

import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/components/monthly_detail_components.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart';
import 'package:salary_report/src/common/toast.dart';
import 'package:salary_report/src/components/time_unit_employee_changes_component.dart';
import 'package:salary_report/src/components/department_stats_component.dart';
import 'package:salary_report/src/services/yearly/yearly_analysis_json_converter.dart';
import 'package:salary_report/src/providers/yearly_analysis_provider.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart' as multi_month;

class YearlyAnalysisPageRiverpod extends ConsumerStatefulWidget {
  const YearlyAnalysisPageRiverpod({
    super.key,
    required this.year,
    this.isMultiYear = false,
    this.endYear,
  });

  final int year;
  final bool isMultiYear;
  final int? endYear;

  @override
  ConsumerState<YearlyAnalysisPageRiverpod> createState() => _YearlyAnalysisPageRiverpodState();
}

class _YearlyAnalysisPageRiverpodState extends ConsumerState<YearlyAnalysisPageRiverpod> {
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  late YearParams _yearParams;

  // 添加截图相关变量
  final GlobalKey repaintKey = GlobalKey();
  final ScrollController controller = ScrollController();
  late ScrollableStitcher screenshotUtil;

  @override
  void initState() {
    super.initState();
    _yearParams = YearParams(year: widget.year);
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
      final startTime = DateTime(widget.year, 1);
      final endTime = widget.isMultiYear && widget.endYear != null
          ? DateTime(widget.endYear!, 12)
          : DateTime(widget.year, 12);

      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.singleYear,
      );

      // 获取分析数据
      final coreData = await ref.read(multi_month.coreDataProvider(_yearParams).future);
      final departmentStats = await ref.read(departmentStatsProvider(_yearParams).future);
      final attendanceStats = await ref.read(attendanceStatsProvider(_yearParams).future);
      final previousYearState = await ref.read(previousYearStateProvider(_yearParams).future);

      // 准备年度分析数据，包含每月详细数据
      final analysisData = await _prepareYearlyAnalysisData(
        coreData,
        departmentStats,
        attendanceStats,
        previousYearState,
      );

      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: departmentStats.monthlyData?.expand((month) => 
          month.departmentStats.values).toList() ?? [],
        analysisData: analysisData,
        endTime: endTime,
        year: widget.year,
        month: 0, // 年度报告没有月份
        isMultiMonth: widget.isMultiYear,
        startTime: startTime,
        attendanceStats: attendanceStats.attendanceData?.values.expand((list) => list).toList() ?? [],
        previousMonthData: previousYearState.previousYearData,
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
      logger.severe('生成报告时发生错误: $e');
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

  /// 生成JSON格式的分析报告
  Future<String> _generateJsonReport() async {
    final coreData = await ref.read(multi_month.coreDataProvider(_yearParams).future);
    final departmentStats = await ref.read(departmentStatsProvider(_yearParams).future);
    final attendanceStats = await ref.read(attendanceStatsProvider(_yearParams).future);
    final previousYearState = await ref.read(previousYearStateProvider(_yearParams).future);

    return YearlyAnalysisJsonConverter.convertAnalysisDataToJson(
      analysisData: <String, dynamic>{
        'monthlyComparisons': coreData?.monthlyComparisons ?? [],
        'startDate': coreData?.startDate,
        'endDate': coreData?.endDate,
        'monthlySummary': coreData?.monthlySummary ?? {},
      },
      departmentStats: departmentStats.monthlyData?.expand((month) => 
        month.departmentStats.values).toList() ?? [],
      attendanceStats: attendanceStats.attendanceData?.values.expand((list) => list).toList() ?? [],
      previousYearData: previousYearState.previousYearData,
      year: widget.year,
    );
  }

  /// 准备年度分析数据
  Future<Map<String, dynamic>> _prepareYearlyAnalysisData(
    MultiMonthComparisonData? coreData,
    multi_month.DepartmentStatsState departmentStats,
    multi_month.AttendanceStatsState attendanceStats,
    PreviousYearState previousYearState,
  ) async {
    final analysisData = <String, dynamic>{
      'monthlyComparisons': coreData?.monthlyComparisons ?? [],
      'startDate': coreData?.startDate,
      'endDate': coreData?.endDate,
      'monthlySummary': coreData?.monthlySummary ?? {},
    };

    // 添加部门统计数据（如果有的话）
    if (coreData?.monthlyComparisons != null) {
      final departmentStatsPerMonth = <Map<String, dynamic>>[];
      final aggregatedDepartmentStats = <String, Map<String, dynamic>>{};
      
      for (var monthData in coreData!.monthlyComparisons) {
        // 添加每月部门统计数据
        departmentStatsPerMonth.add({
          'year': monthData.year,
          'month': monthData.month,
          'departmentStats': monthData.departmentStats.values.map((dept) => {
            'department': dept.department,
            'employeeCount': dept.employeeCount,
            'totalNetSalary': dept.totalNetSalary,
            'averageNetSalary': dept.averageNetSalary,
            'maxSalary': dept.maxSalary,
            'minSalary': dept.minSalary,
            'year': dept.year,
            'month': dept.month,
          }).toList(),
        });

        // 聚合部门统计数据
        for (var dept in monthData.departmentStats.values) {
          if (aggregatedDepartmentStats.containsKey(dept.department)) {
            final existing = aggregatedDepartmentStats[dept.department]!;
            existing['employeeCount'] = (existing['employeeCount'] as int) + dept.employeeCount;
            existing['totalNetSalary'] = (existing['totalNetSalary'] as double) + dept.totalNetSalary;
            existing['averageNetSalary'] = (existing['totalNetSalary'] as double) / (existing['employeeCount'] as int);
            existing['maxSalary'] = math.max(existing['maxSalary'] as double, dept.maxSalary);
            existing['minSalary'] = math.min(existing['minSalary'] as double, dept.minSalary);
          } else {
            aggregatedDepartmentStats[dept.department] = {
              'department': dept.department,
              'employeeCount': dept.employeeCount,
              'totalNetSalary': dept.totalNetSalary,
              'averageNetSalary': dept.averageNetSalary,
              'maxSalary': dept.maxSalary,
              'minSalary': dept.minSalary,
              'year': dept.year,
              'month': dept.month,
            };
          }
        }
      }
      
      analysisData['departmentStatsPerMonth'] = departmentStatsPerMonth;
      analysisData['departmentStats'] = aggregatedDepartmentStats.values.toList();
    }

    // 添加每月员工数量、平均工资、总工资数据
    if (coreData?.monthlyComparisons != null) {
      final employeeCountPerMonth = <Map<String, dynamic>>[];
      final averageSalaryPerMonth = <Map<String, dynamic>>[];
      final totalSalaryPerMonth = <Map<String, dynamic>>[];

      for (var monthData in coreData!.monthlyComparisons) {
        employeeCountPerMonth.add({
          'month': '${monthData.year}年${monthData.month}月',
          'year': monthData.year,
          'monthNum': monthData.month,
          'employeeCount': monthData.employeeCount,
        });

        averageSalaryPerMonth.add({
          'month': '${monthData.year}年${monthData.month}月',
          'year': monthData.year,
          'monthNum': monthData.month,
          'averageSalary': monthData.averageSalary,
        });

        totalSalaryPerMonth.add({
          'month': '${monthData.year}年${monthData.month}月',
          'year': monthData.year,
          'monthNum': monthData.month,
          'totalSalary': monthData.totalSalary,
        });
      }

      analysisData['employeeCountPerMonth'] = employeeCountPerMonth;
      analysisData['averageSalaryPerMonth'] = averageSalaryPerMonth;
      analysisData['totalSalaryPerMonth'] = totalSalaryPerMonth;
    }

    // 添加薪资结构数据（如果有的话）
    if (coreData?.monthlySummary != null) {
      analysisData['salarySummary'] = coreData!.monthlySummary;
    }

    // 添加上年度对比数据
    if (previousYearState.previousYearData != null) {
      analysisData['departmentYearOverYearData'] = [];
      analysisData['positionYearOverYearData'] = [];
    }

    return analysisData;
  }

  /// 显示JSON报告
  Future<void> _showJsonReport() async {
    try {
      final jsonReport = await _generateJsonReport();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('JSON分析报告'),
              content: SingleChildScrollView(child: Text(jsonReport)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('关闭'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: const Text('生成JSON报告失败'),
          description: Text('错误信息: $e'),
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyMetricsState = ref.watch(keyMetricsProvider(_yearParams));
    final previousYearState = ref.watch(previousYearStateProvider(_yearParams));
    final employeeChangesState = ref.watch(employeeChangesProvider(_yearParams));
    final departmentStatsState = ref.watch(departmentStatsProvider(_yearParams));
    final attendanceStatsState = ref.watch(attendanceStatsProvider(_yearParams));

    // 检查是否所有数据都已加载完成
    final bool isLoading = keyMetricsState is AsyncLoading || 
                          previousYearState is AsyncLoading || 
                          employeeChangesState is AsyncLoading || 
                          departmentStatsState is AsyncLoading || 
                          attendanceStatsState is AsyncLoading;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.year}年 工资分析')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 检查是否有错误
    final bool hasError = keyMetricsState is AsyncError || 
                         previousYearState is AsyncError || 
                         employeeChangesState is AsyncError || 
                         departmentStatsState is AsyncError || 
                         attendanceStatsState is AsyncError;

    if (hasError) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.year}年 工资分析')),
        body: Center(
          child: Text(
            '加载数据时发生错误，请重试',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final title = widget.isMultiYear
        ? '${widget.year}年-${widget.endYear}年 工资分析'
        : '${widget.year}年 工资分析';

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
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.code),
              onPressed: _showJsonReport,
              tooltip: '查看JSON报告',
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
                    // 上一年数据展示（如果存在）
                    _buildPreviousYearSection(previousYearState),

                    // 关键指标卡片
                    _buildKeyMetricsSection(keyMetricsState),

                    const SizedBox(height: 24),

                    // 每月员工变动情况
                    _buildEmployeeChangesSection(employeeChangesState),

                    const SizedBox(height: 24),

                    // 月度趋势图
                    _buildMonthlyTrendSection(keyMetricsState),

                    const SizedBox(height: 24),

                    // 年度部门工资对比
                    _buildDepartmentStatsSection(departmentStatsState),

                    const SizedBox(height: 24),

                    // 按月部门工资对比
                    _buildMonthlyDepartmentStatsSection(departmentStatsState),

                    const SizedBox(height: 24),

                    // 按月考勤统计
                    _buildMonthlyAttendanceStatsSection(attendanceStatsState),
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

  // 构建上一年数据部分
  Widget _buildPreviousYearSection(AsyncValue<PreviousYearState> previousYearState) {
    return previousYearState.when(
      data: (state) {
        if (state.previousYearData == null) {
          return const SizedBox.shrink(); // 如果没有上一年数据，不显示任何内容
        }

        final previousYearData = state.previousYearData!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '上一年对比  ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '${previousYearData['year']}年基本情况',
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
                  previousYearData['totalEmployees'].toString(),
                  Icons.people,
                ),
                _buildStatCard(
                  '总人数',
                  previousYearData['totalUniqueEmployees'].toString(),
                  Icons.group,
                ),
                _buildStatCard(
                  '工资总额',
                  '${previousYearData['totalSalary'].toStringAsFixed(2)}元',
                  Icons.account_balance_wallet,
                ),
                _buildStatCard(
                  '平均工资',
                  '${previousYearData['averageSalary'].toStringAsFixed(2)}元',
                  Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  // 构建关键指标部分
  Widget _buildKeyMetricsSection(AsyncValue<multi_month.KeyMetricsState> keyMetricsState) {
    return keyMetricsState.when(
      data: (state) {
        if (state is! YearlyKeyMetricsState || (state).yearData == null) {
          return const Center(child: Text('暂无关键指标数据'));
        }

        final yearData = (state).yearData!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '年度关键指标',
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
                  '总人次',
                  yearData['totalEmployees'].toString(),
                  Icons.people,
                ),
                _buildStatCard(
                  '总人数',
                  yearData['totalUniqueEmployees'].toString(),
                  Icons.group,
                ),
                _buildStatCard(
                  '工资总额',
                  '${yearData['totalSalary'].toStringAsFixed(2)}元',
                  Icons.account_balance_wallet,
                ),
                _buildStatCard(
                  '平均工资',
                  '${yearData['averageSalary'].toStringAsFixed(2)}元',
                  Icons.trending_up,
                ),
                _buildStatCard(
                  '最高工资',
                  '${yearData['highestSalary'].toStringAsFixed(2)}元',
                  Icons.arrow_upward,
                ),
                _buildStatCard(
                  '最低工资',
                  '${yearData['lowestSalary'].toStringAsFixed(2)}元',
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
  Widget _buildEmployeeChangesSection(AsyncValue<multi_month.DepartmentChangesState> employeeChangesState) {
    return employeeChangesState.when(
      data: (state) {
        if (state.comparisonData?.monthlyComparisons == null || state.comparisonData!.monthlyComparisons.isEmpty) {
          return const Center(child: Text('暂无员工变动数据'));
        }

        // 转换数据格式为组件需要的格式
        final monthlyChanges = state.comparisonData!.monthlyComparisons.map((month) => {
          'month': month.month,
          'employeeCount': month.employeeCount,
          'newEmployees': <MinimalEmployeeInfo>[],
          'resignedEmployees': <MinimalEmployeeInfo>[],
          'netChange': 0,
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '每月员工变动情况',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            YearlyTimeUnitEmployeeChangesComponent(
                      yearlyChanges: monthlyChanges,
                    ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载员工变动数据失败: $error')),
    );
  }

  // 构建月度趋势图部分
  Widget _buildMonthlyTrendSection(AsyncValue<multi_month.KeyMetricsState> keyMetricsState) {
    return keyMetricsState.when(
      data: (state) {
        if (state.monthlyData == null || state.monthlyData!.isEmpty) {
          return const Center(child: Text('暂无月度趋势数据'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '月度趋势',
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
                  monthlyData: state.monthlyData!.map((month) => {
                    'month': month.month,
                    'monthLabel': '${month.month}月',
                    'totalSalary': month.totalSalary,
                    'averageSalary': month.averageSalary,
                    'employeeCount': month.employeeCount,
                    'highestSalary': month.highestSalary,
                    'lowestSalary': month.lowestSalary,
                  }).toList(),
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
  Widget _buildDepartmentStatsSection(AsyncValue<multi_month.DepartmentStatsState> departmentStatsState) {
    return departmentStatsState.when(
      data: (state) {
        if (state.monthlyData == null || state.monthlyData!.isEmpty) {
          return const Center(child: Text('暂无部门统计数据'));
        }

        // 从月度数据中提取部门统计
        final departmentStats = state.monthlyData!.expand((month) => 
          month.departmentStats.values).toList();

        return DepartmentStatsComponent(
          departmentStats: departmentStats,
          title: '年度部门工资对比',
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载部门统计数据失败: $error')),
    );
  }

  // 构建按月部门工资对比部分
  Widget _buildMonthlyDepartmentStatsSection(AsyncValue<multi_month.DepartmentStatsState> departmentStatsState) {
    return departmentStatsState.when(
      data: (state) {
        if (state.monthlyData == null || state.monthlyData!.isEmpty) {
          return const Center(child: Text('暂无按月部门工资对比数据'));
        }

        // 转换数据格式
        final monthlyDepartmentStats = <String, List<DepartmentSalaryStats>>{};
        for (var monthData in state.monthlyData!) {
          monthlyDepartmentStats['${monthData.month}月'] = monthData.departmentStats.values.toList();
        }

        return MonthlyDetailContainer(
          title: '按月部门工资对比',
          monthlyData: monthlyDepartmentStats,
          builder: (month, data) {
            return MonthlyDepartmentDetail(
              departmentStats: data as List<DepartmentSalaryStats>,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载按月部门工资对比数据失败: $error')),
    );
  }

  // 构建按月考勤统计部分
  Widget _buildMonthlyAttendanceStatsSection(AsyncValue<multi_month.AttendanceStatsState> attendanceStatsState) {
    return attendanceStatsState.when(
      data: (state) {
        if (state.attendanceData == null || state.attendanceData!.isEmpty) {
          return const Center(child: Text('暂无按月考勤统计数据'));
        }

        return MonthlyDetailContainer(
          title: '按月考勤统计',
          monthlyData: state.attendanceData!,
          builder: (month, data) {
            return MonthlyAttendanceDetail(
              attendanceStats: data as List<AttendanceStats>,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载按月考勤统计数据失败: $error')),
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