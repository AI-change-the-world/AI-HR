import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/services/docx_writer_service.dart';
import 'package:salary_report/src/pages/visualization/report/report_content_model.dart';

ReportContentModel _createMockReportContentModel() {
  return ReportContentModel(
    reportTitle: 'Test Report',
    reportDate: '2025-01-01',
    companyName: 'Test Company',
    reportTime: '2025年1月',
    startTime: '2025-01-01',
    endTime: '2025-01-31',
    compareLast: '', // 添加compareLast参数
    totalEmployees: 100,
    totalSalary: 1000000.0,
    averageSalary: 10000.0,
    departmentCount: 5,
    employeeCount: 100,
    employeeDetails: 'Employee details',
    departmentDetails: 'Department details',
    salaryRangeDescription: 'Salary range description',
    salaryRangeFeatureSummary: 'Salary range feature summary',
    departmentSalaryAnalysis: 'Department salary analysis',
    keySalaryPoint: 'Key salary point',
    salaryRankings: 'Salary rankings',
    basicSalaryRate: 0.7,
    performanceSalaryRate: 0.3,
    salaryStructure: 'Salary structure',
    salaryStructureAdvice: 'Salary structure advice', // 添加薪资结构建议字段
    salaryStructureData: [],
    departmentStats: [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocxWriterService Tests', () {
    late DocxWriterService docxWriterService;

    setUp(() {
      docxWriterService = DocxWriterService();
    });

    test('DocxWriterService should be instantiated correctly', () {
      expect(docxWriterService, isA<DocxWriterService>());
    });

    test('DocxWriterService should have writeReport method', () {
      expect(docxWriterService.writeReport, isA<Function>());
    });

    // Note: We're not testing the actual template loading in unit tests
    // because it requires asset loading which is not available in tests
  });
}
