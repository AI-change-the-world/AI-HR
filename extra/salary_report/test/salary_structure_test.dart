import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_monthly_report_generator.dart';

void main() {
  group('Salary Structure Tests', () {
    test(
      'EnhancedMonthlyReportGenerator should extract salary structure data correctly',
      () {
        // Arrange
        final generator = EnhancedMonthlyReportGenerator();

        // 模拟 salarySummary 数据
        final salarySummary = {
          '绩效工资': 46314.0,
          '公积金基数': 67580.0,
          '补贴工资': 27350.0,
          '税后增减': 0.0,
          '基本工资': 67580.0,
          '个人养老': 10888.64,
          '社保基数': 132083.0,
          '当月基本工资': 67580.0,
          '岗位工资': 44564.0,
          '其他增减': 0.0,
          '病假（天）': 0.0,
          '个人失业': 1008.80,
          '当月绩效工资': 46314.0,
          '饭补': 11690.0,
          '个人公积金': 7073.0,
          '税后应实发': 173039.11,
          '当月补贴工资': 27350.0,
          '电脑补贴等': 0.0,
          'social_security_tax': 21955.10,
          '当月计薪工资': 197498.0,
          '旷工（天）': 0.0,
          '当月岗位工资': 44564.0,
          '事假（小时）': 0.0,
          '缺勤（次）': 0.0,
          '个人医疗': 2984.66,
          '税前工资': 175542.90,
          '离职补偿金': 0.0,
          '当月个人所得税': 2503.79,
          '综合薪资标准': 185808.0,
        };

        // Act
        final result = generator.createSalaryStructureData(salarySummary);

        // Assert
        expect(result, isNotEmpty);

        // 验证是否包含我们关心的薪资结构字段
        final categories = result.map((item) => item['category']).toList();

        expect(categories, contains('基本工资'));
        expect(categories, contains('岗位工资'));
        expect(categories, contains('绩效工资'));
        expect(categories, contains('补贴工资'));
        expect(categories, contains('饭补'));
        expect(categories, contains('电脑补贴等'));
        expect(categories, contains('税前工资'));
        expect(categories, contains('个人养老'));
        expect(categories, contains('个人医疗'));
        expect(categories, contains('个人失业'));
        expect(categories, contains('个人公积金'));
        expect(categories, contains('当月个人所得税'));
        expect(categories, contains('税后应实发'));

        // 验证值是否正确
        final basicSalaryItem = result.firstWhere(
          (item) => item['category'] == '基本工资',
        );
        expect(basicSalaryItem['value'], 67580.0);

        final performanceSalaryItem = result.firstWhere(
          (item) => item['category'] == '绩效工资',
        );
        expect(performanceSalaryItem['value'], 46314.0);
      },
    );

    test('EnhancedMonthlyReportGenerator should handle null salarySummary', () {
      // Arrange
      final generator = EnhancedMonthlyReportGenerator();

      // Act
      final result = generator.createSalaryStructureData(null);

      // Assert
      expect(result, isEmpty);
    });

    test(
      'EnhancedMonthlyReportGenerator should handle empty salarySummary',
      () {
        // Arrange
        final generator = EnhancedMonthlyReportGenerator();

        // Act
        final result = generator.createSalaryStructureData({});

        // Assert
        expect(result, isEmpty);
      },
    );
  });
}
