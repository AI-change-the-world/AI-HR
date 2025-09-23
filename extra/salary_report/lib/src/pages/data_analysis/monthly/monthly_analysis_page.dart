import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:salary_report/src/common/scroll_screenshot.dart';
import 'package:salary_report/src/common/toast.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_monthly_report_generator.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/components/attendance_pagination.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:toastification/toastification.dart';
import 'package:salary_report/src/isar/salary_list.dart';
import 'package:salary_report/src/components/employee_changes_component.dart';
import 'package:salary_report/src/components/department_stats_component.dart';
import 'package:salary_report/src/utils/monthly_analysis_json_converter.dart';

class MonthlyAnalysisPage extends StatefulWidget {
  const MonthlyAnalysisPage({
    super.key,
    required this.year,
    required this.month,
    this.isMultiMonth = false,
  });

  final int year;
  final int month;
  final bool isMultiMonth;

  @override
  State<MonthlyAnalysisPage> createState() => _MonthlyAnalysisPageState();
}

class _MonthlyAnalysisPageState extends State<MonthlyAnalysisPage> {
  late Map<String, dynamic> _analysisData;
  final GlobalKey _chartContainerKey = GlobalKey();
  bool _isGeneratingReport = false;
  bool _isLoading = true;
  late DataAnalysisService _salaryDataService;
  List<DepartmentSalaryStats> _departmentStats = [];
  List<AttendanceStats> _attendanceStats = [];
  LeaveRatioStats? _leaveRatioStats;
  Map<String, dynamic>? _previousMonthData; // 上月数据

  @override
  void initState() {
    super.initState();
    _salaryDataService = DataAnalysisService(IsarDatabase());
    _initAnalysisData();
    screenshotUtil = ScrollableStitcher(
      repaintBoundaryKey: repaintKey,
      scrollController: controller,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _initAnalysisData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 获取上月数据
      await _fetchPreviousMonthData();

      // 使用DataAnalysisService获取数据
      final departmentStats = await _salaryDataService.getDepartmentAggregation(
        widget.year,
        widget.month,
      );

      // 获取考勤统计数据
      final attendanceStats = await _salaryDataService
          .getMonthlyAttendanceStats(year: widget.year, month: widget.month);

      // 获取请假比例统计数据
      final leaveRatioStats = await _salaryDataService.getLeaveRatioStats(
        year: widget.year,
        month: widget.month,
      );

      // 更新本地状态
      setState(() {
        _departmentStats = departmentStats;
        _attendanceStats = attendanceStats;
        _leaveRatioStats = leaveRatioStats;
      });

      // 计算总工资和平均工资
      double totalSalary = 0;
      int totalEmployees = 0;
      double highestSalary = 0;
      double lowestSalary = double.infinity;

      // 获取当月工资数据用于去重统计
      final monthlySalaryData = await _salaryDataService.getMonthlySalaryData(
        widget.year,
        widget.month,
      );

      // 收集员工唯一标识用于去重统计（姓名+身份证，若无身份证则仅用姓名）
      final Set<String> uniqueEmployeeIds = <String>{};
      // 收集当月员工姓名列表
      final List<MinimalEmployeeInfo> currentEmployees =
          <MinimalEmployeeInfo>[];
      if (monthlySalaryData != null) {
        for (var record in monthlySalaryData.records) {
          String employeeId = record.name ?? '';
          if (record.idNumber != null && record.idNumber!.isNotEmpty) {
            employeeId += '_${record.idNumber}';
          }
          uniqueEmployeeIds.add(employeeId);

          // 收集员工信息
          if (record.name != null && record.department != null) {
            currentEmployees.add(
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

            // 更新最高和最低工资
            if (salary > monthlyHighestSalary) {
              monthlyHighestSalary = salary;
            }
            if (salary < monthlyLowestSalary && salary > 0) {
              // 忽略0工资
              monthlyLowestSalary = salary;
            }
          }
        }
      }

      // 使用正确的月度统计数据
      totalSalary = monthlyTotalSalary;
      totalEmployees = monthlyTotalEmployeeCount;
      highestSalary = monthlyHighestSalary;
      lowestSalary = monthlyLowestSalary;

      // 确保最低工资有合理的默认值
      if (lowestSalary == double.infinity) {
        lowestSalary = 0;
      }

      double averageSalary = totalEmployees > 0
          ? totalSalary / totalEmployees
          : 0;

      for (var stat in departmentStats) {
        // 注意：这里不再使用部门统计数据来计算最高最低工资
        // 因为最高最低工资应该是个人的实际工资，而不是部门的平均工资
      }

      // 构建部门统计数据
      final departmentStatsData = departmentStats.map((stat) {
        return {
          'department': stat.department,
          'count': stat.employeeCount,
          'average': stat.averageNetSalary,
          'total': stat.totalNetSalary,
        };
      }).toList();

      // 为单月情况准备月度数据
      final monthlyData = [
        {'month': '${widget.month}月', 'salary': totalSalary},
      ];

      // 计算薪资区间分布数据
      final salaryRanges = await _salaryDataService.getSalaryRangeAggregation(
        widget.year,
        widget.month,
      );

      // 计算部门和薪资范围联合统计数据
      final departmentSalaryRangeStats = await _salaryDataService
          .getDepartmentSalaryRangeAggregation(widget.year, widget.month);

      // 获取工资最高的前10名员工
      final topSalaryEmployees = await _salaryDataService.getTopSalaryEmployees(
        year: widget.year,
        month: widget.month,
        limit: 10,
      );

      // 获取工资最低的前10名员工
      final bottomSalaryEmployees = await _salaryDataService
          .getBottomSalaryEmployees(
            year: widget.year,
            month: widget.month,
            limit: 10,
          );

      // 获取工资汇总数据
      final salarySummary = await _salaryDataService.getSalarySummaryData(
        year: widget.year,
        month: widget.month,
      );

      setState(() {
        _analysisData = {
          'totalEmployees': totalEmployees, // 总人次（不去重）
          'totalUniqueEmployees': uniqueEmployeeIds.length, // 总人数（去重）
          'totalSalary': totalSalary,
          'averageSalary': averageSalary,
          'highestSalary': highestSalary,
          'lowestSalary': lowestSalary,
          'departmentStats': departmentStatsData,
          'monthlyData': monthlyData,
          'salaryRanges': salaryRanges,
          'departmentSalaryRangeStats': departmentSalaryRangeStats,
          'topSalaryEmployees': topSalaryEmployees,
          'bottomSalaryEmployees': bottomSalaryEmployees,
          'salarySummary': salarySummary,
          'currentEmployees': currentEmployees, // 当月员工列表
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

  /// 获取上月数据
  Future<void> _fetchPreviousMonthData() async {
    try {
      // 计算上月的年份和月份
      int previousYear = widget.year;
      int previousMonth = widget.month - 1;

      if (previousMonth == 0) {
        // 如果是1月，上月就是去年的12月
        previousYear = widget.year - 1;
        previousMonth = 12;
      }

      // 获取上月的部门统计数据
      final previousDepartmentStats = await _salaryDataService
          .getDepartmentAggregation(previousYear, previousMonth);

      if (previousDepartmentStats.isNotEmpty) {
        // 计算上月的总员工数和总工资
        int totalEmployees = 0;
        double totalSalary = 0;
        double highestSalary = 0;
        double lowestSalary = double.infinity;

        // 获取上月工资数据用于去重统计
        final previousMonthlySalaryData = await _salaryDataService
            .getMonthlySalaryData(previousYear, previousMonth);

        // 收集员工唯一标识用于去重统计（姓名+身份证，若无身份证则仅用姓名）
        final Set<String> uniqueEmployeeIds = <String>{};
        // 收集上月员工姓名列表
        final List<MinimalEmployeeInfo> previousEmployees =
            <MinimalEmployeeInfo>[];
        if (previousMonthlySalaryData != null) {
          for (var record in previousMonthlySalaryData.records) {
            String employeeId = record.name ?? '';
            if (record.idNumber != null && record.idNumber!.isNotEmpty) {
              employeeId += '_${record.idNumber}';
            }
            uniqueEmployeeIds.add(employeeId);

            // 收集员工信息
            if (record.name != null && record.department != null) {
              previousEmployees.add(
                MinimalEmployeeInfo(
                  name: record.name!,
                  department: record.department!,
                ),
              );
            }
          }
        }

        // 重新计算上月总工资和员工数（正确的方式）
        double monthlyTotalSalary = 0.0;
        int monthlyTotalEmployeeCount = 0;
        double monthlyHighestSalary = 0.0;
        double monthlyLowestSalary = double.infinity;

        // 获取上月工资数据用于最高最低工资计算
        if (previousMonthlySalaryData != null) {
          for (var record in previousMonthlySalaryData.records) {
            if (record.netSalary != null) {
              final salaryStr = record.netSalary!.replaceAll(
                RegExp(r'[^\d.-]'),
                '',
              );
              final salary = double.tryParse(salaryStr) ?? 0;
              monthlyTotalSalary += salary;
              monthlyTotalEmployeeCount++;

              // 更新最高和最低工资
              if (salary > monthlyHighestSalary) {
                monthlyHighestSalary = salary;
              }
              if (salary < monthlyLowestSalary && salary > 0) {
                // 忽略0工资
                monthlyLowestSalary = salary;
              }
            }
          }
        }

        // 使用正确的月度统计数据
        totalSalary = monthlyTotalSalary;
        totalEmployees = monthlyTotalEmployeeCount;
        highestSalary = monthlyHighestSalary;
        lowestSalary = monthlyLowestSalary;

        // 确保最低工资有合理的默认值
        if (lowestSalary == double.infinity) {
          lowestSalary = 0;
        }

        final averageSalary = totalEmployees > 0
            ? totalSalary / totalEmployees
            : 0;

        for (var stat in previousDepartmentStats) {
          // 注意：这里不再使用部门统计数据来计算最高最低工资
          // 因为最高最低工资应该是个人的实际工资，而不是部门的平均工资
        }

        setState(() {
          _previousMonthData = {
            'year': previousYear,
            'month': previousMonth,
            'totalEmployees': totalEmployees, // 总人次（不去重）
            'totalUniqueEmployees': uniqueEmployeeIds.length, // 总人数（去重）
            'totalSalary': totalSalary,
            'averageSalary': averageSalary,
            'highestSalary': highestSalary, // 添加最高工资
            'lowestSalary': lowestSalary, // 添加最低工资
            'previousEmployees': previousEmployees, // 上月员工列表
          };
        });
      }
    } catch (e) {
      print('获取上月数据失败: $e');
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
      final startTime = DateTime(widget.year, widget.month);
      final endTime = widget.isMultiMonth
          ? DateTime(widget.year, widget.month)
          : DateTime(widget.year, widget.month);

      // 使用增强版报告生成器
      final generator = EnhancedMonthlyReportGenerator();
      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _chartContainerKey,
        departmentStats: _departmentStats,
        analysisData: _analysisData,
        attendanceStats: _attendanceStats,
        previousMonthData: _previousMonthData,
        year: widget.year,
        month: widget.month,
        isMultiMonth: widget.isMultiMonth,
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

  /// 生成JSON格式的分析报告
  Future<String> _generateJsonReport() {
    return Future.value(
      MonthlyAnalysisJsonConverter.convertAnalysisDataToJson(
        analysisData: _analysisData,
        departmentStats: _departmentStats,
        attendanceStats: _attendanceStats,
        previousMonthData: _previousMonthData,
        year: widget.year,
        month: widget.month,
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

  final GlobalKey repaintKey = GlobalKey();
  final ScrollController controller = ScrollController();
  late ScrollableStitcher screenshotUtil;

  late ReportService reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.year}年${widget.month.toString().padLeft(2, '0')}月 工资分析',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final title = widget.isMultiMonth
        ? '${widget.year}年${widget.month.toString().padLeft(2, '0')}月起 工资分析'
        : '${widget.year}年${widget.month.toString().padLeft(2, '0')}月 工资分析';

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
          SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isGeneratingReport ? null : _generateSalaryReport,
            tooltip: '生成报告',
          ),
          SizedBox(width: 8),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.code),
              onPressed: _showJsonReport,
              tooltip: '查看JSON报告',
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
                    // 上月数据展示（如果存在）
                    if (_previousMonthData != null) ...[
                      // const Text(
                      //   '上月对比',
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${_previousMonthData!['year']}年${_previousMonthData!['month']}月基本情况',
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
                            _previousMonthData!['totalEmployees'].toString(),
                            Icons.people,
                          ),
                          _buildStatCard(
                            '总人数',
                            _previousMonthData!['totalUniqueEmployees']
                                .toString(),
                            Icons.group,
                          ),
                          _buildStatCard(
                            '工资总额',
                            '¥${_previousMonthData!['totalSalary'].toStringAsFixed(2)}',
                            Icons.account_balance_wallet,
                          ),
                          _buildStatCard(
                            '平均工资',
                            '¥${_previousMonthData!['averageSalary'].toStringAsFixed(2)}',
                            Icons.trending_up,
                          ),
                          _buildStatCard(
                            '最高工资',
                            '¥${_previousMonthData!['highestSalary'].toStringAsFixed(2)}',
                            Icons.arrow_upward,
                          ),
                          _buildStatCard(
                            '最低工资',
                            '¥${_previousMonthData!['lowestSalary'].toStringAsFixed(2)}',
                            Icons.arrow_downward,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 关键指标卡片
                    const Text(
                      '关键指标',
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
                          '工资总额',
                          '¥${_analysisData['totalSalary'].toStringAsFixed(2)}',
                          Icons.account_balance_wallet,
                        ),
                        _buildStatCard(
                          '平均工资',
                          '¥${_analysisData['averageSalary'].toStringAsFixed(2)}',
                          Icons.trending_up,
                        ),
                        _buildStatCard(
                          '最高工资',
                          '¥${_analysisData['highestSalary'].toStringAsFixed(2)}',
                          Icons.arrow_upward,
                        ),
                        _buildStatCard(
                          '最低工资',
                          '¥${_analysisData['lowestSalary'].toStringAsFixed(2)}',
                          Icons.arrow_downward,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 人员变动情况
                    if (_previousMonthData != null &&
                        _analysisData.containsKey('currentEmployees') &&
                        _previousMonthData!.containsKey(
                          'previousEmployees',
                        )) ...[
                      EmployeeChangesComponent(
                        newEmployees: _calculateNewEmployees(
                          _analysisData['currentEmployees']
                              as List<MinimalEmployeeInfo>,
                          _previousMonthData!['previousEmployees']
                              as List<MinimalEmployeeInfo>,
                        ),
                        resignedEmployees: _calculateResignedEmployees(
                          _analysisData['currentEmployees']
                              as List<MinimalEmployeeInfo>,
                          _previousMonthData!['previousEmployees']
                              as List<MinimalEmployeeInfo>,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 部门工资占比饼图
                    const Text(
                      '各部门工资占比',
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
                        child: DepartmentSalaryChart(
                          departmentStats: _departmentStats,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 部门统计
                    DepartmentStatsComponent(
                      departmentStats: _departmentStats,
                      title: '月度部门工资对比',
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
                                        Expanded(child: Text(range.range)),
                                        Expanded(
                                          child: Text(
                                            range.employeeCount.toString(),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '¥${range.totalSalary.toStringAsFixed(2)}',
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '¥${range.averageSalary.toStringAsFixed(2)}',
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
                                            '¥${deptRange.totalSalary.toStringAsFixed(2)}',
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '¥${deptRange.averageSalary.toStringAsFixed(2)}',
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

                    // 工资最高的员工
                    const Text(
                      '工资最高的员工（前10名）',
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
                                  flex: 2,
                                  child: Text(
                                    '姓名',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '部门',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '职位',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '实发工资',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            ...(_analysisData['topSalaryEmployees'] as List)
                                .map<Widget>((record) {
                                  // 确保类型正确
                                  if (record is SalaryListRecord) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text(record.name ?? ''),
                                          ),
                                          Expanded(
                                            child: Text(
                                              record.department ?? '',
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(record.position ?? ''),
                                          ),
                                          Expanded(
                                            child: Text(record.netSalary ?? ''),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 工资最低的员工
                    const Text(
                      '工资最低的员工（前10名）',
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
                                  flex: 2,
                                  child: Text(
                                    '姓名',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '部门',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '职位',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '实发工资',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            ...(_analysisData['bottomSalaryEmployees'] as List)
                                .map<Widget>((record) {
                                  // 确保类型正确
                                  if (record is SalaryListRecord) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text(record.name ?? ''),
                                          ),
                                          Expanded(
                                            child: Text(
                                              record.department ?? '',
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(record.position ?? ''),
                                          ),
                                          Expanded(
                                            child: Text(record.netSalary ?? ''),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
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
                            AttendancePagination(
                              attendanceStats: _attendanceStats,
                            ),
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

  /// 计算新入职员工
  List<MinimalEmployeeInfo> _calculateNewEmployees(
    List<MinimalEmployeeInfo> currentEmployees,
    List<MinimalEmployeeInfo> previousEmployees,
  ) {
    final currentSet = currentEmployees
        .map((e) => '${e.name}_${e.department}')
        .toSet();
    final previousSet = previousEmployees
        .map((e) => '${e.name}_${e.department}')
        .toSet();
    final newEmployeeKeys = currentSet.difference(previousSet);

    return currentEmployees.where((employee) {
      final key = '${employee.name}_${employee.department}';
      return newEmployeeKeys.contains(key);
    }).toList();
  }

  /// 计算离职员工
  List<MinimalEmployeeInfo> _calculateResignedEmployees(
    List<MinimalEmployeeInfo> currentEmployees,
    List<MinimalEmployeeInfo> previousEmployees,
  ) {
    final currentSet = currentEmployees
        .map((e) => '${e.name}_${e.department}')
        .toSet();
    final previousSet = previousEmployees
        .map((e) => '${e.name}_${e.department}')
        .toSet();
    final resignedEmployeeKeys = previousSet.difference(currentSet);

    return previousEmployees.where((employee) {
      final key = '${employee.name}_${employee.department}';
      return resignedEmployeeKeys.contains(key);
    }).toList();
  }
}
