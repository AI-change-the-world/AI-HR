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
}
