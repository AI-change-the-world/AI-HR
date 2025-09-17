import 'package:riverpod/riverpod.dart';
import 'package:salary_report/src/isar/ai_salary_service.dart';
import 'package:salary_report/src/isar/database.dart';
import '../components/smart_time_picker.dart';

// 侧边栏状态管理
final sidebarStateProvider = NotifierProvider<SidebarNotifier, SidebarState>(
  SidebarNotifier.new,
);

// AI薪资服务提供者
final aiSalaryServiceProvider = Provider<AISalaryService>((ref) {
  final database = IsarDatabase();
  return AISalaryService(database);
});

class SidebarState {
  final String selectedRoute;
  final bool isOpen;

  SidebarState({required this.selectedRoute, required this.isOpen});

  SidebarState copyWith({String? selectedRoute, bool? isOpen}) {
    return SidebarState(
      selectedRoute: selectedRoute ?? this.selectedRoute,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

class SidebarNotifier extends Notifier<SidebarState> {
  @override
  SidebarState build() => SidebarState(selectedRoute: '/salary', isOpen: false);

  void setSelectedRoute(String route) {
    state = state.copyWith(selectedRoute: route);
  }

  void toggleSidebar() {
    state = state.copyWith(isOpen: !state.isOpen);
  }

  void setSidebarOpen(bool isOpen) {
    state = state.copyWith(isOpen: isOpen);
  }

  // 根据当前路径更新选中状态
  void updateSelectedRouteFromPath(String path) {
    String selectedRoute = '/salary'; // 默认选中薪资管理

    if (path.startsWith('/salary')) {
      selectedRoute = '/salary';
    } else if (path.startsWith('/analysis')) {
      selectedRoute = '/analysis';
    } else if (path.startsWith('/visualization')) {
      selectedRoute = '/visualization';
    } else if (path.startsWith('/settings')) {
      selectedRoute = '/settings';
    } else if (path == '/') {
      selectedRoute = '/salary'; // 主页默认选中薪资管理
    }

    if (selectedRoute != state.selectedRoute) {
      setSelectedRoute(selectedRoute);
    }
  }
}

// 时间范围状态管理
final timeRangeProvider = NotifierProvider<TimeRangeNotifier, TimeRange?>(
  TimeRangeNotifier.new,
);

class TimeRangeNotifier extends Notifier<TimeRange?> {
  @override
  TimeRange? build() => null;

  void setTimeRange(TimeRange timeRange) {
    state = timeRange;
  }

  void clearTimeRange() {
    state = null;
  }
}

// 分析维度状态管理
final analysisDimensionProvider =
    NotifierProvider<AnalysisDimensionNotifier, String>(
      AnalysisDimensionNotifier.new,
    );

class AnalysisDimensionNotifier extends Notifier<String> {
  @override
  String build() => 'month'; // 默认选择月份分析

  void setDimension(String dimension) {
    state = dimension;
  }
}
