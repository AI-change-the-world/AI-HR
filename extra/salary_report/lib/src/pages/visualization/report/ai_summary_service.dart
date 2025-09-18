// src/report/services/ai_summary_service.dart

import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/llm_client.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';

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

  final String _salaryAnalysisPrompt = """
请基于以下数据，对公司的薪资结构进行合理性评估，并提出优化建议。

【数据说明】
- 人员信息：包含岗位、级别、部门归属、个人薪资等
- 部门信息：包含各部门名称、职能定位、人员规模等
- 部门平均薪资：包含各部门人均薪资水平

【任务要求】
1. 对公司整体薪资结构进行评估，涵盖以下角度：
   - 内部公平性：同层级、同岗位之间薪酬差异是否合理；
   - 部门差异性：不同部门之间平均薪资差异是否符合职能定位；
   - 纵向梯度：不同职级之间薪资层次是否清晰；
   - 激励作用：薪酬结构是否能有效支持绩效导向与人才激励。

2. 结合数据分析主要问题及潜在风险，例如：核心部门薪资偏低导致人才流失风险、部分支持部门薪酬过高导致成本压力等。

3. 提出优化建议，包括但不限于：
   - 调整固定薪酬与浮动薪酬比例；
   - 建立分层级的薪酬带宽；
   - 进行市场薪酬对标，优化核心岗位薪资水平；
   - 控制人力成本占比，提升薪酬激励效果。

【输出要求】
- 用报告风格，语言简洁严谨；
- 输出分为两个部分：“合理性评估” 与 “优化建议”；
- 仅输出评估内容和建议，不要包含解释性文字或额外说明。

【输入数据】
员工详细信息： {{employee_details}}
部门详细信息： {{department_details}}
薪资详细信息： {{salary_range}}，{{salary_range_feature}}
""";
}
