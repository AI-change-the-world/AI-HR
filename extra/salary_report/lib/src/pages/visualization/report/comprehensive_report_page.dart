import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:salary_report/src/components/salary_charts.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 创建一个 Provider 来管理数据服务
final dataAnalysisServiceProvider = Provider<DataAnalysisService>((ref) {
  final database = IsarDatabase();
  return DataAnalysisService(database);
});

class ComprehensiveReportPage extends ConsumerStatefulWidget {
  const ComprehensiveReportPage({super.key});

  @override
  ConsumerState<ComprehensiveReportPage> createState() =>
      _ComprehensiveReportPageState();
}

class _ComprehensiveReportPageState
    extends ConsumerState<ComprehensiveReportPage> {
  List<DepartmentSalaryStats> _departmentStats = [];
  List<AttendanceStats> _attendanceStats = [];
  List<Map<String, dynamic>> _monthlySalaryData = [];
  List<Map<String, dynamic>> _quarterlySalaryData = [];
  List<Map<String, dynamic>> _departmentMonthlyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = ref.read(dataAnalysisServiceProvider);

      // 获取当前年份
      final currentYear = DateTime.now().year;

      // 1. 获取各部门工资统计
      final departmentStats = await dataService.getDepartmentSalaryStats(
        year: currentYear,
      );
      _departmentStats = departmentStats;

      // 2. 获取考勤统计
      final attendanceStats = await dataService.getMonthlyAttendanceStats(
        year: currentYear,
      );
      _attendanceStats = attendanceStats;

      // 3. 计算月度工资数据
      _monthlySalaryData = await _calculateMonthlySalaryData(
        dataService,
        currentYear,
      );

      // 4. 计算季度工资数据
      _quarterlySalaryData = await _calculateQuarterlySalaryData(
        dataService,
        currentYear,
      );

      // 5. 计算各部门月度工资数据
      _departmentMonthlyData = await _calculateDepartmentMonthlyData(
        dataService,
        currentYear,
      );
    } catch (e) {
      print('加载数据时出错: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _calculateMonthlySalaryData(
    DataAnalysisService service,
    int year,
  ) async {
    final monthlyData = <Map<String, dynamic>>[];

    // 获取每个月的数据
    for (int month = 1; month <= 12; month++) {
      final stats = await service.getDepartmentSalaryStats(
        year: year,
        month: month,
      );

      // 计算该月的总工资
      double totalSalary = 0;
      for (var stat in stats) {
        totalSalary += stat.totalNetSalary;
      }

      monthlyData.add({'month': '${month}月', 'salary': totalSalary});
    }

    return monthlyData;
  }

  Future<List<Map<String, dynamic>>> _calculateQuarterlySalaryData(
    DataAnalysisService service,
    int year,
  ) async {
    final quarterlyData = <Map<String, dynamic>>[];

    // 获取每个季度的数据
    for (int quarter = 1; quarter <= 4; quarter++) {
      final stats = await service.getQuarterlyDepartmentSalaryStats(
        year: year,
        quarter: quarter,
      );

      // 计算该季度的总工资
      double totalSalary = 0;
      for (var stat in stats) {
        totalSalary += stat.totalNetSalary;
      }

      quarterlyData.add({'quarter': 'Q$quarter', 'salary': totalSalary});
    }

    return quarterlyData;
  }

  Future<List<Map<String, dynamic>>> _calculateDepartmentMonthlyData(
    DataAnalysisService service,
    int year,
  ) async {
    final departmentMonthlyData = <Map<String, dynamic>>[];

    // 获取每个月各部门的数据
    for (int month = 1; month <= 12; month++) {
      final stats = await service.getDepartmentSalaryStats(
        year: year,
        month: month,
      );

      // 按部门组织数据
      final departmentData = <String, double>{};
      for (var stat in stats) {
        departmentData[stat.department] = stat.totalNetSalary;
      }

      departmentMonthlyData.add({
        'month': '${month}月',
        'departments': departmentData,
      });
    }

    return departmentMonthlyData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('综合可视化报告'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 报告标题
                    const Text(
                      '工资分析综合报告',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '生成时间: ${DateFormat('yyyy年MM月dd日').format(DateTime.now())}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // 添加说明文本
                    const Card(
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '数据说明',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '本报告展示了公司工资数据的综合分析，包括各部门工资占比、月度工资趋势、季度工资趋势以及考勤统计等信息。数据来源于已上传的工资表。',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 检查是否有数据
                    if (_departmentStats.isEmpty &&
                        _attendanceStats.isEmpty &&
                        _monthlySalaryData.isEmpty)
                      const Card(
                        elevation: 3,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Colors.lightBlue,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '暂无数据',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '请先上传工资表数据，然后刷新此页面以查看分析报告。',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // 关键指标概览
                      const Text(
                        '关键指标概览',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSummaryCard(
                                    '总员工数',
                                    '${_calculateTotalEmployees()}人',
                                    Icons.people,
                                  ),
                                  _buildSummaryCard(
                                    '工资总额',
                                    '¥${NumberFormat('#,##0').format(_calculateTotalSalary())}',
                                    Icons.account_balance_wallet,
                                  ),
                                  _buildSummaryCard(
                                    '平均工资',
                                    '¥${NumberFormat('#,##0').format(_calculateAverageSalary())}',
                                    Icons.trending_up,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSummaryCard(
                                    '最高工资',
                                    '¥${NumberFormat('#,##0').format(_calculateHighestSalary())}',
                                    Icons.arrow_upward,
                                  ),
                                  _buildSummaryCard(
                                    '最低工资',
                                    '¥${NumberFormat('#,##0').format(_calculateLowestSalary())}',
                                    Icons.arrow_downward,
                                  ),
                                  _buildSummaryCard(
                                    '部门数',
                                    '${_departmentStats.length}个',
                                    Icons.business,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 部门工资占比饼图
                      const Text(
                        '各部门工资占比',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 3,
                        child: Container(
                          height: 300,
                          padding: const EdgeInsets.all(16.0),
                          child: DepartmentSalaryChart(
                            departmentStats: _departmentStats,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 月度工资趋势折线图
                      const Text(
                        '月度工资趋势',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 3,
                        child: Container(
                          height: 300,
                          padding: const EdgeInsets.all(16.0),
                          child: MonthlySalaryTrendChart(
                            monthlyData: _monthlySalaryData,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 各部门月度工资趋势
                      const Text(
                        '各部门月度工资趋势',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 3,
                        child: Container(
                          height: 300,
                          padding: const EdgeInsets.all(16.0),
                          child: MultiMonthDepartmentSalaryChart(
                            departmentMonthlyData: _departmentMonthlyData,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 季度工资趋势
                      const Text(
                        '季度工资趋势',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 3,
                        child: Container(
                          height: 300,
                          padding: const EdgeInsets.all(16.0),
                          child: SfCartesianChart(
                            title: ChartTitle(text: '季度工资总额趋势'),
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.simpleCurrency(),
                            ),
                            legend: Legend(isVisible: true),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CartesianSeries>[
                              LineSeries<Map<String, dynamic>, String>(
                                dataSource: _quarterlySalaryData,
                                xValueMapper: (Map<String, dynamic> data, _) =>
                                    data['quarter'],
                                yValueMapper: (Map<String, dynamic> data, _) =>
                                    data['salary'],
                                name: '工资总额',
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 考勤统计
                      const Text(
                        '考勤统计',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 3,
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
                                      '病假(天)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '事假(天)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              ..._attendanceStats.take(10).map<Widget>((stat) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Expanded(flex: 2, child: Text(stat.name)),
                                      Expanded(child: Text(stat.department)),
                                      Expanded(
                                        child: Text(
                                          stat.sickLeaveDays.toStringAsFixed(1),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          stat.leaveDays.toStringAsFixed(1),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              if (_attendanceStats.length > 10)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('... 还有更多记录'),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 导出按钮
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: 导出为PDF
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('导出PDF'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: 导出为Excel
                              },
                              icon: const Icon(Icons.table_chart),
                              label: const Text('导出Excel'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.lightBlue),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 计算总员工数
  int _calculateTotalEmployees() {
    int total = 0;
    for (var stat in _departmentStats) {
      total += stat.employeeCount;
    }
    return total;
  }

  // 计算工资总额
  double _calculateTotalSalary() {
    double total = 0;
    for (var stat in _departmentStats) {
      total += stat.totalNetSalary;
    }
    return total;
  }

  // 计算平均工资
  double _calculateAverageSalary() {
    if (_departmentStats.isEmpty) return 0;
    double totalSalary = _calculateTotalSalary();
    int totalEmployees = _calculateTotalEmployees();
    return totalEmployees > 0 ? totalSalary / totalEmployees : 0;
  }

  // 计算最高工资
  double _calculateHighestSalary() {
    if (_departmentStats.isEmpty) return 0;
    double maxSalary = 0;
    for (var stat in _departmentStats) {
      if (stat.averageNetSalary > maxSalary) {
        maxSalary = stat.averageNetSalary;
      }
    }
    return maxSalary;
  }

  // 计算最低工资
  double _calculateLowestSalary() {
    if (_departmentStats.isEmpty) return 0;
    double minSalary = double.infinity;
    for (var stat in _departmentStats) {
      if (stat.averageNetSalary < minSalary) {
        minSalary = stat.averageNetSalary;
      }
    }
    return minSalary == double.infinity ? 0 : minSalary;
  }
}
