import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarOpen = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 在小屏幕上默认收起侧边栏
    if (screenWidth < 768) {
      _isSidebarOpen = false;
    } else {
      _isSidebarOpen = true;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('员工工资智能化分析系统'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        ),
      ),
      body: Row(
        children: [
          // 侧边栏
          if (_isSidebarOpen || screenWidth >= 768)
            SizedBox(
              width: 250,
              child: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.blue),
                      child: Text(
                        '工资分析系统',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.upload_file),
                      title: const Text('工资表管理'),
                      onTap: () {
                        context.go('/salary');
                        if (screenWidth < 768) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.analytics),
                      title: const Text('数据分析'),
                      onTap: () {
                        context.go('/analysis');
                        if (screenWidth < 768) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text('可视化展示'),
                      onTap: () {
                        context.go('/visualization');
                        if (screenWidth < 768) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('系统设置'),
                      onTap: () {
                        context.go('/settings');
                        if (screenWidth < 768) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

          // 主内容区域
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
