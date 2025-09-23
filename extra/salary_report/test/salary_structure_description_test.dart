import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/visualization/report/enhanced_monthly_report_generator.dart';

void main() {
  group('Salary Structure Description Tests', () {
    test(
      'EnhancedMonthlyReportGenerator should generate salary structure description correctly',
      () {
        // Arrange
        final generator = EnhancedMonthlyReportGenerator();

        // 模拟薪资结构数据
        final salaryStructureData = [
          {'category': '基本工资', 'value': 67580.0},
          {'category': '岗位工资', 'value': 44564.0},
          {'category': '绩效工资', 'value': 46314.0},
          {'category': '补贴工资', 'value': 27350.0},
          {'category': '税前工资', 'value': 175542.90},
          {'category': '个人养老', 'value': 10888.64},
          {'category': '个人医疗', 'value': 2984.66},
          {'category': '个人失业', 'value': 1008.80},
          {'category': '个人公积金', 'value': 7073.0},
          {'category': '当月个人所得税', 'value': 2503.79},
          {'category': '税后应实发', 'value': 173039.11},
        ];

        // Act
        final result = generator.generateSalaryStructureDescription(
          salaryStructureData,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result, contains('薪资结构分析如下'));
        expect(result, contains('基本工资为67580.00元'));
        expect(result, contains('岗位工资为44564.00元'));
        expect(result, contains('绩效工资为46314.00元'));
        expect(result, contains('税后应实发为173039.11元'));
      },
    );

    test(
      'EnhancedMonthlyReportGenerator should handle empty salary structure data',
      () {
        // Arrange
        final generator = EnhancedMonthlyReportGenerator();

        // Act
        final result = generator.generateSalaryStructureDescription([]);

        // Assert
        expect(result, equals('暂无薪资结构数据。'));
      },
    );
  });
}
