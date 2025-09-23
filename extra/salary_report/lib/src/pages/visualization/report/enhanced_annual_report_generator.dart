// src/report/enhanced_annual_report_generator.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/services/report_service.dart';
import 'package:salary_report/src/utils/monthly_analysis_json_converter.dart';
import 'package:salary_report/src/services/chart_generation_from_json_service.dart';
import 'package:salary_report/src/pages/visualization/report/chart_generation_service.dart';
import 'package:salary_report/src/pages/visualization/report/docx_writer_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';
import 'package:salary_report/src/pages/visualization/report/report_types.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_report_generator_interface.dart';
import 'package:salary_report/src/isar/salary_list.dart';

/// 增强版年度报告生成器
class EnhancedAnnualReportGenerator implements EnhancedReportGenerator {
  final ChartGenerationService _chartService;
  final ChartGenerationFromJsonService _jsonChartService;
  final DocxWriterService _docxService;
  final DataAnalysisService _analysisService;
  final ReportService _reportService;

  EnhancedAnnualReportGenerator({
    ChartGenerationService? chartService,
    ChartGenerationFromJsonService? jsonChartService,
    DocxWriterService? docxService,
    DataAnalysisService? analysisService,
    ReportService? reportService,
  }) : _chartService = chartService ?? ChartGenerationService(),
       _jsonChartService = jsonChartService ?? ChartGenerationFromJsonService(),
       _docxService = docxService ?? DocxWriterService(),
       _analysisService =
           analysisService ?? DataAnalysisService(IsarDatabase()),
       _reportService = reportService ?? ReportService();

  @override
  Future<String> generateEnhancedReport({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required Map<String, dynamic> analysisData,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousMonthData,
    required int year,
    required int month,
    required bool isMultiMonth,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      logger.info('Starting enhanced annual salary report generation...');

      // 1. 生成JSON格式的分析数据
      final jsonString = MonthlyAnalysisJsonConverter.convertAnalysisDataToJson(
        analysisData: analysisData,
        departmentStats: departmentStats,
        attendanceStats: attendanceStats,
        previousMonthData: previousMonthData,
        year: year,
        month: month,
      );

      // 2. 解析JSON数据
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // 3. 构建薪资结构数据
      final salaryStructureData = _createSalaryStructureData(
        analysisData.containsKey('salarySummary')
            ? analysisData['salarySummary'] as Map<String, dynamic>
            : null,
      );

      // 4. 生成图表图像（从UI）
      final chartImagesFromUI = await _chartService.generateAllCharts(
        previewContainerKey: previewContainerKey,
        departmentStats: departmentStats,
        salaryRanges: _convertToSalaryRangeMap(
          analysisData['salaryRanges'] as List<dynamic>,
        ),
        salaryStructureData: salaryStructureData, // 添加薪资结构数据
      );

      // 5. 生成图表图像（从JSON数据）
      final chartImagesFromJson = await _jsonChartService
          .generateAllChartsFromJson(jsonData: jsonData);

      // 6. 创建组合图表图像集合
      final combinedChartImages = ReportChartImages(
        mainChart: chartImagesFromUI.mainChart,
        departmentDetailsChart: chartImagesFromJson.departmentChart,
        salaryRangeChart: chartImagesFromJson.salaryRangeChart,
        salaryStructureChart: chartImagesFromUI.salaryStructureChart, // 薪资结构饼图
        employeeCountPerMonthChart:
            chartImagesFromUI.employeeCountPerMonthChart,
        averageSalaryPerMonthChart:
            chartImagesFromUI.averageSalaryPerMonthChart,
        totalSalaryPerMonthChart: chartImagesFromUI.totalSalaryPerMonthChart,
        departmentDetailsPerMonthChart:
            chartImagesFromUI.departmentDetailsPerMonthChart,
      );

      // 7. 创建报告内容模型
      final reportContent = _createReportContentModel(
        jsonData,
        analysisData,
        startTime,
        endTime,
      );

      // 8. 写入报告文件
      final reportPath = await _docxService.writeReport(
        data: reportContent,
        images: combinedChartImages,
        reportType: ReportType.singleYear,
      );

      // 9. 添加报告记录到数据库
      await _reportService.addReportRecord(reportPath);

      logger.info('Enhanced annual report generation complete: $reportPath');

      return reportPath;
    } catch (e, stackTrace) {
      logger.severe(
        'Fatal error during enhanced annual report generation: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 创建薪资结构数据
  List<Map<String, dynamic>> _createSalaryStructureData(
    Map<String, dynamic>? salarySummary,
  ) {
    final salaryStructureData = <Map<String, dynamic>>[];

    if (salarySummary == null) {
      return salaryStructureData;
    }

    // 定义薪资结构相关的字段
    final salaryStructureFields = {
      '基本工资': '基本工资',
      '岗位工资': '岗位工资',
      '绩效工资': '绩效工资',
      '补贴工资': '补贴工资',
      '饭补': '饭补',
      '电脑补贴等': '电脑补贴等',
      '税前工资': '税前工资',
      '个人养老': '个人养老',
      '个人医疗': '个人医疗',
      '个人失业': '个人失业',
      '个人公积金': '个人公积金',
      '当月个人所得税': '当月个人所得税',
      '税后应实发': '税后应实发',
    };

    // 遍历 salarySummary，提取薪资结构相关字段
    salarySummary.forEach((key, value) {
      if (salaryStructureFields.containsKey(key) && value is num) {
        salaryStructureData.add({'category': key, 'value': value.toDouble()});
      }
    });

    return salaryStructureData;
  }

  /// 将薪资区间数据转换为图表服务所需的格式
  List<Map<String, dynamic>> _convertToSalaryRangeMap(
    List<dynamic> salaryRanges,
  ) {
    return salaryRanges.map<Map<String, dynamic>>((range) {
      if (range is SalaryRangeStats) {
        return {'range': range.range, 'count': range.employeeCount};
      } else if (range is Map<String, dynamic>) {
        return {
          'range': range['range'] as String,
          'count':
              range['employee_count'] as int? ?? range['count'] as int? ?? 0,
        };
      }
      return {'range': 'Unknown', 'count': 0};
    }).toList();
  }

  ReportContentModel _createReportContentModel(
    Map<String, dynamic> jsonData,
    Map<String, dynamic> analysisData,
    DateTime startTime,
    DateTime endTime,
  ) {
    // 从JSON数据中提取关键信息来构建报告内容模型
    final keyMetrics = jsonData['key_metrics'] as Map<String, dynamic>;
    final currentMonthMetrics =
        keyMetrics['current_month'] as Map<String, dynamic>;

    // 获取部门统计信息
    final departmentStats = analysisData['departmentStats'] as List<dynamic>;

    // 获取薪资区间信息
    final salaryRanges = analysisData['salaryRanges'] as List<dynamic>;

    // 构建薪资结构数据
    final salaryStructureData = _createSalaryStructureData(
      analysisData.containsKey('salarySummary')
          ? analysisData['salarySummary'] as Map<String, dynamic>
          : null,
    );

    // 生成薪资结构描述
    final salaryStructureDescription = _generateSalaryStructureDescription(
      salaryStructureData,
    );

    return ReportContentModel(
      reportTitle: '年度工资分析报告',
      reportDate:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      companyName: AIConfig.companyName,
      reportTime:
          '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
      startTime: '${startTime.year}年',
      endTime: '${endTime.year}年',
      compareLast: '与去年对比',
      totalEmployees: currentMonthMetrics['total_employees'] as int,
      totalSalary: (currentMonthMetrics['total_salary'] as num).toDouble(),
      averageSalary: (currentMonthMetrics['average_salary'] as num).toDouble(),
      departmentCount: departmentStats.length,
      employeeCount: currentMonthMetrics['total_unique_employees'] as int,
      employeeDetails: jsonData['key_param'] as String,
      departmentDetails: _generateDepartmentDetails(departmentStats),
      salaryRangeDescription: _generateSalaryRangeDescription(salaryRanges),
      salaryRangeFeatureSummary: '薪资区间特征总结',
      departmentSalaryAnalysis: '部门工资分析',
      keySalaryPoint: '关键工资点',
      salaryRankings: _generateSalaryRankings(analysisData),
      basicSalaryRate: 0.7,
      performanceSalaryRate: 0.3,
      salaryStructure: salaryStructureDescription, // 使用生成的薪资结构描述
      salaryStructureAdvice: '薪资结构优化建议',
      salaryStructureData: salaryStructureData,
      departmentStats: departmentStats.map((dept) {
        if (dept is Map<String, dynamic>) {
          return DepartmentSalaryStats(
            department: dept['department'] as String,
            employeeCount: dept['count'] as int,
            averageNetSalary: (dept['average'] as num).toDouble(),
            totalNetSalary: (dept['total'] as num).toDouble(),
            year: DateTime.now().year,
            month: DateTime.now().month,
          );
        }
        return DepartmentSalaryStats(
          department: '未知部门',
          employeeCount: 0,
          averageNetSalary: 0.0,
          totalNetSalary: 0.0,
          year: DateTime.now().year,
          month: DateTime.now().month,
        );
      }).toList(),
    );
  }

  /// 生成部门详情描述
  String _generateDepartmentDetails(List<dynamic> departmentStats) {
    final buffer = StringBuffer();
    buffer.writeln('本年度内共有${departmentStats.length}个部门：');
    for (var dept in departmentStats) {
      if (dept is Map<String, dynamic>) {
        buffer.writeln(
          '- ${dept['department']}部门：${dept['count']}人，工资总额¥${(dept['total'] as num).toStringAsFixed(2)}，平均工资¥${(dept['average'] as num).toStringAsFixed(2)}',
        );
      }
    }
    return buffer.toString();
  }

  /// 生成薪资区间描述
  String _generateSalaryRangeDescription(List<dynamic> salaryRanges) {
    final buffer = StringBuffer();
    buffer.writeln('薪资区间分布情况：');
    for (var range in salaryRanges) {
      if (range is SalaryRangeStats) {
        buffer.writeln(
          '- ${range.range}：${range.employeeCount}人，工资总额¥${range.totalSalary.toStringAsFixed(2)}，平均工资¥${range.averageSalary.toStringAsFixed(2)}',
        );
      } else if (range is Map<String, dynamic>) {
        buffer.writeln(
          '- ${range['range']}：${range['employee_count']}人，工资总额¥${(range['total_salary'] as num).toStringAsFixed(2)}，平均工资¥${(range['average_salary'] as num).toStringAsFixed(2)}',
        );
      }
    }
    return buffer.toString();
  }

  /// 生成薪资结构的自然语言描述
  String _generateSalaryStructureDescription(
    List<Map<String, dynamic>> salaryStructureData,
  ) {
    if (salaryStructureData.isEmpty) {
      return '暂无薪资结构数据。';
    }

    final buffer = StringBuffer();
    buffer.write('薪资结构分析如下：');

    // 按值排序，显示最重要的组成部分
    final sortedData = List<Map<String, dynamic>>.from(salaryStructureData);
    sortedData.sort(
      (a, b) => (b['value'] as double).compareTo(a['value'] as double),
    );

    for (int i = 0; i < sortedData.length; i++) {
      final item = sortedData[i];
      final category = item['category'] as String;
      final value = (item['value'] as double).toStringAsFixed(2);

      buffer.write('$category为${value}元');

      if (i < sortedData.length - 1) {
        buffer.write('，');
      }
    }

    buffer.write('。');
    return buffer.toString();
  }

  /// 生成工资排名描述
  String _generateSalaryRankings(Map<String, dynamic> analysisData) {
    final buffer = StringBuffer();

    // 最高工资员工
    final topEmployees = analysisData['topSalaryEmployees'] as List<dynamic>;
    if (topEmployees.isNotEmpty) {
      buffer.writeln('工资最高的员工：');
      for (var i = 0; i < topEmployees.length && i < 5; i++) {
        final employee = topEmployees[i];
        if (employee is SalaryListRecord) {
          buffer.writeln(
            '- ${employee.name}（${employee.department}）：¥${employee.netSalary}',
          );
        } else if (employee is Map<String, dynamic>) {
          buffer.writeln(
            '- ${employee['name']}（${employee['department']}）：¥${employee['net_salary']}',
          );
        }
      }
    }

    // 最低工资员工
    final bottomEmployees =
        analysisData['bottomSalaryEmployees'] as List<dynamic>;
    if (bottomEmployees.isNotEmpty) {
      buffer.writeln('工资最低的员工：');
      for (var i = 0; i < bottomEmployees.length && i < 5; i++) {
        final employee = bottomEmployees[i];
        if (employee is SalaryListRecord) {
          buffer.writeln(
            '- ${employee.name}（${employee.department}）：¥${employee.netSalary}',
          );
        } else if (employee is Map<String, dynamic>) {
          buffer.writeln(
            '- ${employee['name']}（${employee['department']}）：¥${employee['net_salary']}',
          );
        }
      }
    }

    return buffer.toString();
  }
}
