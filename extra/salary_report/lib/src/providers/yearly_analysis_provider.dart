import 'package:riverpod/riverpod.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart' as multi_month;

// 年度参数 - 扩展自DateRangeParams
class YearParams extends multi_month.DateRangeParams {
  YearParams({
    required int year,
  }) : super(
          startYear: year,
          startMonth: 1,
          endYear: year,
          endMonth: 12,
        );

  // 用于 family 的参数比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YearParams && other.startYear == startYear;
  }

  @override
  int get hashCode {
    return startYear.hashCode;
  }
}

// 上一年数据状态
class PreviousYearState {
  final bool isLoading;
  final Map<String, dynamic>? previousYearData;
  final String? error;

  PreviousYearState({
    required this.isLoading,
    this.previousYearData,
    this.error,
  });
}

// 年度关键指标状态 - 扩展自多月分析的KeyMetricsState
class YearlyKeyMetricsState extends multi_month.KeyMetricsState {
  final Map<String, dynamic>? yearData;

  YearlyKeyMetricsState({
    required super.isLoading,
    super.monthlyData,
    this.yearData,
    super.error,
  });
}

// 上一年数据提供者
final previousYearDataProvider = FutureProvider.family<Map<String, dynamic>?, YearParams>((
  ref,
  params,
) async {
  final dataService = DataAnalysisService(IsarDatabase());
  
  try {
    // 计算上一年的年份
    final previousYear = params.startYear - 1;
    
    // 创建上一年的DateRangeParams
    final previousYearParams = multi_month.DateRangeParams(
      startYear: previousYear,
      startMonth: 1,
      endYear: previousYear,
      endMonth: 12,
    );
    
    // 使用多月分析的coreDataProvider获取上一年数据
    final previousYearData = await ref.watch(multi_month.coreDataProvider(previousYearParams).future);
    
    if (previousYearData == null || previousYearData.monthlyComparisons.isEmpty) {
      return null;
    }
    
    // 计算上一年的汇总数据
    double totalSalary = 0;
    int totalEmployees = 0;
    int totalUniqueEmployees = 0;
    double highestSalary = 0;
    double lowestSalary = double.infinity;
    
    // 使用monthlyComparisons计算汇总数据
    for (var monthData in previousYearData.monthlyComparisons) {
      totalSalary += monthData.totalSalary;
      totalEmployees += monthData.employeeCount;
      
      if (monthData.highestSalary > highestSalary) {
        highestSalary = monthData.highestSalary;
      }
      
      if (monthData.lowestSalary < lowestSalary && monthData.lowestSalary > 0) {
        lowestSalary = monthData.lowestSalary;
      }
    }
    
    // 确保有效的最低工资
    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }
    
    // 计算平均工资
    final averageSalary = totalEmployees > 0 ? totalSalary / totalEmployees : 0;
    
    // 获取去重后的员工数量
    totalUniqueEmployees = previousYearData.monthlyComparisons.isNotEmpty ? 
        previousYearData.monthlyComparisons.fold<Set<String>>(
          {},
          (uniqueIds, month) => uniqueIds..addAll(
            month.workers.map((w) => '${w.name}_${w.department}')
          )
        ).length : 0;
    
    return {
      'year': previousYear,
      'totalEmployees': totalEmployees,
      'totalUniqueEmployees': totalUniqueEmployees,
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
    };
  } catch (e) {
    logger.warning('获取上一年数据失败: $e');
    return null; // 上一年数据是可选的，失败不影响主要功能
  }
});

// 年度关键指标提供者 - 扩展自多月分析的keyMetricsProvider
final yearlyKeyMetricsProvider = FutureProvider.family<YearlyKeyMetricsState, YearParams>((
  ref,
  params,
) async {
  // 使用多月分析的coreDataProvider获取数据
  final multiMonthData = await ref.watch(multi_month.coreDataProvider(params).future);
  
  if (multiMonthData == null) {
    return YearlyKeyMetricsState(
      isLoading: false,
      error: '无法获取年度数据',
    );
  }
  
  // 计算年度汇总数据
  double totalSalary = 0;
  int totalEmployees = 0;
  double highestSalary = 0;
  double lowestSalary = double.infinity;
  
  // 使用monthlyComparisons计算汇总数据
  for (var monthData in multiMonthData.monthlyComparisons) {
    totalSalary += monthData.totalSalary;
    totalEmployees += monthData.employeeCount;
    
    if (monthData.highestSalary > highestSalary) {
      highestSalary = monthData.highestSalary;
    }
    
    if (monthData.lowestSalary < lowestSalary && monthData.lowestSalary > 0) {
      lowestSalary = monthData.lowestSalary;
    }
  }
  
  // 确保有效的最低工资
  if (lowestSalary == double.infinity) {
    lowestSalary = 0;
  }
  
  // 计算平均工资
  final averageSalary = totalEmployees > 0 ? totalSalary / totalEmployees : 0;
  
  return YearlyKeyMetricsState(
    isLoading: false,
    monthlyData: multiMonthData.monthlyComparisons,
    yearData: {
      'year': params.startYear,
      'totalEmployees': totalEmployees,
      'totalUniqueEmployees': multiMonthData.monthlyComparisons.isNotEmpty ? 
          multiMonthData.monthlyComparisons.fold<Set<String>>(
            {},
            (uniqueIds, month) => uniqueIds..addAll(
              month.workers.map((w) => '${w.name}_${w.department}')
            )
          ).length : 0,
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
    },
  );
});

// 上一年数据状态提供者
final previousYearStateProvider = FutureProvider.family<PreviousYearState, YearParams>((
  ref,
  params,
) async {
  final previousYearData = await ref.watch(previousYearDataProvider(params).future);
  
  return PreviousYearState(
    isLoading: false,
    previousYearData: previousYearData,
  );
});

// 为了向后兼容，保留原来的keyMetricsProvider接口
final keyMetricsProvider = FutureProvider.family<multi_month.KeyMetricsState, YearParams>((
  ref,
  params,
) async {
  final yearlyData = await ref.watch(yearlyKeyMetricsProvider(params).future);
  return yearlyData;
});

// 部门统计提供者 - 复用多月分析的departmentStatsProvider
final departmentStatsProvider = FutureProvider.family<multi_month.DepartmentStatsState, YearParams>((
  ref,
  params,
) async {
  // 将YearParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的departmentStatsProvider
  return ref.watch(multi_month.departmentStatsProvider(dateRangeParams).future);
});

// 考勤统计提供者 - 复用多月分析的attendanceStatsProvider
final attendanceStatsProvider = FutureProvider.family<multi_month.AttendanceStatsState, YearParams>((
  ref,
  params,
) async {
  // 将YearParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的attendanceStatsProvider
  return ref.watch(multi_month.attendanceStatsProvider(dateRangeParams).future);
});

// 请假比例统计提供者 - 复用多月分析的leaveRatioStatsProvider
final leaveRatioStatsProvider = FutureProvider.family<multi_month.LeaveRatioStatsState, YearParams>((
  ref,
  params,
) async {
  // 将YearParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的leaveRatioStatsProvider
  return ref.watch(multi_month.leaveRatioStatsProvider(dateRangeParams).future);
});

// 部门变化提供者 - 复用多月分析的departmentChangesProvider
final departmentChangesProvider = FutureProvider.family<multi_month.DepartmentChangesState, YearParams>((
  ref,
  params,
) async {
  // 将YearParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的departmentChangesProvider
  return ref.watch(multi_month.departmentChangesProvider(dateRangeParams).future);
});

// 员工变动提供者 - 复用多月分析的departmentChangesProvider
final employeeChangesProvider = FutureProvider.family<multi_month.DepartmentChangesState, YearParams>((
  ref,
  params,
) async {
  // 将YearParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的departmentChangesProvider
  return ref.watch(multi_month.departmentChangesProvider(dateRangeParams).future);
});

// 图表数据提供者 - 复用多月分析的chartDataProvider
final chartDataProvider = FutureProvider.family<multi_month.ChartDataState, YearParams>((
  ref,
  params,
) async {
  // 将YearParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的chartDataProvider
  return ref.watch(multi_month.chartDataProvider(dateRangeParams).future);
});