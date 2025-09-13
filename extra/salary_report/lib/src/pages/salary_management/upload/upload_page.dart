import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:go_router/go_router.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String? _selectedFilePath;
  bool _isUploading = false;

  Future<void> _selectFile() async {
    const XTypeGroup xlsxTypeGroup = XTypeGroup(
      label: 'Excel文件',
      extensions: ['xlsx'],
    );

    final List<XFile> files = await openFiles(
      acceptedTypeGroups: [xlsxTypeGroup],
    );

    if (files.isNotEmpty) {
      setState(() {
        _selectedFilePath = files.first.path;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFilePath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先选择一个文件')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // TODO: 实现文件上传逻辑
      // 调用Rust API进行文件解析和存储
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('文件上传成功')));
        setState(() {
          _selectedFilePath = null;
        });

        // 上传成功后返回到工资表列表页面
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('上传失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

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
              '上传工资表',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '请选择要上传的工资表文件',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('支持格式: .xlsx', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Card(
              elevation: 3,
              shadowColor: Colors.lightBlue.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    if (_selectedFilePath != null) ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '已选择文件:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedFilePath!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.upload_file,
                        size: 60,
                        color: Colors.lightBlue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '点击下方按钮选择文件',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _selectFile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('选择文件', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading || _selectedFilePath == null
                        ? null
                        : _uploadFile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isUploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      _isUploading ? '上传中...' : '上传',
                      style: const TextStyle(fontSize: 16),
                    ),
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
