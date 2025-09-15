import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/toast.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  // 大模型设置
  bool _aiEnabled = false;
  String _baseUrl = '';
  String _apiKey = '';
  String _modelName = '';

  // 公司名称设置
  String _companyName = '';

  // 文本控制器
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelNameController;
  late TextEditingController _companyNameController;

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _baseUrlController = TextEditingController(text: _baseUrl);
    _apiKeyController = TextEditingController(text: _apiKey);
    _modelNameController = TextEditingController(text: _modelName);
    _companyNameController = TextEditingController(text: _companyName);
    _loadSettings();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelNameController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  // 加载设置
  Future<void> _loadSettings() async {
    setState(() {
      _aiEnabled = AIConfig.aiEnabled;
      _baseUrl = AIConfig.baseUrl;
      _apiKey = AIConfig.apiKey;
      _modelName = AIConfig.modelName;
      _companyName = AIConfig.companyName;
    });
  }

  // 保存设置
  Future<void> _saveSettings() async {
    await AIConfig.setAiEnabled(_aiEnabled);
    await AIConfig.setBaseUrl(_baseUrl);
    await AIConfig.setApiKey(_apiKey);
    await AIConfig.setModelName(_modelName);
    await AIConfig.setCompanyName(_companyName);

    if (context.mounted) {
      ToastUtils.success(null, title: '设置已保存');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 移除AppBar，因为主布局已经提供了
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '系统设置',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '配置系统参数',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // 公司信息设置
              const Text(
                '公司信息设置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '公司名称',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          hintText: '请输入公司名称，用于生成报告抬头',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _companyName = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI大模型设置
              const Text(
                'AI大模型设置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI开关
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '启用人工智能',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '开启后可使用AI分析功能',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _aiEnabled,
                            onChanged: (value) {
                              setState(() {
                                _aiEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Base URL输入
                      const Text(
                        'Base URL',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        enabled: _aiEnabled,
                        controller: _baseUrlController,
                        decoration: const InputDecoration(
                          hintText: '请输入大模型API的Base URL',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _baseUrl = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // API Key输入
                      const Text(
                        'API Key',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        enabled: _aiEnabled,
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          hintText: '请输入API密钥',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            _apiKey = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Model Name输入
                      const Text(
                        '模型名称',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        enabled: _aiEnabled,
                        controller: _modelNameController,
                        decoration: const InputDecoration(
                          hintText: '请输入模型名称，如gpt-4',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _modelName = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '保存设置',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
