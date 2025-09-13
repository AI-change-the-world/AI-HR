import 'package:flutter/material.dart';

class SalaryDetailPage extends StatefulWidget {
  const SalaryDetailPage({super.key, required this.reportId});

  final int reportId;

  @override
  State<SalaryDetailPage> createState() => _SalaryDetailPageState();
}

class _SalaryDetailPageState extends State<SalaryDetailPage> {
  // 模拟数据
  final Map<String, dynamic> _reportInfo = {
    'month': '2023年8月',
    'fileName': 'salary_2023_08.xlsx',
    'recordCount': 45,
    'uploadTime': '2023-08-05 14:30',
  };

  final List<Map<String, dynamic>> _salaryRecords = [
    {
      'name': '张三',
      'department': '技术部',
      'position': '高级工程师',
      'netSalary': '12000.00',
    },
    {
      'name': '李四',
      'department': '销售部',
      'position': '销售经理',
      'netSalary': '15000.00',
    },
    {
      'name': '王五',
      'department': '人事部',
      'position': '人事专员',
      'netSalary': '8000.00',
    },
  ];

  final Map<String, String> _summaryData = {
    '总人数': '45',
    '平均工资': '11200.00',
    '最高工资': '25000.00',
    '最低工资': '6500.00',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_reportInfo['month']} 工资详情'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 实现导出功能
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 报告基本信息
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '报告信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('文件名: ${_reportInfo['fileName']}'),
                      Text('记录数: ${_reportInfo['recordCount']}'),
                      Text('上传时间: ${_reportInfo['uploadTime']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 汇总信息
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '汇总信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._summaryData.entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(entry.value),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 工资记录列表
              const Text(
                '工资记录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('姓名')),
                    DataColumn(label: Text('部门')),
                    DataColumn(label: Text('职位')),
                    DataColumn(label: Text('实发工资')),
                  ],
                  rows: _salaryRecords.map((record) {
                    return DataRow(
                      cells: [
                        DataCell(Text(record['name'])),
                        DataCell(Text(record['department'])),
                        DataCell(Text(record['position'])),
                        DataCell(Text(record['netSalary'])),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
