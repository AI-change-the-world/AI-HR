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
  bool _isSelectingStart = true; // true表示正在选择开始时间，false表示正在选择结束时间

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
        width: 700, // 增加宽度以适应左右布局
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
            Expanded(child: _buildContent()),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
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
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        // 左侧：时间选择切换和结果展示
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.05),
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Column(
            children: [
              // 开始/结束时间切换按钮
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSelectingStart = true;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isSelectingStart
                              ? const Color(0xFF6C63FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isSelectingStart
                                ? const Color(0xFF6C63FF)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '开始时间',
                            style: TextStyle(
                              color: _isSelectingStart
                                  ? Colors.white
                                  : const Color(0xFF6C63FF),
                              fontWeight: _isSelectingStart
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSelectingStart = false;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isSelectingStart
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: !_isSelectingStart
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '结束时间',
                            style: TextStyle(
                              color: !_isSelectingStart
                                  ? Colors.white
                                  : const Color(0xFF10B981),
                              fontWeight: !_isSelectingStart
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // 当前选择结果展示
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '当前选择',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    // const SizedBox(height: 16),
                    // _buildResultCard('开始时间', _startDate),
                    // const SizedBox(height: 12),
                    // _buildResultCard('结束时间', _endDate),
                    // const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '时间范围',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            TimeRange(
                              startDate: _startDate,
                              endDate: _endDate,
                              mode: widget.mode,
                            ).toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 右侧：具体时间选择器
        Expanded(child: _buildTimeSelector()),
      ],
    );
  }

  Widget _buildResultCard(String label, DateTime date) {
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    switch (widget.mode) {
      case TimePickerMode.month:
        return _buildMonthSelector();
      case TimePickerMode.year:
        return _buildYearSelector();
      case TimePickerMode.quarter:
        return _buildQuarterSelector();
    }
  }

  Widget _buildMonthSelector() {
    final currentDate = _isSelectingStart ? _startDate : _endDate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 年份选择
          _buildYearDropdown(currentDate.year, (year) {
            setState(() {
              if (_isSelectingStart) {
                _startDate = DateTime(year, currentDate.month);
              } else {
                _endDate = DateTime(year, currentDate.month);
              }
            });
          }),
          const SizedBox(height: 20),
          // 月份选择
          _buildMonthGrid(currentDate.year, currentDate.month, (month) {
            setState(() {
              if (_isSelectingStart) {
                _startDate = DateTime(currentDate.year, month);
              } else {
                _endDate = DateTime(currentDate.year, month);
              }
            });
          }),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    final currentYear = _isSelectingStart ? _startDate.year : _endDate.year;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择年份',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
            ),
            itemCount: 15,
            itemBuilder: (context, index) {
              final year = DateTime.now().year - index;
              final isSelected = currentYear == year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_isSelectingStart) {
                      _startDate = DateTime(year);
                    } else {
                      _endDate = DateTime(year);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF10B981) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF10B981),
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

  Widget _buildQuarterSelector() {
    final currentDate = _isSelectingStart ? _startDate : _endDate;
    final currentQuarter = ((currentDate.month - 1) ~/ 3) + 1;

    final quarters = [
      {'name': '第一季度', 'months': '1-3月', 'value': 1},
      {'name': '第二季度', 'months': '4-6月', 'value': 2},
      {'name': '第三季度', 'months': '7-9月', 'value': 3},
      {'name': '第四季度', 'months': '10-12月', 'value': 4},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 年份选择
          _buildYearDropdown(currentDate.year, (year) {
            setState(() {
              final firstMonthOfQuarter = (currentQuarter - 1) * 3 + 1;
              if (_isSelectingStart) {
                _startDate = DateTime(year, firstMonthOfQuarter);
              } else {
                _endDate = DateTime(year, firstMonthOfQuarter);
              }
            });
          }),
          const SizedBox(height: 20),
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
                  '选择季度 - ${currentDate.year}年',
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
                            if (_isSelectingStart) {
                              _startDate = DateTime(
                                currentDate.year,
                                firstMonthOfQuarter,
                              );
                            } else {
                              _endDate = DateTime(
                                currentDate.year,
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
                                ? const Color(0xFFFF6B6B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF6B6B)
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
                                      : const Color(
                                          0xFFFF6B6B,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Q${quarter['value']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF6B6B),
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
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    Text(
                                      quarter['months'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFFF6B6B),
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

  Widget _buildYearDropdown(int selectedYear, Function(int) onYearSelected) {
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

  Widget _buildMonthGrid(
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
