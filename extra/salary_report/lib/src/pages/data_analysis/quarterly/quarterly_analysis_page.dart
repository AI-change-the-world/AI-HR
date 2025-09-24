import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart'; // 添加截图导入
import 'package:salary_report/src/common/toast.dart'; // 添加Toast导入
import 'package:salary_report/src/components/monthly_employee_changes_component.dart'; // 导入月度员工变化组件
import 'package:salary_report/src/components/single_quarter/quarterly_department_stats_component.dart';
import 'package:salary_report/src/utils/quarterly_analysis_json_converter.dart'; // 添加导入

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
  List<Map<String, dynamic>> _monthlyEmployeeChanges = []; // 每月员工变动数据

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
      final departmentStats = await _salaryDataService.getDepartmentSalaryStats(
        startYear: widget.year,
        startMonth: startMonth,
        endYear: widget.year,
        endMonth: endMonth,
      );

      // for (var stats in departmentStats) {
      //   logger.info('Department: ${stats.averageNetSalary}');
      // }

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
      final List<Map<String, dynamic>> monthlyEmployeeChanges = []; // 每月员工变动数据
      double totalSalary = 0;
      int totalEmployees = 0;
      double highestSalary = 0;
      double lowestSalary = double.infinity;

      // 收集季度内每个月的员工姓名用于去重统计
      final uniqueEmployees = <String>{};

      // 用于计算员工变动的数据结构
      List<Map<String, dynamic>> monthlyEmployeeData = [];

      // 重新计算季度总工资和员工数（正确的方式）
      double quarterlyTotalSalary = 0.0;
      int quarterlyTotalEmployeeCount = 0;
      double quarterlyHighestSalary = 0.0;
      double quarterlyLowestSalary = double.infinity;

      for (int month = startMonth; month <= endMonth; month++) {
        // 获取每月的部门统计数据
        final monthlyDepartmentStats = await _salaryDataService
            .getDepartmentAggregation(widget.year, month);

        // 获取当月工资数据用于去重统计和最高最低工资计算
        final monthlySalaryData = await _salaryDataService.getMonthlySalaryData(
          widget.year,
          month,
        );

        // 收集员工唯一标识用于去重统计（姓名+身份证，若无身份证则仅用姓名）
        final Set<String> uniqueEmployeeIds = <String>{};
        Set<MinimalEmployeeInfo> currentMonthEmployees =
            <MinimalEmployeeInfo>{};
        if (monthlySalaryData != null) {
          for (var record in monthlySalaryData.records) {
            String employeeId = record.name ?? '';
            if (record.idNumber != null && record.idNumber!.isNotEmpty) {
              employeeId += '_${record.idNumber}';
            }
            uniqueEmployeeIds.add(employeeId);
            uniqueEmployees.addAll(uniqueEmployeeIds);

            // 收集员工信息用于计算员工变化
            if (record.name != null && record.department != null) {
              currentMonthEmployees.add(
                MinimalEmployeeInfo(
                  name: record.name!,
                  department: record.department!,
                ),
              );
            }
          }
        }

        // 重新计算月度总工资和员工数（正确的方式）
        double monthlyTotalSalary = 0.0;
        int monthlyTotalEmployeeCount = 0;
        double monthlyHighestSalary = 0.0;
        double monthlyLowestSalary = double.infinity;

        // 获取月度工资数据用于最高最低工资计算
        if (monthlySalaryData != null) {
          for (var record in monthlySalaryData.records) {
            if (record.netSalary != null) {
              final salaryStr = record.netSalary!.replaceAll(
                RegExp(r'[^\d.-]'),
                '',
              );
              final salary = double.tryParse(salaryStr) ?? 0;
              monthlyTotalSalary += salary;
              monthlyTotalEmployeeCount++;
              quarterlyTotalEmployeeCount++;

              // 更新最高和最低工资
              if (salary > monthlyHighestSalary) {
                monthlyHighestSalary = salary;
              }
              if (salary < monthlyLowestSalary && salary > 0) {
                // 忽略0工资
                monthlyLowestSalary = salary;
              }

              // 更新季度最高和最低工资
              if (salary > quarterlyHighestSalary) {
                quarterlyHighestSalary = salary;
              }
              if (salary < quarterlyLowestSalary && salary > 0) {
                // 忽略0工资
                quarterlyLowestSalary = salary;
              }
            }
          }
        }

        // 累加到季度总工资
        quarterlyTotalSalary += monthlyTotalSalary;

        if (monthlyLowestSalary == double.infinity) {
          monthlyLowestSalary = 0;
        }

        double monthlyAverageSalary = monthlyTotalEmployeeCount > 0
            ? monthlyTotalSalary / monthlyTotalEmployeeCount
            : 0;

        monthlyData.add({
          'month': '$month月',
          'totalSalary': monthlyTotalSalary,
          'averageSalary': monthlyAverageSalary,
          'employeeCount': monthlyTotalEmployeeCount,
          'highestSalary': monthlyHighestSalary,
          'lowestSalary': monthlyLowestSalary,
        });

        totalSalary += monthlyTotalSalary;
        totalEmployees += monthlyTotalEmployeeCount;

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

        monthlyEmployeeData.add({
          'month': month,
          'employees': currentMonthEmployees,
          'employeeCount': currentMonthEmployees.length,
        });
      }

      // 计算每月员工变动情况
      for (int i = 0; i < monthlyEmployeeData.length; i++) {
        final currentMonthData = monthlyEmployeeData[i];
        final currentMonth = currentMonthData['month'] as int;
        final currentEmployees =
            currentMonthData['employees'] as Set<MinimalEmployeeInfo>;
        final currentEmployeeCount = currentMonthData['employeeCount'] as int;

        if (i > 0) {
          final previousMonthData = monthlyEmployeeData[i - 1];
          final previousEmployees =
              previousMonthData['employees'] as Set<MinimalEmployeeInfo>;

          // 计算新入职和离职员工
          final newEmployees = currentEmployees
              .difference(previousEmployees)
              .toList();
          final resignedEmployees = previousEmployees
              .difference(currentEmployees)
              .toList();

          monthlyEmployeeChanges.add({
            'month': currentMonth,
            'employeeCount': currentEmployeeCount,
            'newEmployees': newEmployees,
            'resignedEmployees': resignedEmployees,
            'netChange': newEmployees.length - resignedEmployees.length,
          });
        } else {
          // 第一个月，没有前一个月数据进行比较
          monthlyEmployeeChanges.add({
            'month': currentMonth,
            'employeeCount': currentEmployeeCount,
            'newEmployees': <MinimalEmployeeInfo>[],
            'resignedEmployees': <MinimalEmployeeInfo>[],
            'netChange': 0,
          });
        }
      }

      // 使用正确的季度统计数据
      totalSalary = quarterlyTotalSalary;
      totalEmployees = quarterlyTotalEmployeeCount;
      highestSalary = quarterlyHighestSalary;
      lowestSalary = quarterlyLowestSalary;

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
        _monthlyEmployeeChanges = monthlyEmployeeChanges; // 存储每月员工变动数据
      });

      setState(() {
        _analysisData = {
          'totalEmployees': totalEmployees, // 总人次（不去重）
          'totalUniqueEmployees': uniqueEmployees.length, // 总人数（去重）
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
      final endMonth = startMonth + 2;

      // 获取上一季度的部门统计数据
      final previousDepartmentStats = await _salaryDataService
          .getDepartmentSalaryStats(
            startYear: previousYear,
            startMonth: startMonth,
            endYear: previousYear,
            endMonth: endMonth,
          );

      if (previousDepartmentStats.isNotEmpty) {
        // 计算上一季度的总员工数和总工资
        int totalEmployees = 0;
        double totalSalary = 0;
        int totalEmployeeRecords = 0; // 上一季度总员工记录数（不去重，用于计算平均工资）
        final Set<String> uniqueEmployeeIds = <String>{}; // 用于去重统计员工数
        double highestSalary = 0;
        double lowestSalary = double.infinity;

        // 遍历上一季度所有月份获取数据
        for (int month = startMonth; month <= endMonth; month++) {
          final monthlyData = await _salaryDataService.getMonthlySalaryData(
            previousYear,
            month,
          );

          if (monthlyData != null) {
            // 累加员工记录数（不去重，用于计算平均工资）
            totalEmployeeRecords += monthlyData.records.length;

            // 累加上一季度的总工资和计算最高最低工资
            for (var record in monthlyData.records) {
              if (record.netSalary != null) {
                final salaryStr = record.netSalary!.replaceAll(
                  RegExp(r'[^\d.-]'),
                  '',
                );
                final salary = double.tryParse(salaryStr) ?? 0;
                totalSalary += salary;

                // 更新最高和最低工资
                if (salary > highestSalary) {
                  highestSalary = salary;
                }
                if (salary < lowestSalary && salary > 0) {
                  // 忽略0工资
                  lowestSalary = salary;
                }

                // 收集员工唯一标识用于去重统计
                String employeeId = record.name ?? '';
                if (record.idNumber != null && record.idNumber!.isNotEmpty) {
                  employeeId += '_${record.idNumber}';
                }
                uniqueEmployeeIds.add(employeeId);
              }
            }
          }
        }

        if (lowestSalary == double.infinity) {
          lowestSalary = 0;
        }

        final averageSalary = totalEmployeeRecords > 0
            ? totalSalary / totalEmployeeRecords
            : 0;

        setState(() {
          _previousQuarterData = {
            'year': previousYear,
            'quarter': previousQuarter,
            'totalEmployees': totalEmployeeRecords, // 总人次（不去重）
            'totalUniqueEmployees': uniqueEmployeeIds.length, // 总人数（去重）
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
            'highestSalary': highestSalary, // 添加最高工资
            'lowestSalary': lowestSalary, // 添加最低工资
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

      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.singleQuarter,
      );
      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: _departmentStats,
        analysisData: _analysisData,
        endTime: endTime,
        year: widget.year,
        month: widget.quarter,
        isMultiMonth: false,
        startTime: startTime,
        attendanceStats: [], // 季度报告不需要考勤数据
        previousMonthData: null, // 季度报告不需要上月数据
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

  /// 生成JSON格式的分析报告
  Future<String> _generateJsonReport() {
    return Future.value(
      QuarterlyAnalysisJsonConverter.convertAnalysisDataToJson(
        analysisData: _analysisData,
        departmentStats: _departmentStats,
        attendanceStats: _attendanceStats,
        previousQuarterData: _previousQuarterData,
        year: widget.year,
        quarter: widget.quarter,
      ),
    );
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
                            '总人数',
                            _previousQuarterData!['totalUniqueEmployees']
                                .toString(),
                            Icons.group,
                          ),
                          _buildStatCard(
                            '工资总额',
                            '${_previousQuarterData!['totalSalary'].toStringAsFixed(2)}元',
                            Icons.account_balance_wallet,
                          ),
                          _buildStatCard(
                            '平均工资',
                            '${_previousQuarterData!['averageSalary'].toStringAsFixed(2)}元',
                            Icons.trending_up,
                          ),
                          _buildStatCard(
                            '最高工资',
                            '${_previousQuarterData!['highestSalary'].toStringAsFixed(2)}元',
                            Icons.arrow_upward,
                          ),
                          _buildStatCard(
                            '最低工资',
                            '${_previousQuarterData!['lowestSalary'].toStringAsFixed(2)}元',
                            Icons.arrow_downward,
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
                          '总人次',
                          _analysisData['totalEmployees'].toString(),
                          Icons.people,
                        ),
                        _buildStatCard(
                          '总人数',
                          _analysisData['totalUniqueEmployees'].toString(),
                          Icons.group,
                        ),
                        _buildStatCard(
                          '季度工资总额',
                          '${_analysisData['totalSalary'].toStringAsFixed(2)}元',
                          Icons.account_balance_wallet,
                        ),
                        _buildStatCard(
                          '季度平均工资',
                          '${_analysisData['averageSalary'].toStringAsFixed(2)}元',
                          Icons.trending_up,
                        ),
                        _buildStatCard(
                          '最高工资',
                          '${_analysisData['highestSalary'].toStringAsFixed(2)}元',
                          Icons.arrow_upward,
                        ),
                        _buildStatCard(
                          '最低工资',
                          '${_analysisData['lowestSalary'].toStringAsFixed(2)}元',
                          Icons.arrow_downward,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 每月员工变动情况
                    const Text(
                      '每月员工变动情况',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MonthlyEmployeeChangesComponent(
                      monthlyChanges: _monthlyEmployeeChanges,
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
                                        '${data['totalSalary'].toStringAsFixed(2)}元',
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${data['averageSalary'].toStringAsFixed(2)}元',
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

                    // 季度部门统计
                    QuarterlyDepartmentStatsCard(
                      year: widget.year,
                      quarter: widget.quarter,
                      departmentStats: _departmentStats,
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
                                            '${range.totalSalary.toStringAsFixed(2)}元',
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${range.averageSalary.toStringAsFixed(2)}元',
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
                                            '${deptRange.totalSalary.toStringAsFixed(2)}元',
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${deptRange.averageSalary.toStringAsFixed(2)}元',
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
