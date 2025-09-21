import 'package:riverpod/riverpod.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/global_analysis_models.dart';

// 季度范围参数
class QuarterRangeParams {
  final int startYear;
  final int startQuarter;
  final int endYear;
  final int endQuarter;

  QuarterRangeParams({
    required this.startYear,
    required this.startQuarter,
    required this.endYear,
    required this.endQuarter,
  });

  // 用于 family 的参数比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuarterRangeParams &&
        other.startYear == startYear &&
        other.startQuarter == startQuarter &&
        other.endYear == endYear &&
        other.endQuarter == endQuarter;
  }

  @override
  int get hashCode {
    return Object.hash(startYear, startQuarter, endYear, endQuarter);
  }
}

// 多季度分析数据模型 - 拆分成独立的状态
class MultiQuarterAnalysisState {
  final bool isLoading;
  final MultiQuarterComparisonData? comparisonData;
  final String? error;

  MultiQuarterAnalysisState({
    required this.isLoading,
    this.comparisonData,
    this.error,
  });

  MultiQuarterAnalysisState copyWith({
    bool? isLoading,
    MultiQuarterComparisonData? comparisonData,
    String? error,
  }) {
    return MultiQuarterAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      comparisonData: comparisonData ?? this.comparisonData,
      error: error ?? this.error,
    );
  }
}

// 关键指标状态
class KeyMetricsState {
  final bool isLoading;
  final List<QuarterlyComparisonData>? quarterlyData;
  final String? error;

  KeyMetricsState({required this.isLoading, this.quarterlyData, this.error});

  KeyMetricsState copyWith({
    bool? isLoading,
    List<QuarterlyComparisonData>? quarterlyData,
    String? error,
  }) {
    return KeyMetricsState(
      isLoading: isLoading ?? this.isLoading,
      quarterlyData: quarterlyData ?? this.quarterlyData,
      error: error ?? this.error,
    );
  }
}

// 部门统计状态
class DepartmentStatsState {
  final bool isLoading;
  final List<QuarterlyComparisonData>? quarterlyData;
  final String? error;

  DepartmentStatsState({
    required this.isLoading,
    this.quarterlyData,
    this.error,
  });

  DepartmentStatsState copyWith({
    bool? isLoading,
    List<QuarterlyComparisonData>? quarterlyData,
    String? error,
  }) {
    return DepartmentStatsState(
      isLoading: isLoading ?? this.isLoading,
      quarterlyData: quarterlyData ?? this.quarterlyData,
      error: error ?? this.error,
    );
  }
}

// 考勤统计状态
class AttendanceStatsState {
  final bool isLoading;
  final Map<String, List<AttendanceStats>>? attendanceData;
  final String? error;

  AttendanceStatsState({
    required this.isLoading,
    this.attendanceData,
    this.error,
  });

  AttendanceStatsState copyWith({
    bool? isLoading,
    Map<String, List<AttendanceStats>>? attendanceData,
    String? error,
  }) {
    return AttendanceStatsState(
      isLoading: isLoading ?? this.isLoading,
      attendanceData: attendanceData ?? this.attendanceData,
      error: error ?? this.error,
    );
  }
}

// 请假比例统计状态
class LeaveRatioStatsState {
  final bool isLoading;
  final List<QuarterlyComparisonData>? quarterlyData;
  final String? error;

  LeaveRatioStatsState({
    required this.isLoading,
    this.quarterlyData,
    this.error,
  });

  LeaveRatioStatsState copyWith({
    bool? isLoading,
    List<QuarterlyComparisonData>? quarterlyData,
    String? error,
  }) {
    return LeaveRatioStatsState(
      isLoading: isLoading ?? this.isLoading,
      quarterlyData: quarterlyData ?? this.quarterlyData,
      error: error ?? this.error,
    );
  }
}

// 部门变化状态
class DepartmentChangesState {
  final bool isLoading;
  final MultiQuarterComparisonData? comparisonData;
  final String? error;

  DepartmentChangesState({
    required this.isLoading,
    this.comparisonData,
    this.error,
  });

  DepartmentChangesState copyWith({
    bool? isLoading,
    MultiQuarterComparisonData? comparisonData,
    String? error,
  }) {
    return DepartmentChangesState(
      isLoading: isLoading ?? this.isLoading,
      comparisonData: comparisonData ?? this.comparisonData,
      error: error ?? this.error,
    );
  }
}

// 图表数据状态
class ChartDataState {
  final bool isLoading;
  final MultiQuarterComparisonData? comparisonData;
  final String? error;

  ChartDataState({required this.isLoading, this.comparisonData, this.error});

  ChartDataState copyWith({
    bool? isLoading,
    MultiQuarterComparisonData? comparisonData,
    String? error,
  }) {
    return ChartDataState(
      isLoading: isLoading ?? this.isLoading,
      comparisonData: comparisonData ?? this.comparisonData,
      error: error ?? this.error,
    );
  }
}

// 生成季度列表的辅助函数
List<Map<String, int>> _generateQuarterList(
  int startYear,
  int startQuarter,
  int endYear,
  int endQuarter,
) {
  final quarterList = <Map<String, int>>[];

  int currentYear = startYear;
  int currentQuarter = startQuarter;

  while (currentYear < endYear ||
      (currentYear == endYear && currentQuarter <= endQuarter)) {
    quarterList.add({'year': currentYear, 'quarter': currentQuarter});

    // 移动到下一个季度
    if (currentQuarter == 4) {
      currentYear++;
      currentQuarter = 1;
    } else {
      currentQuarter++;
    }
  }

  return quarterList;
}

// 核心数据提供者 - 只调用一次 getMultiQuarterComparisonData
final coreDataProvider =
    FutureProvider.family<MultiQuarterComparisonData?, QuarterRangeParams>((
      ref,
      params,
    ) async {
      final dataService = DataAnalysisService(IsarDatabase());
      return await dataService.getMultiQuarterComparisonData(
        params.startYear,
        params.startQuarter,
        params.endYear,
        params.endQuarter,
      );
    });

// 考勤统计核心数据提供者 - 独立获取考勤数据
final coreAttendanceDataProvider =
    FutureProvider.family<
      Map<String, List<AttendanceStats>>,
      QuarterRangeParams
    >((ref, params) async {
      final dataService = DataAnalysisService(IsarDatabase());

      // 按季度获取考勤数据
      final attendanceData = <String, List<AttendanceStats>>{};

      // 使用更简单的方式生成季度列表
      final quarterList = _generateQuarterList(
        params.startYear,
        params.startQuarter,
        params.endYear,
        params.endQuarter,
      );

      // 遍历每个季度获取考勤数据
      for (var quarterInfo in quarterList) {
        final year = quarterInfo['year']!;
        final quarter = quarterInfo['quarter']!;

        // 计算季度的月份范围
        final quarterStartMonth = (quarter - 1) * 3 + 1;
        final quarterEndMonth = quarter * 3;

        // 获取该季度所有月份的考勤数据
        final attendanceStats = <AttendanceStats>[];

        // 遍历季度内的每个月份
        for (int month = quarterStartMonth; month <= quarterEndMonth; month++) {
          final monthAttendance = await dataService.getMonthlyAttendanceStats(
            year: year,
            month: month,
          );
          attendanceStats.addAll(monthAttendance);
        }

        final quarterKey = '$year-Q${quarter}';
        attendanceData[quarterKey] = attendanceStats;
      }

      return attendanceData;
    });

// 关键指标提供者 - 复用核心数据
final keyMetricsProvider =
    FutureProvider.family<KeyMetricsState, QuarterRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return KeyMetricsState(
        isLoading: false,
        quarterlyData: coreData?.quarterlyComparisons,
      );
    });

// 部门统计提供者 - 复用核心数据
final departmentStatsProvider =
    FutureProvider.family<DepartmentStatsState, QuarterRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return DepartmentStatsState(
        isLoading: false,
        quarterlyData: coreData?.quarterlyComparisons,
      );
    });

// 考勤统计提供者 - 复用考勤核心数据
final attendanceStatsProvider =
    FutureProvider.family<AttendanceStatsState, QuarterRangeParams>((
      ref,
      params,
    ) async {
      final attendanceData = await ref.watch(
        coreAttendanceDataProvider(params).future,
      );

      return AttendanceStatsState(
        isLoading: false,
        attendanceData: attendanceData,
      );
    });

// 请假比例统计提供者 - 复用核心数据
final leaveRatioStatsProvider =
    FutureProvider.family<LeaveRatioStatsState, QuarterRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return LeaveRatioStatsState(
        isLoading: false,
        quarterlyData: coreData?.quarterlyComparisons,
      );
    });

// 部门变化提供者 - 复用核心数据
final departmentChangesProvider =
    FutureProvider.family<DepartmentChangesState, QuarterRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return DepartmentChangesState(isLoading: false, comparisonData: coreData);
    });

// 图表数据提供者 - 复用核心数据
final chartDataProvider =
    FutureProvider.family<ChartDataState, QuarterRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return ChartDataState(isLoading: false, comparisonData: coreData);
    });

// 分页状态模型
class PaginationState {
  final int currentPage;
  final int itemsPerPage;

  PaginationState({required this.currentPage, required this.itemsPerPage});

  PaginationState copyWith({int? currentPage, int? itemsPerPage}) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }
}

// 分页状态提供者
final paginationProvider =
    NotifierProvider<PaginationNotifier, PaginationState>(
      PaginationNotifier.new,
    );

class PaginationNotifier extends Notifier<PaginationState> {
  @override
  PaginationState build() {
    // 默认每页显示3个季度的数据
    return PaginationState(currentPage: 0, itemsPerPage: 3);
  }

  // 设置当前页
  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  // 设置每页显示的项目数
  void setItemsPerPage(int itemsPerPage) {
    state = state.copyWith(itemsPerPage: itemsPerPage);
  }

  // 下一页
  void nextPage(int totalPages) {
    if (state.currentPage < totalPages - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  // 上一页
  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }
}
