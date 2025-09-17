import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_report/src/pages/report_management_page.dart';

void main() {
  testWidgets('ReportManagementPage should build correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: ReportManagementPage()));

    // Verify that the page title is correct
    expect(find.text('报告管理'), findsOneWidget);

    // Verify that the refresh button is present
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    // Verify that the loading indicator is displayed initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
