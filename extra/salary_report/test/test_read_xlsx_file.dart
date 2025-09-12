// ignore_for_file: avoid_print

import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  var file = "test.xlsx";

  var bytes = File(file).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  for (var sheetName in excel.tables.keys) {
    final sheet = excel.tables[sheetName];
    if (sheet == null || sheet.maxRows == 0) continue;

    print("Sheet: $sheetName");

    for (var row in sheet.rows) {
      for (var cell in row) {
        if (cell == null) continue;

        // 无论什么类型，直接取字符串
        final text = cell.value?.toString() ?? "";
        print("cell ${cell.rowIndex}/${cell.columnIndex} = $text");
      }
    }
  }
}
