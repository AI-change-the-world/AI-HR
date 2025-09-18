// src/report/services/docx_writer_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:docx_template_fork/docx_template_fork.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';

class DocxWriterService {
  /// 根据报告类型选择模板并写入报告
  Future<String> writeReport({
    required ReportContentModel data,
    required ReportChartImages images,
    ReportType reportType = ReportType.monthly, // 默认为单月报告
  }) async {
    // 根据报告类型选择模板
    final templatePath = _getTemplatePath(reportType);

    // 加载模板
    final data0 = await rootBundle.load(templatePath);
    final bytes = data0.buffer.asUint8List();

    final docx = await DocxTemplate.fromBytes(bytes);

    // 构建内容
    final content = _buildContent(data, images, reportType);

    final generatedBytes = await docx.generate(content);
    if (generatedBytes == null) {
      throw Exception('Failed to generate DOCX file.');
    }

    // 保存文件，使用更具描述性的文件名
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final formattedTime = _formatDateTime(DateTime.now());
    final reportName = _generateReportName(data, reportType, formattedTime);
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
  String _generateReportName(
    ReportContentModel data,
    ReportType type,
    String timestamp,
  ) {
    final companyName = data.companyName;
    final reportTime = data.reportTime;

    // 根据报告类型生成相应的描述
    String typeDescription;
    switch (type) {
      case ReportType.monthly:
        typeDescription = '月度';
        break;
      case ReportType.multiMonth:
        typeDescription = '多月';
        break;
      case ReportType.quarterly:
        typeDescription = '季度';
        break;
      case ReportType.annual:
        typeDescription = '年度';
        break;
    }

    // 移除报告时间中的特殊字符，使其适合文件名
    final cleanReportTime = reportTime.replaceAll(
      RegExp(r'[^\w\u4e00-\u9fa5]'),
      '',
    );

    return '${companyName}_${reportTime}_${typeDescription}报告_$timestamp';
  }

  /// 根据报告类型获取模板路径
  String _getTemplatePath(ReportType type) {
    switch (type) {
      case ReportType.monthly:
        return 'assets/salary_report_template_monthly.docx';
      case ReportType.multiMonth:
        return 'assets/salary_report_template_multi_month.docx';
      case ReportType.quarterly:
        return 'assets/salary_report_template_quarterly.docx';
      case ReportType.annual:
        return 'assets/salary_report_template_annual.docx';
    }
  }

  /// 构建内容，根据不同报告类型可能有不同的处理
  Content _buildContent(
    ReportContentModel data,
    ReportChartImages images,
    ReportType type,
  ) {
    final content = Content();

    // 添加通用文本字段
    _addCommonTextFields(content, data);

    // 根据报告类型添加特定字段
    switch (type) {
      case ReportType.monthly:
        _addMonthlySpecificFields(content, data);
        break;
      case ReportType.multiMonth:
        _addMultiMonthSpecificFields(content, data);
        break;
      case ReportType.quarterly:
        _addQuarterlySpecificFields(content, data);
        break;
      case ReportType.annual:
        _addAnnualSpecificFields(content, data);
        break;
    }

    // 添加表格内容
    _addTableContent(content, data);

    // 添加图片内容
    _addImageContent(content, images);

    return content;
  }

  /// 添加通用文本字段
  void _addCommonTextFields(Content content, ReportContentModel data) {
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
      ..add(TextContent('basic_rate', data.basicSalaryRate.toStringAsFixed(2)))
      ..add(
        TextContent(
          'performance_rate',
          data.performanceSalaryRate.toStringAsFixed(2),
        ),
      )
      ..add(TextContent('salary_structure_analysis', data.salaryStructure))
      ..add(TextContent('salary_structure', data.salaryStructure))
      ..add(
        TextContent('salary_structure_advice', data.salaryStructureAdvice),
      ); // 添加薪资结构建议

    // 添加 compare_last 如果不为空
    if (data.compareLast.isEmpty) {
      logger.warning('compare_last is empty');
    }
    content.add(TextContent('compare_last', data.compareLast));
  }

  /// 添加单月报告特定字段
  void _addMonthlySpecificFields(Content content, ReportContentModel data) {
    // 单月报告可能需要添加的一些特定字段
    // 这里可以根据需要添加
  }

  /// 添加多月报告特定字段
  void _addMultiMonthSpecificFields(Content content, ReportContentModel data) {
    // 多月报告可能需要添加的一些特定字段
    // 这里可以根据需要添加
  }

  /// 添加季度报告特定字段
  void _addQuarterlySpecificFields(Content content, ReportContentModel data) {
    // 季度报告可能需要添加的一些特定字段
    // 这里可以根据需要添加
  }

  /// 添加年度报告特定字段
  void _addAnnualSpecificFields(Content content, ReportContentModel data) {
    // 年度报告可能需要添加的一些特定字段
    // 这里可以根据需要添加
  }

  /// 添加表格内容
  void _addTableContent(Content content, ReportContentModel data) {
    final departmentRows = data.departmentStats.map((stat) {
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
  void _addImageContent(Content content, ReportChartImages images) {
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
