import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart'; // 添加数据库导入
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/pages/visualization/report/salary_report_generator.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:toastification/toastification.dart';

class YearlyAnalysisPage extends StatefulWidget {
  const YearlyAnalysisPage({
    super.key,
    required this.year,
    this.isMultiYear = false,
    this.endYear,
  });

  final int year;
  final bool isMultiYear;
  final int? endYear;

  @override
  State<YearlyAnalysisPage> createState() => _YearlyAnalysisPageState();
}

class _YearlyAnalysisPageState extends State<YearlyAnalysisPage> {
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  late DataAnalysisService _salaryDataService; // 数据分析服务实例
  late Map<String, dynamic> analysisData = {}; // 存储分析数据

  var future;

  @override
  void initState() {
    super.initState();
    _salaryDataService = DataAnalysisService(IsarDatabase()); // 初始化服务
    future = _initAnalysisData();
  }

  /// 生成工资报告
  Future<void> _generateSalaryReport(Map<String, dynamic> analysisData) async {
    try {
      setState(() {
        _isGeneratingReport = true;
      });

      // 从分析数据中获取部门统计数据
      final departmentStats =
          analysisData['departmentStats'] as List<DepartmentSalaryStats>;

      // 确定开始和结束时间
      final startTime = DateTime(widget.year, 1);
      final endTime = widget.isMultiYear && widget.endYear != null
          ? DateTime(widget.endYear!, 12)
          : DateTime(widget.year, 12);

      final generator = SalaryReportGenerator();
      final reportPath = await generator.generateReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: departmentStats, // 使用从分析数据中获取的部门统计数据
        analysisData: analysisData,
        endTime: endTime,
        year: widget.year,
        month: 0, // 年度报告没有月份
        isMultiMonth: widget.isMultiYear,
        startTime: startTime,
        reportType: ReportType.singleYear, // 明确指定报告类型为年度报告
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

  Future<Map<String, dynamic>> _initAnalysisData() async {
    // 使用DataAnalysisService获取年度聚合数据
    final departmentStats = await _salaryDataService.getDepartmentAggregation(
      widget.year,
      1, // 年度分析从1月开始
    );

    // 获取考勤统计数据
    final attendanceStats = await _salaryDataService.getMonthlyAttendanceStats(
      year: widget.year,
    );

    // 获取每月的详细部门统计数据
    final monthlyDepartmentStats = <String, List<DepartmentSalaryStats>>{};
    for (int month = 1; month <= 12; month++) {
      final monthlyDeptStats = await _salaryDataService
          .getDepartmentAggregation(widget.year, month);
      monthlyDepartmentStats['$month月'] = monthlyDeptStats;
    }

    // 获取每月的详细考勤统计数据
    final monthlyAttendanceStats = <String, List<AttendanceStats>>{};
    for (int month = 1; month <= 12; month++) {
      final monthlyAttStats = await _salaryDataService
          .getMonthlyAttendanceStats(year: widget.year, month: month);
      monthlyAttendanceStats['$month月'] = monthlyAttStats;
    }

    // 获取每月的详细请假比例统计数据
    final monthlyLeaveRatioStats = <String, LeaveRatioStats>{};
    for (int month = 1; month <= 12; month++) {
      final monthlyLeaveStats = await _salaryDataService.getLeaveRatioStats(
        year: widget.year,
        month: month,
      );
      monthlyLeaveRatioStats['$month月'] = monthlyLeaveStats;
    }

    // 从数据库获取真实的月度趋势数据和年度总数据
    final monthlyTrendData = <Map<String, dynamic>>[];
    double totalSalary = 0; // 年度总工资（12个月工资总和）
    int totalEmployeeRecords = 0; // 年度总员工记录数（不去重，用于计算平均工资）
    double highestSalary = 0; // 最高工资
    double lowestSalary = double.infinity; // 最低工资
    final Set<String> uniqueEmployeeIds = <String>{}; // 用于去重统计员工数（姓名+身份证）

    // 遍历12个月获取数据
    for (int month = 1; month <= 12; month++) {
      final monthlyData = await _salaryDataService.getMonthlySalaryData(
        widget.year,
        month,
      );

      // 计算该月的总工资
      double monthlyTotalSalary = 0;
      if (monthlyData != null) {
        for (var record in monthlyData.records) {
          // 累加每个人的工资到月度总工资
          if (record.netSalary != null) {
            final salaryStr = record.netSalary!.replaceAll(
              RegExp(r'[^\d.-]'),
              '',
            );
            final salary = double.tryParse(salaryStr) ?? 0;
            monthlyTotalSalary += salary;
          }

          // 收集员工唯一标识用于去重统计（姓名+身份证，若无身份证则仅用姓名）
          String employeeId = record.name ?? '';
          if (record.idNumber != null && record.idNumber!.isNotEmpty) {
            employeeId += '_${record.idNumber}';
          }
          uniqueEmployeeIds.add(employeeId);

          // 更新最高和最低工资
          if (record.netSalary != null) {
            final salaryStr = record.netSalary!.replaceAll(
              RegExp(r'[^\d.-]'),
              '',
            );
            final salary = double.tryParse(salaryStr) ?? 0;
            if (salary > highestSalary) {
              highestSalary = salary;
            }
            if (salary < lowestSalary && salary > 0) {
              // 忽略0工资
              lowestSalary = salary;
            }
          }
        }

        // 累加员工记录数（不去重，用于计算平均工资）
        totalEmployeeRecords += monthlyData.records.length;
      }

      monthlyTrendData.add({'month': '$month月', 'salary': monthlyTotalSalary});

      // 累加到年度总工资
      totalSalary += monthlyTotalSalary;
    }

    // 如果没有数据，设置默认值
    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }

    // 计算平均工资：年度总工资除以年度总员工记录数（不去重）
    double averageSalary = totalEmployeeRecords > 0
        ? totalSalary / totalEmployeeRecords
        : 0;

    logger.info("monthlyTrendData $monthlyTrendData");

    return {
      'totalEmployees': uniqueEmployeeIds.length, // 去重后的员工数用于显示
      'totalSalary': totalSalary, // 年度总工资（12个月工资总和）
      'averageSalary': averageSalary, // 年度总工资 / 年度总员工记录数
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
      'monthlyTrend': monthlyTrendData,
      'departmentStats': departmentStats, // 年度部门统计数据
      'attendanceStats': attendanceStats, // 年度考勤统计数据
      'monthlyDepartmentStats': monthlyDepartmentStats, // 每月部门统计数据
      'monthlyAttendanceStats': monthlyAttendanceStats, // 每月考勤统计数据
      'monthlyLeaveRatioStats': monthlyLeaveRatioStats, // 每月请假比例统计数据
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isMultiYear
        ? '${widget.year}年-${widget.endYear}年 工资分析'
        : '${widget.year}年 工资分析';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isGeneratingReport
                ? null
                : () {
                    // 检查是否有分析数据再生成报告
                    if (analysisData.isNotEmpty) {
                      _generateSalaryReport(analysisData);
                    }
                  },
            tooltip: '生成报告',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('数据加载失败: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('暂无数据'));
          }

          analysisData = snapshot.data!;
          // logger.info("analysisData $analysisData");
          return _buildContent(analysisData);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> analysisData) {
    // 从分析数据中获取部门统计、考勤统计和请假比例统计数据
    final departmentStats =
        analysisData['departmentStats'] as List<DepartmentSalaryStats>;
    final attendanceStats =
        analysisData['attendanceStats'] as List<AttendanceStats>;
    final monthlyDepartmentStats =
        analysisData['monthlyDepartmentStats']
            as Map<String, List<DepartmentSalaryStats>>;
    final monthlyAttendanceStats =
        analysisData['monthlyAttendanceStats']
            as Map<String, List<AttendanceStats>>;
    final monthlyLeaveRatioStats =
        analysisData['monthlyLeaveRatioStats'] as Map<String, LeaveRatioStats>;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 关键指标卡片
                const Text(
                  '年度关键指标',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildStatCard(
                      '总人数',
                      analysisData['totalEmployees'].toString(),
                      Icons.people,
                    ),
                    _buildStatCard(
                      '工资总额',
                      '¥${analysisData['totalSalary'].toStringAsFixed(2)}',
                      Icons.account_balance_wallet,
                    ),
                    _buildStatCard(
                      '平均工资',
                      '¥${analysisData['averageSalary'].toStringAsFixed(2)}',
                      Icons.trending_up,
                    ),
                    _buildStatCard(
                      '最高工资',
                      '¥${analysisData['highestSalary'].toStringAsFixed(2)}',
                      Icons.arrow_upward,
                    ),
                    _buildStatCard(
                      '最低工资',
                      '¥${analysisData['lowestSalary'].toStringAsFixed(2)}',
                      Icons.arrow_downward,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 月度趋势图
                const Text(
                  '月度趋势',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.all(16.0),
                    child: MonthlySalaryTrendChart(
                      monthlyData: analysisData['monthlyTrend'],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 年度部门工资对比
                const Text(
                  '年度部门工资对比',
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
                              flex: 2,
                              child: Text(
                                '部门',
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
                          ],
                        ),
                        const Divider(),
                        ...departmentStats.map<Widget>((stat) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Expanded(flex: 2, child: Text(stat.department)),
                                Expanded(
                                  child: Text(
                                    '¥${stat.totalNetSalary.toStringAsFixed(2)}',
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '¥${stat.averageNetSalary.toStringAsFixed(2)}',
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

                // 按月部门工资对比
                const Text(
                  '按月部门工资对比',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...monthlyDepartmentStats.entries.map<Widget>((entry) {
                  final month = entry.key;
                  final stats = entry.value;

                  // 如果该月没有数据，则跳过
                  if (stats.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            month,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '部门',
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
                            ],
                          ),
                          const Divider(),
                          ...stats.map<Widget>((stat) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: Text(stat.department),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '¥${stat.totalNetSalary.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '¥${stat.averageNetSalary.toStringAsFixed(2)}',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // 年度考勤统计
                const Text(
                  '年度考勤统计',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        AttendancePagination(attendanceStats: attendanceStats),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 按月考勤统计
                const Text(
                  '按月考勤统计',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...monthlyAttendanceStats.entries.map<Widget>((entry) {
                  final month = entry.key;
                  final stats = entry.value;

                  // 如果该月没有数据，则跳过
                  if (stats.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            month,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AttendancePagination(attendanceStats: stats),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // 按月请假比例统计
                const Text(
                  '按月请假比例统计',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...monthlyLeaveRatioStats.entries.map<Widget>((entry) {
                  final month = entry.key;
                  final stats = entry.value;

                  // 如果该月没有数据，则跳过
                  if (stats.totalEmployees == 0) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            month,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '统计项',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '数值',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Expanded(child: Text('总员工数')),
                                Expanded(
                                  child: Text(stats.totalEmployees.toString()),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Expanded(child: Text('平均病假天数/人')),
                                Expanded(
                                  child: Text(
                                    stats.sickLeaveRatio.toStringAsFixed(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Expanded(child: Text('平均事假天数/人')),
                                Expanded(
                                  child: Text(
                                    stats.leaveRatio.toStringAsFixed(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
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

  List<Map<String, dynamic>> _generateMultiYearData(
    Map<String, dynamic> analysisData,
  ) {
    // 直接返回当前年份的数据，不生成额外的模拟数据
    // 多年度分析应该在 MultiYearAnalysisPage 中处理
    return analysisData['monthlyTrend'] as List<Map<String, dynamic>>;
  }
}
