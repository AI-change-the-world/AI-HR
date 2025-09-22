import 'dart:io';
import 'package:isar_community/isar.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/report_generation_record.dart';

class ReportService {
  final IsarDatabase _database = IsarDatabase();

  /// 添加报告生成记录
  Future<Id> addReportRecord(
    String savePath, {
    ReportSaveFormat reportSaveFormat = ReportSaveFormat.docx,
  }) async {
    final record = ReportGenerationRecord()
      ..savePath = savePath
      ..createdAt = DateTime.now()
      ..reportSaveFormat = reportSaveFormat
      ..isDeleted = false;

    return await _database.isar!.writeTxn(() async {
      return await _database.isar!.reportGenerationRecords.put(record);
    });
  }

  /// 获取所有未删除的报告记录，按创建时间倒序排列
  Future<List<ReportGenerationRecord>> getAllReportRecords() async {
    return await _database.isar!.reportGenerationRecords
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// 标记报告记录为已删除并删除本地文件
  Future<bool> deleteReportRecord(Id id) async {
    return await _database.isar!.writeTxn(() async {
      final record = await _database.isar!.reportGenerationRecords.get(id);
      if (record != null) {
        // 标记为已删除
        record.isDeleted = true;
        await _database.isar!.reportGenerationRecords.put(record);

        // 删除本地文件
        try {
          final file = File(record.savePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // 如果文件删除失败，我们仍然标记为已删除
          // 这里可以添加日志记录
        }

        return true;
      }
      return false;
    });
  }

  /// 删除本地文件但不标记数据库记录为已删除
  Future<bool> deleteLocalFileOnly(Id id) async {
    final record = await _database.isar!.reportGenerationRecords.get(id);
    if (record != null) {
      try {
        final file = File(record.savePath);
        if (await file.exists()) {
          await file.delete();
        }
        return true;
      } catch (e) {
        // 文件删除失败
        return false;
      }
    }
    return false;
  }

  /// 彻底删除记录（从数据库中移除）
  Future<bool> permanentlyDeleteReportRecord(Id id) async {
    return await _database.isar!.writeTxn(() async {
      return await _database.isar!.reportGenerationRecords.delete(id);
    });
  }
}
