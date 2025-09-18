// src/report/services/report_data_service.dart

import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/pages/visualization/report/ai_summary_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';

class ReportDataService {
  final AISummaryService _aiService;
  DataAnalysisService? _dataService;

  ReportDataService(this._aiService);

  // 设置数据服务的方法
  void setDataService(DataAnalysisService dataService) {
    _dataService = dataService;
  }

  // A public method to calculate salary ranges, so it can be used by other services
  Map<String, int> calculateSalaryRanges(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    final ranges = <String, int>{};
    for (final dept in departmentStats) {
      final salary = dept.averageNetSalary;
      String range;
      if (salary < 3000) {
        range = '< 3000';
      } else if (salary < 4000) {
        range = '3000-4000';
      } else if (salary < 5000) {
        range = '4000-5000';
      } else if (salary < 6000) {
        range = '5000-6000';
      } else if (salary < 7000) {
        range = '6000-7000';
      } else if (salary < 8000) {
        range = '7000-8000';
      } else if (salary < 9000) {
        range = '8000-9000';
      } else if (salary < 10000) {
        range = '9000-10000';
      } else {
        range = '> 10000';
      }
      ranges[range] = (ranges[range] ?? 0) + dept.employeeCount;
    }
    return ranges;
  }

  /// 生成薪资结构分析文本
  String _generateSalaryStructureAnalysis(Map<String, dynamic>? summaryData) {
    if (summaryData == null || summaryData.isEmpty) {
      return "暂无薪资结构数据";
    }

    final buffer = StringBuffer();

    // 定义需要显示的薪资结构字段及其显示名称
    final salaryFields = {
      "基本工资": "基本工资",
      "岗位工资": "岗位工资",
      "绩效工资": "绩效工资",
      "补贴工资": "补贴工资",
      "综合薪资标准": "综合薪资标准",
      "当月基本工资": "当月基本工资",
      "当月岗位工资": "当月岗位工资",
      "当月绩效工资": "当月绩效工资",
      "当月补贴工资": "当月补贴工资",
      "加班费": "加班费",
      "津贴": "津贴",
      "奖金": "奖金",
      "社保扣款": "社保扣款",
      "个税": "个税",
      "其他扣款": "其他扣款",
      "饭补": "饭补",
    };

    // 按顺序添加薪资结构信息
    salaryFields.forEach((key, displayName) {
      if (summaryData.containsKey(key)) {
        final value = summaryData[key];
        if (value != null && value.toString().isNotEmpty) {
          buffer.write("$displayName：$value；");
        }
      }
    });

    // 如果没有找到任何相关字段，返回默认信息
    if (buffer.isEmpty) {
      return "暂无薪资结构数据";
    }

    // 优化表述，将最后一个分号替换为句号
    String result = buffer.toString();
    if (result.endsWith("；")) {
      result = result.substring(0, result.length - 1) + "。";
    }

    return result;
  }

  /// 提取薪资结构数据用于生成饼图
  List<Map<String, dynamic>> _extractSalaryStructureData(
    Map<String, dynamic>? summaryData,
  ) {
    final List<Map<String, dynamic>> salaryStructureData = [];

    if (summaryData == null || summaryData.isEmpty) {
      return salaryStructureData;
    }

    // 定义需要显示的薪资结构字段及其显示名称（仅包含收入项）
    final incomeFields = {
      "基本工资": "基本工资",
      "岗位工资": "岗位工资",
      "绩效工资": "绩效工资",
      "补贴工资": "补贴工资",
      "综合薪资标准": "综合薪资标准",
      "当月基本工资": "当月基本工资",
      "当月岗位工资": "当月岗位工资",
      "当月绩效工资": "当月绩效工资",
      "当月补贴工资": "当月补贴工资",
      "加班费": "加班费",
      "津贴": "津贴",
      "奖金": "奖金",
      "饭补": "饭补",
    };

    // 提取收入项数据
    incomeFields.forEach((key, displayName) {
      if (summaryData.containsKey(key)) {
        final value = summaryData[key];
        if (value != null && value.toString().isNotEmpty) {
          // 尝试解析数值
          final numericValue = _parseNumericValue(value.toString());
          if (numericValue != null && numericValue > 0) {
            salaryStructureData.add({
              'category': displayName,
              'value': numericValue,
            });
          }
        }
      }
    });

    return salaryStructureData;
  }

  /// 解析字符串中的数值
  double? _parseNumericValue(String value) {
    // 移除非数字字符（保留数字、小数点和负号）
    final numericString = value.replaceAll(RegExp(r'[^\d.-]'), '');
    if (numericString.isEmpty) return null;

    try {
      return double.parse(numericString);
    } catch (e) {
      return null;
    }
  }

  Future<ReportContentModel> prepareReportData({
    required List<DepartmentSalaryStats> departmentStats,
    required Map<String, dynamic> analysisData,
    required int year,
    required int month,
    required bool isMultiMonth,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final currentTime = DateTime.now();

    // Perform calculations
    final salaryRanges = calculateSalaryRanges(departmentStats);
    final sortedDeptsByCount = List<DepartmentSalaryStats>.from(departmentStats)
      ..sort((a, b) => b.employeeCount.compareTo(a.employeeCount));
    final sortedDeptsBySalary = List<DepartmentSalaryStats>.from(
      departmentStats,
    )..sort((a, b) => b.averageNetSalary.compareTo(a.averageNetSalary));

    // Prepare text descriptions
    final reportTime = isMultiMonth
        ? '$year年$month月至${currentTime.year}年${currentTime.month}月'
        : '$year年$month月';

    final currentTimeStr =
        '${currentTime.year}年${currentTime.month}月${currentTime.day}日';
    final startTimeStr = '${startTime.year}年${startTime.month}月';
    final endTimeStr = '${endTime.year}年${endTime.month}月';

    final salaryRangeDesc = salaryRanges.entries
        .map((e) => '${e.key}元区间有${e.value}人')
        .join('，');

    final employeeCount = departmentStats.fold(
      0,
      (sum, stat) => sum + stat.employeeCount,
    );
    final employeeDetails = sortedDeptsByCount
        .map((dept) => '${dept.department}部门${dept.employeeCount}人')
        .join('，');

    final departmentDetails =
        '${sortedDeptsByCount.map((dept) => '${dept.department}部门${dept.employeeCount}人').join('，')}，详见下图';

    // 获取薪资结构数据
    Map<String, dynamic>? summaryData;
    logger.info(
      'Analysis data isMultiMonth: $isMultiMonth  _dataService is null ${_dataService == null}',
    );
    if (_dataService != null) {
      if (isMultiMonth) {
        summaryData = await _dataService!.getMultiMonthSalarySummaryData(
          startYear: startTime.year,
          startMonth: startTime.month,
          endYear: endTime.year,
          endMonth: endTime.month,
        );
      } else {
        summaryData = await _dataService!.getSalarySummaryData(
          year: year,
          month: month,
        );
      }
    }

    logger.info('Salary summary data: $summaryData');

    // 生成薪资结构分析
    final salaryStructureAnalysis = _generateSalaryStructureAnalysis(
      summaryData,
    );

    // 提取薪资结构数据用于饼图
    final salaryStructureData = _extractSalaryStructureData(summaryData);

    // 获取上月数据用于比较（仅对单月报告）
    String compareLastText = ''; // 默认为空字符串
    if (!isMultiMonth && _dataService != null) {
      final lastMonthStats = await _dataService!
          .getLastMonthEmployeeAndSalaryStats(year: year, month: month);

      if (lastMonthStats != null) {
        final lastTotalEmployees = lastMonthStats['totalEmployees'] as int;
        final lastAverageSalary = lastMonthStats['averageSalary'] as double;

        // 描述上月数据
        final lastMonthDesc =
            '上月员工${lastTotalEmployees}人，平均薪资${lastAverageSalary.toStringAsFixed(2)}元；';

        // 计算员工数量变化
        final employeeChange = employeeCount - lastTotalEmployees;
        final employeeChangeText = employeeChange > 0
            ? '本月员工数量增加${employeeChange}人'
            : employeeChange < 0
            ? '本月员工数量减少${employeeChange.abs()}人'
            : '本月员工数量持平';

        // 计算平均薪资变化
        final salaryChange = analysisData['averageSalary'] - lastAverageSalary;
        final salaryChangeText = salaryChange > 0
            ? '平均薪资增长${salaryChange.toStringAsFixed(2)}元'
            : salaryChange < 0
            ? '平均薪资下降${salaryChange.abs().toStringAsFixed(2)}元'
            : '平均薪资持平';

        compareLastText =
            '$lastMonthDesc$employeeChangeText，$salaryChangeText。';
      }
    }

    // Get AI summaries
    final salaryFeatureSummary = await _aiService.generateSalaryFeatureSummary(
      salaryRangeDesc,
    );
    final departmentAnalysis = await _aiService
        .analyzeDepartmentSalaryDifferences(departmentStats);

    final keySalaryPointAnalysis = await _aiService.analyzeKeySalaryPositions(
      departmentStats,
    );

    // 生成薪资结构合理性评估与优化建议
    final salaryStructureAdvice = await _aiService
        .generateSalaryStructureAdvice(
          employeeDetails: employeeDetails,
          departmentDetails: departmentDetails,
          salaryRange: salaryRangeDesc,
          salaryRangeFeature: salaryFeatureSummary,
        );

    // Convert markdown format to plain text for salary analysis
    final departmentAnalysisText = departmentAnalysis
        .replaceAll(RegExp(r'\$1'), '') // Remove $1 markers
        .replaceAll(RegExp(r'\#\$1'), '') // Remove #$1 markers
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // Remove bold
        .replaceAll(RegExp(r'\* ([^\n]+)'), r'• $1') // Convert list items
        .replaceAll(RegExp(r'\#\#\# ([^\n]+)'), r'$1') // Remove headings
        .replaceAll(RegExp(r'\#\# ([^\n]+)'), r'$1')
        .replaceAll(RegExp(r'\# ([^\n]+)'), r'$1')
        .replaceAll(RegExp(r'\n\s*\n'), r'\n') // Remove extra newlines
        .trim(); // Remove leading/trailing whitespace

    // Convert markdown format to plain text for key salary point analysis
    final keySalaryPointText = keySalaryPointAnalysis
        .replaceAll(RegExp(r'\$1'), '') // Remove $1 markers
        .replaceAll(RegExp(r'\#\$1'), '') // Remove #$1 markers
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // Remove bold
        .replaceAll(RegExp(r'\* ([^\n]+)'), r'• $1') // Convert list items
        .replaceAll(RegExp(r'\#\#\# ([^\n]+)'), r'$1') // Remove headings
        .replaceAll(RegExp(r'\#\# ([^\n]+)'), r'$1')
        .replaceAll(RegExp(r'\# ([^\n]+)'), r'$1')
        .replaceAll(RegExp(r'\n\s*\n'), r'\n') // Remove extra newlines
        .trim(); // Remove leading/trailing whitespace

    // Salary rankings
    final salaryRankings = sortedDeptsBySalary
        .asMap()
        .entries
        .map(
          (e) =>
              '第${e.key + 1}名${e.value.department}部门平均薪资${e.value.averageNetSalary.toStringAsFixed(2)}元',
        )
        .join('；');

    // Build the model
    return ReportContentModel(
      reportTitle: isMultiMonth
          ? '$year年$month月起工资分析报告'
          : '$year年$month月工资分析报告',
      reportDate: currentTimeStr,
      companyName: AIConfig.companyName,
      reportTime: reportTime,
      startTime: startTimeStr,
      endTime: endTimeStr,
      compareLast: compareLastText, // 直接使用compareLastText，不再需要null检查
      totalEmployees: analysisData['totalEmployees'],
      totalSalary: analysisData['totalSalary'],
      averageSalary: analysisData['averageSalary'],
      departmentCount: departmentStats.length,
      employeeCount: employeeCount,
      employeeDetails: employeeDetails,
      departmentDetails: departmentDetails,
      salaryRangeDescription: '$salaryRangeDesc，详见下图。',
      salaryRangeFeatureSummary: salaryFeatureSummary,
      departmentSalaryAnalysis: departmentAnalysisText,
      keySalaryPoint: keySalaryPointText,
      salaryRankings: salaryRankings,
      basicSalaryRate: 85.0, // Example value
      performanceSalaryRate: 15.0, // Example value
      salaryStructure: salaryStructureAnalysis, // 薪资结构分析
      salaryStructureAdvice: salaryStructureAdvice, // 薪资结构合理性评估与优化建议
      salaryStructureData: salaryStructureData, // 薪资结构数据用于图表
      departmentStats: departmentStats,
    );
  }
}
