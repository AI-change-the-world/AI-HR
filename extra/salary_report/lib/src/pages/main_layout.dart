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
        backgroundColor: Colors.lightBlue.shade50,
        elevation: 2,
        shadowColor: Colors.lightBlue.withOpacity(0.3),
      ),
      body: Row(
        children: [
          // 侧边栏
          if (_isSidebarOpen || screenWidth >= 768)
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlue.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 侧边栏头部
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade100,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 30,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '工资分析系统',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 导航菜单
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 20),
                      children: [
                        _buildSidebarItem(
                          icon: Icons.upload_file,
                          title: '工资表管理',
                          route: '/salary',
                          context: context,
                          screenWidth: screenWidth,
                        ),
                        _buildSidebarItem(
                          icon: Icons.analytics,
                          title: '数据分析',
                          route: '/analysis',
                          context: context,
                          screenWidth: screenWidth,
                        ),
                        _buildSidebarItem(
                          icon: Icons.bar_chart,
                          title: '可视化展示',
                          route: '/visualization',
                          context: context,
                          screenWidth: screenWidth,
                        ),
                        _buildSidebarItem(
                          icon: Icons.settings,
                          title: '系统设置',
                          route: '/settings',
                          context: context,
                          screenWidth: screenWidth,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 主内容区域
          Expanded(
            child: Container(
              color: Colors.lightBlue.shade50,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required String route,
    required BuildContext context,
    required double screenWidth,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.go(route);
            if (screenWidth < 768) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Icon(icon, size: 24, color: Colors.lightBlue.shade300),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.lightBlue.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
