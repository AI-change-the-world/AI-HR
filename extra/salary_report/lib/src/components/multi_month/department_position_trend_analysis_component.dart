import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/providers/multi_month_analysis_provider.dart';
import 'package:salary_report/src/providers/multi_month_trend_analysis_provider.dart';
import 'package:salary_report/src/services/global_analysis_models.dart';

// 部门和岗位趋势分析组件
class DepartmentPositionTrendAnalysisComponent extends ConsumerWidget {
  final DateRangeParams params;

  const DepartmentPositionTrendAnalysisComponent({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '注意：以下部门和岗位趋势分析均以选定时间范围的最后一个月为基准进行对比分析',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),

        // 部门环比变化分析
        const Text(
          '部门环比变化分析',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DepartmentMonthOverMonthComponent(params: params),

        const SizedBox(height: 24),

        // 部门同比变化分析
        const Text(
          '部门同比变化分析',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DepartmentYearOverYearComponent(params: params),

        const SizedBox(height: 24),

        // 岗位环比变化分析
        const Text(
          '岗位环比变化分析',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        PositionMonthOverMonthComponent(params: params),

        const SizedBox(height: 24),

        // 岗位同比变化分析
        const Text(
          '岗位同比变化分析',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        PositionYearOverYearComponent(params: params),
      ],
    );
  }
}

// 部门环比变化组件
class DepartmentMonthOverMonthComponent extends ConsumerWidget {
  final DateRangeParams params;

  const DepartmentMonthOverMonthComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAnalysisState = ref.watch(trendAnalysisProvider(params));

    return trendAnalysisState.when(
      data: (data) {
        logger.info('部门环比变化数据: ${data.departmentMonthOverMonthData}');

        if (data.departmentMonthOverMonthData.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('暂无部门环比变化数据'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '部门环比变化分析',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '说明：以选定时间范围的最后一个月为基准，展示各部门与上月相比的员工数量、工资总额、平均工资变化情况',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                DepartmentMonthOverMonthDataTable(
                  data: data.departmentMonthOverMonthData,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('加载数据失败: $error'),
        ),
      ),
    );
  }
}

// 部门同比变化组件
class DepartmentYearOverYearComponent extends ConsumerWidget {
  final DateRangeParams params;

  const DepartmentYearOverYearComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAnalysisState = ref.watch(trendAnalysisProvider(params));

    return trendAnalysisState.when(
      data: (data) {
        if (data.departmentYearOverYearData.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('暂无部门同比变化数据'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '部门同比变化分析',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '说明：以选定时间范围的最后一个月为基准，展示各部门与去年同期相比的员工数量、工资总额、平均工资变化情况',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                DepartmentYearOverYearDataTable(
                  data: data.departmentYearOverYearData,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('加载数据失败: $error'),
        ),
      ),
    );
  }
}

// 岗位环比变化组件
class PositionMonthOverMonthComponent extends ConsumerWidget {
  final DateRangeParams params;

  const PositionMonthOverMonthComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAnalysisState = ref.watch(trendAnalysisProvider(params));

    return trendAnalysisState.when(
      data: (data) {
        if (data.positionMonthOverMonthData.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('暂无岗位环比变化数据'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '岗位环比变化分析',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '说明：以选定时间范围的最后一个月为基准，展示各岗位与上月相比的员工数量、工资总额、平均工资变化情况',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                PositionMonthOverMonthDataTable(
                  data: data.positionMonthOverMonthData,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('加载数据失败: $error'),
        ),
      ),
    );
  }
}

// 岗位同比变化组件
class PositionYearOverYearComponent extends ConsumerWidget {
  final DateRangeParams params;

  const PositionYearOverYearComponent({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAnalysisState = ref.watch(trendAnalysisProvider(params));

    return trendAnalysisState.when(
      data: (data) {
        if (data.positionYearOverYearData.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('暂无岗位同比变化数据'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '岗位同比变化分析',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '说明：以选定时间范围的最后一个月为基准，展示各岗位与去年同期相比的员工数量、工资总额、平均工资变化情况',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                PositionYearOverYearDataTable(
                  data: data.positionYearOverYearData,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('加载数据失败: $error'),
        ),
      ),
    );
  }
}

// 部门环比变化数据表格
class DepartmentMonthOverMonthDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const DepartmentMonthOverMonthDataTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('部门')),
          DataColumn(label: Text('员工数变化')),
          DataColumn(label: Text('员工数变化率')),
          DataColumn(label: Text('工资总额变化')),
          DataColumn(label: Text('工资总额变化率')),
          DataColumn(label: Text('平均工资变化')),
          DataColumn(label: Text('平均工资变化率')),
        ],
        rows: data.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item['department'] as String)),
              DataCell(
                Text(
                  '${item['employee_count_change'] > 0 ? '+' : ''}${item['employee_count_change']}',
                  style: TextStyle(
                    color: item['employee_count_change'] > 0
                        ? Colors.green
                        : (item['employee_count_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['employee_count_change_percent'] > 0 ? '+' : ''}${item['employee_count_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['employee_count_change_percent'] > 0
                        ? Colors.green
                        : (item['employee_count_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['total_salary_change'] > 0 ? '+' : ''}${item['total_salary_change'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item['total_salary_change'] > 0
                        ? Colors.green
                        : (item['total_salary_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['total_salary_change_percent'] > 0 ? '+' : ''}${item['total_salary_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['total_salary_change_percent'] > 0
                        ? Colors.green
                        : (item['total_salary_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['average_salary_change'] > 0 ? '+' : ''}${item['average_salary_change'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item['average_salary_change'] > 0
                        ? Colors.green
                        : (item['average_salary_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['average_salary_change_percent'] > 0 ? '+' : ''}${item['average_salary_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['average_salary_change_percent'] > 0
                        ? Colors.green
                        : (item['average_salary_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// 部门同比变化数据表格
class DepartmentYearOverYearDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const DepartmentYearOverYearDataTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('部门')),
          DataColumn(label: Text('员工数变化')),
          DataColumn(label: Text('员工数变化率')),
          DataColumn(label: Text('工资总额变化')),
          DataColumn(label: Text('工资总额变化率')),
          DataColumn(label: Text('平均工资变化')),
          DataColumn(label: Text('平均工资变化率')),
        ],
        rows: data.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item['department'] as String)),
              DataCell(
                Text(
                  '${item['employee_count_change'] > 0 ? '+' : ''}${item['employee_count_change']}',
                  style: TextStyle(
                    color: item['employee_count_change'] > 0
                        ? Colors.green
                        : (item['employee_count_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['employee_count_change_percent'] > 0 ? '+' : ''}${item['employee_count_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['employee_count_change_percent'] > 0
                        ? Colors.green
                        : (item['employee_count_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['total_salary_change'] > 0 ? '+' : ''}${item['total_salary_change'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item['total_salary_change'] > 0
                        ? Colors.green
                        : (item['total_salary_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['total_salary_change_percent'] > 0 ? '+' : ''}${item['total_salary_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['total_salary_change_percent'] > 0
                        ? Colors.green
                        : (item['total_salary_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['average_salary_change'] > 0 ? '+' : ''}${item['average_salary_change'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item['average_salary_change'] > 0
                        ? Colors.green
                        : (item['average_salary_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['average_salary_change_percent'] > 0 ? '+' : ''}${item['average_salary_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['average_salary_change_percent'] > 0
                        ? Colors.green
                        : (item['average_salary_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// 岗位环比变化数据表格
class PositionMonthOverMonthDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const PositionMonthOverMonthDataTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('岗位')),
          DataColumn(label: Text('员工数变化')),
          DataColumn(label: Text('员工数变化率')),
          DataColumn(label: Text('工资总额变化')),
          DataColumn(label: Text('工资总额变化率')),
          DataColumn(label: Text('平均工资变化')),
          DataColumn(label: Text('平均工资变化率')),
        ],
        rows: data.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item['position'] as String)),
              DataCell(
                Text(
                  '${item['employee_count_change'] > 0 ? '+' : ''}${item['employee_count_change']}',
                  style: TextStyle(
                    color: item['employee_count_change'] > 0
                        ? Colors.green
                        : (item['employee_count_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['employee_count_change_percent'] > 0 ? '+' : ''}${item['employee_count_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['employee_count_change_percent'] > 0
                        ? Colors.green
                        : (item['employee_count_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['total_salary_change'] > 0 ? '+' : ''}${item['total_salary_change'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item['total_salary_change'] > 0
                        ? Colors.green
                        : (item['total_salary_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['total_salary_change_percent'] > 0 ? '+' : ''}${item['total_salary_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['total_salary_change_percent'] > 0
                        ? Colors.green
                        : (item['total_salary_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['average_salary_change'] > 0 ? '+' : ''}${item['average_salary_change'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item['average_salary_change'] > 0
                        ? Colors.green
                        : (item['average_salary_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['average_salary_change_percent'] > 0 ? '+' : ''}${item['average_salary_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['average_salary_change_percent'] > 0
                        ? Colors.green
                        : (item['average_salary_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// 岗位同比变化数据表格
class PositionYearOverYearDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const PositionYearOverYearDataTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('岗位')),
          DataColumn(label: Text('员工数变化')),
          DataColumn(label: Text('员工数变化率')),
          DataColumn(label: Text('工资总额变化')),
          DataColumn(label: Text('工资总额变化率')),
          DataColumn(label: Text('平均工资变化')),
          DataColumn(label: Text('平均工资变化率')),
        ],
        rows: data.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item['position'] as String)),
              DataCell(
                Text(
                  '${item['employee_count_change'] > 0 ? '+' : ''}${item['employee_count_change']}',
                  style: TextStyle(
                    color: item['employee_count_change'] > 0
                        ? Colors.green
                        : (item['employee_count_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['employee_count_change_percent'] > 0 ? '+' : ''}${item['employee_count_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['employee_count_change_percent'] > 0
                        ? Colors.green
                        : (item['employee_count_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['total_salary_change'] > 0 ? '+' : ''}${item['total_salary_change'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item['total_salary_change'] > 0
                        ? Colors.green
                        : (item['total_salary_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['total_salary_change_percent'] > 0 ? '+' : ''}${item['total_salary_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['total_salary_change_percent'] > 0
                        ? Colors.green
                        : (item['total_salary_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['average_salary_change'] > 0 ? '+' : ''}${item['average_salary_change'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item['average_salary_change'] > 0
                        ? Colors.green
                        : (item['average_salary_change'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${item['average_salary_change_percent'] > 0 ? '+' : ''}${item['average_salary_change_percent'].toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: item['average_salary_change_percent'] > 0
                        ? Colors.green
                        : (item['average_salary_change_percent'] < 0
                              ? Colors.red
                              : Colors.black),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
