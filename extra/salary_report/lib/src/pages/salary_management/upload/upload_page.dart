import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:go_router/go_router.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with SingleTickerProviderStateMixin {
  String? _selectedFilePath;
  bool _isUploading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '上传工资表',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          '导入Excel文件进行薪资数据分析',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 支持格式提示
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '支持的文件格式',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '仅支持 .xlsx 格式的Excel文件，请确保文件包含完整的薪资数据',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 上传区域
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFilePath != null
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade300,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_selectedFilePath != null
                                    ? const Color(0xFF10B981)
                                    : Colors.grey)
                                .withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _isUploading ? null : _selectFile,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_selectedFilePath != null)
                              ..._buildSelectedFileContent()
                            else
                              ..._buildSelectFileContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _isUploading ? null : _selectFile,
                        icon: Icons.folder_open_rounded,
                        label: '选择文件',
                        color: const Color(0xFF6C63FF),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _isUploading || _selectedFilePath == null
                            ? null
                            : _uploadFile,
                        icon: _isUploading ? null : Icons.cloud_upload_rounded,
                        label: _isUploading ? '上传中...' : '开始上传',
                        color: const Color(0xFF10B981),
                        isLoading: _isUploading,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 上传指南
                if (!_isUploading) _buildUploadGuide(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSelectedFileContent() {
    return [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 48,
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        '文件已选择',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.description_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _selectedFilePath!.split('/').last,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        '点击"开始上传"按钮来处理此文件',
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
        textAlign: TextAlign.center,
      ),
    ];
  }

  List<Widget> _buildSelectFileContent() {
    return [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.cloud_upload_rounded,
          color: Color(0xFF6C63FF),
          size: 56,
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        '选择要上传的Excel文件',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      Text(
        '拖放文件到这里或点击选择文件',
        style: TextStyle(color: Colors.grey[600], fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        '支持 .xlsx 格式',
        style: TextStyle(color: Colors.grey[500], fontSize: 14),
        textAlign: TextAlign.center,
      ),
    ];
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    IconData? icon,
    required String label,
    required Color color,
    bool isOutlined = false,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          foregroundColor: isOutlined ? color : Colors.white,
          side: isOutlined ? BorderSide(color: color, width: 2) : null,
          elevation: isOutlined ? 0 : 8,
          shadowColor: isOutlined ? null : color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOutlined ? color : Colors.white,
                  ),
                ),
              )
            else if (icon != null)
              Icon(icon, size: 20),
            if (!isLoading && icon != null) const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '上传指南',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideItem('1', '确保 Excel 文件包含员工姓名、部门、职位、薪资等信息'),
          const SizedBox(height: 8),
          _buildGuideItem('2', '文件格式必须为 .xlsx，不支持 .xls 或其他格式'),
          const SizedBox(height: 8),
          _buildGuideItem('3', '建议文件大小不超过 10MB，确保上传速度'),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFF59E0B),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
