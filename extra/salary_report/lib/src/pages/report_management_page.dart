import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';
import 'package:salary_report/src/isar/report_service.dart';

class ReportManagementPage extends StatefulWidget {
  const ReportManagementPage({super.key});

  @override
  State<ReportManagementPage> createState() => _ReportManagementPageState();
}

class _ReportManagementPageState extends State<ReportManagementPage> {
  final ReportService _reportService = ReportService();
  List<ReportGenerationRecord> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await _reportService.getAllReportRecords();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 可以添加错误提示
    }
  }

  Future<void> _refreshReports() async {
    await _loadReports();
  }

  Future<void> _deleteReport(ReportGenerationRecord report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这个报告吗？此操作将同时删除本地文件。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('删除'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final success = await _reportService.deleteReportRecord(report.id);
        if (success) {
          // 刷新列表
          await _refreshReports();
          // 显示成功提示
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('报告已删除')));
        } else {
          // 显示错误提示
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('删除失败')));
        }
      } catch (e) {
        // 显示错误提示
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除过程中发生错误')));
      }
    }
  }

  Future<void> _openReportFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        // 文件打开失败
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('无法打开文件')));
      }
    } catch (e) {
      // 显示错误提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('打开文件时发生错误')));
    }
  }

  String _formatFileSize(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final size = file.lengthSync();
        if (size < 1024) {
          return '$size B';
        } else if (size < 1024 * 1024) {
          return '${(size / 1024).toStringAsFixed(1)} KB';
        } else {
          return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      }
    } catch (e) {
      // 文件大小获取失败
    }
    return '未知大小';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('报告管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
          ? const Center(
              child: Text(
                '暂无报告记录',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshReports,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        report.savePath.split(Platform.pathSeparator).last,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '创建时间: ${_formatDateTime(report.createdAt)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '文件大小: ${_formatFileSize(report.savePath)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.savePath,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () => _openReportFile(report.savePath),
                            tooltip: '打开文件',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReport(report),
                            tooltip: '删除报告',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
