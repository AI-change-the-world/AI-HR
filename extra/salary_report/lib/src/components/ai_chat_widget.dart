import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/ai_salary_service.dart';
import 'package:salary_report/src/isar/database.dart';

/// AI聊天组件
class AIChatWidget extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final double? width;
  final double? height;

  const AIChatWidget({
    super.key,
    this.onClose,
    this.width = 320,
    this.height = 400,
  });

  @override
  ConsumerState<AIChatWidget> createState() => _AIChatWidgetState();
}

class _AIChatWidgetState extends ConsumerState<AIChatWidget>
    with TickerProviderStateMixin {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<ChatMessage> _chatMessages = [];

  bool _isAIProcessing = false;

  late AISalaryService _aiSalaryService;

  @override
  void initState() {
    super.initState();
    final database = IsarDatabase();
    _aiSalaryService = AISalaryService(database);
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  /// 发送消息
  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isAIProcessing) return;

    setState(() {
      _chatMessages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isAIProcessing = true;
    });

    _chatController.clear();
    _scrollToBottom();

    try {
      // 添加AI进度消息
      final progressMessage = ChatMessage(
        text: '🤔 正在思考...',
        isUser: false,
        timestamp: DateTime.now(),
        isProgress: true,
      );

      setState(() {
        _chatMessages.add(progressMessage);
      });
      _scrollToBottom();

      // 调用AI服务，传入进度回调
      final response = await _aiSalaryService.processUserQuery(
        text,
        onProgress: (progress) {
          logger.info('AI processing progress: $progress');
          setState(() {
            // 检查是否是任务规划消息
            final isTaskPlanning =
                progress.contains('📋 任务规划完成') ||
                progress.contains('共') && progress.contains('个步骤');

            // 检查是否是步骤概览（以•开头的步骤列表）
            final isStepOverview = progress.startsWith('• 步骤');

            // 检查是否是步骤执行消息
            final isStepExecution =
                progress.contains('🔄 正在执行步骤') ||
                progress.contains('✅ 步骤') && progress.contains('完成') ||
                progress.contains('❌ 步骤') && progress.contains('失败');

            // 检查是否是最终执行消息
            final isFinalMessage =
                progress.contains('🧠 正在综合分析') ||
                progress.contains('🚀 开始执行任务') ||
                progress.contains('🤔 正在分析') ||
                progress.contains('🧠 智能体正在规划');

            if (isTaskPlanning) {
              // 任务规划消息：创建一个可展开的步骤组件
              _chatMessages.add(
                ChatMessage(
                  text: progress,
                  isUser: false,
                  timestamp: DateTime.now(),
                  isProgress: true,
                  isTaskPlanning: true,
                ),
              );
            } else if (isStepOverview) {
              // 步骤概览：添加到最后一个任务规划消息中
              final lastPlanningIndex = _chatMessages.lastIndexWhere(
                (msg) => msg.isTaskPlanning,
              );
              if (lastPlanningIndex != -1) {
                final planningMessage = _chatMessages[lastPlanningIndex];
                _chatMessages[lastPlanningIndex] = ChatMessage(
                  text: planningMessage.text,
                  isUser: false,
                  timestamp: planningMessage.timestamp,
                  isProgress: true,
                  isTaskPlanning: true,
                  stepDetails: [
                    ...(planningMessage.stepDetails ?? []),
                    progress,
                  ],
                );
              }
            } else if (isStepExecution || isFinalMessage) {
              // 步骤执行消息：更新最后一条进度消息
              final lastStatusIndex = _chatMessages.lastIndexWhere(
                (msg) => msg.isProgress && !msg.isUser && !msg.isTaskPlanning,
              );

              if (lastStatusIndex != -1) {
                // 更新最后一条状态消息
                _chatMessages[lastStatusIndex] = ChatMessage(
                  text: progress,
                  isUser: false,
                  timestamp: _chatMessages[lastStatusIndex].timestamp,
                  isProgress: true,
                );
              } else {
                // 添加新的状态消息
                _chatMessages.add(
                  ChatMessage(
                    text: progress,
                    isUser: false,
                    timestamp: DateTime.now(),
                    isProgress: true,
                  ),
                );
              }
            } else {
              // 其他进度消息：更新最后一条非规划消息
              final lastProgressIndex = _chatMessages.lastIndexWhere(
                (msg) => msg.isProgress && !msg.isUser && !msg.isTaskPlanning,
              );

              if (lastProgressIndex != -1) {
                _chatMessages[lastProgressIndex] = ChatMessage(
                  text: progress,
                  isUser: false,
                  timestamp: _chatMessages[lastProgressIndex].timestamp,
                  isProgress: true,
                );
              } else {
                _chatMessages.add(
                  ChatMessage(
                    text: progress,
                    isUser: false,
                    timestamp: DateTime.now(),
                    isProgress: true,
                  ),
                );
              }
            }
          });
          _scrollToBottom();
        },
      );

      setState(() {
        // 不移除进度消息，保留完整的思考过程
        // 只移除最后一条临时的进度消息（如果存在）
        final lastProgressIndex = _chatMessages.lastIndexWhere(
          (msg) =>
              msg.isProgress &&
              !msg.isUser &&
              (msg.text.contains('正在') || msg.text.contains('…')),
        );
        if (lastProgressIndex != -1) {
          _chatMessages.removeAt(lastProgressIndex);
        }

        // 添加最终回答
        _chatMessages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
            isMarkdown: true,
          ),
        );
        _isAIProcessing = false;
      });

      _scrollToBottom();
    } catch (e, s) {
      logger.warning('AI processing failed: $e $s');
      setState(() {
        // 只移除最后一条临时进度消息，保留完整的思考过程
        final lastProgressIndex = _chatMessages.lastIndexWhere(
          (msg) => msg.isProgress && !msg.isUser,
        );
        if (lastProgressIndex != -1) {
          _chatMessages.removeAt(lastProgressIndex);
        }

        _chatMessages.add(
          ChatMessage(
            text: '**错误**\n\n处理您的请求时发生了错误，请稍后重试。',
            isUser: false,
            timestamp: DateTime.now(),
            isMarkdown: true,
          ),
        );
        _isAIProcessing = false;
      });
      _scrollToBottom();
    }
  }

  /// 滚动到底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 快速问题建议
  void _sendQuickQuestion(String question) {
    _chatController.text = question;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
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
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF26D0CE)],
              ),
              borderRadius: BorderRadius.only(
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
                const Expanded(
                  child: Text(
                    'AI薪资分析助手',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.onClose != null)
                  GestureDetector(
                    onTap: widget.onClose,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          // 聊天内容区域
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
          // 输入区域
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF6C63FF)),
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
                  child: _isAIProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _isAIProcessing ? null : _sendMessage,
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
    );
  }

  /// 构建欢迎消息
  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.psychology_rounded,
            size: 48,
            color: Color(0xFF6C63FF),
          ),
          const SizedBox(height: 16),
          const Text(
            '你好！我是AI薪资分析助手',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '我可以帮助您分析员工薪资、绩效和考勤数据',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            '试试这些快速问题：',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickQuestionChip('2024年平均工资是多少'),
              _buildQuickQuestionChip('各部门薪资对比'),
              _buildQuickQuestionChip('工资最高的前5名员工'),
              _buildQuickQuestionChip('技术部员工绩效分析'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建快速问题芯片
  Widget _buildQuickQuestionChip(String question) {
    return GestureDetector(
      onTap: () => _sendQuickQuestion(question),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          question,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 构建聘天消息
  Widget _buildChatMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF26D0CE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                message.isProgress
                    ? (message.isTaskPlanning
                          ? Icons.psychology_rounded
                          : Icons.schedule_rounded)
                    : Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: message.isTaskPlanning
                ? _buildTaskPlanningMessage(message)
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? const Color(0xFF6C63FF)
                          : message.isProgress
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: message.isMarkdown && !message.isUser
                        ? MarkdownBlock(data: message.text)
                        : Text(
                            message.text,
                            style: TextStyle(
                              color: message.isUser
                                  ? Colors.white
                                  : message.isProgress
                                  ? Colors.blue.shade800
                                  : const Color(0xFF2D3748),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                  ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建任务规划消息（可展开查看详情）
  Widget _buildTaskPlanningMessage(ChatMessage message) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isExpanded = false;

        return Container(
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主标题区域
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.expand_more,
                        color: Colors.purple.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (message.stepDetails?.isNotEmpty == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${message.stepDetails!.length}',
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // 步骤详情区域
              if (isExpanded && message.stepDetails?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.purple.shade200),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: message.stepDetails!.map((step) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 8, right: 8),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                step.replaceFirst('• ', ''),
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 聘天消息模型
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isMarkdown;
  final bool isProgress;
  final bool isTaskPlanning;
  final List<String>? stepDetails;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isMarkdown = false,
    this.isProgress = false,
    this.isTaskPlanning = false,
    this.stepDetails,
  });
}
