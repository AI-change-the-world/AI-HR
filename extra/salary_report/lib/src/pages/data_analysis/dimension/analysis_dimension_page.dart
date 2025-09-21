// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:salary_report/src/common/toast.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart'; // 添加数据库导入
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/global_analysis_models.dart';
import '../../../components/smart_time_picker.dart';
import '../../../providers/app_providers.dart';

class AnalysisDimensionPage extends ConsumerStatefulWidget {
  const AnalysisDimensionPage({super.key});

  @override
  ConsumerState<AnalysisDimensionPage> createState() =>
      _AnalysisDimensionPageState();
}

class _AnalysisDimensionPageState extends ConsumerState<AnalysisDimensionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF26D0CE), Color(0xFF1EAECC)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF26D0CE,
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '数据分析',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          '选择分析维度和时间范围进行深度数据洞察',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 维度选择
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFF26D0CE).withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF26D0CE).withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF26D0CE).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF26D0CE,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF26D0CE),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '选择分析维度',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDimensionOption(
                        'month',
                        '按月份分析',
                        '查看单个月份的详细薪资数据',
                        Icons.calendar_today_rounded,
                        const Color(0xFF6C63FF),
                      ),
                      const SizedBox(height: 12),
                      _buildDimensionOption(
                        'year',
                        '按年份分析',
                        '分析全年薪资趋势和变化',
                        Icons.date_range_rounded,
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(height: 12),
                      _buildDimensionOption(
                        'quarter',
                        '按季度分析',
                        '对比季度间薪资数据差异',
                        Icons.view_week_rounded,
                        const Color(0xFFFF6B6B),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 时间选择
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF6C63FF,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF6C63FF),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '时间范围',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTimeSelector(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 开始分析按钮
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26D0CE), Color(0xFF6C63FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF26D0CE).withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final selectedDimension = ref.read(
                        analysisDimensionProvider,
                      );
                      final timeRange = ref.read(timeRangeProvider);

                      if (timeRange == null) {
                        ToastUtils.error(null, title: '请先选择时间范围');
                        return;
                      }

                      // 使用DataAnalysisService进行数据分析并传递给分析页面
                      await _navigateWithAggregatedData(
                        selectedDimension,
                        timeRange,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.analytics_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '开始数据分析',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final selectedDimension = ref.watch(analysisDimensionProvider);
    final isSelected = selectedDimension == value;

    return GestureDetector(
      onTap: () {
        ref.read(analysisDimensionProvider.notifier).setDimension(value);
        // 清除之前的时间选择
        ref.read(timeRangeProvider.notifier).clearTimeRange();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    final selectedDimension = ref.watch(analysisDimensionProvider);
    final timeRange = ref.watch(timeRangeProvider);

    return GestureDetector(
      onTap: () async {
        TimePickerMode mode;
        switch (selectedDimension) {
          case 'month':
            mode = TimePickerMode.month;
            break;
          case 'year':
            mode = TimePickerMode.year;
            break;
          case 'quarter':
            mode = TimePickerMode.quarter;
            break;
          default:
            mode = TimePickerMode.month;
        }

        await showDialog(
          context: context,
          builder: (context) => SmartTimePicker(
            mode: mode,
            initialRange: timeRange,
            onRangeSelected: (TimeRange selectedRange) {
              ref.read(timeRangeProvider.notifier).setTimeRange(selectedRange);
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6C63FF).withValues(alpha: 0.1),
              const Color(0xFF26D0CE).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF26D0CE)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeRange?.toString() ?? '点击选择时间范围',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: timeRange != null
                          ? const Color(0xFF2D3748)
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击选择${_getDimensionText(selectedDimension)}范围',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF6C63FF),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDimensionText(String dimension) {
    switch (dimension) {
      case 'month':
        return '月份';
      case 'year':
        return '年份';
      case 'quarter':
        return '季度';
      default:
        return '时间';
    }
  }

  // 聚合数据并导航到分析页面
  Future<void> _navigateWithAggregatedData(
    String dimension,
    TimeRange timeRange,
  ) async {
    try {
      // 使用新的DataAnalysisService
      final salaryDataService = DataAnalysisService(IsarDatabase());

      // 根据维度进行不同的数据分析和导航
      if (dimension == 'month') {
        // 按月份分析
        await _navigateMonthlyAnalysis(salaryDataService, timeRange);
      } else if (dimension == 'year') {
        // 按年份分析
        await _navigateYearlyAnalysis(salaryDataService, timeRange);
      } else if (dimension == 'quarter') {
        // 按季度分析
        await _navigateQuarterlyAnalysis(salaryDataService, timeRange);
      }
    } catch (e) {
      logger.severe('数据分析过程中发生错误: $e');
      ToastUtils.error(null, title: '数据分析失败: $e');
    }
  }

  // 按月份分析并导航
  Future<void> _navigateMonthlyAnalysis(
    DataAnalysisService service,
    TimeRange timeRange,
  ) async {
    logger.info('开始按月份分析数据');
    logger.info('时间范围: ${timeRange.startDate} 到 ${timeRange.endDate}');

    // 如果是单个月份
    if (timeRange.startDate.year == timeRange.endDate.year &&
        timeRange.startDate.month == timeRange.endDate.month) {
      // 导航到月度分析页面
      context.push(
        '/analysis/monthly?year=${timeRange.startDate.year}&month=${timeRange.startDate.month}',
      );
    } else {
      // 多个月份对比分析
      final comparisonData = await service.getMultiMonthComparisonData(
        timeRange.startDate.year,
        timeRange.startDate.month,
        timeRange.endDate.year,
        timeRange.endDate.month,
      );

      if (comparisonData != null) {
        // 导航到多月分析页面
        context.push(
          '/analysis/monthly?year=${timeRange.startDate.year}&month=${timeRange.startDate.month}&endYear=${timeRange.endDate.year}&endMonth=${timeRange.endDate.month}',
          extra: {'comparisonData': comparisonData, 'isMultiMonth': true},
        );
      }
    }
  }

  // 按年份分析并导航
  Future<void> _navigateYearlyAnalysis(
    DataAnalysisService service,
    TimeRange timeRange,
  ) async {
    logger.info('开始按年份分析数据');
    logger.info(
      '时间范围: ${timeRange.startDate.year} 年到 ${timeRange.endDate.year} 年',
    );

    // 单一年份分析
    if (timeRange.startDate.year == timeRange.endDate.year) {
      final departmentStats = await service.getDepartmentAggregation(
        timeRange.startDate.year,
        1, // 年度分析从1月开始
      );

      // 这里可以获取其他数据，如考勤统计等
      final attendanceStats = <AttendanceStats>[]; // 暂时为空，实际应用中应从数据库获取
      final leaveRatioStats = null; // 暂时为空，实际应用中应从数据库获取

      // 记录数据
      _logAnalysisResults(departmentStats, attendanceStats, leaveRatioStats);

      // 导航到年度分析页面
      context.push(
        '/analysis/yearly?year=${timeRange.startDate.year}',
        extra: {
          'departmentStats': departmentStats,
          'attendanceStats': attendanceStats,
          'leaveRatioStats': leaveRatioStats,
        },
      );
    } else {
      // 多年份对比分析
      // 这里可以实现多年份对比分析逻辑
      // 暂时使用单年分析逻辑
      final departmentStats = await service.getDepartmentAggregation(
        timeRange.startDate.year,
        1, // 年度分析从1月开始
      );

      // 这里可以获取其他数据，如考勤统计等
      final attendanceStats = <AttendanceStats>[]; // 暂时为空，实际应用中应从数据库获取
      final leaveRatioStats = null; // 暂时为空，实际应用中应从数据库获取

      // 记录数据
      _logAnalysisResults(departmentStats, attendanceStats, leaveRatioStats);

      // 导航到多年份对比分析页面
      context.push(
        '/analysis/yearly?year=${timeRange.startDate.year}&endYear=${timeRange.endDate.year}',
        extra: {
          'departmentStats': departmentStats,
          'attendanceStats': attendanceStats,
          'leaveRatioStats': leaveRatioStats,
          'isMultiYear': true,
        },
      );
    }
  }

  // 按季度分析并导航
  Future<void> _navigateQuarterlyAnalysis(
    DataAnalysisService service,
    TimeRange timeRange,
  ) async {
    logger.info('开始按季度分析数据');

    // 计算季度
    final startQuarter = ((timeRange.startDate.month - 1) ~/ 3) + 1;
    final endQuarter = ((timeRange.endDate.month - 1) ~/ 3) + 1;

    logger.info(
      '时间范围: ${timeRange.startDate.year} 年第$startQuarter季度 到 ${timeRange.endDate.year} 年第$endQuarter季度',
    );

    // 单个季度分析
    if (timeRange.startDate.year == timeRange.endDate.year &&
        startQuarter == endQuarter) {
      final departmentStats = await service.getDepartmentAggregation(
        timeRange.startDate.year,
        (startQuarter - 1) * 3 + 1, // 季度的起始月份
      );

      // 这里可以获取其他数据，如考勤统计等
      final attendanceStats = <AttendanceStats>[]; // 暂时为空，实际应用中应从数据库获取
      final leaveRatioStats = null; // 暂时为空，实际应用中应从数据库获取

      // 记录数据
      _logAnalysisResults(departmentStats, attendanceStats, leaveRatioStats);

      // 导航到季度分析页面
      context.push(
        '/analysis/quarterly?year=${timeRange.startDate.year}&quarter=$startQuarter',
        extra: {
          'departmentStats': departmentStats,
          'attendanceStats': attendanceStats,
          'leaveRatioStats': leaveRatioStats,
        },
      );
    } else {
      // 多个季度对比分析
      // 这里可以实现多季度对比分析逻辑
      // 暂时使用单季度分析逻辑
      final departmentStats = await service.getDepartmentAggregation(
        timeRange.startDate.year,
        (startQuarter - 1) * 3 + 1, // 季度的起始月份
      );

      // 这里可以获取其他数据，如考勤统计等
      final attendanceStats = <AttendanceStats>[]; // 暂时为空，实际应用中应从数据库获取
      final leaveRatioStats = null; // 暂时为空，实际应用中应从数据库获取

      // 记录数据
      _logAnalysisResults(departmentStats, attendanceStats, leaveRatioStats);

      // 导航到多季度对比分析页面
      context.push(
        '/analysis/quarterly?year=${timeRange.startDate.year}&quarter=$startQuarter&endYear=${timeRange.endDate.year}&endQuarter=$endQuarter',
        extra: {
          'departmentStats': departmentStats,
          'attendanceStats': attendanceStats,
          'leaveRatioStats': leaveRatioStats,
          'isMultiQuarter': true,
        },
      );
    }
  }

  // 记录分析结果
  void _logAnalysisResults(
    List<DepartmentSalaryStats> departmentStats,
    List<AttendanceStats> attendanceStats,
    LeaveRatioStats? leaveRatioStats,
  ) {
    logger.info('部门工资统计结果:');
    for (var stat in departmentStats) {
      logger.info(
        '  部门: ${stat.department}, 总工资: ${stat.totalNetSalary}, 平均工资: ${stat.averageNetSalary}, 员工数: ${stat.employeeCount}',
      );
    }

    logger.info('考勤统计结果 (前10条记录):');
    final displayCount = attendanceStats.length > 10
        ? 10
        : attendanceStats.length;
    for (int i = 0; i < displayCount; i++) {
      final stat = attendanceStats[i];
      logger.info(
        '  姓名: ${stat.name}, 部门: ${stat.department}, 病假: ${stat.sickLeaveDays}天, 事假: ${stat.leaveDays}天, 缺勤: ${stat.absenceCount}次, 旷工: ${stat.truancyDays}天',
      );
    }
    if (attendanceStats.length > 10) {
      logger.info('  ... 还有 ${attendanceStats.length - 10} 条记录');
    }

    if (leaveRatioStats != null) {
      logger.info('请假比例统计:');
      logger.info('  总员工数: ${leaveRatioStats.totalEmployees}');
      logger.info('  平均病假天数: ${leaveRatioStats.sickLeaveRatio}');
      logger.info('  平均事假天数: ${leaveRatioStats.leaveRatio}');
    }
  }
}
