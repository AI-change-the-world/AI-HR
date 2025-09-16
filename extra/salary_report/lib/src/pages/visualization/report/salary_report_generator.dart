import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:docx_template_fork/docx_template_fork.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      logger.info('开始生成工资报告...');

      // 计算工资区间数据
      final salaryRanges = _calculateSalaryRanges(departmentStats);
      logger.info('计算得到的工资区间数据: $salaryRanges');

      // 1. 截图图表组件
      final chartImages = await _captureChartImages(
        previewContainerKey,
        departmentStats,
        salaryRanges,
      );
      logger.info('图表截图完成: ${chartImages.length} 个图表');

      // 2. 准备报告数据
      final reportData = _prepareReportData(
        departmentStats: departmentStats,
        attendanceStats: attendanceStats,
        leaveRatioStats: leaveRatioStats,
        year: year,
        month: month,
        isMultiMonth: isMultiMonth,
        analysisData: analysisData,
        startTime: startTime,
        endTime: endTime,
        chartImages: chartImages,
      );
      logger.info('报告数据准备完成');

      // 3. 生成报告文件
      final reportPath = await _generateReportFile(
        chartImages,
        reportData,
        departmentStats,
      );
      logger.info('报告生成完成: $reportPath');

      return reportPath;
    } catch (e, stackTrace) {
      logger.info('生成工资报告时出错: $e');
      logger.info('错误堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 计算工资区间分布
  static Map<String, int> _calculateSalaryRanges(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    final salaryRanges = <String, int>{};
    for (final dept in departmentStats) {
      final avgSalary = dept.averageNetSalary;
      String range;
      if (avgSalary < 3000) {
        range = '少于3000';
      } else if (avgSalary < 4000) {
        range = '3000-4000';
      } else if (avgSalary < 5000) {
        range = '4000-5000';
      } else if (avgSalary < 6000) {
        range = '5000-6000';
      } else if (avgSalary < 7000) {
        range = '6000-7000';
      } else if (avgSalary < 8000) {
        range = '7000-8000';
      } else if (avgSalary < 9000) {
        range = '8000-9000';
      } else if (avgSalary < 10000) {
        range = '9000-10000';
      } else {
        range = '10000以上';
      }

      salaryRanges[range] = (salaryRanges[range] ?? 0) + dept.employeeCount;
    }

    logger.info('计算得到的工资区间数据: $salaryRanges');
    return salaryRanges;
  }

  /// 截图图表组件
  static Future<Map<String, Uint8List?>> _captureChartImages(
    GlobalKey previewContainerKey,
    List<DepartmentSalaryStats> departmentStats,
    Map<String, int> salaryRanges, // 添加工资区间数据参数
  ) async {
    final Map<String, Uint8List?> images = {};

    try {
      // 首先尝试从现有的previewContainerKey截图
      if (previewContainerKey.currentContext != null) {
        final boundary =
            previewContainerKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        images['main_chart'] = byteData?.buffer.asUint8List();
      }

      // 生成虚拟图表图像
      final employeeChartImage = await _generateEmployeeDistributionChart(
        departmentStats,
      );
      images['employee_details_chart'] = employeeChartImage;

      logger.info('传递给图表的工资区间数据: $salaryRanges');
      final salaryRangeChartImage = await _generateSalaryRangeChart(
        departmentStats,
        salaryRanges: salaryRanges, // 传递工资区间数据
      );
      images['salary_range_chart'] = salaryRangeChartImage;

      return images;
    } catch (e) {
      logger.info('截图图表时出错: $e');
      return images;
    }
  }

  /// 生成员工分布饼图
  static Future<Uint8List?> _generateEmployeeDistributionChart(
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    try {
      final screenshotController = ScreenshotController();

      // 直接使用传入的数据，不创建虚假数据
      // 如果没有数据，图表将为空，这在实际应用中应该由调用方确保数据存在

      // 创建一个包含MediaQuery的虚拟容器（使用您提供的正确方式）
      final virtualChartWidget = MediaQuery(
        data: const MediaQueryData(),
        child: Container(
          width: 800,
          height: 600,
          color: Colors.white,
          child: SfCircularChart(
            title: ChartTitle(text: '各部门员工分布'),
            legend: Legend(isVisible: true),
            series: _getEmployeeDistributionSeries(departmentStats),
          ),
        ),
      );

      // 使用screenshot包截图虚拟图表
      final imageBytes = await screenshotController.captureFromWidget(
        virtualChartWidget,
        delay: const Duration(milliseconds: 200),
        pixelRatio: 3.0,
      );

      return imageBytes;
    } catch (e) {
      logger.info('生成员工分布图表时出错: $e');
      return null;
    }
  }

  /// 生成工资区间柱状图
  static Future<Uint8List?> _generateSalaryRangeChart(
    List<DepartmentSalaryStats> departmentStats, {
    Map<String, int>? salaryRanges, // 使salaryRanges成为可选参数
  }) async {
    try {
      final screenshotController = ScreenshotController();

      // 如果没有提供salaryRanges，则基于部门数据计算
      List<ColumnSeries<Map<String, dynamic>, String>> series;
      if (salaryRanges != null) {
        logger.info('使用传入的工资区间数据: $salaryRanges');
        series = _getSalaryRangeSeriesWithData(salaryRanges);
      } else {
        logger.info('未提供工资区间数据，基于部门数据计算');
        series = _getSalaryRangeSeries(departmentStats);
      }

      logger.info('生成工资区间图表的系列: ${series.firstOrNull?.dataSource}');

      // 创建一个包含MediaQuery的虚拟容器（使用您提供的正确方式）
      final virtualChartWidget = MediaQuery(
        data: MediaQueryData.fromView(WidgetsBinding.instance.window),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            width: 800,
            height: 600,
            color: Colors.white,
            child: SfCartesianChart(
              title: ChartTitle(text: '工资区间分布'),
              primaryXAxis: CategoryAxis(
                labelRotation: 0,
                labelIntersectAction: AxisLabelIntersectAction.rotate45,
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                // 移除固定的interval设置，让图表自动调整
              ),
              legend: Legend(isVisible: true),
              series: series,
            ),
          ),
        ),
      );

      // 使用screenshot包截图虚拟图表
      final imageBytes = await screenshotController.captureFromWidget(
        virtualChartWidget,
        delay: const Duration(milliseconds: 200),
        pixelRatio: 3.0,
      );

      return imageBytes;
    } catch (e) {
      logger.info('生成工资区间图表时出错: $e');
      return null;
    }
  }

  /// 获取员工分布饼图数据系列
  static List<PieSeries<Map<String, dynamic>, String>>
  _getEmployeeDistributionSeries(List<DepartmentSalaryStats> departmentStats) {
    final List<Map<String, dynamic>> employeeData = departmentStats.map((stat) {
      return {'department': stat.department, 'count': stat.employeeCount};
    }).toList();

    return [
      PieSeries<Map<String, dynamic>, String>(
        dataSource: employeeData,
        xValueMapper: (data, _) => data['department'] as String,
        yValueMapper: (data, _) => data['count'] as int,
        dataLabelMapper: (data, _) =>
            '${data['department']}\n${data['count']}人',
        dataLabelSettings: const DataLabelSettings(isVisible: true),
        enableTooltip: true,
      ),
    ];
  }

  /// 获取工资区间柱状图数据系列
  static List<ColumnSeries<Map<String, dynamic>, String>>
  _getSalaryRangeSeriesWithData(Map<String, int> salaryRanges) {
    logger.info('salaryRanges: $salaryRanges');

    final List<Map<String, dynamic>> salaryRangeData = salaryRanges.entries.map(
      (entry) {
        return {'range': entry.key, 'count': entry.value};
      },
    ).toList();

    logger.info('处理后的工资区间数据: $salaryRangeData');

    // 检查处理后的数据是否为空
    if (salaryRangeData.isEmpty) {
      logger.info('处理后的工资区间数据为空，返回空系列');
      return [
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: [],
          xValueMapper: (data, _) => data['range'] as String,
          yValueMapper: (data, _) => data['count'] as int,
          dataLabelMapper: (data, _) => '${data['range']}\n${data['count']}人',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontSize: 12, color: Colors.black),
          ),
          enableTooltip: true,
        ),
      ];
    }

    return [
      ColumnSeries<Map<String, dynamic>, String>(
        animationDelay: 0,
        animationDuration: 0,
        dataSource: salaryRangeData,
        xValueMapper: (data, _) => data['range'] as String,
        yValueMapper: (data, _) => data['count'] as int,
        dataLabelMapper: (data, _) => '${data['range']}\n${data['count']}人',
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          textStyle: TextStyle(fontSize: 12, color: Colors.black),
        ),
        enableTooltip: true,
      ),
    ];
  }

  /// 获取工资区间柱状图数据系列（基于部门统计数据）
  static List<ColumnSeries<Map<String, dynamic>, String>> _getSalaryRangeSeries(
    List<DepartmentSalaryStats> departmentStats,
  ) {
    // 计算工资区间分布
    final salaryRanges = <String, int>{};
    for (final dept in departmentStats) {
      final avgSalary = dept.averageNetSalary;
      String range;
      if (avgSalary < 3000) {
        range = '少于3000';
      } else if (avgSalary < 4000) {
        range = '3000-4000';
      } else if (avgSalary < 5000) {
        range = '4000-5000';
      } else if (avgSalary < 6000) {
        range = '5000-6000';
      } else if (avgSalary < 7000) {
        range = '6000-7000';
      } else if (avgSalary < 8000) {
        range = '7000-8000';
      } else if (avgSalary < 9000) {
        range = '8000-9000';
      } else if (avgSalary < 10000) {
        range = '9000-10000';
      } else {
        range = '10000以上';
      }

      salaryRanges[range] = (salaryRanges[range] ?? 0) + dept.employeeCount;
    }

    return _getSalaryRangeSeriesWithData(salaryRanges);
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
    required DateTime startTime,
    required DateTime endTime,
    required Map<String, Uint8List?> chartImages,
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

    // 公司名称
    final companyName = AIConfig.companyName;

    // 当前时间
    final currentTime = DateTime.now();

    // 报告时间范围
    String reportTime;

    if (isMultiMonth) {
      // 多个月份
      reportTime = '$year年$month月至${currentTime.year}年${currentTime.month}月';
    } else {
      // 单个月份
      reportTime = '$year年$month月';
    }

    // 部门数量
    final departmentCount = departmentStats.length;

    // 员工总数
    final employeeCount = departmentStats.fold(
      0,
      (sum, stat) => sum + stat.employeeCount,
    );

    // 员工详细信息（按部门人数排序）
    final sortedDepartments = List<DepartmentSalaryStats>.from(departmentStats)
      ..sort((a, b) => b.employeeCount.compareTo(a.employeeCount));

    final employeeDetails = sortedDepartments
        .map((dept) => '${dept.department}部门${dept.employeeCount}人')
        .join('，');

    // 平均薪资
    final averageSalary = analysisData['averageSalary'] as double? ?? 0.0;

    // 工资区间统计（使用已计算的数据）
    // 注意：这里我们不再重新计算工资区间数据，而是使用图表生成时已计算的数据
    // 在报告正文中，我们只提供文字描述，图表由图像展示

    final salaryRangeDescriptions = '详见图表';

    // 各部门平均薪资排名
    final sortedBySalary = List<DepartmentSalaryStats>.from(departmentStats)
      ..sort((a, b) => b.averageNetSalary.compareTo(a.averageNetSalary));

    final salaryOrder = sortedBySalary
        .asMap()
        .entries
        .map(
          (entry) =>
              '第${entry.key + 1}名${entry.value.department}部门平均薪资${entry.value.averageNetSalary.toStringAsFixed(2)}元',
        )
        .join('；');

    // 基本工资和绩效工资占比（简化处理，实际需要具体数据）
    final basicRate = 85.0; // 假设值
    final performanceRate = 15.0; // 假设值

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

      // 新增参数
      'company_name': companyName,
      'start_time': '${startTime.year}年${startTime.month}月',
      'end_time': '${endTime.year}年${endTime.month}月',
      'current_time':
          '${currentTime.year}年${currentTime.month}月${currentTime.day}日',
      'report_time': reportTime,
      'department_count': departmentCount.toString(),
      'employee_count': employeeCount.toString(),
      'employee_details': employeeDetails,
      'employee_details_chart': '', // 图像数据将在生成报告时处理
      'avarage_salary': averageSalary.toStringAsFixed(2),
      'salary_range': salaryRangeDescriptions, // 使用图表展示，文字描述简化
      'salary_range_chart': '', // 图像数据将在生成报告时处理
      'salary_order': salaryOrder,
      'basic_rate': basicRate.toStringAsFixed(2),
      'performance_rate': performanceRate.toStringAsFixed(2),
    };
  }

  /// 生成报告文件
  static Future<String> _generateReportFile(
    Map<String, Uint8List?> chartImages,
    Map<String, dynamic> reportData,
    List<DepartmentSalaryStats> departmentStats,
  ) async {
    try {
      logger.info('开始生成报告文件...');

      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();
      final outputPath =
          '${appDocDir.path}/salary_report_${DateTime.now().millisecondsSinceEpoch}.docx';

      // 模板文件路径
      final templatePath = 'salary_report_template.docx';
      logger.info('模板路径: $templatePath');
      logger.info('输出路径: $outputPath');

      // 检查模板文件是否存在
      final templateFile = File(templatePath);
      if (!await templateFile.exists()) {
        throw Exception('模板文件不存在: $templatePath');
      }

      // 加载模板
      logger.info('正在加载模板...');
      final templateBytes = await templateFile.readAsBytes();
      logger.info('模板大小: ${templateBytes.length} 字节');
      final docx = await DocxTemplate.fromBytes(templateBytes);
      logger.info('模板加载完成');

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
        ..add(TextContent('avg_salary', reportData['avg_salary'] as String))
        ..add(TextContent('company_name', reportData['company_name'] as String))
        ..add(TextContent('start_time', reportData['start_time'] as String))
        ..add(TextContent('end_time', reportData['end_time'] as String))
        ..add(TextContent('current_time', reportData['current_time'] as String))
        ..add(TextContent('report_time', reportData['report_time'] as String))
        ..add(
          TextContent(
            'department_count',
            reportData['department_count'] as String,
          ),
        )
        ..add(
          TextContent('employee_count', reportData['employee_count'] as String),
        )
        ..add(
          TextContent(
            'employee_details',
            reportData['employee_details'] as String,
          ),
        )
        ..add(
          TextContent('avarage_salary', reportData['avarage_salary'] as String),
        )
        ..add(TextContent('salary_range', reportData['salary_range'] as String))
        ..add(TextContent('salary_order', reportData['salary_order'] as String))
        ..add(TextContent('basic_rate', reportData['basic_rate'] as String))
        ..add(
          TextContent(
            'performance_rate',
            reportData['performance_rate'] as String,
          ),
        );

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
      // 添加主图表
      if (chartImages['main_chart'] != null) {
        try {
          content.add(
            ImageContent('chart_overall', chartImages['main_chart']!),
          );
          logger.info('成功添加整体图表');
        } catch (e) {
          logger.info('添加整体图表失败: $e');
        }

        try {
          content.add(
            ImageContent('chart_department', chartImages['main_chart']!),
          );
          logger.info('成功添加部门图表');
        } catch (e) {
          logger.info('添加部门图表失败: $e');
        }
      }

      // 添加员工详情图表
      if (chartImages['employee_details_chart'] != null) {
        try {
          content.add(
            ImageContent(
              'employee_details_chart',
              chartImages['employee_details_chart']!,
            ),
          );
          logger.info('成功添加员工详情图表');
        } catch (e) {
          logger.info('添加员工详情图表失败: $e');
        }
      }

      // 添加工资区间图表
      if (chartImages['salary_range_chart'] != null) {
        try {
          content.add(
            ImageContent(
              'salary_range_chart',
              chartImages['salary_range_chart']!,
            ),
          );
          logger.info('成功添加工资区间图表');
        } catch (e) {
          logger.info('添加工资区间图表失败: $e');
        }
      }

      logger.info("keys: ${content.keys}");
      // 生成报告
      logger.info('正在生成报告...');
      final bytes = await docx.generate(content);
      if (bytes == null) {
        throw Exception('生成报告失败，返回空字节');
      }
      logger.info('报告生成完成，大小: ${bytes.length} 字节');

      // 保存文件
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      logger.info('报告文件保存完成');

      return outputPath;
    } catch (e, stackTrace) {
      logger.info('生成报告文件时出错: $e');
      logger.info('错误堆栈: $stackTrace');
      rethrow;
    }
  }
}
