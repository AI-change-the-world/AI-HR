// src/services/multi_year/docx_writer_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:docx_template_fork/docx_template_fork.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

import 'package:salary_report/src/services/multi_year/multi_year_report_models.dart';

class MultiYearDocxWriterService {
  /// 写入多年报告
  Future<String> writeReport({
    required MultiYearReportContentModel data,
    required MultiYearReportChartImages images,
  }) async {
    // 使用多年报告模板
    final templatePath = 'assets/salary_report_template_multi_year.docx';

    logger.info('开始写入多年报告, 使用模板: $templatePath');

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
    MultiYearReportContentModel data,
    String timestamp,
  ) {
    final companyName = data.companyName;
    final reportTime = data.reportTime;
    final typeDescription = '多年';

    // 移除报告时间中的特殊字符，使其适合文件名
    final cleanReportTime = reportTime.replaceAll(
      RegExp(r'[^\w\u4e00-\u9fa5]'),
      '',
    );

    return '${companyName}_${reportTime}_$typeDescription报告_$timestamp';
  }

  /// 构建内容
  Content _buildContent(
    MultiYearReportContentModel data,
    MultiYearReportChartImages images,
  ) {
    final content = Content();

    // 添加通用文本字段
    _addCommonTextFields(content, data);

    // 添加多年报告特定字段
    _addMultiYearSpecificFields(content, data);

    // 添加表格内容
    _addTableContent(content, data);

    // 添加图片内容
    _addImageContent(content, images);

    return content;
  }

  /// 格式化每年人数变化数据
  String _formatEmployeeCountPerYearData(
    List<Map<String, dynamic>> employeeCountPerYear,
  ) {
    if (employeeCountPerYear.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var item in employeeCountPerYear) {
      // 修改格式，不使用冒号分隔，直接说明哪年总共有多少人，并显示各部门详情
      buffer.write('${item["year"]}年总共有${item["employeeCount"]}人');

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

  /// 格式化每年平均薪资变化数据
  String _formatAverageSalaryPerYearData(
    List<Map<String, dynamic>> averageSalaryPerYear,
  ) {
    if (averageSalaryPerYear.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var item in averageSalaryPerYear) {
      // 修改格式，不使用冒号分隔
      buffer.write(
        '${item["year"]}年平均薪资为${(item["averageSalary"] as double).toStringAsFixed(2)}元；',
      );
    }
    // 移除最后的分号并添加句号
    final result = buffer.toString();
    return result.isEmpty ? '' : '${result.substring(0, result.length - 1)}。';
  }

  /// 格式化每年总工资变化数据
  String _formatTotalSalaryPerYearData(
    List<Map<String, dynamic>> totalSalaryPerYear,
  ) {
    if (totalSalaryPerYear.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var item in totalSalaryPerYear) {
      // 修改格式，不使用冒号分隔
      buffer.write(
        '${item["year"]}年总工资为${(item["totalSalary"] as double).toStringAsFixed(2)}元；',
      );
    }
    // 移除最后的分号并添加句号
    final result = buffer.toString();
    return result.isEmpty ? '' : '${result.substring(0, result.length - 1)}。';
  }

  /// 格式化部门详情数据
  String _formatDepartmentDetailsData(
    List<Map<String, dynamic>> departmentDetailsPerYear,
  ) {
    if (departmentDetailsPerYear.isEmpty) {
      return '';
    }

    final departmentDetailsData = StringBuffer();
    for (var yearData in departmentDetailsPerYear) {
      // 修改格式，显示各部门详情
      departmentDetailsData.write(
        '${yearData["year"]}年总共有${(yearData["departments"] as List).length}个部门：',
      );
      final departments = yearData["departments"] as List<dynamic>;
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
  void _addCommonTextFields(Content content, MultiYearReportContentModel data) {
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

    // 添加多年报告可能有的额外文本字段（即使为空也要添加占位符）
    content
      ..add(
        TextContent(
          'employee_count_per_year_data',
          data.employeeCountPerYear != null
              ? _formatEmployeeCountPerYearData(data.employeeCountPerYear!)
              : '',
        ),
      )
      ..add(
        TextContent(
          'average_salary_per_year_data',
          data.averageSalaryPerYear != null
              ? _formatAverageSalaryPerYearData(data.averageSalaryPerYear!)
              : '',
        ),
      )
      ..add(
        TextContent(
          'total_salary_per_year_data',
          data.totalSalaryPerYear != null
              ? _formatTotalSalaryPerYearData(data.totalSalaryPerYear!)
              : '',
        ),
      )
      ..add(
        TextContent(
          'department_details_per_year_data',
          data.departmentDetailsPerYear != null
              ? _formatDepartmentDetailsData(data.departmentDetailsPerYear!)
              : '',
        ),
      );
  }

  /// 添加多年报告特定字段
  void _addMultiYearSpecificFields(
    Content content,
    MultiYearReportContentModel data,
  ) {
    // 多年报告特定的处理逻辑（如果有的话）
    // 通用文本字段已经在 _addCommonTextFields 中处理了
  }

  /// 添加表格内容
  void _addTableContent(Content content, MultiYearReportContentModel data) {
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
  void _addImageContent(Content content, MultiYearReportChartImages images) {
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
    // 添加多年报告专用图表
    if (images.employeeCountPerYearChart != null) {
      content.add(
        ImageContent(
          'employee_count_per_year_chart',
          images.employeeCountPerYearChart!,
        ),
      );
    }
    if (images.averageSalaryPerYearChart != null) {
      content.add(
        ImageContent(
          'average_salary_per_year_chart',
          images.averageSalaryPerYearChart!,
        ),
      );
    }
    if (images.totalSalaryPerYearChart != null) {
      content.add(
        ImageContent(
          'total_salary_per_year_chart',
          images.totalSalaryPerYearChart!,
        ),
      );
    }
    if (images.departmentDetailsPerYearChart != null) {
      content.add(
        ImageContent(
          'department_details_per_year_chart',
          images.departmentDetailsPerYearChart!,
        ),
      );
    }
  }
}
