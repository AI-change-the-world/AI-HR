import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/utils/monthly_analysis_json_converter.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';
import 'package:salary_report/src/isar/salary_list.dart';

void main() {
  group('MonthlyAnalysisJsonConverter Tests', () {
    test(
      'generateDepartmentChartDataSet should convert department stats to chart data',
      () {
        // Arrange
        final departmentStats = [
          DepartmentSalaryStats(
            department: '技术部',
            employeeCount: 10,
            averageNetSalary: 10000.0,
            totalNetSalary: 100000.0,
            year: 2023,
            month: 10,
          ),
          DepartmentSalaryStats(
            department: '销售部',
            employeeCount: 5,
            averageNetSalary: 8000.0,
            totalNetSalary: 40000.0,
            year: 2023,
            month: 10,
          ),
        ];

        // Act
        final result =
            MonthlyAnalysisJsonConverter.generateDepartmentChartDataSet(
              departmentStats,
            );

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, 2);
        expect(result[0]['department'], '技术部');
        expect(result[0]['employee_count'], 10);
        expect(result[0]['average_salary'], 10000.0);
        expect(result[0]['total_salary'], 100000.0);
      },
    );

    test(
      'generateSalaryRangeChartDataSet should convert salary ranges to chart data',
      () {
        // Arrange
        final salaryRanges = [
          SalaryRangeStats(
            range: '5000-8000',
            employeeCount: 5,
            totalSalary: 30000.0,
            averageSalary: 6000.0,
            year: 2023,
            month: 10,
          ),
          SalaryRangeStats(
            range: '8000-12000',
            employeeCount: 10,
            totalSalary: 100000.0,
            averageSalary: 10000.0,
            year: 2023,
            month: 10,
          ),
        ];

        // Act
        final result =
            MonthlyAnalysisJsonConverter.generateSalaryRangeChartDataSet(
              salaryRanges,
            );

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, 2);
        expect(result[0]['range'], '5000-8000');
        expect(result[0]['count'], 5);
        expect(result[0]['total'], 30000.0);
      },
    );

    test(
      'generateTopEmployeesChartDataSet should convert top employees to chart data',
      () {
        // Arrange
        final record1 = SalaryListRecord()
          ..name = '张三'
          ..netSalary = '12000.00';
        final record2 = SalaryListRecord()
          ..name = '李四'
          ..netSalary = '10000.00';
        final topEmployees = [record1, record2];

        // Act
        final result =
            MonthlyAnalysisJsonConverter.generateTopEmployeesChartDataSet(
              topEmployees,
            );

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, 2);
        expect(result[0]['name'], '张三');
        expect(result[0]['net_salary'], 12000.0);
      },
    );

    test(
      'generateAttendanceChartDataSet should convert attendance stats to chart data',
      () {
        // Arrange
        final attendanceStats = [
          AttendanceStats(
            name: '张三',
            department: '技术部',
            sickLeaveDays: 1.0,
            leaveDays: 2.0,
            absenceCount: 0,
            truancyDays: 0,
            year: 2023,
            month: 10,
          ),
          AttendanceStats(
            name: '李四',
            department: '销售部',
            sickLeaveDays: 0.0,
            leaveDays: 1.0,
            absenceCount: 1,
            truancyDays: 0,
            year: 2023,
            month: 10,
          ),
        ];

        // Act
        final result =
            MonthlyAnalysisJsonConverter.generateAttendanceChartDataSet(
              attendanceStats,
            );

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, 2);
        expect(result[0]['name'], '张三');
        expect(result[0]['sick_leave_days'], 1.0);
        expect(result[0]['leave_days'], 2.0);
        expect(result[0]['absence_count'], 0);
        expect(result[0]['truancy_days'], 0);
      },
    );
  });
}
