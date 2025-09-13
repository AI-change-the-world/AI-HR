import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:salary_report/src/pages/main_layout.dart';
import 'package:salary_report/src/pages/salary_management/list/salary_list_page.dart';
import 'package:salary_report/src/pages/salary_management/upload/upload_page.dart';
import 'package:salary_report/src/pages/salary_management/detail/salary_detail_page.dart';
import 'package:salary_report/src/pages/data_analysis/dimension/analysis_dimension_page.dart';
import 'package:salary_report/src/pages/data_analysis/monthly/monthly_analysis_page.dart';
import 'package:salary_report/src/pages/data_analysis/yearly/yearly_analysis_page.dart';
import 'package:salary_report/src/pages/data_analysis/quarterly/quarterly_analysis_page.dart';
import 'package:salary_report/src/pages/visualization/chart/chart_page.dart';
import 'package:salary_report/src/pages/visualization/report/report_page.dart';
import 'package:salary_report/src/pages/settings/user/user_settings_page.dart';
import 'package:salary_report/src/pages/settings/system/system_settings_page.dart';
import 'package:salary_report/src/rust/frb_generated.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  await RustLib.init();
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
            GoRoute(
              path: '/',
              builder: (context, state) => const SalaryListPage(),
            ),
            GoRoute(
              path: '/salary',
              builder: (context, state) => const SalaryListPage(),
              routes: [
                GoRoute(
                  path: 'upload',
                  builder: (context, state) => const UploadPage(),
                ),
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
                    return MonthlyAnalysisPage(year: year, month: month);
                  },
                ),
                GoRoute(
                  path: 'yearly',
                  builder: (context, state) {
                    final year = int.parse(
                      state.uri.queryParameters['year'] ?? '2023',
                    );
                    return YearlyAnalysisPage(year: year);
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
                    return QuarterlyAnalysisPage(year: year, quarter: quarter);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/visualization',
              builder: (context, state) => const ChartPage(),
              routes: [
                GoRoute(
                  path: 'report',
                  builder: (context, state) => const ReportPage(),
                ),
              ],
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const UserSettingsPage(),
              routes: [
                GoRoute(
                  path: 'system',
                  builder: (context, state) => const SystemSettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      child: ToastificationWrapper(
        child: MaterialApp.router(
          title: '员工工资智能化分析系统',
          theme: ThemeData(
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
              shadowColor: Colors.lightBlue.withOpacity(0.1),
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
