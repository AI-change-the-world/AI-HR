// src/report/services/ai_summary_service.dart

import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/llm_client.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/global_analysis_models.dart';

class AISummaryService {
  final LLMClient _llmClient;

  AISummaryService() : _llmClient = LLMClient();

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
- 输出分为两部分：“合理性评估” 与 “优化建议”,不需要添加额外的标题或段落标题，只需要两个段落即可。
- 仅输出连续的纯文本，不要使用任何 Markdown 标记（如#、-、*）、列表符号或额外说明。
- 按段落组织内容，而不是项目符号。


【输入数据】
员工详细信息： {{employee_details}}
部门详细信息： {{department_details}}
薪资详细信息： {{salary_range}}，{{salary_range_feature}}
""";
}
