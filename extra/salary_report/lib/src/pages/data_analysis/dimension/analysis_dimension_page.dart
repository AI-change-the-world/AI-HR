import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnalysisDimensionPage extends StatefulWidget {
  const AnalysisDimensionPage({super.key});

  @override
  State<AnalysisDimensionPage> createState() => _AnalysisDimensionPageState();
}

class _AnalysisDimensionPageState extends State<AnalysisDimensionPage> {
  String _selectedDimension = 'month';
  DateTime _selectedDate = DateTime.now();

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
              '数据分析',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '请选择分析维度和时间范围',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // 维度选择
            Card(
              elevation: 3,
              shadowColor: Colors.lightBlue.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '分析维度',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('按月份分析'),
                      leading: Radio<String>(
                        fillColor: MaterialStateProperty.all(Colors.lightBlue),
                        value: 'month',
                        groupValue: _selectedDimension,
                        onChanged: (value) {
                          setState(() {
                            _selectedDimension = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedDimension = 'month';
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('按年份分析'),
                      leading: Radio<String>(
                        fillColor: MaterialStateProperty.all(Colors.lightBlue),
                        value: 'year',
                        groupValue: _selectedDimension,
                        onChanged: (value) {
                          setState(() {
                            _selectedDimension = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedDimension = 'year';
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('按季度分析'),
                      leading: Radio<String>(
                        fillColor: MaterialStateProperty.all(Colors.lightBlue),
                        value: 'quarter',
                        groupValue: _selectedDimension,
                        onChanged: (value) {
                          setState(() {
                            _selectedDimension = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedDimension = 'quarter';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 时间选择
            Card(
              elevation: 3,
              shadowColor: Colors.lightBlue.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '时间范围',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedDimension == 'month') ...[
                      const Text('选择月份'),
                      const SizedBox(height: 12),
                      ListTile(
                        title: Text(
                          '${_selectedDate.year}年${_selectedDate.month.toString().padLeft(2, '0')}月',
                        ),
                        trailing: const Icon(
                          Icons.calendar_today,
                          color: Colors.lightBlue,
                        ),
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
                    ] else if (_selectedDimension == 'year') ...[
                      const Text('选择年份'),
                      const SizedBox(height: 12),
                      ListTile(
                        title: Text('${_selectedDate.year}年'),
                        trailing: const Icon(
                          Icons.calendar_today,
                          color: Colors.lightBlue,
                        ),
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
                      const Text('选择季度'),
                      const SizedBox(height: 12),
                      ListTile(
                        title: Text(
                          '${_selectedDate.year}年第${(((_selectedDate.month - 1) ~/ 3) + 1)}季度',
                        ),
                        trailing: const Icon(
                          Icons.calendar_today,
                          color: Colors.lightBlue,
                        ),
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
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 确认按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 使用go_router进行导航
                  if (_selectedDimension == 'month') {
                    context.push(
                      '/analysis/monthly?year=${_selectedDate.year}&month=${_selectedDate.month}',
                    );
                  } else if (_selectedDimension == 'year') {
                    context.push('/analysis/yearly?year=${_selectedDate.year}');
                  } else {
                    final quarter = ((_selectedDate.month - 1) ~/ 3) + 1;
                    context.push(
                      '/analysis/quarterly?year=${_selectedDate.year}&quarter=$quarter',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '开始分析',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
