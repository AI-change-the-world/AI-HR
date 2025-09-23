import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_monthly_report_generator.dart';

void main() {
  group('EnhancedMonthlyReportGenerator Tests', () {
    test('should create salary structure data correctly', () {
      // Arrange
      final generator = EnhancedMonthlyReportGenerator();

      // 模拟薪资摘要数据
      final salarySummary = {
        '基本工资': 67580.0,
        '岗位工资': 44564.0,
        '绩效工资': 46314.0,
        '补贴工资': 27350.0,
        '饭补': 11690.0,
        '电脑补贴等': 0.0,
        '税前工资': 175542.90,
        '个人养老': 10888.64,
        '个人医疗': 2984.66,
        '个人失业': 1008.80,
        '个人公积金': 7073.0,
        '当月个人所得税': 2503.79,
        '税后应实发': 173039.11,
      };

      // Act
      final result = generator.createSalaryStructureData(salarySummary);

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, greaterThan(0));

      // 检查是否包含关键薪资结构字段
      final categories = result
          .map((item) => item['category'] as String)
          .toList();
      expect(categories, contains('基本工资'));
      expect(categories, contains('岗位工资'));
      expect(categories, contains('绩效工资'));
      expect(categories, contains('补贴工资'));
      expect(categories, contains('饭补'));
      expect(categories, contains('电脑补贴等'));

      // 验证值是否正确
      final basicSalaryItem = result.firstWhere(
        (item) => item['category'] == '基本工资',
      );
      expect(basicSalaryItem['value'], 67580.0);
    });
  });
}
