import 'package:flutter/material.dart';

enum TimePickerMode { month, year, quarter }

class TimeRange {
  final DateTime startDate;
  final DateTime endDate;
  final TimePickerMode mode;

  TimeRange({
    required this.startDate,
    required this.endDate,
    required this.mode,
  });

  @override
  String toString() {
    if (mode == TimePickerMode.month) {
      if (startDate.year == endDate.year && startDate.month == endDate.month) {
        return '${startDate.year}年${startDate.month.toString().padLeft(2, '0')}月';
      } else {
        return '${startDate.year}年${startDate.month.toString().padLeft(2, '0')}月 - ${endDate.year}年${endDate.month.toString().padLeft(2, '0')}月';
      }
    } else if (mode == TimePickerMode.year) {
      if (startDate.year == endDate.year) {
        return '${startDate.year}年';
      } else {
        return '${startDate.year}年 - ${endDate.year}年';
      }
    } else {
      final startQuarter = ((startDate.month - 1) ~/ 3) + 1;
      final endQuarter = ((endDate.month - 1) ~/ 3) + 1;
      if (startDate.year == endDate.year && startQuarter == endQuarter) {
        return '${startDate.year}年第${startQuarter}季度';
      } else {
        return '${startDate.year}年Q${startQuarter} - ${endDate.year}年Q${endQuarter}';
      }
    }
  }
}

class SmartTimePicker extends StatefulWidget {
  final TimePickerMode mode;
  final TimeRange? initialRange;
  final Function(TimeRange) onRangeSelected;

  const SmartTimePicker({
    super.key,
    required this.mode,
    this.initialRange,
    required this.onRangeSelected,
  });

  @override
  State<SmartTimePicker> createState() => _SmartTimePickerState();
}

class _SmartTimePickerState extends State<SmartTimePicker> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();

    if (widget.initialRange != null) {
      _startDate = widget.initialRange!.startDate;
      _endDate = widget.initialRange!.endDate;
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 450,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(child: _buildContent()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = '';
    String subtitle = '';
    IconData icon = Icons.calendar_today;
    Color color = const Color(0xFF6C63FF);

    switch (widget.mode) {
      case TimePickerMode.month:
        title = '选择月份范围';
        subtitle = '选择要分析的起始和结束月份';
        icon = Icons.calendar_today_rounded;
        color = const Color(0xFF6C63FF);
        break;
      case TimePickerMode.year:
        title = '选择年份范围';
        subtitle = '选择要分析的起始和结束年份';
        icon = Icons.date_range_rounded;
        color = const Color(0xFF10B981);
        break;
      case TimePickerMode.quarter:
        title = '选择季度范围';
        subtitle = '选择要分析的起始和结束季度';
        icon = Icons.view_week_rounded;
        color = const Color(0xFFFF6B6B);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 左右结构的开始/结束时间显示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTimeCard('开始时间', _startDate, true, color),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeCard('结束时间', _endDate, false, color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(
    String label,
    DateTime date,
    bool isStart,
    Color color,
  ) {
    String displayText = '';
    switch (widget.mode) {
      case TimePickerMode.month:
        displayText = '${date.year}年${date.month.toString().padLeft(2, '0')}月';
        break;
      case TimePickerMode.year:
        displayText = '${date.year}年';
        break;
      case TimePickerMode.quarter:
        final quarter = ((date.month - 1) ~/ 3) + 1;
        displayText = '${date.year}年Q${quarter}';
        break;
    }

    return GestureDetector(
      onTap: () {
        _selectTime(isStart);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(bool isStart) {
    setState(() {
      // 这里可以添加更复杂的交互逻辑，比如弹出选择器
      // 当前实现是让用户点击卡片来切换选择状态
    });
  }

  Widget _buildContent() {
    switch (widget.mode) {
      case TimePickerMode.month:
        return _buildMonthPicker();
      case TimePickerMode.year:
        return _buildYearPicker();
      case TimePickerMode.quarter:
        return _buildQuarterPicker();
    }
  }

  Widget _buildMonthPicker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 开始时间选择
          _buildTimeSection('开始时间', _startDate, true),
          const SizedBox(height: 20),
          // 结束时间选择
          _buildTimeSection('结束时间', _endDate, false),
        ],
      ),
    );
  }

  Widget _buildTimeSection(String title, DateTime date, bool isStart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isStart
            ? const Color(0xFF6C63FF).withOpacity(0.05)
            : const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStart
              ? const Color(0xFF6C63FF).withOpacity(0.3)
              : const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isStart
                  ? const Color(0xFF6C63FF)
                  : const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          // 年份选择
          _buildYearSelector(date.year, (year) {
            setState(() {
              if (isStart) {
                _startDate = DateTime(year, date.month);
              } else {
                _endDate = DateTime(year, date.month);
              }
            });
          }),
          const SizedBox(height: 16),
          // 月份选择
          _buildMonthSelector(date.year, date.month, (month) {
            setState(() {
              if (isStart) {
                _startDate = DateTime(date.year, month);
              } else {
                _endDate = DateTime(date.year, month);
              }
            });
          }),
        ],
      ),
    );
  }

  Widget _buildYearSelector(int selectedYear, Function(int) onYearSelected) {
    final currentYear = DateTime.now().year;
    final years = List.generate(20, (index) => currentYear - index); // 生成最近20年

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择年份',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 12),
          // 使用下拉菜单替代滚动列表
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedYear,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF6C63FF),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C63FF),
                ),
                items: years.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(
                      '${year}年',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (int? newYear) {
                  if (newYear != null) {
                    onYearSelected(newYear);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(
    int year,
    int selectedMonth,
    Function(int) onMonthSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择月份 - ${year}年',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = selectedMonth == month;

              return GestureDetector(
                onTap: () => onMonthSelected(month),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${month.toString().padLeft(2, '0')}月',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYearPicker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 开始时间选择
          _buildYearSection('开始时间', _startDate.year, true),
          const SizedBox(height: 20),
          // 结束时间选择
          _buildYearSection('结束时间', _endDate.year, false),
        ],
      ),
    );
  }

  Widget _buildYearSection(String title, int year, bool isStart) {
    final currentYear = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isStart
            ? const Color(0xFF10B981).withOpacity(0.05)
            : const Color(0xFFFF6B6B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStart
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFFF6B6B).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isStart
                  ? const Color(0xFF10B981)
                  : const Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
            ),
            itemCount: 15,
            itemBuilder: (context, index) {
              final itemYear = currentYear - index;
              final isSelected = year == itemYear;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isStart) {
                      _startDate = DateTime(itemYear);
                    } else {
                      _endDate = DateTime(itemYear);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isStart
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFF6B6B))
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (isStart
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFF6B6B))
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      itemYear.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isStart
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFFF6B6B)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuarterPicker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 开始时间选择
          _buildQuarterSection('开始时间', _startDate, true),
          const SizedBox(height: 20),
          // 结束时间选择
          _buildQuarterSection('结束时间', _endDate, false),
        ],
      ),
    );
  }

  Widget _buildQuarterSection(String title, DateTime date, bool isStart) {
    final currentQuarter = ((date.month - 1) ~/ 3) + 1;

    final quarters = [
      {'name': '第一季度', 'months': '1-3月', 'value': 1},
      {'name': '第二季度', 'months': '4-6月', 'value': 2},
      {'name': '第三季度', 'months': '7-9月', 'value': 3},
      {'name': '第四季度', 'months': '10-12月', 'value': 4},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isStart
            ? const Color(0xFFFF6B6B).withOpacity(0.05)
            : const Color(0xFF6C63FF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStart
              ? const Color(0xFFFF6B6B).withOpacity(0.3)
              : const Color(0xFF6C63FF).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isStart
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 16),
          // 年份选择
          _buildYearSelector(date.year, (year) {
            setState(() {
              final firstMonthOfQuarter = (currentQuarter - 1) * 3 + 1;
              if (isStart) {
                _startDate = DateTime(year, firstMonthOfQuarter);
              } else {
                _endDate = DateTime(year, firstMonthOfQuarter);
              }
            });
          }),
          const SizedBox(height: 16),
          // 季度选择
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择季度 - ${date.year}年',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: quarters.map((quarter) {
                    final isSelected = currentQuarter == quarter['value'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            final firstMonthOfQuarter =
                                ((quarter['value'] as int) - 1) * 3 + 1;
                            if (isStart) {
                              _startDate = DateTime(
                                date.year,
                                firstMonthOfQuarter,
                              );
                            } else {
                              _endDate = DateTime(
                                date.year,
                                firstMonthOfQuarter,
                              );
                            }
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isStart
                                      ? const Color(0xFFFF6B6B)
                                      : const Color(0xFF6C63FF))
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? (isStart
                                        ? const Color(0xFFFF6B6B)
                                        : const Color(0xFF6C63FF))
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : (isStart
                                            ? const Color(
                                                0xFFFF6B6B,
                                              ).withOpacity(0.1)
                                            : const Color(
                                                0xFF6C63FF,
                                              ).withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Q${quarter['value']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : (isStart
                                              ? const Color(0xFFFF6B6B)
                                              : const Color(0xFF6C63FF)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quarter['name'] as String,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF2D3748),
                                      ),
                                    ),
                                    Text(
                                      quarter['months'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.8)
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    Color color = const Color(0xFF6C63FF);
    switch (widget.mode) {
      case TimePickerMode.year:
        color = const Color(0xFF10B981);
        break;
      case TimePickerMode.quarter:
        color = const Color(0xFFFF6B6B);
        break;
      default:
        color = const Color(0xFF6C63FF);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                '取消',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // 确保开始时间不晚于结束时间
                DateTime finalStartDate = _startDate;
                DateTime finalEndDate = _endDate;

                if (_startDate.isAfter(_endDate)) {
                  finalStartDate = _endDate;
                  finalEndDate = _startDate;
                }

                final timeRange = TimeRange(
                  startDate: finalStartDate,
                  endDate: finalEndDate,
                  mode: widget.mode,
                );

                widget.onRangeSelected(timeRange);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '确认选择',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
