import 'package:riverpod/riverpod.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

// 年度范围参数
class YearRangeParams {
  final int startYear;
  final int endYear;

  YearRangeParams({required this.startYear, required this.endYear});

  // 用于 family 的参数比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YearRangeParams &&
        other.startYear == startYear &&
        other.endYear == endYear;
  }

  @override
  int get hashCode {
    return Object.hash(startYear, endYear);
  }
}

// 关键指标状态
class KeyMetricsState {
  final bool isLoading;
  final List<YearlyComparisonData>? yearlyData;
  final String? error;

  KeyMetricsState({required this.isLoading, this.yearlyData, this.error});

  KeyMetricsState copyWith({
    bool? isLoading,
    List<YearlyComparisonData>? yearlyData,
    String? error,
  }) {
    return KeyMetricsState(
      isLoading: isLoading ?? this.isLoading,
      yearlyData: yearlyData ?? this.yearlyData,
      error: error ?? this.error,
    );
  }
}

// 部门统计状态
class DepartmentStatsState {
  final bool isLoading;
  final List<YearlyComparisonData>? yearlyData;
  final String? error;

  DepartmentStatsState({required this.isLoading, this.yearlyData, this.error});

  DepartmentStatsState copyWith({
    bool? isLoading,
    List<YearlyComparisonData>? yearlyData,
    String? error,
  }) {
    return DepartmentStatsState(
      isLoading: isLoading ?? this.isLoading,
      yearlyData: yearlyData ?? this.yearlyData,
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
  final List<YearlyComparisonData>? yearlyData;
  final String? error;

  LeaveRatioStatsState({required this.isLoading, this.yearlyData, this.error});

  LeaveRatioStatsState copyWith({
    bool? isLoading,
    List<YearlyComparisonData>? yearlyData,
    String? error,
  }) {
    return LeaveRatioStatsState(
      isLoading: isLoading ?? this.isLoading,
      yearlyData: yearlyData ?? this.yearlyData,
      error: error ?? this.error,
    );
  }
}

// 部门变化状态
class DepartmentChangesState {
  final bool isLoading;
  final MultiYearComparisonData? comparisonData;
  final String? error;

  DepartmentChangesState({
    required this.isLoading,
    this.comparisonData,
    this.error,
  });

  DepartmentChangesState copyWith({
    bool? isLoading,
    MultiYearComparisonData? comparisonData,
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
  final MultiYearComparisonData? comparisonData;
  final String? error;

  ChartDataState({required this.isLoading, this.comparisonData, this.error});

  ChartDataState copyWith({
    bool? isLoading,
    MultiYearComparisonData? comparisonData,
    String? error,
  }) {
    return ChartDataState(
      isLoading: isLoading ?? this.isLoading,
      comparisonData: comparisonData ?? this.comparisonData,
      error: error ?? this.error,
    );
  }
}

// 核心数据提供者 - 只调用一次 getMultiYearComparisonData
final coreDataProvider =
    FutureProvider.family<MultiYearComparisonData?, YearRangeParams>((
      ref,
      params,
    ) async {
      final service = DataAnalysisService(IsarDatabase());
      return await service.getMultiYearComparisonData(
        params.startYear,
        params.endYear,
      );
    });

// 考勤统计核心数据提供者 - 独立获取考勤数据
final coreAttendanceDataProvider =
    FutureProvider.family<Map<String, List<AttendanceStats>>, YearRangeParams>((
      ref,
      params,
    ) async {
      final service = DataAnalysisService(IsarDatabase());

      // 按年份获取考勤数据
      final attendanceData = <String, List<AttendanceStats>>{};

      // 为每个年份获取考勤数据
      for (int year = params.startYear; year <= params.endYear; year++) {
        final stats = await service.getMonthlyAttendanceStats(
          year: year, // 修复：使用正确的参数
        );
        attendanceData['$year年'] = stats;
      }

      return attendanceData;
    });

// 关键指标提供者 - 复用核心数据
final keyMetricsProvider =
    FutureProvider.family<KeyMetricsState, YearRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return KeyMetricsState(
        isLoading: false,
        yearlyData: coreData?.yearlyComparisons,
      );
    });

// 部门统计提供者 - 复用核心数据
final departmentStatsProvider =
    FutureProvider.family<DepartmentStatsState, YearRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return DepartmentStatsState(
        isLoading: false,
        yearlyData: coreData?.yearlyComparisons,
      );
    });

// 考勤统计提供者 - 复用考勤核心数据
final attendanceStatsProvider =
    FutureProvider.family<AttendanceStatsState, YearRangeParams>((
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
    FutureProvider.family<LeaveRatioStatsState, YearRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return LeaveRatioStatsState(
        isLoading: false,
        yearlyData: coreData?.yearlyComparisons,
      );
    });

// 部门变化提供者 - 复用核心数据
final departmentChangesProvider =
    FutureProvider.family<DepartmentChangesState, YearRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return DepartmentChangesState(isLoading: false, comparisonData: coreData);
    });

// 图表数据提供者 - 复用核心数据
final chartDataProvider =
    FutureProvider.family<ChartDataState, YearRangeParams>((ref, params) async {
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
    // 默认每页显示3年的数据
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
