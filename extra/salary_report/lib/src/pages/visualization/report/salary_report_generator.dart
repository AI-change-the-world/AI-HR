import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:docx_template_fork/docx_template_fork.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';

class SalaryReportGenerator {
  /// 生成工资报告
  static Future<String> generateSalaryReport({
    required GlobalKey previewContainerKey,
    required List<DepartmentSalaryStats> departmentStats,
    required List<AttendanceStats> attendanceStats,
    required LeaveRatioStats? leaveRatioStats,
    required int year,
    required int month,
    required bool isMultiMonth,
    required Map<String, dynamic> analysisData,
  }) async {
    try {
      print('开始生成工资报告...');

      // 1. 截图图表组件
      final chartImage = await _captureChartImage(previewContainerKey);
      print('图表截图完成: ${chartImage != null ? '成功' : '失败'}');

      // 2. 准备报告数据
      final reportData = _prepareReportData(
        departmentStats: departmentStats,
        attendanceStats: attendanceStats,
        leaveRatioStats: leaveRatioStats,
        year: year,
        month: month,
        isMultiMonth: isMultiMonth,
        analysisData: analysisData,
      );
      print('报告数据准备完成');

      // 3. 生成报告文件
      final reportPath = await _generateReportFile(
        chartImage,
        reportData,
        departmentStats,
      );
      print('报告生成完成: $reportPath');

      return reportPath;
    } catch (e, stackTrace) {
      print('生成工资报告时出错: $e');
      print('错误堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 截图图表组件
  static Future<Uint8List?> _captureChartImage(
    GlobalKey previewContainerKey,
  ) async {
    try {
      if (previewContainerKey.currentContext == null) {
        print('截图容器上下文为空');
        return null;
      }

      final boundary =
          previewContainerKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('截图图表时出错: $e');
      return null;
    }
  }

  /// 准备报告数据
  static Map<String, dynamic> _prepareReportData({
    required List<DepartmentSalaryStats> departmentStats,
    required List<AttendanceStats> attendanceStats,
    required LeaveRatioStats? leaveRatioStats,
    required int year,
    required int month,
    required bool isMultiMonth,
    required Map<String, dynamic> analysisData,
  }) {
    // 准备部门统计数据
    final departmentData = departmentStats.map((stat) {
      return {
        'department_name': stat.department,
        'department_employees': stat.employeeCount.toString(),
        'department_salary': stat.totalNetSalary.toStringAsFixed(2),
        'department_avg_salary': stat.averageNetSalary.toStringAsFixed(2),
      };
    }).toList();

    // 准备考勤统计数据
    final attendanceData = attendanceStats.map((stat) {
      return {
        'name': stat.name,
        'department': stat.department,
        'sickLeaveDays': stat.sickLeaveDays.toStringAsFixed(2),
        'leaveDays': stat.leaveDays.toStringAsFixed(2),
        'absenceCount': stat.absenceCount.toString(),
        'truancyDays': stat.truancyDays.toStringAsFixed(2),
      };
    }).toList();

    // 准备请假比例数据
    final leaveData = leaveRatioStats != null
        ? {
            'totalEmployees': leaveRatioStats.totalEmployees.toString(),
            'sickLeaveRatio': leaveRatioStats.sickLeaveRatio.toStringAsFixed(2),
            'leaveRatio': leaveRatioStats.leaveRatio.toStringAsFixed(2),
          }
        : null;

    return {
      'reportTitle': isMultiMonth
          ? '$year年$month月起工资分析报告'
          : '$year年$month月工资分析报告',
      'reportDate': DateTime.now().toString().split(' ')[0],
      'total_employees': analysisData['totalEmployees'].toString(),
      'total_salary': analysisData['totalSalary'].toStringAsFixed(2),
      'avg_salary': analysisData['averageSalary'].toStringAsFixed(2),
      'departments': departmentData,
      'attendanceStats': attendanceData,
      'leaveStats': leaveData,
    };
  }

  /// 生成报告文件
  static Future<String> _generateReportFile(
    Uint8List? chartImage,
    Map<String, dynamic> reportData,
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    try {
      print('开始生成报告文件...');

      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();
      final outputPath =
          '${appDocDir.path}/salary_report_${DateTime.now().millisecondsSinceEpoch}.docx';

      // 模板文件路径
      final templatePath = 'salary_report_template.docx';
      print('模板路径: $templatePath');
      print('输出路径: $outputPath');

      // 检查模板文件是否存在
      final templateFile = File(templatePath);
      if (!await templateFile.exists()) {
        throw Exception('模板文件不存在: $templatePath');
      }

      // 加载模板
      print('正在加载模板...');
      final templateBytes = await templateFile.readAsBytes();
      print('模板大小: ${templateBytes.length} 字节');
      final docx = await DocxTemplate.fromBytes(templateBytes);
      print('模板加载完成');

      // 准备数据 - 根据模板中的实际占位符名称
      final content = Content();

      // 添加文本内容 - 使用模板中的实际占位符名称
      content
        ..add(
          TextContent(
            'total_employees',
            reportData['total_employees'] as String,
          ),
        )
        ..add(TextContent('total_salary', reportData['total_salary'] as String))
        ..add(TextContent('avg_salary', reportData['avg_salary'] as String));

      // 添加部门数据 - 使用模板中的实际占位符名称
      if (reportData['departments'] != null &&
          (reportData['departments'] as List).isNotEmpty) {
        final departmentRows = <RowContent>[];
        for (final dept in reportData['departments'] as List) {
          final row = RowContent();
          row
            ..add(
              TextContent('department_name', dept['department_name'] as String),
            )
            ..add(
              TextContent(
                'department_employees',
                dept['department_employees'] as String,
              ),
            )
            ..add(
              TextContent(
                'department_salary',
                dept['department_salary'] as String,
              ),
            )
            ..add(
              TextContent(
                'department_avg_salary',
                dept['department_avg_salary'] as String,
              ),
            );
          departmentRows.add(row);
        }
        content.add(TableContent('departments', departmentRows));
      }

      // 添加图表图片 - 使用模板中的实际占位符名称
      if (chartImage != null) {
        // 尝试两个图表占位符
        try {
          content.add(ImageContent('chart_overall', chartImage));
          print('成功添加整体图表');
        } catch (e) {
          print('添加整体图表失败: $e');
        }

        try {
          content.add(ImageContent('chart_department', chartImage));
          print('成功添加部门图表');
        } catch (e) {
          print('添加部门图表失败: $e');
        }
      }

      print("keys: ${content.keys}");
      // 生成报告
      print('正在生成报告...');
      final bytes = await docx.generate(content);
      if (bytes == null) {
        throw Exception('生成报告失败，返回空字节');
      }
      print('报告生成完成，大小: ${bytes.length} 字节');

      // 保存文件
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      print('报告文件保存完成');

      return outputPath;
    } catch (e, stackTrace) {
      print('生成报告文件时出错: $e');
      print('错误堆栈: $stackTrace');
      rethrow;
    }
  }
}
