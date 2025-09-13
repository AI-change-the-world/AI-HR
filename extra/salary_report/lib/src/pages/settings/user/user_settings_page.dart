import 'package:flutter/material.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  String _themeMode = 'system';
  String _language = 'zh';

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
                '用户设置',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '管理和配置您的个人偏好',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              const Text(
                '账户信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text('用户名'),
                  subtitle: const Text('admin'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.lightBlue,
                  ),
                  onTap: () {
                    // TODO: 修改用户名
                  },
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '通知设置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('启用通知'),
                  subtitle: const Text('接收系统通知和提醒'),
                  value: _notificationsEnabled,
                  activeColor: Colors.lightBlue,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '同步设置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('自动同步'),
                  subtitle: const Text('自动同步数据到云端'),
                  value: _autoSyncEnabled,
                  activeColor: Colors.lightBlue,
                  onChanged: (value) {
                    setState(() {
                      _autoSyncEnabled = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '显示设置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '主题模式',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('跟随系统'),
                        leading: Radio<String>(
                          fillColor: MaterialStateProperty.all(
                            Colors.lightBlue,
                          ),
                          value: 'system',
                          groupValue: _themeMode,
                          onChanged: (value) {
                            setState(() {
                              _themeMode = value!;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _themeMode = 'system';
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('浅色模式'),
                        leading: Radio<String>(
                          fillColor: MaterialStateProperty.all(
                            Colors.lightBlue,
                          ),
                          value: 'light',
                          groupValue: _themeMode,
                          onChanged: (value) {
                            setState(() {
                              _themeMode = value!;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _themeMode = 'light';
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('深色模式'),
                        leading: Radio<String>(
                          fillColor: MaterialStateProperty.all(
                            Colors.lightBlue,
                          ),
                          value: 'dark',
                          groupValue: _themeMode,
                          onChanged: (value) {
                            setState(() {
                              _themeMode = value!;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _themeMode = 'dark';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '语言',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('中文'),
                        leading: Radio<String>(
                          fillColor: MaterialStateProperty.all(
                            Colors.lightBlue,
                          ),
                          value: 'zh',
                          groupValue: _language,
                          onChanged: (value) {
                            setState(() {
                              _language = value!;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _language = 'zh';
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('English'),
                        leading: Radio<String>(
                          fillColor: MaterialStateProperty.all(
                            Colors.lightBlue,
                          ),
                          value: 'en',
                          groupValue: _language,
                          onChanged: (value) {
                            setState(() {
                              _language = value!;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _language = 'en';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '账户操作',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shadowColor: Colors.lightBlue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('修改密码'),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.lightBlue,
                      ),
                      onTap: () {
                        // TODO: 修改密码
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('退出登录'),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.lightBlue,
                      ),
                      onTap: () {
                        // TODO: 退出登录
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
