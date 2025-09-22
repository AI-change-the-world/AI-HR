import 'package:isar_community/isar.dart';

part 'report_generation_record.g.dart';

@collection
class ReportGenerationRecord {
  Id id = Isar.autoIncrement;

  late String savePath;
  bool isDeleted = false;
  late DateTime createdAt = DateTime.now();

  @enumerated
  ReportType reportType = ReportType.docx;
}

enum ReportType { docx, image }
