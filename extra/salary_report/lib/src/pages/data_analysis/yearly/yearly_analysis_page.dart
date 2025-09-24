import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/components/monthly_detail_components.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart'; // 添加截图导入
import 'package:salary_report/src/common/toast.dart'; // 添加Toast导入
import 'package:salary_report/src/components/monthly_employee_changes_component.dart'; // 导入月度员工变化组件
import 'package:salary_report/src/components/department_stats_component.dart';
import 'package:salary_report/src/services/yearly/yearly_analysis_json_converter.dart'; // 添加导入

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
  Map<String, dynamic>? _previousYearData; // 上一年数据

  var future;

  // 添加截图相关变量
  final GlobalKey repaintKey = GlobalKey();
  final ScrollController controller = ScrollController();
  late ScrollableStitcher screenshotUtil;

  @override
  void initState() {
    super.initState();
    _salaryDataService = DataAnalysisService(IsarDatabase()); // 初始化服务
    future = _initAnalysisData();
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
  Future<void> _generateSalaryReport(Map<String, dynamic> analysisData) async {
    try {
      setState(() {
        _isGeneratingReport = true;
      });

      // 从分析数据中获取部门统计数据
      final departmentStats =
          analysisData['departmentStats'] as List<DepartmentSalaryStats>;

      analysisData['salarySummary'] = await _salaryDataService
          .getMonthlySummaryMap(widget.year, 1, widget.year, 12);

      // 确定开始和结束时间
      final startTime = DateTime(widget.year, 1);
      final endTime = widget.isMultiYear && widget.endYear != null
          ? DateTime(widget.endYear!, 12)
          : DateTime(widget.year, 12);

      final generator = EnhancedReportGeneratorFactory.createGenerator(
        ReportType.singleYear,
      );
      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: departmentStats, // 使用从分析数据中获取的部门统计数据
        analysisData: analysisData,
        endTime: endTime,
        year: widget.year,
        month: 0, // 年度报告没有月份
        isMultiMonth: widget.isMultiYear,
        startTime: startTime,
        attendanceStats: [], // 年度报告不需要考勤数据
        previousMonthData: null, // 年度报告不需要上月数据
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
    // 获取上一年的数据
    await _fetchPreviousYearData();

    // 使用DataAnalysisService获取年度聚合数据（整个年度的数据）
    final departmentStats = await _salaryDataService.getDepartmentSalaryStats(
      year: widget.year,
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

    // 获取每月的具体请假详情数据（直接使用考勤统计数据）
    final monthlyLeaveDetails = <String, List<AttendanceStats>>{};
    for (int month = 1; month <= 12; month++) {
      final monthlyLeaveDetailsList = await _salaryDataService
          .getMonthlyAttendanceStats(year: widget.year, month: month);
      // 过滤出有请假记录的员工
      final leaveDetails = monthlyLeaveDetailsList.where((stat) {
        return stat.sickLeaveDays > 0 || stat.leaveDays > 0;
      }).toList();
      monthlyLeaveDetails['$month月'] = leaveDetails;
    }

    // 从数据库获取真实的月度趋势数据和年度总数据
    final monthlyTrendData = <Map<String, dynamic>>[];
    final monthlyEmployeeChanges = <Map<String, dynamic>>[]; // 每月员工变化数据
    double totalSalary = 0; // 年度总工资（12个月工资总和）
    int totalEmployeeRecords = 0; // 年度总员工记录数（不去重，用于计算平均工资）
    double highestSalary = 0; // 最高工资
    double lowestSalary = double.infinity; // 最低工资
    final Set<String> uniqueEmployeeIds = <String>{}; // 用于去重统计员工数（姓名+身份证）

    // 用于计算员工变化的数据结构
    List<Map<String, dynamic>> monthlyEmployeeData = [];

    // 遍历12个月获取数据
    for (int month = 1; month <= 12; month++) {
      final monthlyData = await _salaryDataService.getMonthlySalaryData(
        widget.year,
        month,
      );

      // 计算该月的总工资
      double monthlyTotalSalary = 0;
      Set<MinimalEmployeeInfo> currentMonthEmployees = <MinimalEmployeeInfo>{};

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

          // 收集员工信息用于计算员工变化
          if (record.name != null && record.department != null) {
            currentMonthEmployees.add(
              MinimalEmployeeInfo(
                name: record.name!,
                department: record.department!,
              ),
            );
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

      monthlyTrendData.add({
        'month': '$month月',
        'totalSalary': monthlyTotalSalary,
      });

      // 存储每月员工数据用于计算变化
      monthlyEmployeeData.add({
        'month': month,
        'employees': currentMonthEmployees,
        'employeeCount': currentMonthEmployees.length,
      });

      // 累加到年度总工资
      totalSalary += monthlyTotalSalary;
    }

    // 计算每月员工变化情况
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
      'totalEmployees': totalEmployeeRecords, // 总人次（不去重）
      'totalUniqueEmployees': uniqueEmployeeIds.length, // 总人数（去重）
      'totalSalary': totalSalary, // 年度总工资（12个月工资总和）
      'averageSalary': averageSalary, // 年度总工资 / 年度总员工记录数
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
      'monthlyTrend': monthlyTrendData,
      'monthlyEmployeeChanges': monthlyEmployeeChanges, // 每月员工变化数据
      'departmentStats': departmentStats, // 年度部门统计数据
      'attendanceStats': attendanceStats, // 年度考勤统计数据
      'monthlyDepartmentStats': monthlyDepartmentStats, // 每月部门统计数据
      'monthlyAttendanceStats': monthlyAttendanceStats, // 每月考勤统计数据
      'monthlyLeaveDetails': monthlyLeaveDetails, // 每月具体请假详情数据
    };
  }

  /// 获取上一年的数据
  Future<void> _fetchPreviousYearData() async {
    try {
      // 获取上一年的年份
      final previousYear = widget.year - 1;

      // 获取上一年的部门统计数据（整个年度的数据）
      final previousDepartmentStats = await _salaryDataService
          .getDepartmentSalaryStats(year: previousYear);

      if (previousDepartmentStats.isNotEmpty) {
        // 计算上一年的总员工数和总工资
        int totalEmployees = 0;
        double totalSalary = 0;
        int totalEmployeeRecords = 0; // 上一年总员工记录数（不去重，用于计算平均工资）
        final Set<String> uniqueEmployeeIds = <String>{}; // 用于去重统计员工数

        // 遍历上一年12个月获取数据
        for (int month = 1; month <= 12; month++) {
          final monthlyData = await _salaryDataService.getMonthlySalaryData(
            previousYear,
            month,
          );

          if (monthlyData != null) {
            // 累加员工记录数（不去重，用于计算平均工资）
            totalEmployeeRecords += monthlyData.records.length;

            // 累加上一年的总工资
            for (var record in monthlyData.records) {
              if (record.netSalary != null) {
                final salaryStr = record.netSalary!.replaceAll(
                  RegExp(r'[^\d.-]'),
                  '',
                );
                final salary = double.tryParse(salaryStr) ?? 0;
                totalSalary += salary;

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

        // 计算上一年的平均工资
        final averageSalary = totalEmployeeRecords > 0
            ? totalSalary / totalEmployeeRecords
            : 0;

        setState(() {
          _previousYearData = {
            'year': previousYear,
            'totalEmployees': totalEmployeeRecords, // 总人次（不去重）
            'totalUniqueEmployees': uniqueEmployeeIds.length, // 总人数（去重）
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
          };
        });
      }
    } catch (e) {
      print('获取上一年数据失败: $e');
      // 不处理错误，因为这是可选的数据显示
    }
  }

  late ReportService reportService = ReportService();

  /// 生成JSON格式的分析报告
  Future<String> _generateJsonReport(Map<String, dynamic> analysisData) {
    // 从分析数据中获取部门统计数据
    final departmentStats =
        analysisData['departmentStats'] as List<DepartmentSalaryStats>;

    // 从分析数据中获取考勤统计数据
    final attendanceStats =
        analysisData['attendanceStats'] as List<AttendanceStats>;

    return Future.value(
      YearlyAnalysisJsonConverter.convertAnalysisDataToJson(
        analysisData: analysisData,
        departmentStats: departmentStats,
        attendanceStats: attendanceStats,
        previousYearData: _previousYearData,
        year: widget.year,
      ),
    );
  }

  /// 显示JSON报告
  Future<void> _showJsonReport(Map<String, dynamic> analysisData) async {
    try {
      final jsonReport = await _generateJsonReport(analysisData);

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
              onPressed: analysisData.isNotEmpty
                  ? () {
                      _showJsonReport(analysisData);
                    }
                  : null,
              tooltip: '查看JSON报告',
            ),
          SizedBox(width: 8),
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
    final monthlyLeaveDetails =
        analysisData['monthlyLeaveDetails']
            as Map<String, List<AttendanceStats>>;
    final monthlyEmployeeChanges =
        analysisData['monthlyEmployeeChanges']
            as List<Map<String, dynamic>>; // 获取每月员工变化数据

    return Stack(
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
                  if (_previousYearData != null) ...[
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
                            text: '${_previousYearData!['year']}年基本情况',
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
                          _previousYearData!['totalEmployees'].toString(),
                          Icons.people,
                        ),
                        _buildStatCard(
                          '总人数',
                          _previousYearData!['totalUniqueEmployees'].toString(),
                          Icons.group,
                        ),
                        _buildStatCard(
                          '工资总额',
                          '${_previousYearData!['totalSalary'].toStringAsFixed(2)}元',
                          Icons.account_balance_wallet,
                        ),
                        _buildStatCard(
                          '平均工资',
                          '${_previousYearData!['averageSalary'].toStringAsFixed(2)}元',
                          Icons.trending_up,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

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
                        '总人次',
                        analysisData['totalEmployees'].toString(),
                        Icons.people,
                      ),
                      _buildStatCard(
                        '总人数',
                        analysisData['totalUniqueEmployees'].toString(),
                        Icons.group,
                      ),
                      _buildStatCard(
                        '工资总额',
                        '${analysisData['totalSalary'].toStringAsFixed(2)}元',
                        Icons.account_balance_wallet,
                      ),
                      _buildStatCard(
                        '平均工资',
                        '${analysisData['averageSalary'].toStringAsFixed(2)}元',
                        Icons.trending_up,
                      ),
                      _buildStatCard(
                        '最高工资',
                        '${analysisData['highestSalary'].toStringAsFixed(2)}元',
                        Icons.arrow_upward,
                      ),
                      _buildStatCard(
                        '最低工资',
                        '${analysisData['lowestSalary'].toStringAsFixed(2)}元',
                        Icons.arrow_downward,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 每月员工变动情况
                  const Text(
                    '每月员工变动情况',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  MonthlyEmployeeChangesComponent(
                    monthlyChanges: monthlyEmployeeChanges,
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
                  DepartmentStatsComponent(
                    departmentStats: departmentStats,
                    title: '年度部门工资对比',
                  ),

                  const SizedBox(height: 24),

                  // 按月部门工资对比
                  MonthlyDetailContainer(
                    title: '按月部门工资对比',
                    monthlyData: monthlyDepartmentStats,
                    builder: (month, data) {
                      return MonthlyDepartmentDetail(
                        departmentStats: data as List<DepartmentSalaryStats>,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 按月考勤统计
                  MonthlyDetailContainer(
                    title: '按月考勤统计',
                    monthlyData: monthlyAttendanceStats,
                    builder: (month, data) {
                      return MonthlyAttendanceDetail(
                        attendanceStats: data as List<AttendanceStats>,
                      );
                    },
                  ),

                  // 按月具体请假详情
                  // MonthlyDetailContainer(
                  //   title: '按月具体请假详情',
                  //   monthlyData: monthlyLeaveDetails,
                  //   builder: (month, data) {
                  //     return _buildLeaveDetails(data as List<AttendanceStats>);
                  //   },
                  // ),
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
    );
  }

  /// 从月份字符串中提取月份数字
  int _extractMonthNumber(String monthString) {
    final RegExp regExp = RegExp(r'(\d+)月');
    final match = regExp.firstMatch(monthString);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 1; // 默认返回1月
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

  Widget _buildComparisonStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 1,
      child: SizedBox(
        width: 120,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建请假详情组件
  Widget _buildLeaveDetails(List<AttendanceStats> leaveDetails) {
    logger.info("buildLeaveDetails $leaveDetails");

    if (leaveDetails.isEmpty) {
      return const Center(child: Text('没有请假记录'));
    }

    return LeaveDetailBuilder.buildLeaveDetails(leaveDetails);
  }
}
