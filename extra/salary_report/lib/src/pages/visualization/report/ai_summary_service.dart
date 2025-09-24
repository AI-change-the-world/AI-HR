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
          
      final summary = await _llmClient.getAnswer(
        '''
薪资分布数据：
$salaryRangeDescriptions

部门薪资数据：
$departmentData

$customPrompt
        ''',
      );
      return summary.isNotEmpty ? summary : "无法生成薪资区间特征总结";
    } catch (e) {
      logger.info('AI salary range feature summary with custom prompt failed: $e');
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
      logger.info('AI department salary analysis with custom prompt failed: $e');
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
  Future<String> generateQuarterlyTotalSalaryAnalysis(
    double totalSalary,
    double previousQuarterTotalSalary,
    List<Map<String, dynamic>> monthlyData,
  ) async {
    if (!AIConfig.aiEnabled) return "";

    try {
      final monthlyBreakdown = monthlyData
          .map((data) => 
              '${data['month']}: 总额${data['totalSalary'].toStringAsFixed(2)}元, ' +
              '员工数${data['employeeCount']}人')
          .join('\n');
      
      final changeRate = previousQuarterTotalSalary > 0 
          ? ((totalSalary - previousQuarterTotalSalary) / previousQuarterTotalSalary * 100).toStringAsFixed(2)
          : "无法计算";
      
      final prompt = '''
请分析以下季度工资总额数据：
- 本季度工资总额：${totalSalary.toStringAsFixed(2)}元
- 上季度工资总额：${previousQuarterTotalSalary.toStringAsFixed(2)}元
- 环比变化率：${changeRate}%
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
          .map((data) => 
              '${data['month']}: 平均工资${data['averageSalary'].toStringAsFixed(2)}元, ' +
              '员工数${data['employeeCount']}人')
          .join('\n');
      
      final departmentData = departmentStats
          .map((dept) => 
              '${dept.department}: 平均工资${dept.averageNetSalary.toStringAsFixed(2)}元, ' +
              '员工数${dept.employeeCount}人')
          .join('\n');
      
      final changeRate = previousQuarterAverageSalary > 0 
          ? ((averageSalary - previousQuarterAverageSalary) / previousQuarterAverageSalary * 100).toStringAsFixed(2)
          : "无法计算";
      
      final prompt = '''
请分析以下季度平均工资数据：
- 本季度平均工资：${averageSalary.toStringAsFixed(2)}元
- 上季度平均工资：${previousQuarterAverageSalary.toStringAsFixed(2)}元
- 环比变化率：${changeRate}%
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
            .map((change) => 
                '${change['month']}月: 新入职${change['newEmployees'].length}人, ' +
                '离职${change['resignedEmployees'].length}人, ' +
                '净变化${change['netChange']}人')
            .join('\n');
      }
      
      final changeRate = previousQuarterTotalEmployees > 0 
          ? ((totalEmployees - previousQuarterTotalEmployees) / previousQuarterTotalEmployees * 100).toStringAsFixed(2)
          : "无法计算";
      
      final prompt = '''
请分析以下季度员工数量数据：
- 本季度总人次：${totalEmployees}人
- 本季度去重后总人数：${uniqueEmployees}人
- 上季度总人次：${previousQuarterTotalEmployees}人
- 环比变化率：${changeRate}%
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
          .map((item) => 
              '${item['category']}: ${item['value'].toStringAsFixed(2)}元')
          .join('\n');
      
      final prompt = '''
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
      final totalSalaryChange = ((currentQuarterData['totalSalary'] - previousQuarterData['totalSalary']) / previousQuarterData['totalSalary'] * 100).toStringAsFixed(2);
      final averageSalaryChange = ((currentQuarterData['averageSalary'] - previousQuarterData['averageSalary']) / previousQuarterData['averageSalary'] * 100).toStringAsFixed(2);
      final employeeCountChange = ((currentQuarterData['totalEmployees'] - previousQuarterData['totalEmployees']) / previousQuarterData['totalEmployees'] * 100).toStringAsFixed(2);
      
      final prompt = '''
请分析以下季度环比变化数据：
- 工资总额变化率：${totalSalaryChange}%
- 平均工资变化率：${averageSalaryChange}%
- 员工数量变化率：${employeeCountChange}%
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
}
