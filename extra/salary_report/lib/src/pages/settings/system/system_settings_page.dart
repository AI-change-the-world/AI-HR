import 'package:flutter/material.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  String _storageLocation = 'internal';
  bool _autoBackupEnabled = true;
  String _backupFrequency = 'daily';
  bool _dataEncryptionEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('系统设置')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '存储设置',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        '存储位置',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('内部存储'),
                        leading: Radio<String>(
                          value: 'internal',
                          groupValue: _storageLocation,
                          onChanged: (value) {
                            setState(() {
                              _storageLocation = value!;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _storageLocation = 'internal';
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('外部存储'),
                        leading: Radio<String>(
                          value: 'external',
                          groupValue: _storageLocation,
                          onChanged: (value) {
                            setState(() {
                              _storageLocation = value!;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _storageLocation = 'external';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '备份设置',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  title: const Text('自动备份'),
                  subtitle: const Text('定期自动备份数据'),
                  value: _autoBackupEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoBackupEnabled = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),

              if (_autoBackupEnabled)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          '备份频率',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          title: const Text('每天'),
                          leading: Radio<String>(
                            value: 'daily',
                            groupValue: _backupFrequency,
                            onChanged: (value) {
                              setState(() {
                                _backupFrequency = value!;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _backupFrequency = 'daily';
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('每周'),
                          leading: Radio<String>(
                            value: 'weekly',
                            groupValue: _backupFrequency,
                            onChanged: (value) {
                              setState(() {
                                _backupFrequency = value!;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _backupFrequency = 'weekly';
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('每月'),
                          leading: Radio<String>(
                            value: 'monthly',
                            groupValue: _backupFrequency,
                            onChanged: (value) {
                              setState(() {
                                _backupFrequency = value!;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _backupFrequency = 'monthly';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              const Text(
                '安全设置',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  title: const Text('数据加密'),
                  subtitle: const Text('对存储的数据进行加密'),
                  value: _dataEncryptionEnabled,
                  onChanged: (value) {
                    setState(() {
                      _dataEncryptionEnabled = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '系统信息',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text('应用版本'),
                        subtitle: Text('v1.0.0'),
                      ),
                      const Divider(),
                      const ListTile(
                        title: Text('数据存储位置'),
                        subtitle: Text('/storage/emulated/0/salary_reports/'),
                      ),
                      const Divider(),
                      const ListTile(
                        title: Text('已存储数据'),
                        subtitle: Text('12 个工资表文件'),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('存储空间'),
                        subtitle: const Text('已使用 2.4MB / 总计 100MB'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // TODO: 清理缓存
                          },
                          child: const Text('清理'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '高级操作',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('导入数据'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: 导入数据
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('导出数据'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: 导出数据
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('重置应用'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: 重置应用
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
