// src/report/enhanced_report_generator_interface.dart

import 'package:flutter/material.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

/// 增强版报告生成器接口
abstract class EnhancedReportGenerator {
  /// 生成增强版报告
  ///
  /// [previewContainerKey] 预览容器的 GlobalKey
  /// [departmentStats] 部门统计信息
  /// [analysisData] 分析数据
  /// [attendanceStats] 考勤统计信息
  /// [previousMonthData] 上月数据（可选）
  /// [year] 年份
  /// [month] 月份
  /// [isMultiMonth] 是否为多月报告
  /// [startTime] 开始时间
  /// [endTime] 结束时间
  /// 返回生成的报告文件路径
  Future<String> generateEnhancedReport({
    required GlobalKey previewContainerKey,
    required dynamic departmentStats,
    required Map<String, dynamic> analysisData,
    required List<AttendanceStats> attendanceStats,
    required Map<String, dynamic>? previousMonthData,
    required int year,
    required int month,
    required bool isMultiMonth,
    required DateTime startTime,
    required DateTime endTime,
  });
}
