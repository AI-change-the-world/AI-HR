import 'dart:io';

import 'package:docx_template_fork/docx_template_fork.dart';

void main() async {
  final f = File("salary_report_template.docx");
  final docx = await DocxTemplate.fromBytes(await f.readAsBytes());

  final content = Content();
  content.add(TextContent("passport", "20"));
  content.add(TextContent("company_name", "100000"));

  final docGenerated = await docx.generate(content);
  final fileGenerated = File('generated.docx');
  if (docGenerated != null) await fileGenerated.writeAsBytes(docGenerated);
}
