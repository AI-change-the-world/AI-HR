import 'package:riverpod/riverpod.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart' as multi_month;

// 季度参数 - 扩展自DateRangeParams
class QuarterParams extends multi_month.DateRangeParams {
  final int quarter;

  QuarterParams({
    required int year,
    required this.quarter,
  }) : super(
          startYear: year,
          startMonth: (quarter - 1) * 3 + 1,
          endYear: year,
          endMonth: (quarter - 1) * 3 + 3,
        );

  // 用于 family 的参数比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuarterParams &&
        other.startYear == startYear &&
        other.quarter == quarter;
  }

  @override
  int get hashCode {
    return Object.hash(startYear, quarter);
  }
}

// 上一季度数据状态
class PreviousQuarterState {
  final bool isLoading;
  final Map<String, dynamic>? previousQuarterData;
  final String? error;

  PreviousQuarterState({
    required this.isLoading,
    this.previousQuarterData,
    this.error,
  });
}

// 季度关键指标状态 - 扩展自多月分析的KeyMetricsState
class QuarterlyKeyMetricsState extends multi_month.KeyMetricsState {
  final Map<String, dynamic>? quarterData;

  QuarterlyKeyMetricsState({
    required super.isLoading,
    super.monthlyData,
    this.quarterData,
    super.error,
  });
}

// 上一季度数据提供者
final previousQuarterDataProvider = FutureProvider.family<Map<String, dynamic>?, QuarterParams>((
  ref,
  params,
) async {
  final dataService = DataAnalysisService(IsarDatabase());
  
  try {
    // 计算上一季度的年份和季度
    int previousYear = params.startYear;
    int previousQuarter = params.quarter - 1;
    
    if (previousQuarter == 0) {
      // 如果是第一季度，上一季度就是去年的第四季度
      previousYear = params.startYear - 1;
      previousQuarter = 4;
    }
    
    // 计算上一季度的起始月份和结束月份
    final startMonth = (previousQuarter - 1) * 3 + 1;
    final endMonth = startMonth + 2;
    
    // 创建上一季度的DateRangeParams
    final previousQuarterParams = multi_month.DateRangeParams(
      startYear: previousYear,
      startMonth: startMonth,
      endYear: previousYear,
      endMonth: endMonth,
    );
    
    // 使用多月分析的coreDataProvider获取上一季度数据
    final previousQuarterData = await ref.watch(multi_month.coreDataProvider(previousQuarterParams).future);
    
    if (previousQuarterData == null || previousQuarterData.monthlyComparisons.isEmpty) {
      return null;
    }
    
    // 计算上一季度的汇总数据
    double totalSalary = 0;
    int totalEmployees = 0;
    int totalUniqueEmployees = 0;
    double highestSalary = 0;
    double lowestSalary = double.infinity;
    
    // 使用monthlyComparisons计算汇总数据
    for (var monthData in previousQuarterData.monthlyComparisons) {
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
    totalUniqueEmployees = previousQuarterData.monthlyComparisons.isNotEmpty ? 
        previousQuarterData.monthlyComparisons.fold<Set<String>>(
          {},
          (uniqueIds, month) => uniqueIds..addAll(
            month.workers.map((w) => '${w.name}_${w.department}')
          )
        ).length : 0;
    
    return {
      'year': previousYear,
      'quarter': previousQuarter,
      'totalEmployees': totalEmployees,
      'totalUniqueEmployees': totalUniqueEmployees,
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
    };
  } catch (e) {
    logger.warning('获取上一季度数据失败: $e');
    return null; // 上一季度数据是可选的，失败不影响主要功能
  }
});

// 季度关键指标提供者 - 扩展自多月分析的keyMetricsProvider
final quarterlyKeyMetricsProvider = FutureProvider.family<QuarterlyKeyMetricsState, QuarterParams>((
  ref,
  params,
) async {
  // 使用多月分析的coreDataProvider获取数据
  final multiMonthData = await ref.watch(multi_month.coreDataProvider(params).future);
  
  if (multiMonthData == null) {
    return QuarterlyKeyMetricsState(
      isLoading: false,
      error: '无法获取季度数据',
    );
  }
  
  // 计算季度汇总数据
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
  
  return QuarterlyKeyMetricsState(
    isLoading: false,
    monthlyData: multiMonthData.monthlyComparisons,
    quarterData: {
      'year': params.startYear,
      'quarter': params.quarter,
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

// 上一季度数据状态提供者
final previousQuarterStateProvider = FutureProvider.family<PreviousQuarterState, QuarterParams>((
  ref,
  params,
) async {
  final previousQuarterData = await ref.watch(previousQuarterDataProvider(params).future);
  
  return PreviousQuarterState(
    isLoading: false,
    previousQuarterData: previousQuarterData,
  );
});

// 为了向后兼容，保留原来的keyMetricsProvider接口
final keyMetricsProvider = FutureProvider.family<multi_month.KeyMetricsState, QuarterParams>((
  ref,
  params,
) async {
  final quarterlyData = await ref.watch(quarterlyKeyMetricsProvider(params).future);
  return quarterlyData;
});

// 部门统计提供者 - 复用多月分析的departmentStatsProvider
final departmentStatsProvider = FutureProvider.family<multi_month.DepartmentStatsState, QuarterParams>((
  ref,
  params,
) async {
  // 将QuarterParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的departmentStatsProvider
  return ref.watch(multi_month.departmentStatsProvider(dateRangeParams).future);
});

// 考勤统计提供者 - 复用多月分析的attendanceStatsProvider
final attendanceStatsProvider = FutureProvider.family<multi_month.AttendanceStatsState, QuarterParams>((
  ref,
  params,
) async {
  // 将QuarterParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的attendanceStatsProvider
  return ref.watch(multi_month.attendanceStatsProvider(dateRangeParams).future);
});

// 请假比例统计提供者 - 复用多月分析的leaveRatioStatsProvider
final leaveRatioStatsProvider = FutureProvider.family<multi_month.LeaveRatioStatsState, QuarterParams>((
  ref,
  params,
) async {
  // 将QuarterParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的leaveRatioStatsProvider
  return ref.watch(multi_month.leaveRatioStatsProvider(dateRangeParams).future);
});

// 部门变化提供者 - 复用多月分析的departmentChangesProvider
final departmentChangesProvider = FutureProvider.family<multi_month.DepartmentChangesState, QuarterParams>((
  ref,
  params,
) async {
  // 将QuarterParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的departmentChangesProvider
  return ref.watch(multi_month.departmentChangesProvider(dateRangeParams).future);
});

// 员工变动提供者 - 复用多月分析的departmentChangesProvider
final employeeChangesProvider = FutureProvider.family<multi_month.DepartmentChangesState, QuarterParams>((
  ref,
  params,
) async {
  // 将QuarterParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的departmentChangesProvider
  return ref.watch(multi_month.departmentChangesProvider(dateRangeParams).future);
});

// 图表数据提供者 - 复用多月分析的chartDataProvider
final chartDataProvider = FutureProvider.family<multi_month.ChartDataState, QuarterParams>((
  ref,
  params,
) async {
  // 将QuarterParams转换为DateRangeParams
  final dateRangeParams = params;
  
  // 使用多月分析的chartDataProvider
  return ref.watch(multi_month.chartDataProvider(dateRangeParams).future);
});