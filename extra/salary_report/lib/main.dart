import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/pages/main_layout.dart';
import 'package:salary_report/src/pages/salary_management/upload/upload_page.dart';
import 'package:salary_report/src/pages/salary_management/detail/salary_detail_page.dart';
import 'package:salary_report/src/pages/data_analysis/dimension/analysis_dimension_page.dart';
import 'package:salary_report/src/pages/data_analysis/monthly/monthly_analysis_page.dart';
import 'package:salary_report/src/pages/data_analysis/yearly/yearly_analysis_page.dart';
import 'package:salary_report/src/pages/data_analysis/quarterly/quarterly_analysis_page.dart';
import 'package:salary_report/src/pages/visualization/chart/chart_page.dart';
import 'package:salary_report/src/pages/visualization/report/report_page.dart';
import 'package:salary_report/src/pages/visualization/report/comprehensive_report_page.dart';
import 'package:salary_report/src/pages/report_management_page.dart';
import 'package:salary_report/src/pages/settings/user/user_settings_page.dart';
import 'package:salary_report/src/rust/frb_generated.dart';
import 'package:toastification/toastification.dart';
import 'package:logging/logging.dart';
import 'package:salary_report/src/isar/data_analysis_service.dart';
import 'package:salary_report/src/common/ai_config.dart';

Future<void> main() async {
  await RustLib.init();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
  IsarDatabase database = IsarDatabase();
  await database.initialDatabase();

  // 初始化AI配置
  await AIConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const UploadPage()),
            GoRoute(
              path: '/salary',
              builder: (context, state) => const UploadPage(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) => SalaryDetailPage(
                    reportId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/analysis',
              builder: (context, state) => const AnalysisDimensionPage(),
              routes: [
                GoRoute(
                  path: 'monthly',
                  builder: (context, state) {
                    final year = int.parse(
                      state.uri.queryParameters['year'] ?? '2023',
                    );
                    final month = int.parse(
                      state.uri.queryParameters['month'] ?? '8',
                    );
                    // 获取传递的额外数据
                    final extra = state.extra as Map<String, dynamic>?;

                    return MonthlyAnalysisPage(
                      year: year,
                      month: month,
                      departmentStats:
                          extra?['departmentStats']
                              as List<DepartmentSalaryStats>? ??
                          [],
                      attendanceStats:
                          extra?['attendanceStats'] as List<AttendanceStats>? ??
                          [],
                      leaveRatioStats:
                          extra?['leaveRatioStats'] as LeaveRatioStats?,
                      isMultiMonth: extra?['isMultiMonth'] as bool? ?? false,
                    );
                  },
                ),
                GoRoute(
                  path: 'yearly',
                  builder: (context, state) {
                    final year = int.parse(
                      state.uri.queryParameters['year'] ?? '2023',
                    );
                    final endYear = state.uri.queryParameters['endYear'] != null
                        ? int.parse(state.uri.queryParameters['endYear']!)
                        : null;
                    // 获取传递的额外数据
                    final extra = state.extra as Map<String, dynamic>?;

                    return YearlyAnalysisPage(
                      year: year,
                      departmentStats:
                          extra?['departmentStats']
                              as List<DepartmentSalaryStats>? ??
                          [],
                      attendanceStats:
                          extra?['attendanceStats'] as List<AttendanceStats>? ??
                          [],
                      leaveRatioStats:
                          extra?['leaveRatioStats'] as LeaveRatioStats?,
                      isMultiYear: extra?['isMultiYear'] as bool? ?? false,
                      endYear: endYear,
                    );
                  },
                ),
                GoRoute(
                  path: 'quarterly',
                  builder: (context, state) {
                    final year = int.parse(
                      state.uri.queryParameters['year'] ?? '2023',
                    );
                    final quarter = int.parse(
                      state.uri.queryParameters['quarter'] ?? '3',
                    );
                    final endYear = state.uri.queryParameters['endYear'] != null
                        ? int.parse(state.uri.queryParameters['endYear']!)
                        : null;
                    final endQuarter =
                        state.uri.queryParameters['endQuarter'] != null
                        ? int.parse(state.uri.queryParameters['endQuarter']!)
                        : null;
                    // 获取传递的额外数据
                    final extra = state.extra as Map<String, dynamic>?;

                    return QuarterlyAnalysisPage(
                      year: year,
                      quarter: quarter,
                      departmentStats:
                          extra?['departmentStats']
                              as List<DepartmentSalaryStats>? ??
                          [],
                      attendanceStats:
                          extra?['attendanceStats'] as List<AttendanceStats>? ??
                          [],
                      leaveRatioStats:
                          extra?['leaveRatioStats'] as LeaveRatioStats?,
                      isMultiQuarter:
                          extra?['isMultiQuarter'] as bool? ?? false,
                      endYear: endYear,
                      endQuarter: endQuarter,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/visualization',
              builder: (context, state) => const ComprehensiveReportPage(),
              routes: [
                GoRoute(
                  path: 'report',
                  builder: (context, state) => const ReportPage(),
                ),
                GoRoute(
                  path: 'chart',
                  builder: (context, state) => const ChartPage(),
                ),
                GoRoute(
                  path: 'comprehensive',
                  builder: (context, state) => const ComprehensiveReportPage(),
                ),
              ],
            ),
            GoRoute(
              path: '/report-management',
              builder: (context, state) => const ReportManagementPage(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const UserSettingsPage(),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      child: ToastificationWrapper(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: '员工工资智能化分析系统',
          theme: ThemeData(
            fontFamily: "ph",
            primarySwatch: Colors.lightBlue,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.lightBlue.shade50,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.lightBlue.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}
