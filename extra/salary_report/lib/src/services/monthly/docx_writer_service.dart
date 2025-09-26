// src/services/monthly/docx_writer_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:docx_template_fork/docx_template_fork.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

import 'package:salary_report/src/services/monthly/monthly_report_models.dart';

class MonthlyDocxWriterService {
  /// 写入单月报告
  Future<String> writeReport({
    required MonthlyReportContentModel data,
    required MonthlyReportChartImages images,
  }) async {
    // 使用单月报告模板
    final templatePath = 'assets/salary_report_template_monthly.docx';

    logger.info('开始写入单月报告, 使用模板: $templatePath');

    // 加载模板
    final data0 = await rootBundle.load(templatePath);
    final bytes = data0.buffer.asUint8List();

    final docx = await DocxTemplate.fromBytes(bytes);

    // 构建内容
    final content = _buildContent(data, images);

    final generatedBytes = await docx.generate(content);
    if (generatedBytes == null) {
      throw Exception('Failed to generate DOCX file.');
    }

    // 保存文件，使用更具描述性的文件名
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final formattedTime = _formatDateTime(DateTime.now());
    final reportName = _generateReportName(data, formattedTime);
    final outputPath = '${dir.path}/$reportName.docx';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(generatedBytes);

    logger.info('Report successfully generated at: $outputPath');
    return outputPath;
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}_${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// 生成报告文件名
  String _generateReportName(MonthlyReportContentModel data, String timestamp) {
    final companyName = data.companyName;
    final reportTime = data.reportTime;
    final typeDescription = '月度';

    // 移除报告时间中的特殊字符，使其适合文件名
    final cleanReportTime = reportTime.replaceAll(
      RegExp(r'[^\w\u4e00-\u9fa5]'),
      '',
    );

    return '${companyName}_${reportTime}_$typeDescription报告_$timestamp';
  }

  /// 构建内容
  Content _buildContent(
    MonthlyReportContentModel data,
    MonthlyReportChartImages images,
  ) {
    final content = Content();

    // 添加通用文本字段
    _addCommonTextFields(content, data);

    // 添加单月报告特定字段
    _addMonthlySpecificFields(content, data);

    // 添加表格内容
    _addTableContent(content, data);

    // 添加图片内容
    _addImageContent(content, images);

    return content;
  }

  /// 添加通用文本字段
  void _addCommonTextFields(Content content, MonthlyReportContentModel data) {
    content
      ..add(TextContent('company_name', data.companyName))
      ..add(TextContent('report_time', data.reportTime))
      ..add(TextContent('current_time', data.reportDate))
      ..add(TextContent('start_time', data.startTime))
      ..add(TextContent('end_time', data.endTime))
      ..add(TextContent('total_employees', data.totalEmployees.toString()))
      ..add(TextContent('total_salary', data.totalSalary.toStringAsFixed(2)))
      ..add(TextContent('avg_salary', data.averageSalary.toStringAsFixed(2)))
      ..add(TextContent('department_count', data.departmentCount.toString()))
      ..add(TextContent('employee_count', data.employeeCount.toString()))
      ..add(TextContent('employee_details', data.employeeDetails))
      ..add(TextContent('department_details', data.departmentDetails))
      ..add(TextContent('salary_range', data.salaryRangeDescription))
      ..add(TextContent('salary_range_feature', data.salaryRangeFeatureSummary))
      ..add(TextContent('salary_reason', data.departmentSalaryAnalysis))
      ..add(TextContent('key_salary_point', data.keySalaryPoint))
      ..add(TextContent('salary_order', data.salaryRankings))
      ..add(TextContent('basic_rate', '70.00')) // 使用默认值替代已删除的字段
      ..add(
        TextContent(
          'performance_rate',
          '30.00', // 使用默认值替代已删除的字段
        ),
      )
      ..add(TextContent('salary_structure_analysis', data.salaryStructure))
      ..add(TextContent('salary_structure', data.salaryStructure))
      ..add(TextContent('salary_structure_advice', data.salaryStructureAdvice));

    // 添加 compare_last 如果不为空
    if (data.compareLast.isEmpty) {
      logger.warning('compare_last is empty');
    }
    content.add(TextContent('compare_last', data.compareLast));
  }

  /// 添加单月报告特定字段
  void _addMonthlySpecificFields(
    Content content,
    MonthlyReportContentModel data,
  ) {
    // 单月报告可能需要添加的一些特定字段
    // 这里可以根据需要添加
  }

  /// 添加表格内容
  void _addTableContent(Content content, MonthlyReportContentModel data) {
    final departmentRows = data.departmentStats.map<RowContent>((
      DepartmentSalaryStats stat,
    ) {
      return RowContent()
        ..add(TextContent('department_name', stat.department))
        ..add(
          TextContent('department_employees', stat.employeeCount.toString()),
        )
        ..add(
          TextContent(
            'department_salary',
            stat.totalNetSalary.toStringAsFixed(2),
          ),
        )
        ..add(
          TextContent(
            'department_avg_salary',
            stat.averageNetSalary.toStringAsFixed(2),
          ),
        );
    }).toList();
    content.add(TableContent('departments', departmentRows));
  }

  /// 添加图片内容
  void _addImageContent(Content content, MonthlyReportChartImages images) {
    if (images.mainChart != null) {
      content.add(ImageContent('chart_overall', images.mainChart!));
    }
    if (images.departmentDetailsChart != null) {
      content.add(
        ImageContent(
          'department_details_chart',
          images.departmentDetailsChart!,
        ),
      );
    }
    if (images.salaryRangeChart != null) {
      content.add(ImageContent('salary_range_chart', images.salaryRangeChart!));
    }
    // 添加薪资结构饼图
    if (images.salaryStructureChart != null) {
      content.add(
        ImageContent('salary_structure_chart', images.salaryStructureChart!),
      );
    }
  }
}
