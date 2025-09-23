// src/pages/visualization/report/enhanced_report_example_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_factory.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
// 移除了file_picker导入
// 移除了open_file导入

// 创建一个 Provider 来管理数据服务
final dataAnalysisServiceProvider = Provider<DataAnalysisService>((ref) {
  final database = IsarDatabase();
  return DataAnalysisService(database);
});

class EnhancedReportExamplePage extends ConsumerStatefulWidget {
  const EnhancedReportExamplePage({super.key});

  @override
  ConsumerState<EnhancedReportExamplePage> createState() =>
      _EnhancedReportExamplePageState();
}

class _EnhancedReportExamplePageState
    extends ConsumerState<EnhancedReportExamplePage> {
  bool _isLoading = false;
  String _statusMessage = '';
  ReportType _selectedReportType = ReportType.singleMonth;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final GlobalKey _previewContainerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('增强版报告生成示例'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 报告类型选择
              const Text(
                '选择报告类型',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButton<ReportType>(
                value: _selectedReportType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: ReportType.singleMonth,
                    child: Text('单月报告'),
                  ),
                  DropdownMenuItem(
                    value: ReportType.multiMonth,
                    child: Text('多月报告'),
                  ),
                  DropdownMenuItem(
                    value: ReportType.singleQuarter,
                    child: Text('单季度报告'),
                  ),
                  DropdownMenuItem(
                    value: ReportType.multiQuarter,
                    child: Text('多季度报告'),
                  ),
                  DropdownMenuItem(
                    value: ReportType.singleYear,
                    child: Text('单年报告'),
                  ),
                  DropdownMenuItem(
                    value: ReportType.multiYear,
                    child: Text('多年报告'),
                  ),
                ],
                onChanged: (ReportType? value) {
                  if (value != null) {
                    setState(() {
                      _selectedReportType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // 时间范围选择
              const Text(
                '选择时间范围',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('开始时间'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null && picked != _startDate) {
                              setState(() {
                                _startDate = picked;
                              });
                            }
                          },
                          child: Text(
                            '${_startDate.year}年${_startDate.month}月${_startDate.day}日',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('结束时间'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null && picked != _endDate) {
                              setState(() {
                                _endDate = picked;
                              });
                            }
                          },
                          child: Text(
                            '${_endDate.year}年${_endDate.month}月${_endDate.day}日',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 预览容器（用于生成图表）
              Container(
                key: _previewContainerKey,
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '图表预览区域\n（用于生成报告中的图表）',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 生成报告按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateEnhancedReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text('正在生成报告...'),
                          ],
                        )
                      : const Text('生成增强版报告', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),

              // 状态信息
              if (_statusMessage.isNotEmpty)
                Card(
                  color: _statusMessage.contains('成功')
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('成功')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 生成增强版报告
  Future<void> _generateEnhancedReport() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在生成报告...';
    });

    try {
      // 获取数据服务
      final dataService = ref.read(dataAnalysisServiceProvider);

      // 根据选择的时间范围获取数据
      final departmentStats = await dataService.getDepartmentSalaryStats(
        year: _startDate.year,
        month: _startDate.month,
      );

      final attendanceStats = await dataService.getMonthlyAttendanceStats(
        year: _startDate.year,
        month: _startDate.month,
      );

      // 构造分析数据（这里简化处理，实际应用中应根据具体需求构造）
      final analysisData = {
        'departmentStats': departmentStats,
        'salaryRanges': await dataService.getSalaryRangeAggregation(
          _startDate.year,
          _startDate.month,
        ),
        'totalEmployees': departmentStats.fold(
          0,
          (sum, stat) => sum + stat.employeeCount,
        ),
        'totalSalary': departmentStats.fold(
          0.0,
          (sum, stat) => sum + stat.totalNetSalary,
        ),
      };

      // 创建报告生成器
      final generator = EnhancedReportGeneratorFactory.createGenerator(
        _selectedReportType,
      );

      // 生成报告
      final reportPath = await generator.generateEnhancedReport(
        previewContainerKey: _previewContainerKey,
        departmentStats: departmentStats,
        analysisData: analysisData,
        attendanceStats: attendanceStats,
        previousMonthData: null,
        year: _startDate.year,
        month: _startDate.month,
        isMultiMonth: _selectedReportType == ReportType.multiMonth,
        startTime: _startDate,
        endTime: _endDate,
      );

      setState(() {
        _statusMessage = '报告生成成功！文件路径：$reportPath';
      });

      // 显示报告生成成功的消息
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('报告生成成功！')));
    } catch (e) {
      setState(() {
        _statusMessage = '报告生成失败：$e';
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
