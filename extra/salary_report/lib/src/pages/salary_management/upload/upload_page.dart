import 'package:flutter/material.dart';
import 'year_detail_page.dart';

// 年度数据模型
class YearData {
  final int year;
  final int uploadedCount;
  final List<MonthData> months;

  YearData({
    required this.year,
    required this.uploadedCount,
    required this.months,
  });
}

class MonthData {
  final int month;
  final bool hasData;
  final String? fileName;

  MonthData({required this.month, required this.hasData, this.fileName});
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _chatAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chatScaleAnimation;
  late Animation<Offset> _chatSlideAnimation;

  bool _showAIChat = false;
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  final ScrollController _chatScrollController = ScrollController();

  // 模拟年度数据
  late List<YearData> _yearDataList;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initMockData();
    _animationController.forward();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _chatAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _chatScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chatAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _chatSlideAnimation =
        Tween<Offset>(begin: const Offset(1.2, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _chatAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  void _initMockData() {
    _yearDataList = [
      YearData(
        year: 2024,
        uploadedCount: 8,
        months: List.generate(
          12,
          (index) => MonthData(
            month: index + 1,
            hasData: index < 8,
            fileName: index < 8 ? '2024年${index + 1}月工资表.xlsx' : null,
          ),
        ),
      ),
      YearData(
        year: 2023,
        uploadedCount: 12,
        months: List.generate(
          12,
          (index) => MonthData(
            month: index + 1,
            hasData: true,
            fileName: '2023年${index + 1}月工资表.xlsx',
          ),
        ),
      ),
      YearData(
        year: 2022,
        uploadedCount: 10,
        months: List.generate(
          12,
          (index) => MonthData(
            month: index + 1,
            hasData: index < 10,
            fileName: index < 10 ? '2022年${index + 1}月工资表.xlsx' : null,
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chatAnimationController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _toggleAIChat() {
    setState(() {
      _showAIChat = !_showAIChat;
    });

    if (_showAIChat) {
      _chatAnimationController.forward();
    } else {
      _chatAnimationController.reverse();
    }
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;

    setState(() {
      _chatMessages.add(
        ChatMessage(
          text: _chatController.text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    // 模拟AI回复
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _chatMessages.add(
            ChatMessage(
              text: '感谢您的提问！我是工资分析助手，可以帮您解答关于薪资数据分析的相关问题。请告诉我您想了解什么？',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });

        _scrollToBottom();
      }
    });

    _chatController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _navigateToYearDetail(YearData yearData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => YearDetailPage(yearData: yearData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
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
                                color: const Color(
                                  0xFF6C63FF,
                                ).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '薪资数据管理',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              '按年度管理和上传Excel薪资数据',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // 这里实现一个
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 年份统计概览
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6C63FF).withValues(alpha: 0.1),
                            const Color(0xFF26D0CE).withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              '总年份',
                              _yearDataList.length.toString(),
                              Icons.calendar_today,
                              const Color(0xFF6C63FF),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _buildStatItem(
                              '总上传数',
                              _yearDataList
                                  .fold(
                                    0,
                                    (sum, year) => sum + year.uploadedCount,
                                  )
                                  .toString(),
                              Icons.cloud_upload,
                              const Color(0xFF10B981),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _buildStatItem(
                              '最新年份',
                              _yearDataList.first.year.toString(),
                              Icons.update,
                              const Color(0xFF26D0CE),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 年份卡片列表
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _yearDataList.length,
                      itemBuilder: (context, index) {
                        final yearData = _yearDataList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildYearCard(yearData, index),
                        );
                      },
                    ),

                    const SizedBox(height: 80), // 为浮动按钮留出空间
                  ],
                ),
              ),
            ),
          ),

          // AI问答浮动按钮
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton.extended(
              onPressed: _toggleAIChat,
              backgroundColor: const Color(0xFF6C63FF),
              icon: Icon(
                _showAIChat ? Icons.close : Icons.smart_toy_rounded,
                color: Colors.white,
              ),
              label: Text(
                _showAIChat ? '关闭' : 'AI助手',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              heroTag: "ai_chat",
            ),
          ),

          // AI聊天界面
          if (_showAIChat) _buildAIChatInterface(),
        ],
      ),
    );
  }

  // List<Widget> _buildSelectedFileContent() {
  //   return [
  //     Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF10B981).withValues(alpha: 0.1),
  //         shape: BoxShape.circle,
  //       ),
  //       child: const Icon(
  //         Icons.check_circle_rounded,
  //         color: Color(0xFF10B981),
  //         size: 48,
  //       ),
  //     ),
  //     const SizedBox(height: 24),
  //     const Text(
  //       '文件已选择',
  //       style: TextStyle(
  //         fontSize: 20,
  //         fontWeight: FontWeight.bold,
  //         color: Color(0xFF2D3748),
  //       ),
  //     ),
  //     const SizedBox(height: 12),
  //     Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF10B981).withValues(alpha: 0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //           color: const Color(0xFF10B981).withValues(alpha: 0.3),
  //           width: 1,
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Icon(
  //             Icons.description_rounded,
  //             color: Color(0xFF10B981),
  //             size: 20,
  //           ),
  //           const SizedBox(width: 8),
  //           Flexible(
  //             child: Text(
  //               '文件已选择',
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.w600,
  //                 color: Color(0xFF10B981),
  //                 fontSize: 14,
  //               ),
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     const SizedBox(height: 16),
  //     Text(
  //       '点击"开始上传"按钮来处理此文件',
  //       style: TextStyle(color: Colors.grey[600], fontSize: 14),
  //       textAlign: TextAlign.center,
  //     ),
  //   ];
  // }

  // List<Widget> _buildSelectFileContent() {
  //   return [
  //     Container(
  //       padding: const EdgeInsets.all(24),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
  //         shape: BoxShape.circle,
  //       ),
  //       child: const Icon(
  //         Icons.cloud_upload_rounded,
  //         color: Color(0xFF6C63FF),
  //         size: 56,
  //       ),
  //     ),
  //     const SizedBox(height: 24),
  //     const Text(
  //       '选择要上传的Excel文件',
  //       style: TextStyle(
  //         fontSize: 20,
  //         fontWeight: FontWeight.bold,
  //         color: Color(0xFF2D3748),
  //       ),
  //       textAlign: TextAlign.center,
  //     ),
  //     const SizedBox(height: 12),
  //     Text(
  //       '拖放文件到这里或点击选择文件',
  //       style: TextStyle(color: Colors.grey[600], fontSize: 16),
  //       textAlign: TextAlign.center,
  //     ),
  //     const SizedBox(height: 8),
  //     Text(
  //       '支持 .xlsx 格式',
  //       style: TextStyle(color: Colors.grey[500], fontSize: 14),
  //       textAlign: TextAlign.center,
  //     ),
  //   ];
  // }

  // Widget _buildActionButton({
  //   required VoidCallback? onPressed,
  //   IconData? icon,
  //   required String label,
  //   required Color color,
  //   bool isOutlined = false,
  //   bool isLoading = false,
  // }) {
  //   return SizedBox(
  //     height: 56,
  //     child: ElevatedButton(
  //       onPressed: onPressed,
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: isOutlined ? Colors.white : color,
  //         foregroundColor: isOutlined ? color : Colors.white,
  //         side: isOutlined ? BorderSide(color: color, width: 2) : null,
  //         elevation: isOutlined ? 0 : 8,
  //         shadowColor: isOutlined ? null : color.withValues(alpha: 0.3),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           if (isLoading)
  //             SizedBox(
  //               width: 20,
  //               height: 20,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2,
  //                 valueColor: AlwaysStoppedAnimation<Color>(
  //                   isOutlined ? color : Colors.white,
  //                 ),
  //               ),
  //             )
  //           else if (icon != null)
  //             Icon(icon, size: 20),
  //           if (!isLoading && icon != null) const SizedBox(width: 8),
  //           Text(
  //             label,
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildUploadGuide() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade50,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: Colors.grey.shade200, width: 1),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Icon(
  //               Icons.lightbulb_outline,
  //               color: Color(0xFFF59E0B),
  //               size: 20,
  //             ),
  //             const SizedBox(width: 8),
  //             const Text(
  //               '上传指南',
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Color(0xFFF59E0B),
  //                 fontSize: 16,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         _buildGuideItem('1', '确保 Excel 文件包含员工姓名、部门、职位、薪资等信息'),
  //         const SizedBox(height: 8),
  //         _buildGuideItem('2', '文件格式必须为 .xlsx，不支持 .xls 或其他格式'),
  //         const SizedBox(height: 8),
  //         _buildGuideItem('3', '建议文件大小不超过 10MB，确保上传速度'),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildGuideItem(String step, String text) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Container(
  //         width: 20,
  //         height: 20,
  //         decoration: const BoxDecoration(
  //           color: Color(0xFFF59E0B),
  //           shape: BoxShape.circle,
  //         ),
  //         child: Center(
  //           child: Text(
  //             step,
  //             style: const TextStyle(
  //               color: Colors.white,
  //               fontSize: 10,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: Text(
  //           text,
  //           style: TextStyle(
  //             color: Colors.grey[700],
  //             fontSize: 14,
  //             height: 1.4,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildYearCard(YearData yearData, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToYearDetail(yearData),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF26D0CE)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        yearData.year.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '年',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${yearData.year}年薪资数据',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: yearData.uploadedCount == 12
                                  ? const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.1)
                                  : const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${yearData.uploadedCount}/12',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: yearData.uploadedCount == 12
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: yearData.uploadedCount / 12,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF26D0CE)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '已上传 ${yearData.uploadedCount} 个月的数据',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIChatInterface() {
    return Positioned(
      right: 24,
      bottom: 100,
      child: SlideTransition(
        position: _chatSlideAnimation,
        child: ScaleTransition(
          scale: _chatScaleAnimation,
          child: Container(
            width: 320,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF26D0CE)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI薪资分析助手',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _chatMessages.isEmpty
                      ? _buildWelcomeMessage()
                      : ListView.builder(
                          controller: _chatScrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            return _buildChatMessage(_chatMessages[index]);
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: InputDecoration(
                            hintText: '请输入您的问题...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            isDense: true,
                          ),
                          onSubmitted: (value) => _sendMessage(),
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF26D0CE)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF6C63FF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '您好！我是AI薪资分析助手',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '我可以帮您分析薪资数据，回答相关问题。请告诉我您想了解什么？',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : const Color(0xFF2D3748),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF26D0CE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 12),
            ),
          ],
        ],
      ),
    );
  }
}

// 聊天消息模型
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
