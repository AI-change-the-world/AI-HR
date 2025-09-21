import 'dart:async';
import 'package:riverpod/riverpod.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';

// 多月分析数据模型 - 拆分成独立的状态
class MultiMonthAnalysisState {
  final bool isLoading;
  final MultiMonthComparisonData? comparisonData;
  final String? error;

  MultiMonthAnalysisState({
    required this.isLoading,
    this.comparisonData,
    this.error,
  });

  MultiMonthAnalysisState copyWith({
    bool? isLoading,
    MultiMonthComparisonData? comparisonData,
    String? error,
  }) {
    return MultiMonthAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      comparisonData: comparisonData ?? this.comparisonData,
      error: error ?? this.error,
    );
  }
}

// 关键指标状态
class KeyMetricsState {
  final bool isLoading;
  final List<MonthlyComparisonData>? monthlyData;
  final String? error;

  KeyMetricsState({required this.isLoading, this.monthlyData, this.error});

  KeyMetricsState copyWith({
    bool? isLoading,
    List<MonthlyComparisonData>? monthlyData,
    String? error,
  }) {
    return KeyMetricsState(
      isLoading: isLoading ?? this.isLoading,
      monthlyData: monthlyData ?? this.monthlyData,
      error: error ?? this.error,
    );
  }
}

// 部门统计状态
class DepartmentStatsState {
  final bool isLoading;
  final List<MonthlyComparisonData>? monthlyData;
  final String? error;

  DepartmentStatsState({required this.isLoading, this.monthlyData, this.error});

  DepartmentStatsState copyWith({
    bool? isLoading,
    List<MonthlyComparisonData>? monthlyData,
    String? error,
  }) {
    return DepartmentStatsState(
      isLoading: isLoading ?? this.isLoading,
      monthlyData: monthlyData ?? this.monthlyData,
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
  final List<MonthlyComparisonData>? monthlyData;
  final String? error;

  LeaveRatioStatsState({required this.isLoading, this.monthlyData, this.error});

  LeaveRatioStatsState copyWith({
    bool? isLoading,
    List<MonthlyComparisonData>? monthlyData,
    String? error,
  }) {
    return LeaveRatioStatsState(
      isLoading: isLoading ?? this.isLoading,
      monthlyData: monthlyData ?? this.monthlyData,
      error: error ?? this.error,
    );
  }
}

// 部门变化状态
class DepartmentChangesState {
  final bool isLoading;
  final MultiMonthComparisonData? comparisonData;
  final String? error;

  DepartmentChangesState({
    required this.isLoading,
    this.comparisonData,
    this.error,
  });

  DepartmentChangesState copyWith({
    bool? isLoading,
    MultiMonthComparisonData? comparisonData,
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
  final MultiMonthComparisonData? comparisonData;
  final String? error;

  ChartDataState({required this.isLoading, this.comparisonData, this.error});

  ChartDataState copyWith({
    bool? isLoading,
    MultiMonthComparisonData? comparisonData,
    String? error,
  }) {
    return ChartDataState(
      isLoading: isLoading ?? this.isLoading,
      comparisonData: comparisonData ?? this.comparisonData,
      error: error ?? this.error,
    );
  }
}

// 时间范围参数
class DateRangeParams {
  final int startYear;
  final int startMonth;
  final int endYear;
  final int endMonth;

  DateRangeParams({
    required this.startYear,
    required this.startMonth,
    required this.endYear,
    required this.endMonth,
  });

  // 用于 family 的参数比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeParams &&
        other.startYear == startYear &&
        other.startMonth == startMonth &&
        other.endYear == endYear &&
        other.endMonth == endMonth;
  }

  @override
  int get hashCode {
    return Object.hash(startYear, startMonth, endYear, endMonth);
  }
}

// 核心数据提供者 - 只调用一次 getMultiMonthComparisonData
final coreDataProvider =
    FutureProvider.family<MultiMonthComparisonData?, DateRangeParams>((
      ref,
      params,
    ) async {
      final dataService = DataAnalysisService(IsarDatabase());
      final comparisonData = await dataService.getMultiMonthComparisonData(
        params.startYear,
        params.startMonth,
        params.endYear,
        params.endMonth,
      );
      return comparisonData;
    });

// 考勤统计核心数据提供者 - 独立获取考勤数据
final coreAttendanceDataProvider =
    FutureProvider.family<Map<String, List<AttendanceStats>>, DateRangeParams>((
      ref,
      params,
    ) async {
      final dataService = DataAnalysisService(IsarDatabase());

      // 按月份获取考勤数据
      final attendanceData = <String, List<AttendanceStats>>{};

      // 使用更简单的方式生成月份列表
      final monthList = _generateMonthList(
        params.startYear,
        params.startMonth,
        params.endYear,
        params.endMonth,
      );

      // 遍历每个月份获取考勤数据
      for (var monthInfo in monthList) {
        final year = monthInfo['year']!;
        final month = monthInfo['month']!;

        final attendanceStats = await dataService.getMonthlyAttendanceStats(
          year: year,
          month: month,
        );

        final monthKey = '$year-${month.toString().padLeft(2, '0')}';
        attendanceData[monthKey] = attendanceStats;
      }

      return attendanceData;
    });

// 生成月份列表的辅助函数
List<Map<String, int>> _generateMonthList(
  int startYear,
  int startMonth,
  int endYear,
  int endMonth,
) {
  final monthList = <Map<String, int>>[];

  int currentYear = startYear;
  int currentMonth = startMonth;

  while (currentYear < endYear ||
      (currentYear == endYear && currentMonth <= endMonth)) {
    monthList.add({'year': currentYear, 'month': currentMonth});

    // 移动到下一个月
    if (currentMonth == 12) {
      currentYear++;
      currentMonth = 1;
    } else {
      currentMonth++;
    }
  }

  return monthList;
}

// 关键指标提供者 - 复用核心数据
final keyMetricsProvider =
    FutureProvider.family<KeyMetricsState, DateRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return KeyMetricsState(
        isLoading: false,
        monthlyData: coreData?.monthlyComparisons,
      );
    });

// 部门统计提供者 - 复用核心数据
final departmentStatsProvider =
    FutureProvider.family<DepartmentStatsState, DateRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return DepartmentStatsState(
        isLoading: false,
        monthlyData: coreData?.monthlyComparisons,
      );
    });

// 考勤统计提供者 - 复用考勤核心数据
final attendanceStatsProvider =
    FutureProvider.family<AttendanceStatsState, DateRangeParams>((
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
    FutureProvider.family<LeaveRatioStatsState, DateRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return LeaveRatioStatsState(
        isLoading: false,
        monthlyData: coreData?.monthlyComparisons,
      );
    });

// 部门变化提供者 - 复用核心数据
final departmentChangesProvider =
    FutureProvider.family<DepartmentChangesState, DateRangeParams>((
      ref,
      params,
    ) async {
      final coreData = await ref.watch(coreDataProvider(params).future);

      return DepartmentChangesState(isLoading: false, comparisonData: coreData);
    });

// 图表数据提供者 - 复用核心数据
final chartDataProvider =
    FutureProvider.family<ChartDataState, DateRangeParams>((ref, params) async {
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
    // 默认每页显示3个月的数据
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
