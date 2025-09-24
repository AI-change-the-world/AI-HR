// src/report/services/ai_summary_service.dart

import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/llm_client.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

class AISummaryService {
  final LLMClient _llmClient;

  AISummaryService() : _llmClient = LLMClient();

  /// 直接使用自定义提示获取 AI 回答
  Future<String> getAnswer(String prompt) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI custom prompt failed: $e');
      return ""; // Fallback to empty
    }
  }

  Future<String> generateSalaryFeatureSummary(
    String salaryRangeDescriptions,
  ) async {
    if (!AIConfig.aiEnabled) return salaryRangeDescriptions;

    try {
      final prompt =
          '''
请基于以下薪资分布数据：
$salaryRangeDescriptions

撰写一段薪资分布特征总结。要求语言严谨、简洁，体现报告风格。内容需涵盖整体分布情况、主要集中区间，以及分布的均衡性或差异性。仅输出总结内容，不添加额外说明。
      ''';
      final summary = await _llmClient.getAnswer(prompt);
      return summary.isNotEmpty ? summary : salaryRangeDescriptions;
    } catch (e) {
      logger.info('AI salary feature summary failed: $e');
      return salaryRangeDescriptions; // Fallback to raw description
    }
  }

  Future<String> analyzeDepartmentSalaryDifferences(
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: ${dept.employeeCount} employees, total salary ${dept.totalNetSalary.toStringAsFixed(2)}, average salary ${dept.averageNetSalary.toStringAsFixed(2)}',
          )
          .join('; ');

      final prompt =
          '''
请基于以下部门薪资数据：
$departmentData

撰写一段严谨简洁的报告风格分析，阐述各部门之间薪资差异的原因，内容需包含薪资差异的主要原因、影响因素分析以及可能的改进建议。要求只输出一个连续的段落，不允许分段或使用任何格式标记。
      ''';
      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI department salary analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  Future<String> analyzeKeySalaryPositions(
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: ${dept.employeeCount} employees, total salary ${dept.totalNetSalary.toStringAsFixed(2)}, average salary ${dept.averageNetSalary.toStringAsFixed(2)}',
          )
          .join('; ');

      // TODO 可能要联网
      final prompt =
          '''
请基于以下部门薪资数据：
$departmentData

分析关键岗位的薪资情况。要求语言严谨、简洁，体现报告风格。内容需涵盖关键岗位识别、薪资水平分析、市场竞争力评估，以及优化建议。仅输出分析内容，不添加额外说明，要求只输出一个连续的段落，不允许分段或使用任何格式标记。
      ''';
      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI key salary positions analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  String formatContent(String content) {
    content = content.replaceAll("\n\n", "\n"); // Remove extra newlines
    List<String> lines = content.split('\n');
    logger.info('Formatting content length: ${lines.length}');
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line.trim().isEmpty || line.length < 3) {
        continue;
      }
      if (i > 0) {
        line = "\u00A0\u00A0$line";
      }
      sb.writeln(line);
    }
    return sb.toString();
  }

  /// 生成薪资结构合理性评估与优化建议
  Future<String> generateSalaryStructureAdvice({
    required String employeeDetails,
    required String departmentDetails,
    required String salaryRange,
    required String salaryRangeFeature,
  }) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final prompt = _monthlySalaryAnalysisPrompt
          .replaceAll('{{employee_details}}', employeeDetails)
          .replaceAll('{{department_details}}', departmentDetails)
          .replaceAll('{{salary_range}}', salaryRange)
          .replaceAll('{{salary_range_feature}}', salaryRangeFeature);

      final formatted = formatContent(await _llmClient.getAnswer(prompt));

      logger.info('AI salary structure advice: $formatted');

      return formatted;
    } catch (e) {
      logger.info('AI salary structure advice failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成薪资区间特征总结
  Future<String> generateSalaryRangeFeatureSummary(
    List<Map<String, int>> salaryRanges,
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final salaryRangeDescriptions = salaryRanges
          .map(
            (range) => range.entries
                .map((entry) => '${entry.key}: ${entry.value}人')
                .join('\n'),
          )
          .join('\n');

      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: ${dept.employeeCount}人, 工资总额${dept.totalNetSalary.toStringAsFixed(2)}, 平均工资${dept.averageNetSalary.toStringAsFixed(2)}',
          )
          .join('; ');

      final prompt =
          '''
请基于以下薪资分布数据：
$salaryRangeDescriptions

以及以下部门薪资数据：
$departmentData

撰写一段薪资分布特征总结。要求语言严谨、简洁，体现报告风格。内容需涵盖整体分布情况、主要集中区间，以及分布的均衡性或差异性。仅输出总结内容，不添加额外说明。
      ''';
      final summary = await _llmClient.getAnswer(prompt);
      return summary.isNotEmpty ? summary : salaryRangeDescriptions;
    } catch (e) {
      logger.info('AI salary range feature summary failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 使用自定义提示生成薪资区间特征总结
  Future<String> generateSalaryRangeFeatureSummaryWithCustomPrompt(
    List<Map<String, int>> salaryRanges,
    List<DepartmentSalaryStats> departmentStats,
    String customPrompt,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final salaryRangeDescriptions = salaryRanges
          .map(
            (range) => range.entries
                .map((entry) => '${entry.key}: ${entry.value}人次')
                .join('\n'),
          )
          .join('\n');

      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: ${dept.employeeCount}人次, 工资总额${dept.totalNetSalary.toStringAsFixed(2)}, 平均工资${dept.averageNetSalary.toStringAsFixed(2)}',
          )
          .join('; ');

      final prompt = customPrompt
          .replaceAll('{{salary_range_descriptions}}', salaryRangeDescriptions)
          .replaceAll('{{department_data}}', departmentData);

      final summary = await _llmClient.getAnswer('''
薪资分布数据：
$salaryRangeDescriptions

部门薪资数据：
$departmentData

$customPrompt
        ''');
      return summary.isNotEmpty ? summary : "无法生成薪资区间特征总结";
    } catch (e) {
      logger.info(
        'AI salary range feature summary with custom prompt failed: $e',
      );
      return ""; // Fallback to empty
    }
  }

  /// 生成部门薪资分析
  Future<String> generateDepartmentSalaryAnalysis(
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: ${dept.employeeCount}人, 工资总额${dept.totalNetSalary.toStringAsFixed(2)}, 平均工资${dept.averageNetSalary.toStringAsFixed(2)}',
          )
          .join('; ');

      final prompt =
          '''
请基于以下部门薪资数据：
$departmentData

撰写一段严谨简洁的报告风格分析，阐述各部门之间薪资差异的原因，内容需包含薪资差异的主要原因、影响因素分析以及可能的改进建议。要求只输出一个连续的段落，不允许分段或使用任何格式标记。
      ''';
      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI department salary analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 使用自定义提示生成部门薪资分析
  Future<String> generateDepartmentSalaryAnalysisWithCustomPrompt(
    List<DepartmentSalaryStats> departmentStats,
    String customPrompt,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: ${dept.employeeCount}人次, 工资总额${dept.totalNetSalary.toStringAsFixed(2)}, 平均工资${dept.averageNetSalary.toStringAsFixed(2)}',
          )
          .join('; ');

      final prompt =
          '''
部门薪资数据：
$departmentData

$customPrompt
          ''';
      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info(
        'AI department salary analysis with custom prompt failed: $e',
      );
      return ""; // Fallback to empty
    }
  }

  /// 生成关键薪资点分析
  Future<String> generateKeySalaryPoint(
    List<DepartmentSalaryStats> departmentStats,
    List<Map<String, int>> salaryRanges,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: ${dept.employeeCount}人, 工资总额${dept.totalNetSalary.toStringAsFixed(2)}, 平均工资${dept.averageNetSalary.toStringAsFixed(2)}',
          )
          .join('; ');

      final salaryRangeDescriptions = salaryRanges
          .map(
            (range) => range.entries
                .map((entry) => '${entry.key}: ${entry.value}人')
                .join('\n'),
          )
          .join('\n');

      final prompt =
          '''
请基于以下部门薪资数据：
$departmentData

以及薪资分布数据：
$salaryRangeDescriptions

分析关键岗位的薪资情况。要求语言严谨、简洁，体现报告风格。内容需涵盖关键岗位识别、薪资水平分析、市场竞争力评估，以及优化建议。仅输出分析内容，不添加额外说明，要求只输出一个连续的段落，不允许分段或使用任何格式标记。
      ''';
      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI key salary point analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 使用自定义提示生成关键薪资点分析
  Future<String> generateKeySalaryPointWithCustomPrompt(
    List<DepartmentSalaryStats> departmentStats,
    List<Map<String, int>> salaryRanges,
    String customPrompt,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: ${dept.employeeCount}人次, 工资总额${dept.totalNetSalary.toStringAsFixed(2)}, 平均工资${dept.averageNetSalary.toStringAsFixed(2)}',
          )
          .join('; ');

      final salaryRangeDescriptions = salaryRanges
          .map(
            (range) => range.entries
                .map((entry) => '${entry.key}: ${entry.value}人次')
                .join('\n'),
          )
          .join('\n');

      final prompt =
          '''
部门薪资数据：
$departmentData

薪资分布数据：
$salaryRangeDescriptions

$customPrompt
      ''';
      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI key salary point analysis with custom prompt failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成季度工资总额分析
  @Deprecated("Deprecated")
  Future<String> generateQuarterlyTotalSalaryAnalysis(
    double totalSalary,
    double previousQuarterTotalSalary,
    List<Map<String, dynamic>> monthlyData,
  ) async {
    logger.info('monthlyData   $monthlyData');

    if (!AIConfig.aiEnabled) return "";

    try {
      final monthlyBreakdown = monthlyData
          .map(
            (data) =>
                '${data['month']}: 总额${data['totalSalary'].toStringAsFixed(2)}元, ' '员工数${data['employeeCount']}人',
          )
          .join('\n');

      final changeRate = previousQuarterTotalSalary > 0
          ? ((totalSalary - previousQuarterTotalSalary) /
                    previousQuarterTotalSalary *
                    100)
                .toStringAsFixed(2)
          : "无法计算";

      final prompt =
          '''
请分析以下季度工资总额数据：
- 本季度工资总额：${totalSalary.toStringAsFixed(2)}元
- 上季度工资总额：${previousQuarterTotalSalary.toStringAsFixed(2)}元
- 环比变化率：$changeRate%
- 月度明细：
$monthlyBreakdown

请撰写一段关于季度工资总额的分析，包括总体趋势、月度波动原因、与上季度的对比分析，以及可能的影响因素。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI quarterly total salary analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成季度平均工资分析
  Future<String> generateQuarterlyAverageSalaryAnalysis(
    double averageSalary,
    double previousQuarterAverageSalary,
    List<Map<String, dynamic>> monthlyData,
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final monthlyBreakdown = monthlyData
          .map(
            (data) =>
                '${data['month']}: 平均工资${data['averageSalary'].toStringAsFixed(2)}元, ' '员工数${data['employeeCount']}人',
          )
          .join('\n');

      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: 平均工资${dept.averageNetSalary.toStringAsFixed(2)}元, ' '员工数${dept.employeeCount}人',
          )
          .join('\n');

      final changeRate = previousQuarterAverageSalary > 0
          ? ((averageSalary - previousQuarterAverageSalary) /
                    previousQuarterAverageSalary *
                    100)
                .toStringAsFixed(2)
          : "无法计算";

      final prompt =
          '''
请分析以下季度平均工资数据：
- 本季度平均工资：${averageSalary.toStringAsFixed(2)}元
- 上季度平均工资：${previousQuarterAverageSalary.toStringAsFixed(2)}元
- 环比变化率：$changeRate%
- 月度明细：
$monthlyBreakdown
- 部门平均工资：
$departmentData

请撰写一段关于季度平均工资的分析，包括总体水平评估、部门间差异、月度波动原因，以及与上季度的对比分析。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI quarterly average salary analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成季度员工数量分析
  Future<String> generateQuarterlyEmployeeCountAnalysis(
    int totalEmployees,
    int uniqueEmployees,
    int previousQuarterTotalEmployees,
    List<Map<String, dynamic>> monthlyData,
    List<Map<String, dynamic>> employeeChanges,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final monthlyBreakdown = monthlyData
          .map((data) => '${data['month']}: ${data['employeeCount']}人')
          .join('\n');

      String employeeChangesText = "";
      if (employeeChanges.isNotEmpty) {
        employeeChangesText = employeeChanges
            .map(
              (change) =>
                  '${change['month']}月: 新入职${change['newEmployees'].length}人, ' '离职${change['resignedEmployees'].length}人, ' '净变化${change['netChange']}人',
            )
            .join('\n');
      }

      final changeRate = previousQuarterTotalEmployees > 0
          ? ((totalEmployees - previousQuarterTotalEmployees) /
                    previousQuarterTotalEmployees *
                    100)
                .toStringAsFixed(2)
          : "无法计算";

      final prompt =
          '''
请分析以下季度员工数量数据：
- 本季度总人次：$totalEmployees人
- 本季度去重后总人数：$uniqueEmployees人
- 上季度总人次：$previousQuarterTotalEmployees人
- 环比变化率：$changeRate%
- 月度明细：
$monthlyBreakdown
${employeeChangesText.isNotEmpty ? '- 员工变动情况：\n$employeeChangesText' : ''}

请撰写一段关于季度员工数量的分析，包括人员规模、稳定性、流动性，以及与上季度的对比分析。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI quarterly employee count analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成季度工资构成分析
  Future<String> generateQuarterlySalaryCompositionAnalysis(
    List<Map<String, dynamic>> salaryStructureData,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final salaryComposition = salaryStructureData
          .map(
            (item) =>
                '${item['category']}: ${item['value'].toStringAsFixed(2)}元',
          )
          .join('\n');

      final prompt =
          '''
请分析以下季度工资构成数据：
$salaryComposition

请撰写一段关于季度工资构成的分析，包括各组成部分的占比、合理性评估，以及优化建议。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI quarterly salary composition analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成季度环比变化分析
  Future<String> generateQuarterlyMoMChangeAnalysis(
    Map<String, dynamic> currentQuarterData,
    Map<String, dynamic>? previousQuarterData,
  ) async {
    if (!AIConfig.aiEnabled || previousQuarterData == null) return "";

    try {
      final totalSalaryChange =
          ((currentQuarterData['totalSalary'] -
                      previousQuarterData['totalSalary']) /
                  previousQuarterData['totalSalary'] *
                  100)
              .toStringAsFixed(2);
      final averageSalaryChange =
          ((currentQuarterData['averageSalary'] -
                      previousQuarterData['averageSalary']) /
                  previousQuarterData['averageSalary'] *
                  100)
              .toStringAsFixed(2);
      final employeeCountChange =
          ((currentQuarterData['totalEmployees'] -
                      previousQuarterData['totalEmployees']) /
                  previousQuarterData['totalEmployees'] *
                  100)
              .toStringAsFixed(2);

      final prompt =
          '''
请分析以下季度环比变化数据：
- 工资总额变化率：$totalSalaryChange%
- 平均工资变化率：$averageSalaryChange%
- 员工数量变化率：$employeeCountChange%
- 本季度：${currentQuarterData['year']}年第${currentQuarterData['quarter']}季度
- 上季度：${previousQuarterData['year']}年第${previousQuarterData['quarter']}季度

请撰写一段关于季度环比变化的分析，包括各指标变化的原因、相互关系，以及对公司的影响。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI quarterly MoM change analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  final String _monthlySalaryAnalysisPrompt = """
请基于以下数据，对公司的薪资结构进行合理性评估，并提出优化建议。

【数据说明】
- 人员信息：包含岗位、级别、部门归属、个人薪资等
- 部门信息：包含各部门名称、职能定位、人员规模等
- 部门平均薪资：包含各部门人均薪资水平

【任务要求】
1. 对公司整体薪资结构进行评估，涵盖以下角度：
   - 内部公平性
   - 部门差异性
   - 纵向梯度
   - 激励作用
2. 结合数据分析主要问题及潜在风险。
3. 提出优化建议，包括但不限于：
   - 调整固定薪酬与浮动薪酬比例
   - 建立分层级的薪酬带宽
   - 进行市场薪酬对标
   - 控制人力成本占比

【输出要求】
- 用报告风格，语言简洁严谨。
- 输出分为两部分："合理性评估" 与 "优化建议",不需要添加额外的标题或段落标题，只需要两个段落即可。
- 仅输出连续的纯文本，不要使用任何 Markdown 标记（如#、-、*）、列表符号或额外说明。
- 按段落组织内容，而不是项目符号。


【输入数据】
员工详细信息： {{employee_details}}
部门详细信息： {{department_details}}
薪资详细信息： {{salary_range}}，{{salary_range_feature}}
""";

  final String _quarterlySalaryAnalysisPrompt = """
请基于以下数据，对公司的季度薪资情况进行全面分析，并提出优化建议。

【数据说明】
- 季度工资总额：包含整个季度的工资支出总额及月度分布
- 季度平均工资：包含整个季度的平均工资水平及部门差异
- 季度员工数量：包含季度内的员工总数、流动情况
- 工资构成：包含固定工资、奖金、补贴等各部分占比
- 环比变化：与上季度相比的变化情况

【任务要求】
1. 对公司季度薪资情况进行全面评估，涵盖以下角度：
   - 总体薪资水平及变化趋势
   - 部门间薪资差异及合理性
   - 员工流动与薪资关系
   - 薪资结构合理性
2. 结合数据分析主要问题及潜在风险。
3. 提出针对性的优化建议。

【输出要求】
- 用报告风格，语言简洁严谨。
- 输出分为两部分："季度薪资分析" 与 "优化建议"，不需要添加额外的标题或段落标题，只需要两个段落即可。
- 仅输出连续的纯文本，不要使用任何 Markdown 标记（如#、-、*）、列表符号或额外说明。
- 按段落组织内容，而不是项目符号。

【输入数据】
季度工资总额： {{quarter_total_salary}}
季度平均工资： {{quarter_average_salary}}
季度员工数量： {{quarter_employee_count}}
部门工资情况： {{department_salary_avg_q}}
工资构成： {{salary_composition_q}}
环比变化： {{quarter_mom_change}}
""";

  /// 生成季度趋势分析
  Future<String> generateQuarterlyTrendAnalysis(
    List<QuarterlyComparisonData> quarterlyComparisons,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      // 按时间排序
      final sortedData =
          List<QuarterlyComparisonData>.from(quarterlyComparisons)
            ..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.quarter.compareTo(b.quarter);
            });

      final trendData = sortedData
          .map(
            (q) =>
                '${q.year}年第${q.quarter}季度: 员工数${q.employeeCount}人, ' '工资总额${q.totalSalary.toStringAsFixed(2)}元, ' '平均工资${q.averageSalary.toStringAsFixed(2)}元',
          )
          .join('\n');

      final prompt =
          '''
请分析以下多季度工资趋势数据：
$trendData

请撰写一段关于多季度工资趋势的分析，包括总体趋势、季节性波动、长期变化等方面。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI quarterly trend analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成部门对比分析
  Future<String> generateDepartmentComparisonAnalysis(
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final departmentData = departmentStats
          .map(
            (dept) =>
                '${dept.department}: 员工数${dept.employeeCount}人, ' '工资总额${dept.totalNetSalary.toStringAsFixed(2)}元, ' '平均工资${dept.averageNetSalary.toStringAsFixed(2)}元',
          )
          .join('\n');

      final prompt =
          '''
请分析以下部门薪资对比数据：
$departmentData

请撰写一段关于部门间薪资差异的分析，包括差异原因、合理性评估、潜在问题等方面。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI department comparison analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成季度环比分析
  Future<String> generateQuarterOverQuarterAnalysis(
    List<QuarterlyComparisonData> quarterlyComparisons,
  ) async {
    if (!AIConfig.aiEnabled || quarterlyComparisons.length < 2) return "";

    try {
      // 按时间排序
      final sortedData =
          List<QuarterlyComparisonData>.from(quarterlyComparisons)
            ..sort((a, b) {
              if (a.year != b.year) {
                return a.year.compareTo(b.year);
              }
              return a.quarter.compareTo(b.quarter);
            });

      final qoqData = <String>[];
      for (int i = 1; i < sortedData.length; i++) {
        final current = sortedData[i];
        final previous = sortedData[i - 1];

        final employeeCountChange =
            current.employeeCount - previous.employeeCount;
        final employeeCountChangeRate = previous.employeeCount > 0
            ? (employeeCountChange / previous.employeeCount * 100)
                  .toStringAsFixed(2)
            : "N/A";

        final totalSalaryChange = current.totalSalary - previous.totalSalary;
        final totalSalaryChangeRate = previous.totalSalary > 0
            ? (totalSalaryChange / previous.totalSalary * 100).toStringAsFixed(
                2,
              )
            : "N/A";

        final averageSalaryChange =
            current.averageSalary - previous.averageSalary;
        final averageSalaryChangeRate = previous.averageSalary > 0
            ? (averageSalaryChange / previous.averageSalary * 100)
                  .toStringAsFixed(2)
            : "N/A";

        qoqData.add(
          '${current.year}年第${current.quarter}季度 vs ${previous.year}年第${previous.quarter}季度: ' '员工数变化$employeeCountChange人($employeeCountChangeRate%), ' '工资总额变化${totalSalaryChange.toStringAsFixed(2)}元($totalSalaryChangeRate%), ' '平均工资变化${averageSalaryChange.toStringAsFixed(2)}元($averageSalaryChangeRate%)',
        );
      }

      final prompt =
          '''
请分析以下季度环比变化数据：
${qoqData.join('\n')}

请撰写一段关于季度环比变化的分析，包括变化趋势、波动原因、关键时点等方面。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI quarter over quarter analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成年度同比分析
  Future<String> generateYearOverYearAnalysis(
    List<dynamic>
    comparisons, // 可以是 QuarterlyComparisonData 或 YearlyComparisonData
  ) async {
    if (!AIConfig.aiEnabled || comparisons.length < 2) return "";

    try {
      final yoyData = <String>[];

      if (comparisons.isNotEmpty &&
          comparisons.first is QuarterlyComparisonData) {
        // 处理季度数据
        final quarterlyData = comparisons.cast<QuarterlyComparisonData>();

        // 按时间排序
        final sortedData = List<QuarterlyComparisonData>.from(quarterlyData)
          ..sort((a, b) {
            if (a.year != b.year) {
              return a.year.compareTo(b.year);
            }
            return a.quarter.compareTo(b.quarter);
          });

        // 查找同比数据（去年同季度）
        for (var currentQuarter in sortedData) {
          QuarterlyComparisonData? lastYearQuarter;
          try {
            lastYearQuarter = sortedData.firstWhere(
              (q) =>
                  q.year == currentQuarter.year - 1 &&
                  q.quarter == currentQuarter.quarter,
            );
          } catch (e) {
            lastYearQuarter = null;
          }

          if (lastYearQuarter != null) {
            final employeeCountChange =
                currentQuarter.employeeCount - lastYearQuarter.employeeCount;
            final employeeCountChangeRate = lastYearQuarter.employeeCount > 0
                ? (employeeCountChange / lastYearQuarter.employeeCount * 100)
                      .toStringAsFixed(2)
                : "N/A";

            final totalSalaryChange =
                currentQuarter.totalSalary - lastYearQuarter.totalSalary;
            final totalSalaryChangeRate = lastYearQuarter.totalSalary > 0
                ? (totalSalaryChange / lastYearQuarter.totalSalary * 100)
                      .toStringAsFixed(2)
                : "N/A";

            final averageSalaryChange =
                currentQuarter.averageSalary - lastYearQuarter.averageSalary;
            final averageSalaryChangeRate = lastYearQuarter.averageSalary > 0
                ? (averageSalaryChange / lastYearQuarter.averageSalary * 100)
                      .toStringAsFixed(2)
                : "N/A";

            yoyData.add(
              '${currentQuarter.year}年第${currentQuarter.quarter}季度 vs ${lastYearQuarter.year}年第${lastYearQuarter.quarter}季度: ' '员工数变化$employeeCountChange人($employeeCountChangeRate%), ' '工资总额变化${totalSalaryChange.toStringAsFixed(2)}元($totalSalaryChangeRate%), ' '平均工资变化${averageSalaryChange.toStringAsFixed(2)}元($averageSalaryChangeRate%)',
            );
          }
        }
      } else if (comparisons.isNotEmpty &&
          comparisons.first is YearlyComparisonData) {
        // 处理年度数据
        final yearlyData = comparisons.cast<YearlyComparisonData>();

        // 按年份排序
        final sortedData = List<YearlyComparisonData>.from(yearlyData)
          ..sort((a, b) => a.year.compareTo(b.year));

        // 计算同比变化
        for (int i = 1; i < sortedData.length; i++) {
          final currentYear = sortedData[i];
          final previousYear = sortedData[i - 1];

          final employeeCountChange =
              currentYear.employeeCount - previousYear.employeeCount;
          final employeeCountChangeRate = previousYear.employeeCount > 0
              ? (employeeCountChange / previousYear.employeeCount * 100)
                    .toStringAsFixed(2)
              : "N/A";

          final totalSalaryChange =
              currentYear.totalSalary - previousYear.totalSalary;
          final totalSalaryChangeRate = previousYear.totalSalary > 0
              ? (totalSalaryChange / previousYear.totalSalary * 100)
                    .toStringAsFixed(2)
              : "N/A";

          final averageSalaryChange =
              currentYear.averageSalary - previousYear.averageSalary;
          final averageSalaryChangeRate = previousYear.averageSalary > 0
              ? (averageSalaryChange / previousYear.averageSalary * 100)
                    .toStringAsFixed(2)
              : "N/A";

          yoyData.add(
            '${currentYear.year}年 vs ${previousYear.year}年: ' '员工数变化$employeeCountChange人($employeeCountChangeRate%), ' '工资总额变化${totalSalaryChange.toStringAsFixed(2)}元($totalSalaryChangeRate%), ' '平均工资变化${averageSalaryChange.toStringAsFixed(2)}元($averageSalaryChangeRate%)',
          );
        }
      }

      if (yoyData.isEmpty) {
        return "无法获取同比数据进行分析。";
      }

      final prompt =
          '''
请分析以下同比变化数据：
${yoyData.join('\n')}

请撰写一段关于同比变化的分析，包括变化趋势、年度对比、长期发展等方面。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI year over year analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成薪资区间分析
  Future<String> generateSalaryRangeAnalysis(
    List<SalaryRangeStats> salaryRangeStats,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final rangeData = salaryRangeStats
          .map(
            (range) =>
                '${range.range}: 员工数${range.employeeCount}人, ' '工资总额${range.totalSalary.toStringAsFixed(2)}元, ' '平均工资${range.averageSalary.toStringAsFixed(2)}元',
          )
          .join('\n');

      final prompt =
          '''
请分析以下薪资区间数据：
$rangeData

请撰写一段关于薪资区间分布的分析，包括分布特点、集中趋势、差异原因等方面。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI salary range analysis failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成多季度结论
  Future<String> generateMultiQuarterConclusions(
    MultiQuarterComparisonData comparisonData,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      // 提取关键数据
      final quarterCount = comparisonData.quarterlyComparisons.length;
      final startQuarter = comparisonData.quarterlyComparisons.first;
      final endQuarter = comparisonData.quarterlyComparisons.last;

      final totalSalaryChange =
          endQuarter.totalSalary - startQuarter.totalSalary;
      final totalSalaryChangeRate = startQuarter.totalSalary > 0
          ? (totalSalaryChange / startQuarter.totalSalary * 100)
                .toStringAsFixed(2)
          : "N/A";

      final averageSalaryChange =
          endQuarter.averageSalary - startQuarter.averageSalary;
      final averageSalaryChangeRate = startQuarter.averageSalary > 0
          ? (averageSalaryChange / startQuarter.averageSalary * 100)
                .toStringAsFixed(2)
          : "N/A";

      final prompt =
          '''
请基于以下多季度工资数据，提供综合结论和优化建议：

分析周期：${startQuarter.year}年第${startQuarter.quarter}季度至${endQuarter.year}年第${endQuarter.quarter}季度，共$quarterCount个季度
总体变化：工资总额变化${totalSalaryChange.toStringAsFixed(2)}元($totalSalaryChangeRate%)，平均工资变化${averageSalaryChange.toStringAsFixed(2)}元($averageSalaryChangeRate%)

请提供一段关于多季度薪资数据的综合结论，以及针对性的优化建议。要求语言严谨、简洁，体现报告风格。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI multi-quarter conclusions failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成多年度结论
  Future<String> generateMultiYearConclusions(
    MultiYearComparisonData comparisonData,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      // 提取关键数据
      final yearCount = comparisonData.yearlyComparisons.length;
      final startYear = comparisonData.yearlyComparisons.first;
      final endYear = comparisonData.yearlyComparisons.last;

      final totalSalaryChange = endYear.totalSalary - startYear.totalSalary;
      final totalSalaryChangeRate = startYear.totalSalary > 0
          ? (totalSalaryChange / startYear.totalSalary * 100).toStringAsFixed(2)
          : "N/A";

      final averageSalaryChange =
          endYear.averageSalary - startYear.averageSalary;
      final averageSalaryChangeRate = startYear.averageSalary > 0
          ? (averageSalaryChange / startYear.averageSalary * 100)
                .toStringAsFixed(2)
          : "N/A";

      final prompt =
          '''
请基于以下多年度工资数据，提供综合结论和优化建议：

分析周期：${startYear.year}年至${endYear.year}年，共$yearCount年
总体变化：工资总额变化${totalSalaryChange.toStringAsFixed(2)}元($totalSalaryChangeRate%)，平均工资变化${averageSalaryChange.toStringAsFixed(2)}元($averageSalaryChangeRate%)

请提供一段关于多年度薪资数据的综合结论，以及针对性的优化建议。要求语言严谨、简洁，体现报告风格。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI multi-year conclusions failed: $e');
      return ""; // Fallback to empty
    }
  }

  /// 生成年度趋势分析
  Future<String> generateYearlyTrendAnalysis(
    List<YearlyComparisonData> yearlyComparisons,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      // 按年份排序
      final sortedData = List<YearlyComparisonData>.from(yearlyComparisons)
        ..sort((a, b) => a.year.compareTo(b.year));

      final trendData = sortedData
          .map(
            (y) =>
                '${y.year}年: 员工数${y.employeeCount}人, ' '工资总额${y.totalSalary.toStringAsFixed(2)}元, ' '平均工资${y.averageSalary.toStringAsFixed(2)}元',
          )
          .join('\n');

      final prompt =
          '''
请分析以下多年度工资趋势数据：
$trendData

请撰写一段关于多年度工资趋势的分析，包括总体趋势、年度波动、长期变化等方面。要求语言严谨、简洁，体现报告风格。仅输出一个连续的段落，不使用任何格式标记。
      ''';

      return await _llmClient.getAnswer(prompt);
    } catch (e) {
      logger.info('AI yearly trend analysis failed: $e');
      return ""; // Fallback to empty
    }
  }
}
