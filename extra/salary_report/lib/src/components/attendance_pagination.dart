import 'package:flutter/material.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';

class AttendancePagination extends StatefulWidget {
  final List<AttendanceStats> attendanceStats;
  final int itemsPerPage;

  const AttendancePagination({
    super.key,
    required this.attendanceStats,
    this.itemsPerPage = 10,
  });

  @override
  State<AttendancePagination> createState() => _AttendancePaginationState();
}

class _AttendancePaginationState extends State<AttendancePagination> {
  late int _currentPage;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    _totalPages = (widget.attendanceStats.length / widget.itemsPerPage).ceil();
  }

  @override
  void didUpdateWidget(covariant AttendancePagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当数据更新时，重新计算总页数并重置到第一页
    if (oldWidget.attendanceStats != widget.attendanceStats) {
      _totalPages = (widget.attendanceStats.length / widget.itemsPerPage)
          .ceil();
      _currentPage = 1;
    }
  }

  List<AttendanceStats> _getCurrentPageData() {
    final start = (_currentPage - 1) * widget.itemsPerPage;
    final end = start + widget.itemsPerPage;
    return widget.attendanceStats.sublist(
      start,
      end > widget.attendanceStats.length ? widget.attendanceStats.length : end,
    );
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPageData = _getCurrentPageData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 表头
        const Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('姓名', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text('部门', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text(
                '病假(天)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                '事假(天)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const Divider(),
        // 数据列表
        ...currentPageData.map<Widget>((stat) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(flex: 2, child: Text(stat.name)),
                Expanded(child: Text(stat.department)),
                Expanded(child: Text(stat.sickLeaveDays.toStringAsFixed(1))),
                Expanded(child: Text(stat.leaveDays.toStringAsFixed(1))),
              ],
            ),
          );
        }).toList(),
        // 分页控件
        if (_totalPages > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _currentPage > 1
                    ? () => _goToPage(_currentPage - 1)
                    : null,
              ),
              Text('第 $_currentPage / $_totalPages 页'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _currentPage < _totalPages
                    ? () => _goToPage(_currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
