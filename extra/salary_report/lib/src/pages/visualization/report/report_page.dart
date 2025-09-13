import 'package:flutter/material.dart';
import 'package:salary_report/src/common/toast.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _selectedReportType = 'monthly';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('报告生成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '生成分析报告',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 报告类型选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '报告类型',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('月度报告'),
                      leading: Radio<String>(
                        value: 'monthly',
                        groupValue: _selectedReportType,
                        onChanged: (value) {
                          setState(() {
                            _selectedReportType = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedReportType = 'monthly';
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('年度报告'),
                      leading: Radio<String>(
                        value: 'yearly',
                        groupValue: _selectedReportType,
                        onChanged: (value) {
                          setState(() {
                            _selectedReportType = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedReportType = 'yearly';
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('季度报告'),
                      leading: Radio<String>(
                        value: 'quarterly',
                        groupValue: _selectedReportType,
                        onChanged: (value) {
                          setState(() {
                            _selectedReportType = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedReportType = 'quarterly';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 时间选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择时间',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedReportType == 'monthly') ...[
                      ListTile(
                        title: Text(
                          '${_selectedDate.year}年${_selectedDate.month.toString().padLeft(2, '0')}月',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ] else if (_selectedReportType == 'yearly') ...[
                      ListTile(
                        title: Text('${_selectedDate.year}年'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDatePickerMode: DatePickerMode.year,
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ] else ...[
                      ListTile(
                        title: Text(
                          '${_selectedDate.year}年第${(((_selectedDate.month - 1) ~/ 3) + 1)}季度',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 生成报告按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 生成报告逻辑

                  ToastUtils.info(null, title: '报告生成中...');
                },
                child: const Text('生成报告'),
              ),
            ),

            const SizedBox(height: 16),

            // 报告预览区域
            const Text(
              '报告预览',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '工资分析报告',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('生成时间: 2023年8月15日'),
                        const SizedBox(height: 16),
                        const Text(
                          '摘要',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '本报告分析了2023年8月份公司员工工资情况。总体来看，公司共有45名员工，工资总额为504,000元，平均工资为11,200元。',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '详细分析',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. 部门工资对比:\n'
                          '- 技术部平均工资最高，为13,500元\n'
                          '- 销售部平均工资为12,800元\n'
                          '- 财务部平均工资为11,800元\n'
                          '- 人事部平均工资为9,500元\n\n'
                          '2. 工资分布:\n'
                          '- 最高工资: 25,000元\n'
                          '- 最低工资: 6,500元\n'
                          '- 工资中位数: 11,500元',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 导出按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: 导出为PDF
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('导出PDF'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
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
        ),
      ),
    );
  }
}
