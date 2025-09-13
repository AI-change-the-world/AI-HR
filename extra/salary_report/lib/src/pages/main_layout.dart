import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A47A3);
  static const Color secondary = Color(0xFF26D0CE);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarOpen = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 在小屏幕上默认收起侧边栏
    if (screenWidth < 768) {
      _isSidebarOpen = false;
    } else {
      _isSidebarOpen = true;
    }

    return Scaffold(
      key: _scaffoldKey,
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(70),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //         colors: [AppColors.primary, AppColors.primaryLight],
      //       ),
      //       boxShadow: [
      //         BoxShadow(
      //           color: AppColors.cardShadow,
      //           blurRadius: 10,
      //           offset: const Offset(0, 2),
      //         ),
      //       ],
      //     ),
      //     child: AppBar(
      //       title: Row(
      //         children: [
      //           Container(
      //             padding: const EdgeInsets.all(8),
      //             decoration: BoxDecoration(
      //               color: Colors.white.withOpacity(0.2),
      //               borderRadius: BorderRadius.circular(12),
      //             ),
      //             child: const Icon(
      //               Icons.analytics_outlined,
      //               color: Colors.white,
      //               size: 24,
      //             ),
      //           ),
      //           const SizedBox(width: 12),
      //           const Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               Text(
      //                 '薪资智能分析',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 20,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //               Text(
      //                 'Smart Salary Analytics',
      //                 style: TextStyle(
      //                   color: Colors.white70,
      //                   fontSize: 12,
      //                   fontWeight: FontWeight.w400,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //       centerTitle: false,
      //       leading: IconButton(
      //         icon: Container(
      //           padding: const EdgeInsets.all(8),
      //           decoration: BoxDecoration(
      //             color: Colors.white.withOpacity(0.2),
      //             borderRadius: BorderRadius.circular(10),
      //           ),
      //           child: const Icon(
      //             Icons.menu_rounded,
      //             color: Colors.white,
      //             size: 20,
      //           ),
      //         ),
      //         onPressed: () {
      //           setState(() {
      //             _isSidebarOpen = !_isSidebarOpen;
      //           });
      //         },
      //       ),
      //       backgroundColor: Colors.transparent,
      //       elevation: 0,
      //       actions: [
      //         Padding(
      //           padding: const EdgeInsets.only(right: 16),
      //           child: CircleAvatar(
      //             backgroundColor: Colors.white.withOpacity(0.2),
      //             child: const Icon(
      //               Icons.person_outline,
      //               color: Colors.white,
      //               size: 20,
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Colors.white],
          ),
        ),
        child: Row(
          children: [
            // 侧边栏
            if (_isSidebarOpen || screenWidth >= 768)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 20,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 侧边栏头部
                    // Container(
                    //   padding: const EdgeInsets.all(24),
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       begin: Alignment.topLeft,
                    //       end: Alignment.bottomRight,
                    //       colors: [
                    //         AppColors.primary.withOpacity(0.1),
                    //         AppColors.secondary.withOpacity(0.1),
                    //       ],
                    //     ),
                    //     borderRadius: const BorderRadius.only(
                    //       bottomLeft: Radius.circular(30),
                    //       bottomRight: Radius.circular(30),
                    //     ),
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.all(16),
                    //         decoration: BoxDecoration(
                    //           gradient: LinearGradient(
                    //             colors: [
                    //               AppColors.primary,
                    //               AppColors.primaryLight,
                    //             ],
                    //           ),
                    //           borderRadius: BorderRadius.circular(20),
                    //           boxShadow: [
                    //             BoxShadow(
                    //               color: AppColors.primary.withOpacity(0.3),
                    //               blurRadius: 15,
                    //               offset: const Offset(0, 8),
                    //             ),
                    //           ],
                    //         ),
                    //         child: const Icon(
                    //           Icons.trending_up_rounded,
                    //           size: 32,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 16),
                    //       const Text(
                    //         '薪资分析中心',
                    //         style: TextStyle(
                    //           color: AppColors.primaryDark,
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 4),
                    //       Text(
                    //         'Salary Analytics Hub',
                    //         style: TextStyle(
                    //           color: Colors.grey[600],
                    //           fontSize: 12,
                    //           fontWeight: FontWeight.w400,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // 导航菜单
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        children: [
                          _buildSidebarItem(
                            icon: Icons.cloud_upload_rounded,
                            title: '工资表管理',
                            subtitle: '上传与管理',
                            route: '/salary',
                            context: context,
                            screenWidth: screenWidth,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _buildSidebarItem(
                            icon: Icons.analytics_outlined,
                            title: '数据分析',
                            subtitle: '深度洞察',
                            route: '/analysis',
                            context: context,
                            screenWidth: screenWidth,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(height: 12),
                          _buildSidebarItem(
                            icon: Icons.bar_chart_rounded,
                            title: '可视化展示',
                            subtitle: '图表报告',
                            route: '/visualization',
                            context: context,
                            screenWidth: screenWidth,
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: 12),
                          _buildSidebarItem(
                            icon: Icons.settings_outlined,
                            title: '系统设置',
                            subtitle: '个性配置',
                            route: '/settings',
                            context: context,
                            screenWidth: screenWidth,
                            color: Colors.grey[600]!,
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
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required BuildContext context,
    required double screenWidth,
    required Color color,
  }) {
    final isSelected = GoRouterState.of(context).uri.path.startsWith(route);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isSelected
            ? LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              )
            : null,
        border: isSelected
            ? Border.all(color: color.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.go(route);
            if (screenWidth < 768) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? color : Colors.grey[800],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
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
