import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/common/logger.dart';

// 简化的多月份分析数据模型
@immutable
class MultiMonthAnalysisData {
  final Map<String, Map<String, dynamic>> monthlyKeyMetrics;
  final List<Map<String, dynamic>> chartData;
  final String cacheKey;

  const MultiMonthAnalysisData({
    required this.monthlyKeyMetrics,
    required this.chartData,
    required this.cacheKey,
  });
}

// 状态类
@immutable
class MultiMonthAnalysisState {
  final bool isLoading;
  final MultiMonthAnalysisData? data;
  final String? error;

  const MultiMonthAnalysisState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  MultiMonthAnalysisState copyWith({
    bool? isLoading,
    MultiMonthAnalysisData? data,
    String? error,
  }) {
    return MultiMonthAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

// Notifier类
class MultiMonthAnalysisNotifier extends Notifier<MultiMonthAnalysisState> {
  @override
  MultiMonthAnalysisState build() => const MultiMonthAnalysisState();

  Future<void> loadData({
    required DataAnalysisService dataAnalysisService,
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
  }) async {
    // 检查是否已有相同参数的数据
    final cacheKey = '$startYear-$startMonth-$endYear-$endMonth';
    if (state.data != null && state.data!.cacheKey == cacheKey && !state.isLoading) {
      return; // 数据已存在且参数相同，无需重新加载
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 获取部门薪资统计数据
      final departmentStats = await dataAnalysisService.getMonthlyDepartmentSalaryStats(
        startYear: startYear,
        startMonth: startMonth,
        endYear: endYear,
        endMonth: endMonth,
      );

      // 处理数据
      final processedData = _processData(departmentStats, cacheKey);

      state = state.copyWith(
        isLoading: false,
        data: processedData,
        error: null,
      );
    } catch (e) {
      logger.severe('Failed to load multi-month analysis data: $e');
      state = state.copyWith(
        isLoading: false,
        error: '数据加载失败: ${e.toString()}',
      );
    }
  }

  void clearData() {
    state = const MultiMonthAnalysisState();
  }

  MultiMonthAnalysisData _processData(
    List<dynamic> departmentStats,
    String cacheKey,
  ) {
    // 使用Map来避免重复计算
    final monthlyData = <String, _MonthlyData>{};
    
    // 处理部门统计数据
    for (final stat in departmentStats) {
      // 假设stat是一个包含年月和部门信息的对象
      final year = stat.year ?? 0;
      final month = stat.month ?? 0;
      final monthKey = '$year-${month.toString().padLeft(2, '0')}';
      final monthData = monthlyData.putIfAbsent(monthKey, () => _MonthlyData(monthKey));
      
      monthData.addDepartment({
        'department': stat.department ?? '未知部门',
        'count': stat.employeeCount ?? 0,
        'total': stat.totalNetSalary ?? 0.0,
        'average': stat.averageNetSalary ?? 0.0,
        'highest': stat.averageNetSalary ?? 0.0,
        'lowest': stat.averageNetSalary ?? 0.0,
      });
    }

    // 生成最终数据结构
    final monthlyKeyMetrics = <String, Map<String, dynamic>>{};
    final chartData = <Map<String, dynamic>>[];

    // 按时间排序月份
    final sortedMonthKeys = monthlyData.keys.toList()
      ..sort((a, b) {
        final aParts = a.split('-');
        final bParts = b.split('-');
        final aYear = int.parse(aParts[0]);
        final aMonth = int.parse(aParts[1]);
        final bYear = int.parse(bParts[0]);
        final bMonth = int.parse(bParts[1]);

        if (aYear != bYear) return aYear.compareTo(bYear);
        return aMonth.compareTo(bMonth);
      });

    // 构建输出数据
    for (final monthKey in sortedMonthKeys) {
      final monthData = monthlyData[monthKey]!;
      final metrics = monthData.getMetrics();

      monthlyKeyMetrics[monthKey] = metrics;

      final parts = monthKey.split('-');
      chartData.add({
        'month': '${parts[0]}年${parts[1]}月',
        'totalEmployees': metrics['totalEmployees'],
        'totalSalary': metrics['totalSalary'],
        'averageSalary': metrics['averageSalary'],
        'departments': monthData.getDepartmentMap(),
      });
    }

    return MultiMonthAnalysisData(
      monthlyKeyMetrics: monthlyKeyMetrics,
      chartData: chartData,
      cacheKey: cacheKey,
    );
  }
}

// 辅助类，用于优化数据处理
class _MonthlyData {
  final String monthKey;
  final List<Map<String, dynamic>> _departments = [];
  Map<String, dynamic>? _cachedMetrics;
  Map<String, dynamic>? _cachedDepartmentMap;

  _MonthlyData(this.monthKey);

  void addDepartment(Map<String, dynamic> department) {
    _departments.add(department);
    // 清除缓存
    _cachedMetrics = null;
    _cachedDepartmentMap = null;
  }

  List<Map<String, dynamic>> getDepartments() => _departments;

  Map<String, dynamic> getMetrics() {
    if (_cachedMetrics != null) return _cachedMetrics!;

    int totalEmployees = 0;
    double totalSalary = 0;
    double highestSalary = 0;
    double lowestSalary = double.infinity;

    for (final dept in _departments) {
      totalEmployees += dept['count'] as int;
      totalSalary += dept['total'] as double;
      final deptHighest = dept['highest'] as double;
      final deptLowest = dept['lowest'] as double;
      if (deptHighest > highestSalary) highestSalary = deptHighest;
      if (deptLowest < lowestSalary) lowestSalary = deptLowest;
    }

    if (lowestSalary == double.infinity) lowestSalary = 0;
    final averageSalary = totalEmployees > 0 ? totalSalary / totalEmployees : 0;

    _cachedMetrics = {
      'totalEmployees': totalEmployees,
      'totalSalary': totalSalary,
      'averageSalary': averageSalary,
      'highestSalary': highestSalary,
      'lowestSalary': lowestSalary,
    };

    return _cachedMetrics!;
  }

  Map<String, dynamic> getDepartmentMap() {
    if (_cachedDepartmentMap != null) return _cachedDepartmentMap!;

    final departments = <String, dynamic>{};
    for (final dept in _departments) {
      departments[dept['department']] = {
        'count': dept['count'],
        'averageSalary': dept['average'],
        'totalSalary': dept['total'],
      };
    }

    _cachedDepartmentMap = departments;
    return _cachedDepartmentMap!;
  }
}

// Provider定义
final multiMonthAnalysisProvider = StateNotifierProvider<MultiMonthAnalysisNotifier, MultiMonthAnalysisState>(
  (ref) => MultiMonthAnalysisNotifier(),
);
