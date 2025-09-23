// src/services/multi_quarter/docx_writer_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:docx_template_fork/docx_template_fork.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

import 'package:salary_report/src/services/multi_quarter/multi_quarter_report_models.dart';

class MultiQuarterDocxWriterService {
  /// 写入多季度报告
  Future<String> writeReport({
    required MultiQuarterReportContentModel data,
    required MultiQuarterReportChartImages images,
  }) async {
    // 使用多季度报告模板
    final templatePath = 'assets/salary_report_template_multi_quarter.docx';

    logger.info('开始写入多季度报告, 使用模板: $templatePath');

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
  String _generateReportName(
    MultiQuarterReportContentModel data,
    String timestamp,
  ) {
    final companyName = data.companyName;
    final reportTime = data.reportTime;
    final typeDescription = '多季度';

    // 移除报告时间中的特殊字符，使其适合文件名
    final cleanReportTime = reportTime.replaceAll(
      RegExp(r'[^\w\u4e00-\u9fa5]'),
      '',
    );

    return '${companyName}_${reportTime}_$typeDescription报告_$timestamp';
  }

  /// 构建内容
  Content _buildContent(
    MultiQuarterReportContentModel data,
    MultiQuarterReportChartImages images,
  ) {
    final content = Content();

    // 添加通用文本字段
    _addCommonTextFields(content, data);

    // 添加多季度报告特定字段
    _addMultiQuarterSpecificFields(content, data);

    // 添加表格内容
    _addTableContent(content, data);

    // 添加图片内容
    _addImageContent(content, images);

    return content;
  }

  /// 格式化每季度人数变化数据
  String _formatEmployeeCountPerQuarterData(
    List<Map<String, dynamic>> employeeCountPerQuarter,
  ) {
    if (employeeCountPerQuarter.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var item in employeeCountPerQuarter) {
      // 修改格式，不使用冒号分隔，直接说明哪年哪季度总共有多少人，并显示各部门详情
      buffer.write('${item["quarter"]}季度总共有${item["employeeCount"]}人');

      // 如果有部门详情，也显示出来
      if (item.containsKey('departments') && item['departments'] is List) {
        final departments = item['departments'] as List;
        if (departments.isNotEmpty) {
          buffer.write('，其中');
          final deptDetails = departments
              .map((dept) {
                if (dept is Map<String, dynamic>) {
                  return '${dept["department"]}${dept["count"]}人';
                }
                return '';
              })
              .join('，');
          buffer.write(deptDetails);
        }
      }
      buffer.write('；');
    }
    // 移除最后的分号并添加句号
    final result = buffer.toString();
    return result.isEmpty ? '' : '${result.substring(0, result.length - 1)}。';
  }

  /// 格式化每季度平均薪资变化数据
  String _formatAverageSalaryPerQuarterData(
    List<Map<String, dynamic>> averageSalaryPerQuarter,
  ) {
    if (averageSalaryPerQuarter.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var item in averageSalaryPerQuarter) {
      // 修改格式，不使用冒号分隔
      buffer.write(
        '${item["quarter"]}季度平均薪资为¥${(item["averageSalary"] as double).toStringAsFixed(2)}；',
      );
    }
    // 移除最后的分号并添加句号
    final result = buffer.toString();
    return result.isEmpty ? '' : '${result.substring(0, result.length - 1)}。';
  }

  /// 格式化每季度总工资变化数据
  String _formatTotalSalaryPerQuarterData(
    List<Map<String, dynamic>> totalSalaryPerQuarter,
  ) {
    if (totalSalaryPerQuarter.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var item in totalSalaryPerQuarter) {
      // 修改格式，不使用冒号分隔
      buffer.write(
        '${item["quarter"]}季度总工资为¥${(item["totalSalary"] as double).toStringAsFixed(2)}；',
      );
    }
    // 移除最后的分号并添加句号
    final result = buffer.toString();
    return result.isEmpty ? '' : '${result.substring(0, result.length - 1)}。';
  }

  /// 格式化部门详情数据
  String _formatDepartmentDetailsData(
    List<Map<String, dynamic>> departmentDetailsPerQuarter,
  ) {
    if (departmentDetailsPerQuarter.isEmpty) {
      return '';
    }

    final departmentDetailsData = StringBuffer();
    for (var quarterData in departmentDetailsPerQuarter) {
      // 修改格式，显示各部门详情
      departmentDetailsData.write(
        '${quarterData["quarter"]}季度总共有${(quarterData["departments"] as List).length}个部门：',
      );
      final departments = quarterData["departments"] as List<dynamic>;
      final deptDetails = departments
          .map((dept) {
            if (dept is Map<String, dynamic>) {
              return '${dept["department"]}${dept["employeeCount"]}人';
            }
            return '';
          })
          .join('，');
      departmentDetailsData.write('$deptDetails；');
    }
    // 移除最后的分号并添加句号
    final result = departmentDetailsData.toString();
    return result.isEmpty ? '' : '${result.substring(0, result.length - 1)}。';
  }

  /// 添加通用文本字段
  void _addCommonTextFields(
    Content content,
    MultiQuarterReportContentModel data,
  ) {
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
      ..add(TextContent('salary_structure_advice', data.salaryStructureAdvice));

    // 添加 compare_last 如果不为空
    if (data.compareLast.isEmpty) {
      logger.warning('compare_last is empty');
    }
    content.add(TextContent('compare_last', data.compareLast));

    // 添加多季度报告可能有的额外文本字段（即使为空也要添加占位符）
    content
      ..add(
        TextContent(
          'employee_count_per_quarter_data',
          data.employeeCountPerQuarter != null
              ? _formatEmployeeCountPerQuarterData(
                  data.employeeCountPerQuarter!,
                )
              : '',
        ),
      )
      ..add(
        TextContent(
          'average_salary_per_quarter_data',
          data.averageSalaryPerQuarter != null
              ? _formatAverageSalaryPerQuarterData(
                  data.averageSalaryPerQuarter!,
                )
              : '',
        ),
      )
      ..add(
        TextContent(
          'total_salary_per_quarter_data',
          data.totalSalaryPerQuarter != null
              ? _formatTotalSalaryPerQuarterData(data.totalSalaryPerQuarter!)
              : '',
        ),
      )
      ..add(
        TextContent(
          'department_details_per_quarter_data',
          data.departmentDetailsPerQuarter != null
              ? _formatDepartmentDetailsData(data.departmentDetailsPerQuarter!)
              : '',
        ),
      );
  }

  /// 添加多季度报告特定字段
  void _addMultiQuarterSpecificFields(
    Content content,
    MultiQuarterReportContentModel data,
  ) {
    // 多季度报告特定的处理逻辑（如果有的话）
    // 通用文本字段已经在 _addCommonTextFields 中处理了
  }

  /// 添加表格内容
  void _addTableContent(Content content, MultiQuarterReportContentModel data) {
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
  void _addImageContent(Content content, MultiQuarterReportChartImages images) {
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
    // 添加多季度报告专用图表
    if (images.employeeCountPerQuarterChart != null) {
      content.add(
        ImageContent(
          'employee_count_per_quarter_chart',
          images.employeeCountPerQuarterChart!,
        ),
      );
    }
    if (images.averageSalaryPerQuarterChart != null) {
      content.add(
        ImageContent(
          'average_salary_per_quarter_chart',
          images.averageSalaryPerQuarterChart!,
        ),
      );
    }
    if (images.totalSalaryPerQuarterChart != null) {
      content.add(
        ImageContent(
          'total_salary_per_quarter_chart',
          images.totalSalaryPerQuarterChart!,
        ),
      );
    }
    if (images.departmentDetailsPerQuarterChart != null) {
      content.add(
        ImageContent(
          'department_details_per_quarter_chart',
          images.departmentDetailsPerQuarterChart!,
        ),
      );
    }
  }
}
