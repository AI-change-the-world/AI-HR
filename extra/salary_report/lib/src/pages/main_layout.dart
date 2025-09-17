import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
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

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final sidebarState = ref.watch(sidebarStateProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // 根据当前路径更新选中状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = GoRouterState.of(context).uri.path;
      ref
          .read(sidebarStateProvider.notifier)
          .updateSelectedRouteFromPath(currentRoute);
    });

    // 在小屏幕上自动管理侧边栏状态
    final shouldShowSidebar = sidebarState.isOpen || screenWidth >= 768;

    return Scaffold(
      key: _scaffoldKey,
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
            if (shouldShowSidebar)
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
                            icon: Icons.folder_open_rounded,
                            title: '报告管理',
                            subtitle: '查看与删除',
                            route: '/report-management',
                            context: context,
                            screenWidth: screenWidth,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 12),
                          _buildSidebarItem(
                            icon: Icons.settings_outlined,
                            title: '系统设置',
                            subtitle: 'AI配置',
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
    final sidebarState = ref.watch(sidebarStateProvider);
    final isSelected = sidebarState.selectedRoute == route;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              )
            : null,
        border: isSelected
            ? Border.all(color: color.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(sidebarStateProvider.notifier).setSelectedRoute(route);
            context.go(route);
            if (screenWidth < 768) {
              ref.read(sidebarStateProvider.notifier).setSidebarOpen(false);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
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
                          fontFamily: 'ph',
                          fontSize: 15,
                          color: isSelected ? color : Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'ph',
                          fontSize: 12,
                          color: Colors.grey[600],
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
