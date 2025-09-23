// src/report/report_data_service.dart

import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:salary_report/src/pages/visualization/report/analysis_data.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

/// 报告数据服务
/// 负责准备报告所需的所有数据和文本内容
class ReportDataService {
  final AISummaryService _aiService;
  final DataAnalysisService _dataService;

  ReportDataService({
    required AISummaryService aiService,
    required DataAnalysisService dataService,
  }) : _aiService = aiService,
       _dataService = dataService;

  /// 计算薪资区间分布
  List<Map<String, int>> calculateSalaryRanges(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    // 定义薪资范围
    final salaryRanges = [
      {'min': 0.0, 'max': 3000.0, 'label': '< 3000'},
      {'min': 3000.0, 'max': 4000.0, 'label': '3000-4000'},
      {'min': 4000.0, 'max': 5000.0, 'label': '4000-5000'},
      {'min': 5000.0, 'max': 6000.0, 'label': '5000-6000'},
      {'min': 6000.0, 'max': 7000.0, 'label': '6000-7000'},
      {'min': 7000.0, 'max': 8000.0, 'label': '7000-8000'},
      {'min': 8000.0, 'max': 9000.0, 'label': '8000-9000'},
      {'min': 9000.0, 'max': 10000.0, 'label': '9000-10000'},
      {'min': 10000.0, 'max': double.infinity, 'label': '10000以上'},
    ];

    final rangeCounts = <String, int>{};

    // 初始化计数器
    for (var range in salaryRanges) {
      rangeCounts[range['label'] as String] = 0;
    }

    // 统计每个薪资范围的人数
    for (var stat in departmentStats) {
      for (var range in salaryRanges) {
        final min = range['min'] as double;
        final max = range['max'] as double;
        if (stat.averageNetSalary >= min && stat.averageNetSalary < max) {
          final label = range['label'] as String;
          rangeCounts[label] = rangeCounts[label]! + stat.employeeCount;
          break;
        }
      }
    }

    return rangeCounts.entries
        .map((entry) => {entry.key: entry.value})
        .toList();
  }

  /// 通用的报告数据准备方法
  Future<ReportContentModel> prepareReportData({
    required List<DepartmentSalaryStats> departmentStats,
    required Map<String, dynamic> analysisData,
    required int year,
    required int month,
    required bool isMultiMonth,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // 根据是否为多月报告调用相应的方法
    if (isMultiMonth) {
      // 对于多月报告，创建一个简单的MultiMonthAnalysisData对象
      final monthlyData = [
        MonthlyAnalysisData(
          year: year,
          month: month,
          departmentStats: departmentStats,
          analysisData: analysisData,
        ),
      ];

      final multiMonthData = MultiMonthAnalysisData(
        startTime: startTime,
        endTime: endTime,
        monthlyData: monthlyData,
      );

      return await prepareReportDataForMultiMonth(multiMonthData);
    } else {
      // 对于单月报告
      final singleMonthData = SingleMonthAnalysisData(
        year: year,
        month: month,
        departmentStats: departmentStats,
        analysisData: analysisData,
      );

      return await prepareReportDataForSingleMonth(singleMonthData);
    }
  }

  /// 为单月报告准备数据
  Future<ReportContentModel> prepareReportDataForSingleMonth(
    SingleMonthAnalysisData data,
  ) async {
    // 计算基本统计数据
    double totalEmployees = 0.0;
    double totalSalary = 0.0;
    double highestSalary = 0.0;
    double lowestSalary = double.infinity;

    for (var stat in data.departmentStats) {
      totalEmployees += stat.employeeCount;
      totalSalary += stat.totalNetSalary;
      if (stat.averageNetSalary > highestSalary) {
        highestSalary = stat.averageNetSalary;
      }
      if (stat.averageNetSalary < lowestSalary) {
        lowestSalary = stat.averageNetSalary;
      }
    }

    if (lowestSalary == double.infinity) {
      lowestSalary = 0.0;
    }

    final double averageSalary = totalEmployees > 0
        ? totalSalary / totalEmployees.toDouble()
        : 0.0;

    // 生成部门详情
    final departmentDetails = StringBuffer();
    for (var stat in data.departmentStats) {
      departmentDetails.writeln(
        '${stat.department}: ${stat.employeeCount}人, 平均工资¥${stat.averageNetSalary.toStringAsFixed(2)}',
      );
    }

    // 生成员工详情（这里简化处理，实际应用中可能需要更多数据）
    final employeeDetails = '总员工数: $totalEmployees人';

    // 生成薪资区间描述
    final salaryRanges = calculateSalaryRanges(data.departmentStats);
    final salaryRangeDescription = _generateSalaryRangeDescription(
      salaryRanges, // 将Map转换为List<Map<String, int>>
    );

    // 生成薪资结构数据（用于图表）
    final salaryStructureData = _generateSalaryStructureData(
      data.departmentStats,
    );

    // 生成报告标题和时间信息
    final reportTitle = '${data.year}年${data.month}月工资分析报告';
    final reportDate = DateFormat('yyyy年MM月dd日').format(DateTime.now());
    final reportTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final startTime = '${data.year}年${data.month}月01日';
    final endTime =
        '${data.year}年${data.month}月${_getLastDayOfMonth(data.year, data.month)}日';

    // 生成薪资结构分析
    final salaryStructure = _generateSalaryStructureAnalysis(
      data.departmentStats,
    );

    // 生成薪资结构优化建议
    final salaryStructureAdvice = _generateSalaryStructureAdvice(
      data.departmentStats,
    );

    // 生成AI分析内容
    final salaryRangeFeatureSummary = await _aiService
        .generateSalaryRangeFeatureSummary(
          salaryRanges,
          data.departmentStats,
        ); // 传递List<Map<String, int>>

    final departmentSalaryAnalysis = await _aiService
        .generateDepartmentSalaryAnalysis(data.departmentStats);

    final keySalaryPoint = await _aiService.generateKeySalaryPoint(
      data.departmentStats,
      salaryRanges, // 传递List<Map<String, int>>
    );

    // 生成薪资排名
    final salaryRankings = _generateSalaryRankings(data.departmentStats);

    // 计算基础工资和绩效工资比例（这里简化处理）
    final basicSalaryRate = 0.7; // 假设基础工资占70%
    final performanceSalaryRate = 0.3; // 假设绩效工资占30%

    return ReportContentModel(
      reportTitle: reportTitle,
      reportDate: reportDate,
      companyName: '示例公司',
      reportTime: reportTime,
      startTime: startTime,
      endTime: endTime,
      compareLast: '与上月相比', // 简化处理
      totalEmployees: totalEmployees.toInt(),
      totalSalary: totalSalary,
      averageSalary: averageSalary,
      departmentCount: data.departmentStats.length,
      employeeCount: totalEmployees.toInt(),
      employeeDetails: employeeDetails,
      departmentDetails: departmentDetails.toString(),
      salaryRangeDescription: salaryRangeDescription,
      salaryRangeFeatureSummary: salaryRangeFeatureSummary,
      departmentSalaryAnalysis: departmentSalaryAnalysis,
      keySalaryPoint: keySalaryPoint,
      salaryRankings: salaryRankings,
      basicSalaryRate: basicSalaryRate,
      performanceSalaryRate: performanceSalaryRate,
      salaryStructure: salaryStructure,
      salaryStructureAdvice: salaryStructureAdvice,
      salaryStructureData: salaryStructureData,
      departmentStats: data.departmentStats,
    );
  }

  /// 为多月报告准备数据
  Future<ReportContentModel> prepareReportDataForMultiMonth(
    MultiMonthAnalysisData data,
  ) async {
    // 获取最后一个月的数据用于基础统计
    final lastMonthData = data.monthlyData.last;

    // 计算基本统计数据
    double totalEmployees = 0.0;
    double totalSalary = 0.0;
    double highestSalary = 0.0;
    double lowestSalary = double.infinity;

    for (var stat in lastMonthData.departmentStats) {
      totalEmployees += stat.employeeCount;
      totalSalary += stat.totalNetSalary;
      if (stat.averageNetSalary > highestSalary) {
        highestSalary = stat.averageNetSalary;
      }
      if (stat.averageNetSalary < lowestSalary) {
        lowestSalary = stat.averageNetSalary;
      }
    }

    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }

    final double averageSalary = totalEmployees > 0
        ? totalSalary / totalEmployees
        : 0.0;

    // 生成部门详情
    final departmentDetails = StringBuffer();
    for (var stat in lastMonthData.departmentStats) {
      departmentDetails.writeln(
        '${stat.department}: ${stat.employeeCount}人, 平均工资¥${stat.averageNetSalary.toStringAsFixed(2)}',
      );
    }

    // 生成员工详情（这里简化处理，实际应用中可能需要更多数据）
    final employeeDetails = '总员工数: $totalEmployees人';

    // 生成薪资区间描述
    final salaryRanges = calculateSalaryRanges(lastMonthData.departmentStats);
    final salaryRangeDescription = _generateSalaryRangeDescription(
      salaryRanges, // 将Map转换为List<Map<String, int>>
    );

    // 生成薪资结构数据（用于图表）
    final salaryStructureData = _generateSalaryStructureData(
      lastMonthData.departmentStats,
    );

    // 生成报告标题和时间信息
    final reportTitle =
        '${data.startTime.year}年${data.startTime.month}月至${data.endTime.year}年${data.endTime.month}月工资分析报告';
    final reportDate = DateFormat('yyyy年MM月dd日').format(DateTime.now());
    final reportTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final startTime =
        '${data.startTime.year}年${data.startTime.month}月${data.startTime.day}日';
    final endTime =
        '${data.endTime.year}年${data.endTime.month}月${data.endTime.day}日';

    // 生成薪资结构分析
    final salaryStructure = _generateSalaryStructureAnalysis(
      lastMonthData.departmentStats,
    );

    // 生成薪资结构优化建议
    final salaryStructureAdvice = _generateSalaryStructureAdvice(
      lastMonthData.departmentStats,
    );

    // 生成AI分析内容
    final salaryRangeFeatureSummary = await _aiService
        .generateSalaryRangeFeatureSummary(
          salaryRanges, // 传递List<Map<String, int>>
          lastMonthData.departmentStats,
        );

    final departmentSalaryAnalysis = await _aiService
        .generateDepartmentSalaryAnalysis(lastMonthData.departmentStats);

    final keySalaryPoint = await _aiService.generateKeySalaryPoint(
      lastMonthData.departmentStats,
      salaryRanges, // 传递List<Map<String, int>>
    );

    // 生成薪资排名
    final salaryRankings = _generateSalaryRankings(
      lastMonthData.departmentStats,
    );

    // 计算基础工资和绩效工资比例（这里简化处理）
    final basicSalaryRate = 0.7; // 假设基础工资占70%
    final performanceSalaryRate = 0.3; // 假设绩效工资占30%

    // 多月报告专用数据
    final employeeCountPerMonth = _calculateEmployeeCountPerMonth(data);
    final averageSalaryPerMonth = _calculateAverageSalaryPerMonth(data);
    final totalSalaryPerMonth = _calculateTotalSalaryPerMonth(data);
    final departmentDetailsPerMonth = _calculateDepartmentDetailsPerMonth(data);

    return ReportContentModel(
      reportTitle: reportTitle,
      reportDate: reportDate,
      companyName: '示例公司',
      reportTime: reportTime,
      startTime: startTime,
      endTime: endTime,
      compareLast: '与上期相比', // 简化处理
      totalEmployees: totalEmployees.toInt(),
      totalSalary: totalSalary,
      averageSalary: averageSalary,
      departmentCount: lastMonthData.departmentStats.length,
      employeeCount: totalEmployees.toInt(),
      employeeDetails: employeeDetails,
      departmentDetails: departmentDetails.toString(),
      salaryRangeDescription: salaryRangeDescription,
      salaryRangeFeatureSummary: salaryRangeFeatureSummary,
      departmentSalaryAnalysis: departmentSalaryAnalysis,
      keySalaryPoint: keySalaryPoint,
      salaryRankings: salaryRankings,
      basicSalaryRate: basicSalaryRate,
      performanceSalaryRate: performanceSalaryRate,
      salaryStructure: salaryStructure,
      salaryStructureAdvice: salaryStructureAdvice,
      salaryStructureData: salaryStructureData,
      departmentStats: lastMonthData.departmentStats,
      // 多月报告专用字段
      employeeCountPerMonth: employeeCountPerMonth,
      averageSalaryPerMonth: averageSalaryPerMonth,
      totalSalaryPerMonth: totalSalaryPerMonth,
      departmentDetailsPerMonth: departmentDetailsPerMonth,
    );
  }

  /// 为单季度报告准备数据
  Future<ReportContentModel> prepareReportDataForSingleQuarter(
    SingleQuarterAnalysisData data,
  ) async {
    // 复用单月报告的逻辑，因为数据结构相似
    final singleMonthData = SingleMonthAnalysisData(
      year: data.year,
      month: (data.quarter - 1) * 3 + 1, // 季度的第一个月
      departmentStats: data.departmentStats,
      analysisData: data.analysisData,
    );

    return await prepareReportDataForSingleMonth(singleMonthData);
  }

  /// 为多季度报告准备数据
  Future<ReportContentModel> prepareReportDataForMultiQuarter(
    MultiQuarterAnalysisData data,
  ) async {
    // 获取最后一个季度的数据用于基础统计
    final lastQuarterData = data.quarterlyData.last;

    // 计算基本统计数据
    double totalEmployees = 0.0;
    double totalSalary = 0.0;
    double highestSalary = 0.0;
    double lowestSalary = double.infinity;

    for (var stat in lastQuarterData.departmentStats) {
      totalEmployees += stat.employeeCount;
      totalSalary += stat.totalNetSalary;
      if (stat.averageNetSalary > highestSalary) {
        highestSalary = stat.averageNetSalary;
      }
      if (stat.averageNetSalary < lowestSalary) {
        lowestSalary = stat.averageNetSalary;
      }
    }

    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }

    final double averageSalary = totalEmployees > 0
        ? totalSalary / totalEmployees
        : 0.0;

    // 生成部门详情
    final departmentDetails = StringBuffer();
    for (var stat in lastQuarterData.departmentStats) {
      departmentDetails.writeln(
        '${stat.department}: ${stat.employeeCount}人, 平均工资¥${stat.averageNetSalary.toStringAsFixed(2)}',
      );
    }

    // 生成员工详情（这里简化处理，实际应用中可能需要更多数据）
    final employeeDetails = '总员工数: $totalEmployees人';

    // 生成薪资区间描述
    final salaryRanges = calculateSalaryRanges(lastQuarterData.departmentStats);
    final salaryRangeDescription = _generateSalaryRangeDescription(
      salaryRanges, // 将Map转换为List<Map<String, int>>
    );

    // 生成薪资结构数据（用于图表）
    final salaryStructureData = _generateSalaryStructureData(
      lastQuarterData.departmentStats,
    );

    // 生成报告标题和时间信息
    final reportTitle =
        '${data.startTime.year}年第${((data.startTime.month - 1) ~/ 3) + 1}季度至${data.endTime.year}年第${((data.endTime.month - 1) ~/ 3) + 1}季度工资分析报告';
    final reportDate = DateFormat('yyyy年MM月dd日').format(DateTime.now());
    final reportTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final startTime =
        '${data.startTime.year}年${data.startTime.month}月${data.startTime.day}日';
    final endTime =
        '${data.endTime.year}年${data.endTime.month}月${data.endTime.day}日';

    // 生成薪资结构分析
    final salaryStructure = _generateSalaryStructureAnalysis(
      lastQuarterData.departmentStats,
    );

    // 生成薪资结构优化建议
    final salaryStructureAdvice = _generateSalaryStructureAdvice(
      lastQuarterData.departmentStats,
    );

    // 生成AI分析内容
    final salaryRangeFeatureSummary = await _aiService
        .generateSalaryRangeFeatureSummary(
          salaryRanges, // 传递List<Map<String, int>>
          lastQuarterData.departmentStats,
        );

    final departmentSalaryAnalysis = await _aiService
        .generateDepartmentSalaryAnalysis(lastQuarterData.departmentStats);

    final keySalaryPoint = await _aiService.generateKeySalaryPoint(
      lastQuarterData.departmentStats,
      salaryRanges, // 传递List<Map<String, int>>
    );

    // 生成薪资排名
    final salaryRankings = _generateSalaryRankings(
      lastQuarterData.departmentStats,
    );

    // 计算基础工资和绩效工资比例（这里简化处理）
    final basicSalaryRate = 0.7; // 假设基础工资占70%
    final performanceSalaryRate = 0.3; // 假设绩效工资占30%

    return ReportContentModel(
      reportTitle: reportTitle,
      reportDate: reportDate,
      companyName: '示例公司',
      reportTime: reportTime,
      startTime: startTime,
      endTime: endTime,
      compareLast: '与上期相比', // 简化处理
      totalEmployees: totalEmployees.toInt(),
      totalSalary: totalSalary,
      averageSalary: averageSalary,
      departmentCount: lastQuarterData.departmentStats.length,
      employeeCount: totalEmployees.toInt(),
      employeeDetails: employeeDetails,
      departmentDetails: departmentDetails.toString(),
      salaryRangeDescription: salaryRangeDescription,
      salaryRangeFeatureSummary: salaryRangeFeatureSummary,
      departmentSalaryAnalysis: departmentSalaryAnalysis,
      keySalaryPoint: keySalaryPoint,
      salaryRankings: salaryRankings,
      basicSalaryRate: basicSalaryRate,
      performanceSalaryRate: performanceSalaryRate,
      salaryStructure: salaryStructure,
      salaryStructureAdvice: salaryStructureAdvice,
      salaryStructureData: salaryStructureData,
      departmentStats: lastQuarterData.departmentStats,
    );
  }

  /// 为单年报告准备数据
  Future<ReportContentModel> prepareReportDataForSingleYear(
    SingleYearAnalysisData data,
  ) async {
    // 计算基本统计数据
    double totalEmployees = 0.0;
    double totalSalary = 0.0;
    double highestSalary = 0.0;
    double lowestSalary = double.infinity;

    for (var stat in data.departmentStats) {
      totalEmployees += stat.employeeCount;
      totalSalary += stat.totalNetSalary;
      if (stat.averageNetSalary > highestSalary) {
        highestSalary = stat.averageNetSalary;
      }
      if (stat.averageNetSalary < lowestSalary) {
        lowestSalary = stat.averageNetSalary;
      }
    }

    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }

    final double averageSalary = totalEmployees > 0
        ? totalSalary / totalEmployees
        : 0.0;

    // 生成部门详情
    final departmentDetails = StringBuffer();
    for (var stat in data.departmentStats) {
      departmentDetails.writeln(
        '${stat.department}: ${stat.employeeCount}人, 平均工资¥${stat.averageNetSalary.toStringAsFixed(2)}',
      );
    }

    // 生成员工详情（这里简化处理，实际应用中可能需要更多数据）
    final employeeDetails = '总员工数: $totalEmployees人';

    // 生成薪资区间描述
    final salaryRanges = calculateSalaryRanges(data.departmentStats);
    final salaryRangeDescription = _generateSalaryRangeDescription(
      salaryRanges, // 将Map转换为List<Map<String, int>>
    );

    // 生成薪资结构数据（用于图表）
    final salaryStructureData = _generateSalaryStructureData(
      data.departmentStats,
    );

    // 生成报告标题和时间信息
    final reportTitle = '${data.year}年度工资分析报告';
    final reportDate = DateFormat('yyyy年MM月dd日').format(DateTime.now());
    final reportTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final startTime = '${data.year}年01月01日';
    final endTime = '${data.year}年12月31日';

    // 生成薪资结构分析
    final salaryStructure = _generateSalaryStructureAnalysis(
      data.departmentStats,
    );

    // 生成薪资结构优化建议
    final salaryStructureAdvice = _generateSalaryStructureAdvice(
      data.departmentStats,
    );

    // 生成AI分析内容
    final salaryRangeFeatureSummary = await _aiService
        .generateSalaryRangeFeatureSummary(
          salaryRanges,
          data.departmentStats,
        ); // 传递List<Map<String, int>>

    final departmentSalaryAnalysis = await _aiService
        .generateDepartmentSalaryAnalysis(data.departmentStats);

    final keySalaryPoint = await _aiService.generateKeySalaryPoint(
      data.departmentStats,
      salaryRanges, // 传递List<Map<String, int>>
    );

    // 生成薪资排名
    final salaryRankings = _generateSalaryRankings(data.departmentStats);

    // 计算基础工资和绩效工资比例（这里简化处理）
    final basicSalaryRate = 0.7; // 假设基础工资占70%
    final performanceSalaryRate = 0.3; // 假设绩效工资占30%

    return ReportContentModel(
      reportTitle: reportTitle,
      reportDate: reportDate,
      companyName: '示例公司',
      reportTime: reportTime,
      startTime: startTime,
      endTime: endTime,
      compareLast: '与上年相比', // 简化处理
      totalEmployees: totalEmployees.toInt(),
      totalSalary: totalSalary,
      averageSalary: averageSalary,
      departmentCount: data.departmentStats.length,
      employeeCount: totalEmployees.toInt(),
      employeeDetails: employeeDetails,
      departmentDetails: departmentDetails.toString(),
      salaryRangeDescription: salaryRangeDescription,
      salaryRangeFeatureSummary: salaryRangeFeatureSummary,
      departmentSalaryAnalysis: departmentSalaryAnalysis,
      keySalaryPoint: keySalaryPoint,
      salaryRankings: salaryRankings,
      basicSalaryRate: basicSalaryRate,
      performanceSalaryRate: performanceSalaryRate,
      salaryStructure: salaryStructure,
      salaryStructureAdvice: salaryStructureAdvice,
      salaryStructureData: salaryStructureData,
      departmentStats: data.departmentStats,
    );
  }

  /// 为多年报告准备数据
  Future<ReportContentModel> prepareReportDataForMultiYear(
    MultiYearAnalysisData data,
  ) async {
    // 获取最后一年的数据用于基础统计
    final lastYearData = data.annualData.last;

    // 计算基本统计数据
    double totalEmployees = 0.0;
    double totalSalary = 0.0;
    double highestSalary = 0.0;
    double lowestSalary = double.infinity;

    for (var stat in lastYearData.departmentStats) {
      totalEmployees += stat.employeeCount;
      totalSalary += stat.totalNetSalary;
      if (stat.averageNetSalary > highestSalary) {
        highestSalary = stat.averageNetSalary;
      }
      if (stat.averageNetSalary < lowestSalary) {
        lowestSalary = stat.averageNetSalary;
      }
    }

    if (lowestSalary == double.infinity) {
      lowestSalary = 0;
    }

    final double averageSalary = totalEmployees > 0
        ? totalSalary / totalEmployees
        : 0.0;

    // 生成部门详情
    final departmentDetails = StringBuffer();
    for (var stat in lastYearData.departmentStats) {
      departmentDetails.writeln(
        '${stat.department}: ${stat.employeeCount}人, 平均工资¥${stat.averageNetSalary.toStringAsFixed(2)}',
      );
    }

    // 生成员工详情（这里简化处理，实际应用中可能需要更多数据）
    final employeeDetails = '总员工数: $totalEmployees人';

    // 生成薪资区间描述
    final salaryRanges = calculateSalaryRanges(lastYearData.departmentStats);
    final salaryRangeDescription = _generateSalaryRangeDescription(
      salaryRanges, // 将Map转换为List<Map<String, int>>
    );

    // 生成薪资结构数据（用于图表）
    final salaryStructureData = _generateSalaryStructureData(
      lastYearData.departmentStats,
    );

    // 生成报告标题和时间信息
    final reportTitle = '${data.startYear}年至${data.endYear}年工资分析报告';
    final reportDate = DateFormat('yyyy年MM月dd日').format(DateTime.now());
    final reportTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final startTime = '${data.startYear}年01月01日';
    final endTime = '${data.endYear}年12月31日';

    // 生成薪资结构分析
    final salaryStructure = _generateSalaryStructureAnalysis(
      lastYearData.departmentStats,
    );

    // 生成薪资结构优化建议
    final salaryStructureAdvice = _generateSalaryStructureAdvice(
      lastYearData.departmentStats,
    );

    // 生成AI分析内容
    final salaryRangeFeatureSummary = await _aiService
        .generateSalaryRangeFeatureSummary(
          salaryRanges, // 传递List<Map<String, int>>
          lastYearData.departmentStats,
        );

    final departmentSalaryAnalysis = await _aiService
        .generateDepartmentSalaryAnalysis(lastYearData.departmentStats);

    final keySalaryPoint = await _aiService.generateKeySalaryPoint(
      lastYearData.departmentStats,
      salaryRanges, // 传递List<Map<String, int>>
    );

    // 生成薪资排名
    final salaryRankings = _generateSalaryRankings(
      lastYearData.departmentStats,
    );

    // 计算基础工资和绩效工资比例（这里简化处理）
    final basicSalaryRate = 0.7; // 假设基础工资占70%
    final performanceSalaryRate = 0.3; // 假设绩效工资占30%

    return ReportContentModel(
      reportTitle: reportTitle,
      reportDate: reportDate,
      companyName: '示例公司',
      reportTime: reportTime,
      startTime: startTime,
      endTime: endTime,
      compareLast: '与上年相比', // 简化处理
      totalEmployees: totalEmployees.toInt(),
      totalSalary: totalSalary,
      averageSalary: averageSalary,
      departmentCount: lastYearData.departmentStats.length,
      employeeCount: totalEmployees.toInt(),
      employeeDetails: employeeDetails,
      departmentDetails: departmentDetails.toString(),
      salaryRangeDescription: salaryRangeDescription,
      salaryRangeFeatureSummary: salaryRangeFeatureSummary,
      departmentSalaryAnalysis: departmentSalaryAnalysis,
      keySalaryPoint: keySalaryPoint,
      salaryRankings: salaryRankings,
      basicSalaryRate: basicSalaryRate,
      performanceSalaryRate: performanceSalaryRate,
      salaryStructure: salaryStructure,
      salaryStructureAdvice: salaryStructureAdvice,
      salaryStructureData: salaryStructureData,
      departmentStats: lastYearData.departmentStats,
    );
  }

  /// 计算每月员工数量
  List<Map<String, dynamic>> _calculateEmployeeCountPerMonth(
    MultiMonthAnalysisData data,
  ) {
    final result = <Map<String, dynamic>>[];
    for (var monthlyData in data.monthlyData) {
      double totalEmployees = 0.0;
      for (var stat in monthlyData.departmentStats) {
        totalEmployees += stat.employeeCount;
      }
      result.add({
        'year': monthlyData.year,
        'month': monthlyData.month,
        'employeeCount': totalEmployees,
      });
    }
    return result;
  }

  /// 计算每月平均薪资
  List<Map<String, dynamic>> _calculateAverageSalaryPerMonth(
    MultiMonthAnalysisData data,
  ) {
    final result = <Map<String, dynamic>>[];
    for (var monthlyData in data.monthlyData) {
      double totalEmployees = 0.0;
      double totalSalary = 0.0;
      for (var stat in monthlyData.departmentStats) {
        totalEmployees += stat.employeeCount;
        totalSalary += stat.totalNetSalary;
      }
      final averageSalary = totalEmployees > 0
          ? totalSalary / totalEmployees
          : 0.0;
      result.add({
        'year': monthlyData.year,
        'month': monthlyData.month,
        'averageSalary': averageSalary,
      });
    }
    return result;
  }

  /// 计算每月总薪资
  List<Map<String, dynamic>> _calculateTotalSalaryPerMonth(
    MultiMonthAnalysisData data,
  ) {
    final result = <Map<String, dynamic>>[];
    for (var monthlyData in data.monthlyData) {
      double totalSalary = 0.0;
      for (var stat in monthlyData.departmentStats) {
        totalSalary += stat.totalNetSalary;
      }
      result.add({
        'year': monthlyData.year,
        'month': monthlyData.month,
        'totalSalary': totalSalary,
      });
    }
    return result;
  }

  /// 计算每月部门详情
  List<Map<String, dynamic>> _calculateDepartmentDetailsPerMonth(
    MultiMonthAnalysisData data,
  ) {
    final result = <Map<String, dynamic>>[];
    for (var monthlyData in data.monthlyData) {
      final departmentDetails = <Map<String, dynamic>>[];
      for (var stat in monthlyData.departmentStats) {
        departmentDetails.add({
          'department': stat.department,
          'employeeCount': stat.employeeCount,
          'averageSalary': stat.averageNetSalary,
          'totalSalary': stat.totalNetSalary,
        });
      }
      result.add({
        'year': monthlyData.year,
        'month': monthlyData.month,
        'departmentDetails': departmentDetails,
      });
    }
    return result;
  }

  /// 生成薪资区间描述
  String _generateSalaryRangeDescription(
    List<Map<String, int>> salaryRangesList,
  ) {
    final buffer = StringBuffer();
    for (var salaryRanges in salaryRangesList) {
      salaryRanges.forEach((label, count) {
        if (count > 0) {
          buffer.writeln('$label: $count人');
        }
      });
    }
    return buffer.toString();
  }

  /// 生成薪资结构数据（用于图表）
  List<Map<String, dynamic>> _generateSalaryStructureData(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    final data = <Map<String, dynamic>>[];
    for (var stat in departmentStats) {
      data.add({
        'department': stat.department,
        'averageSalary': stat.averageNetSalary,
        'employeeCount': stat.employeeCount,
      });
    }
    return data;
  }

  /// 获取指定年月的最后一天
  int _getLastDayOfMonth(int year, int month) {
    final date = DateTime(year, month + 1, 0);
    return date.day;
  }

  /// 生成薪资结构分析
  String _generateSalaryStructureAnalysis(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    // 这里简化处理，实际应用中可能需要更复杂的分析
    return '薪资结构分析内容...';
  }

  /// 生成薪资结构优化建议
  String _generateSalaryStructureAdvice(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    // 这里简化处理，实际应用中可能需要更复杂的分析
    return '薪资结构优化建议内容...';
  }

  /// 生成薪资排名
  String _generateSalaryRankings(List<DepartmentSalaryStats> departmentStats) {
    // 按平均薪资排序
    final sortedStats = List<DepartmentSalaryStats>.from(departmentStats)
      ..sort((a, b) => b.averageNetSalary.compareTo(a.averageNetSalary));

    final buffer = StringBuffer();
    for (int i = 0; i < sortedStats.length && i < 10; i++) {
      final stat = sortedStats[i];
      buffer.writeln(
        '${i + 1}. ${stat.department}: ¥${stat.averageNetSalary.toStringAsFixed(2)}',
      );
    }
    return buffer.toString();
  }
}
