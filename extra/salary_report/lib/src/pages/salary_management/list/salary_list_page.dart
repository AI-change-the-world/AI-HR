import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SalaryListPage extends StatefulWidget {
  const SalaryListPage({super.key});

  @override
  State<SalaryListPage> createState() => _SalaryListPageState();
}

class _SalaryListPageState extends State<SalaryListPage> {
  // 模拟数据
  final List<Map<String, dynamic>> _salaryReports = [
    {
      'id': 1,
      'month': '2023年8月',
      'fileName': 'salary_2023_08.xlsx',
      'recordCount': 45,
      'uploadTime': '2023-08-05 14:30',
    },
    {
      'id': 2,
      'month': '2023年7月',
      'fileName': 'salary_2023_07.xlsx',
      'recordCount': 42,
      'uploadTime': '2023-07-05 14:30',
    },
    {
      'id': 3,
      'month': '2023年6月',
      'fileName': 'salary_2023_06.xlsx',
      'recordCount': 40,
      'uploadTime': '2023-06-05 14:30',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 移除AppBar，因为主布局已经提供了
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '已上传的工资表',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _salaryReports.length,
                itemBuilder: (context, index) {
                  final report = _salaryReports[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    shadowColor: Colors.lightBlue.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        report['month'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            '文件名: ${report['fileName']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '记录数: ${report['recordCount']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '上传时间: ${report['uploadTime']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.lightBlue,
                      ),
                      onTap: () {
                        // 使用go_router进行导航
                        context.push('/salary/detail/${report['id']}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/salary/upload');
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
