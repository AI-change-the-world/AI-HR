// src/services/multi_month/docx_writer_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:docx_template_fork/docx_template_fork.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

import 'package:salary_report/src/services/multi_month/multi_month_report_models.dart';

class MultiMonthDocxWriterService {
  /// 写入多月报告
  Future<String> writeReport({
    required MultiMonthReportContentModel data,
    required MultiMonthReportChartImages images,
  }) async {
    // 使用多月报告模板
    final templatePath = 'assets/salary_report_template_multi_month.docx';

    logger.info('开始写入多月报告, 使用模板: $templatePath');

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
    MultiMonthReportContentModel data,
    String timestamp,
  ) {
    final companyName = data.companyName;
    final reportTime = data.reportTime;
    final typeDescription = '多月';

    // 移除报告时间中的特殊字符，使其适合文件名
    final cleanReportTime = reportTime.replaceAll(
      RegExp(r'[^\w\u4e00-\u9fa5]'),
      '',
    );

    return '${companyName}_${reportTime}_$typeDescription报告_$timestamp';
  }

  /// 构建内容
  Content _buildContent(
    MultiMonthReportContentModel data,
    MultiMonthReportChartImages images,
  ) {
    final content = Content();

    // 添加通用文本字段
    _addCommonTextFields(content, data);

    // 添加多月报告特定字段
    _addMultiMonthSpecificFields(content, data);

    // 添加表格内容
    _addTableContent(content, data);

    // 添加图片内容
    _addImageContent(content, images);

    return content;
  }

  /// 格式化每月人数变化数据
  String _formatEmployeeCountPerMonthData(
    List<Map<String, dynamic>> employeeCountPerMonth,
  ) {
    if (employeeCountPerMonth.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var item in employeeCountPerMonth) {
      // 修改格式，不使用冒号分隔，直接说明哪年哪月总共有多少人，并显示各部门详情
      buffer.write('${item["month"]}总共有${item["employeeCount"]}人');

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

  /// 格式化每月平均薪资变化数据
  String _formatAverageSalaryPerMonthData(
    List<Map<String, dynamic>> averageSalaryPerMonth,
  ) {
    logger.info('averageSalaryPerMonth xxx: $averageSalaryPerMonth');

    if (averageSalaryPerMonth.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var item in averageSalaryPerMonth) {
      // 修改格式，不使用冒号分隔
      buffer.write(
        '${item["month"]}平均薪资为${(item["averageSalary"] as double).toStringAsFixed(2)}元；',
      );
    }
    // 移除最后的分号并添加句号
    final result = buffer.toString();
    return result.isEmpty ? '' : '${result.substring(0, result.length - 1)}。';
  }

  /// 格式化每月总工资变化数据
  String _formatTotalSalaryPerMonthData(
    List<Map<String, dynamic>> totalSalaryPerMonth,
  ) {
    if (totalSalaryPerMonth.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var item in totalSalaryPerMonth) {
      // 修改格式，不使用冒号分隔
      buffer.write(
        '${item["month"]}总工资为${(double.tryParse(item["totalSalary"].toString()) ?? 0.0).toStringAsFixed(2)}元；',
      );
    }
    // 移除最后的分号并添加句号
    final result = buffer.toString();
    return result.isEmpty ? '' : '${result.substring(0, result.length - 1)}。';
  }

  /// 格式化部门详情数据
  String _formatDepartmentDetailsData(
    List<Map<String, dynamic>> departmentDetailsPerMonth,
  ) {
    if (departmentDetailsPerMonth.isEmpty) {
      return '';
    }

    final departmentDetailsData = StringBuffer();
    for (var monthData in departmentDetailsPerMonth) {
      if (monthData["departments"] == null) {
        continue;
      }

      // 修改格式，显示各部门详情
      departmentDetailsData.write(
        '${monthData["month"]}总共有${(monthData["departments"] as List).length}个部门：',
      );
      final departments = monthData["departments"] as List<dynamic>;
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
    MultiMonthReportContentModel data,
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
      ..add(TextContent('salary_order', data.salaryOrder))
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

    // 添加多月报告可能有的额外文本字段（即使为空也要添加占位符）
    content
      ..add(
        TextContent(
          'employee_count_per_month_data',
          data.employeeCountPerMonth != null
              ? _formatEmployeeCountPerMonthData(data.employeeCountPerMonth!)
              : '',
        ),
      )
      ..add(
        TextContent(
          'average_salary_per_month_data',
          data.averageSalaryPerMonth != null
              ? _formatAverageSalaryPerMonthData(data.averageSalaryPerMonth!)
              : '',
        ),
      )
      ..add(
        TextContent(
          'total_salary_per_month_data',
          data.totalSalaryPerMonth != null
              ? _formatTotalSalaryPerMonthData(data.totalSalaryPerMonth!)
              : '',
        ),
      )
      ..add(
        TextContent(
          'department_details_per_month_data',
          data.departmentDetailsPerMonth != null
              ? _formatDepartmentDetailsData(data.departmentDetailsPerMonth!)
              : '',
        ),
      );
  }

  /// 添加多月报告特定字段
  void _addMultiMonthSpecificFields(
    Content content,
    MultiMonthReportContentModel data,
  ) {
    // 多月报告特定的处理逻辑（如果有的话）
    // 通用文本字段已经在 _addCommonTextFields 中处理了
  }

  /// 添加表格内容
  void _addTableContent(Content content, MultiMonthReportContentModel data) {
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
  void _addImageContent(Content content, MultiMonthReportChartImages images) {
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
    if (images.salaryStructureStackedChart != null) {
      content.add(
        ImageContent(
          'salary_structure_chart',
          images.salaryStructureStackedChart!,
        ),
      );
    }
    // 添加多月报告专用图表
    if (images.employeeCountPerMonthChart != null) {
      content.add(
        ImageContent(
          'employee_count_per_month_chart',
          images.employeeCountPerMonthChart!,
        ),
      );
    }
    if (images.averageSalaryPerMonthChart != null) {
      content.add(
        ImageContent(
          'average_salary_per_month_chart',
          images.averageSalaryPerMonthChart!,
        ),
      );
    }
    if (images.totalSalaryPerMonthChart != null) {
      content.add(
        ImageContent(
          'total_salary_per_month_chart',
          images.totalSalaryPerMonthChart!,
        ),
      );
    }
    if (images.departmentDetailsPerMonthChart != null) {
      content.add(
        ImageContent(
          'department_details_per_month_chart',
          images.departmentDetailsPerMonthChart!,
        ),
      );
    }
    // 添加同比环比对比图表
    if (images.departmentMonthOverMonthChart != null) {
      content.add(
        ImageContent(
          'department_month_over_month_chart',
          images.departmentMonthOverMonthChart!,
        ),
      );
    }
    if (images.departmentYearOverYearChart != null) {
      content.add(
        ImageContent(
          'department_year_over_year_chart',
          images.departmentYearOverYearChart!,
        ),
      );
    }
    if (images.positionMonthOverMonthChart != null) {
      content.add(
        ImageContent(
          'position_month_over_month_chart',
          images.positionMonthOverMonthChart!,
        ),
      );
    }
    if (images.positionYearOverYearChart != null) {
      content.add(
        ImageContent(
          'position_year_over_year_chart',
          images.positionYearOverYearChart!,
        ),
      );
    }
  }
}
