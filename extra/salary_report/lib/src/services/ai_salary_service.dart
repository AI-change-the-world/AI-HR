import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:salary_report/src/common/llm_client.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/services/data_analysis_service.dart';
import 'package:salary_report/src/isar/salary_list.dart';
import 'package:isar_community/isar.dart';

class AISalaryService {
  final DataAnalysisService _queryService;
  final IsarDatabase _database;
  final LLMClient _llmClient;

  AISalaryService(IsarDatabase database)
    : _queryService = DataAnalysisService(database),
      _database = database,
      _llmClient = LLMClient();

  /// 处理用户查询请求
  Future<String> processUserQuery(String userQuery) async {
    // 1. 使用LLM识别用户意图
    final intentResult = await _recognizeIntent(userQuery);

    logger.info('Intent: $intentResult');

    // 2. 解析意图识别结果
    final intent = intentResult['intent'] as String;
    final parameters = Map<String, dynamic>.from(intentResult['parameters']);

    // 3. 根据意图执行相应的查询
    switch (intent) {
      case 'employee_salary':
        return await _handleEmployeeSalaryQuery(parameters);
      case 'department_salary':
        return await _handleDepartmentSalaryQuery(parameters);
      case 'top_salary':
        return await _handleTopSalaryQuery(parameters);
      case 'bottom_salary':
        return await _handleBottomSalaryQuery(parameters);
      case 'employee_attendance':
        return await _handleEmployeeAttendanceQuery(parameters);
      case 'average_salary':
        return await _handleAverageSalaryQuery(parameters);
      case 'total_salary':
        return await _handleTotalSalaryQuery(parameters);
      case 'department_average':
        return await _handleDepartmentAverageQuery(parameters);
      default:
        return '抱歉，我无法理解您的查询请求。请尝试重新表述您的问题。';
    }
  }

  // 构建提示词
  final prompt = '''
你是一个薪资报表查询助手，你的任务是理解用户的问题并将其分类到相应的查询意图中。

数据结构说明：
1. SalaryList: 包含某年某月的所有员工薪资记录
   - year: 年份
   - month: 月份
   - records: 员工薪资记录列表
   - total: 总记录数字符串

2. SalaryListRecord: 单个员工的薪资记录
   - name: 员工姓名
   - department: 部门
   - position: 职位
   - attendance: 出勤情况
   - netSalary: 实发工资
   - payDays: 计薪日天数
   - actualPayDays: 实际出勤折算天数
   - sickLeave: 病假天数
   - leave: 事假天数
   - absence: 缺勤次数
   - truancy: 旷工天数
   - performanceScore: 绩效得分

可用的查询意图包括：

1. "employee_salary": 查询某年某月某员工的工资详情
   - 关键词: 工资, 薪资, 员工, 姓名
   - 示例: "查询2023年10月张三的工资", "2023年10月李四薪资多少"

2. "department_salary": 查询某年某月某部门的工资详情
   - 关键词: 部门, 工资, 薪资
   - 示例: "查询2023年10月技术部的工资情况", "2023年10月销售部薪资"

3. "top_salary": 查询某年某月工资最高的前N名员工
   - 关键词: 最高, 前几名, 排名, 工资最多
   - 示例: "2023年10月工资最高的前5名", "工资排名前10的员工"

4. "bottom_salary": 查询某年某月工资最低的前N名员工
   - 关键词: 最低, 最少, 工资最少
   - 示例: "2023年10月工资最低的员工", "薪资最少的前5名"

5. "employee_attendance": 查询某年某月某员工的考勤情况
   - 关键词: 考勤, 出勤, 病假, 事假, 旷工, 缺勤
   - 示例: "查询2023年10月张三的考勤情况", "李四的出勤记录"

6. "average_salary": 查询某年某月所有员工的平均工资
   - 关键词: 平均, 平均工资, 人均薪资
   - 示例: "2023年10月的平均工资是多少", "查询人均薪资"

7. "total_salary": 查询某年某月所有员工的工资总和
   - 关键词: 总和, 总计, 工资总额
   - 示例: "2023年10月工资总和", "薪资总额是多少"

8. "department_average": 查询某年某月各部门的平均工资
   - 关键词: 部门, 平均, 工资对比
   - 示例: "各部门平均工资对比", "2023年10月各部门薪资情况"

请根据用户的问题，识别出对应的查询意图，并提取相关的参数：
- 年份(year): 四位数字年份
- 月份(month): 1-12的数字
- 员工姓名(employeeName): 员工的姓名
- 部门(department): 部门名称
- 数量(limit): 前N名中的N值，默认为10

用户问题: {{question}}

请以以下JSON格式输出结果:
{
  "intent": "查询意图",
  "parameters": {
    "year": 年份,
    "month": 月份,
    "employeeName": "员工姓名",
    "department": "部门名称",
    "limit": 数量
  }
}
''';

  /// 识别用户意图
  Future<Map<String, dynamic>> _recognizeIntent(String userQuery) async {
    try {
      final p = prompt.replaceFirst("{{question}}", userQuery);

      final result = await _llmClient.getAnswer(
        p,
        format: ResponseFormat.jsonObject(),
      );

      logger.info('LLM Result: $result');

      // 解析JSON结果
      final jsonStart = result.indexOf('{');
      final jsonEnd = result.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = result.substring(jsonStart, jsonEnd + 1);
        final parsedResult = jsonDecode(jsonString) as Map<String, dynamic>;
        return parsedResult;
      }
    } catch (e) {
      // 如果解析失败，返回默认值
      return {'intent': 'unknown', 'parameters': {}};
    }

    // 默认返回值
    return {'intent': 'unknown', 'parameters': {}};
  }

  /// 处理员工工资查询
  Future<String> _handleEmployeeSalaryQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = int.tryParse(parameters['year'].toString());
    final month = int.tryParse(parameters['month'].toString());
    final employeeName = parameters['employeeName'] as String?;

    // 如果没有提供员工姓名，无法进行查询
    if (employeeName == null) {
      return '请提供员工姓名进行查询。';
    }

    // 如果提供了年份但没有提供月份，查询该年份的所有记录
    if (year != null && month == null) {
      return await _searchEmployeeSalaryByYear(year, employeeName);
    }

    // 如果提供了月份但没有提供年份，查询所有年份中该月份的记录
    if (year == null && month != null) {
      return await _searchEmployeeSalaryByMonth(month, employeeName);
    }

    // 如果既没有提供年份也没有提供月份，查询所有记录中该员工的信息
    if (year == null && month == null) {
      return await _searchEmployeeSalaryAll(employeeName);
    }

    // 如果提供了完整的年份和月份，按原逻辑查询
    final record = await _queryService.getEmployeeSalaryByYearMonth(
      year: year!,
      month: month!,
      employeeName: employeeName,
    );

    if (record == null) {
      return '未找到 $year 年 $month 月员工 $employeeName 的工资记录。';
    }

    return '员工 $employeeName 在 $year 年 $month 月的工资详情：\n'
        '部门: ${record.department ?? "未知"}\n'
        '职位: ${record.position ?? "未知"}\n'
        '实发工资: ${record.netSalary ?? "未知"}\n'
        '出勤情况: ${record.attendance ?? "未知"}\n'
        '计薪日天数: ${record.payDays ?? "未知"}\n'
        '实际出勤折算天数: ${record.actualPayDays ?? "未知"}\n'
        '病假天数: ${record.sickLeave ?? "未知"}\n'
        '事假小时数: ${record.personalLeave ?? "未知"}\n'
        '缺勤次数: ${record.absence ?? "未知"}\n'
        '旷工天数: ${record.truancy ?? "未知"}\n'
        '绩效得分: ${record.performanceScore ?? "未知"}';
  }

  /// 查询某年所有月份中某员工的工资记录
  Future<String> _searchEmployeeSalaryByYear(
    int year,
    String employeeName,
  ) async {
    final isar = _database.isar!;

    // 查询指定年份的所有工资数据
    final salaryLists = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $year 年的工资记录。';
    }

    final List<String> results = [];

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          results.add(
            '$year 年 ${salaryList.month} 月: ${record.netSalary ?? "未知工资"}',
          );
        }
      }
    }

    if (results.isEmpty) {
      return '未找到 $year 年员工 $employeeName 的工资记录。';
    }

    return '员工 $employeeName 在 $year 年的工资记录：\n${results.join('\n')}';
  }

  /// 查询所有年份中某月份某员工的工资记录
  Future<String> _searchEmployeeSalaryByMonth(
    int month,
    String employeeName,
  ) async {
    final isar = _database.isar!;

    // 查询所有工资数据，然后过滤月份
    final salaryLists = await isar.salaryLists
        .filter()
        .monthEqualTo(month)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $month 月的工资记录。';
    }

    final List<String> results = [];

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          results.add(
            '${salaryList.year} 年 $month 月: ${record.netSalary ?? "未知工资"}',
          );
        }
      }
    }

    if (results.isEmpty) {
      return '未找到 $month 月员工 $employeeName 的工资记录。';
    }

    return '员工 $employeeName 在所有年份 $month 月的工资记录：\n${results.join('\n')}';
  }

  /// 查询所有记录中某员工的工资信息
  Future<String> _searchEmployeeSalaryAll(String employeeName) async {
    final isar = _database.isar!;

    // 查询所有工资数据
    final salaryLists = await isar.salaryLists.where().findAll();

    if (salaryLists.isEmpty) {
      return '未找到任何工资记录。';
    }

    final List<String> results = [];

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          results.add(
            '${salaryList.year} 年 ${salaryList.month} 月: ${record.netSalary ?? "未知工资"}',
          );
        }
      }
    }

    if (results.isEmpty) {
      return '未找到员工 $employeeName 的任何工资记录。';
    }

    return '员工 $employeeName 在所有时间的工资记录：\n${results.join('\n')}';
  }

  /// 处理部门工资查询
  Future<String> _handleDepartmentSalaryQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;
    final department = parameters['department'] as String?;

    // 如果没有提供部门名称，无法进行查询
    if (department == null) {
      return '请提供部门名称进行查询。';
    }

    // 如果提供了年份但没有提供月份，查询该年份的所有记录
    if (year != null && month == null) {
      return await _searchDepartmentSalaryByYear(year, department);
    }

    // 如果提供了月份但没有提供年份，查询所有年份中该月份的记录
    if (year == null && month != null) {
      return await _searchDepartmentSalaryByMonth(month, department);
    }

    // 如果既没有提供年份也没有提供月份，查询所有记录中该部门的信息
    if (year == null && month == null) {
      return await _searchDepartmentSalaryAll(department);
    }

    // 如果提供了完整的年份和月份，按原逻辑查询
    final records = await _queryService.getDepartmentSalaryByYearMonth(
      year: year!,
      month: month!,
      department: department,
    );

    if (records.isEmpty) {
      return '未找到 $year 年 $month 月 $department 部门的工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('$year 年 $month 月 $department 部门工资详情：');
    buffer.writeln('共有 ${records.length} 名员工');

    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      buffer.writeln(
        '${i + 1}. ${record.name ?? "未知员工"}: ${record.netSalary ?? "未知工资"}',
      );
    }

    return buffer.toString();
  }

  /// 查询某年所有月份中某部门的工资记录
  Future<String> _searchDepartmentSalaryByYear(
    int year,
    String department,
  ) async {
    final isar = _database.isar!;

    // 查询指定年份的所有工资数据
    final salaryLists = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $year 年的工资记录。';
    }

    final Map<int, List<SalaryListRecord>> results = {};

    for (var salaryList in salaryLists) {
      final List<SalaryListRecord> deptRecords = [];
      for (var record in salaryList.records) {
        if (record.department == department) {
          deptRecords.add(record);
        }
      }
      if (deptRecords.isNotEmpty) {
        results[salaryList.month] = deptRecords;
      }
    }

    if (results.isEmpty) {
      return '未找到 $year 年 $department 部门的工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('$year 年 $department 部门各月份工资记录：');

    results.forEach((month, records) {
      buffer.writeln('$month 月: ${records.length} 名员工');
      for (int i = 0; i < records.length && i < 3; i++) {
        final record = records[i];
        buffer.writeln(
          '  ${record.name ?? "未知员工"}: ${record.netSalary ?? "未知工资"}',
        );
      }
      if (records.length > 3) {
        buffer.writeln('  ... 还有 ${records.length - 3} 名员工');
      }
    });

    return buffer.toString();
  }

  /// 查询所有年份中某月份某部门的工资记录
  Future<String> _searchDepartmentSalaryByMonth(
    int month,
    String department,
  ) async {
    final isar = _database.isar!;

    // 查询所有工资数据，然后过滤月份
    final salaryLists = await isar.salaryLists
        .filter()
        .monthEqualTo(month)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $month 月的工资记录。';
    }

    final Map<int, List<SalaryListRecord>> results = {};

    for (var salaryList in salaryLists) {
      final List<SalaryListRecord> deptRecords = [];
      for (var record in salaryList.records) {
        if (record.department == department) {
          deptRecords.add(record);
        }
      }
      if (deptRecords.isNotEmpty) {
        results[salaryList.year] = deptRecords;
      }
    }

    if (results.isEmpty) {
      return '未找到 $month 月 $department 部门的工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('所有年份 $month 月 $department 部门工资记录：');

    results.forEach((year, records) {
      buffer.writeln('$year 年: ${records.length} 名员工');
      for (int i = 0; i < records.length && i < 3; i++) {
        final record = records[i];
        buffer.writeln(
          '  ${record.name ?? "未知员工"}: ${record.netSalary ?? "未知工资"}',
        );
      }
      if (records.length > 3) {
        buffer.writeln('  ... 还有 ${records.length - 3} 名员工');
      }
    });

    return buffer.toString();
  }

  /// 查询所有记录中某部门的工资信息
  Future<String> _searchDepartmentSalaryAll(String department) async {
    final isar = _database.isar!;

    // 查询所有工资数据
    final salaryLists = await isar.salaryLists.where().findAll();

    if (salaryLists.isEmpty) {
      return '未找到任何工资记录。';
    }

    final Map<String, List<SalaryListRecord>> results = {};

    for (var salaryList in salaryLists) {
      final List<SalaryListRecord> deptRecords = [];
      for (var record in salaryList.records) {
        if (record.department == department) {
          deptRecords.add(record);
        }
      }
      if (deptRecords.isNotEmpty) {
        results['${salaryList.year}年${salaryList.month}月'] = deptRecords;
      }
    }

    if (results.isEmpty) {
      return '未找到 $department 部门的任何工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('$department 部门在所有时间的工资记录：');

    results.forEach((period, records) {
      buffer.writeln('$period: ${records.length} 名员工');
      for (int i = 0; i < records.length && i < 3; i++) {
        final record = records[i];
        buffer.writeln(
          '  ${record.name ?? "未知员工"}: ${record.netSalary ?? "未知工资"}',
        );
      }
      if (records.length > 3) {
        buffer.writeln('  ... 还有 ${records.length - 3} 名员工');
      }
    });

    return buffer.toString();
  }

  /// 处理最高工资查询
  Future<String> _handleTopSalaryQuery(Map<String, dynamic> parameters) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;
    final limit = parameters['limit'] as int? ?? 10;

    // 如果提供了年份但没有提供月份，查询该年份的所有记录
    if (year != null && month == null) {
      return await _searchTopSalaryByYear(year, limit);
    }

    // 如果提供了月份但没有提供年份，查询所有年份中该月份的记录
    if (year == null && month != null) {
      return await _searchTopSalaryByMonth(month, limit);
    }

    // 如果既没有提供年份也没有提供月份，查询所有记录
    if (year == null && month == null) {
      return await _searchTopSalaryAll(limit);
    }

    // 如果提供了完整的年份和月份，按原逻辑查询
    final records = await _queryService.getTopSalaryEmployees(
      year: year!,
      month: month!,
      limit: limit,
    );

    if (records.isEmpty) {
      return '未找到 $year 年 $month 月的工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('$year 年 $month 月工资排名前 ${records.length} 名员工：');

    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      buffer.writeln(
        '${i + 1}. ${record.name ?? "未知员工"}: ${record.netSalary ?? "未知工资"}',
      );
    }

    return buffer.toString();
  }

  /// 查询某年所有月份中工资最高的员工
  Future<String> _searchTopSalaryByYear(int year, int limit) async {
    final isar = _database.isar!;

    // 查询指定年份的所有工资数据
    final salaryLists = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $year 年的工资记录。';
    }

    // 收集所有记录
    final List<SalaryListRecord> allRecords = [];
    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name != null && record.netSalary != null) {
          allRecords.add(record);
        }
      }
    }

    if (allRecords.isEmpty) {
      return '未找到 $year 年的有效工资记录。';
    }

    // 按工资排序
    allRecords.sort((a, b) {
      final salaryA =
          double.tryParse(a.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      final salaryB =
          double.tryParse(b.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      return salaryB.compareTo(salaryA); // 降序排列
    });

    final topRecords = allRecords.take(limit).toList();

    final buffer = StringBuffer();
    buffer.writeln('$year 年工资排名前 ${topRecords.length} 名员工：');

    for (int i = 0; i < topRecords.length; i++) {
      final record = topRecords[i];
      buffer.writeln(
        '${i + 1}. ${record.name ?? "未知员工"} (${record.department ?? "未知部门"}): ${record.netSalary ?? "未知工资"}',
      );
    }

    return buffer.toString();
  }

  /// 查询所有年份中某月份工资最高的员工
  Future<String> _searchTopSalaryByMonth(int month, int limit) async {
    final isar = _database.isar!;

    // 查询所有工资数据，然后过滤月份
    final salaryLists = await isar.salaryLists
        .filter()
        .monthEqualTo(month)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $month 月的工资记录。';
    }

    // 收集所有记录
    final List<SalaryListRecord> allRecords = [];
    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name != null && record.netSalary != null) {
          allRecords.add(record);
        }
      }
    }

    if (allRecords.isEmpty) {
      return '未找到 $month 月的有效工资记录。';
    }

    // 按工资排序
    allRecords.sort((a, b) {
      final salaryA =
          double.tryParse(a.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      final salaryB =
          double.tryParse(b.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      return salaryB.compareTo(salaryA); // 降序排列
    });

    final topRecords = allRecords.take(limit).toList();

    final buffer = StringBuffer();
    buffer.writeln('所有年份 $month 月工资排名前 ${topRecords.length} 名员工：');

    for (int i = 0; i < topRecords.length; i++) {
      final record = topRecords[i];
      buffer.writeln(
        '${i + 1}. ${record.name ?? "未知员工"} (${record.department ?? "未知部门"}): ${record.netSalary ?? "未知工资"}',
      );
    }

    return buffer.toString();
  }

  /// 查询所有记录中工资最高的员工
  Future<String> _searchTopSalaryAll(int limit) async {
    final isar = _database.isar!;

    // 查询所有工资数据
    final salaryLists = await isar.salaryLists.where().findAll();

    if (salaryLists.isEmpty) {
      return '未找到任何工资记录。';
    }

    // 收集所有记录
    final List<SalaryListRecord> allRecords = [];
    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name != null && record.netSalary != null) {
          allRecords.add(record);
        }
      }
    }

    if (allRecords.isEmpty) {
      return '未找到任何有效工资记录。';
    }

    // 按工资排序
    allRecords.sort((a, b) {
      final salaryA =
          double.tryParse(a.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      final salaryB =
          double.tryParse(b.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      return salaryB.compareTo(salaryA); // 降序排列
    });

    final topRecords = allRecords.take(limit).toList();

    final buffer = StringBuffer();
    buffer.writeln('所有时间工资排名前 ${topRecords.length} 名员工：');

    for (int i = 0; i < topRecords.length; i++) {
      final record = topRecords[i];
      buffer.writeln(
        '${i + 1}. ${record.name ?? "未知员工"} (${record.department ?? "未知部门"}): ${record.netSalary ?? "未知工资"}',
      );
    }

    return buffer.toString();
  }

  /// 处理最低工资查询
  Future<String> _handleBottomSalaryQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;
    final limit = parameters['limit'] as int? ?? 10;

    // 如果提供了年份但没有提供月份，查询该年份的所有记录
    if (year != null && month == null) {
      return await _searchBottomSalaryByYear(year, limit);
    }

    // 如果提供了月份但没有提供年份，查询所有年份中该月份的记录
    if (year == null && month != null) {
      return await _searchBottomSalaryByMonth(month, limit);
    }

    // 如果既没有提供年份也没有提供月份，查询所有记录
    if (year == null && month == null) {
      return await _searchBottomSalaryAll(limit);
    }

    // 如果提供了完整的年份和月份，按原逻辑查询
    final records = await _queryService.getBottomSalaryEmployees(
      year: year!,
      month: month!,
      limit: limit,
    );

    if (records.isEmpty) {
      return '未找到 $year 年 $month 月的工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('$year 年 $month 月工资最低的 ${records.length} 名员工：');

    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      buffer.writeln(
        '${i + 1}. ${record.name ?? "未知员工"}: ${record.netSalary ?? "未知工资"}',
      );
    }

    return buffer.toString();
  }

  /// 查询某年所有月份中工资最低的员工
  Future<String> _searchBottomSalaryByYear(int year, int limit) async {
    final isar = _database.isar!;

    // 查询指定年份的所有工资数据
    final salaryLists = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $year 年的工资记录。';
    }

    // 收集所有记录
    final List<SalaryListRecord> allRecords = [];
    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name != null && record.netSalary != null) {
          allRecords.add(record);
        }
      }
    }

    if (allRecords.isEmpty) {
      return '未找到 $year 年的有效工资记录。';
    }

    // 按工资排序
    allRecords.sort((a, b) {
      final salaryA =
          double.tryParse(a.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      final salaryB =
          double.tryParse(b.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      return salaryA.compareTo(salaryB); // 升序排列
    });

    final bottomRecords = allRecords.take(limit).toList();

    final buffer = StringBuffer();
    buffer.writeln('$year 年工资最低的 ${bottomRecords.length} 名员工：');

    for (int i = 0; i < bottomRecords.length; i++) {
      final record = bottomRecords[i];
      buffer.writeln(
        '${i + 1}. ${record.name ?? "未知员工"} (${record.department ?? "未知部门"}): ${record.netSalary ?? "未知工资"}',
      );
    }

    return buffer.toString();
  }

  /// 查询所有年份中某月份工资最低的员工
  Future<String> _searchBottomSalaryByMonth(int month, int limit) async {
    final isar = _database.isar!;

    // 查询所有工资数据，然后过滤月份
    final salaryLists = await isar.salaryLists
        .filter()
        .monthEqualTo(month)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $month 月的工资记录。';
    }

    // 收集所有记录
    final List<SalaryListRecord> allRecords = [];
    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name != null && record.netSalary != null) {
          allRecords.add(record);
        }
      }
    }

    if (allRecords.isEmpty) {
      return '未找到 $month 月的有效工资记录。';
    }

    // 按工资排序
    allRecords.sort((a, b) {
      final salaryA =
          double.tryParse(a.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      final salaryB =
          double.tryParse(b.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      return salaryA.compareTo(salaryB); // 升序排列
    });

    final bottomRecords = allRecords.take(limit).toList();

    final buffer = StringBuffer();
    buffer.writeln('所有年份 $month 月工资最低的 ${bottomRecords.length} 名员工：');

    for (int i = 0; i < bottomRecords.length; i++) {
      final record = bottomRecords[i];
      buffer.writeln(
        '${i + 1}. ${record.name ?? "未知员工"} (${record.department ?? "未知部门"}): ${record.netSalary ?? "未知工资"}',
      );
    }

    return buffer.toString();
  }

  /// 查询所有记录中工资最低的员工
  Future<String> _searchBottomSalaryAll(int limit) async {
    final isar = _database.isar!;

    // 查询所有工资数据
    final salaryLists = await isar.salaryLists.where().findAll();

    if (salaryLists.isEmpty) {
      return '未找到任何工资记录。';
    }

    // 收集所有记录
    final List<SalaryListRecord> allRecords = [];
    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name != null && record.netSalary != null) {
          allRecords.add(record);
        }
      }
    }

    if (allRecords.isEmpty) {
      return '未找到任何有效工资记录。';
    }

    // 按工资排序
    allRecords.sort((a, b) {
      final salaryA =
          double.tryParse(a.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      final salaryB =
          double.tryParse(b.netSalary!.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
      return salaryA.compareTo(salaryB); // 升序排列
    });

    final bottomRecords = allRecords.take(limit).toList();

    final buffer = StringBuffer();
    buffer.writeln('所有时间工资最低的 ${bottomRecords.length} 名员工：');

    for (int i = 0; i < bottomRecords.length; i++) {
      final record = bottomRecords[i];
      buffer.writeln(
        '${i + 1}. ${record.name ?? "未知员工"} (${record.department ?? "未知部门"}): ${record.netSalary ?? "未知工资"}',
      );
    }

    return buffer.toString();
  }

  /// 处理员工考勤查询
  Future<String> _handleEmployeeAttendanceQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;
    final employeeName = parameters['employeeName'] as String?;

    // 如果没有提供员工姓名，无法进行查询
    if (employeeName == null) {
      return '请提供员工姓名进行查询。';
    }

    // 如果提供了年份但没有提供月份，查询该年份的所有记录
    if (year != null && month == null) {
      return await _searchEmployeeAttendanceByYear(year, employeeName);
    }

    // 如果提供了月份但没有提供年份，查询所有年份中该月份的记录
    if (year == null && month != null) {
      return await _searchEmployeeAttendanceByMonth(month, employeeName);
    }

    // 如果既没有提供年份也没有提供月份，查询所有记录中该员工的信息
    if (year == null && month == null) {
      return await _searchEmployeeAttendanceAll(employeeName);
    }

    // 如果提供了完整的年份和月份，按原逻辑查询
    final attendance = await _queryService.getEmployeeAttendance(
      year: year!,
      month: month!,
      employeeName: employeeName,
    );

    if (attendance.isEmpty) {
      return '未找到 $year 年 $month 月员工 $employeeName 的考勤记录。';
    }

    return '员工 $employeeName 在 $year 年 $month 月的考勤情况：\n'
        '出勤情况: ${attendance['attendance'] ?? "未知"}\n'
        '计薪日天数: ${attendance['payDays'] ?? "未知"}\n'
        '实际出勤折算天数: ${attendance['actualPayDays'] ?? "未知"}\n'
        '病假天数: ${attendance['sickLeave'] ?? "未知"}\n'
        '事假天数: ${attendance['leave'] ?? "未知"}\n'
        '缺勤次数: ${attendance['absence'] ?? "未知"}\n'
        '旷工天数: ${attendance['truancy'] ?? "未知"}';
  }

  /// 查询某年所有月份中某员工的考勤记录
  Future<String> _searchEmployeeAttendanceByYear(
    int year,
    String employeeName,
  ) async {
    final isar = _database.isar!;

    // 查询指定年份的所有工资数据
    final salaryLists = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $year 年的考勤记录。';
    }

    final List<String> results = [];

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          results.add(
            '$year 年 ${salaryList.month} 月: '
            '出勤情况=${record.attendance ?? "未知"}, '
            '病假=${record.sickLeave ?? "未知"}, '
            '事假=${record.personalLeave ?? "未知"}',
          );
        }
      }
    }

    if (results.isEmpty) {
      return '未找到 $year 年员工 $employeeName 的考勤记录。';
    }

    return '员工 $employeeName 在 $year 年的考勤记录：\n${results.join('\n')}';
  }

  /// 查询所有年份中某月份某员工的考勤记录
  Future<String> _searchEmployeeAttendanceByMonth(
    int month,
    String employeeName,
  ) async {
    final isar = _database.isar!;

    // 查询所有工资数据，然后过滤月份
    final salaryLists = await isar.salaryLists
        .filter()
        .monthEqualTo(month)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $month 月的考勤记录。';
    }

    final List<String> results = [];

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          results.add(
            '${salaryList.year} 年 $month 月: '
            '出勤情况=${record.attendance ?? "未知"}, '
            '病假=${record.sickLeave ?? "未知"}, '
            '事假=${record.personalLeave ?? "未知"}',
          );
        }
      }
    }

    if (results.isEmpty) {
      return '未找到 $month 月员工 $employeeName 的考勤记录。';
    }

    return '员工 $employeeName 在所有年份 $month 月的考勤记录：\n${results.join('\n')}';
  }

  /// 查询所有记录中某员工的考勤信息
  Future<String> _searchEmployeeAttendanceAll(String employeeName) async {
    final isar = _database.isar!;

    // 查询所有工资数据
    final salaryLists = await isar.salaryLists.where().findAll();

    if (salaryLists.isEmpty) {
      return '未找到任何考勤记录。';
    }

    final List<String> results = [];

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          results.add(
            '${salaryList.year} 年 ${salaryList.month} 月: '
            '出勤情况=${record.attendance ?? "未知"}, '
            '病假=${record.sickLeave ?? "未知"}, '
            '事假=${record.personalLeave ?? "未知"}',
          );
        }
      }
    }

    if (results.isEmpty) {
      return '未找到员工 $employeeName 的任何考勤记录。';
    }

    return '员工 $employeeName 在所有时间的考勤记录：\n${results.join('\n')}';
  }

  /// 处理平均工资查询
  Future<String> _handleAverageSalaryQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;

    // 如果提供了年份但没有提供月份，查询该年份的所有记录
    if (year != null && month == null) {
      return await _searchAverageSalaryByYear(year);
    }

    // 如果提供了月份但没有提供年份，查询所有年份中该月份的记录
    if (year == null && month != null) {
      return await _searchAverageSalaryByMonth(month);
    }

    // 如果既没有提供年份也没有提供月份，查询所有记录
    if (year == null && month == null) {
      return await _searchAverageSalaryAll();
    }

    // 如果提供了完整的年份和月份，按原逻辑查询
    final averageSalary = await _queryService.getAverageSalary(
      year: year!,
      month: month!,
    );

    return '$year 年 $month 月所有员工的平均工资为: ${averageSalary.toStringAsFixed(2)} 元';
  }

  /// 查询某年所有月份的平均工资
  Future<String> _searchAverageSalaryByYear(int year) async {
    final isar = _database.isar!;

    // 查询指定年份的所有工资数据
    final salaryLists = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $year 年的工资记录。';
    }

    final Map<int, double> monthlyAverages = {};
    double totalAverage = 0;
    int validMonths = 0;

    for (var salaryList in salaryLists) {
      double totalSalary = 0;
      int count = 0;

      for (var record in salaryList.records) {
        if (record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;
          totalSalary += salary;
          count++;
        }
      }

      if (count > 0) {
        final average = totalSalary / count;
        monthlyAverages[salaryList.month] = average;
        totalAverage += average;
        validMonths++;
      }
    }

    if (monthlyAverages.isEmpty) {
      return '未找到 $year 年的有效工资记录。';
    }

    final overallAverage = totalAverage / validMonths;

    final buffer = StringBuffer();
    buffer.writeln('$year 年各月份平均工资：');

    monthlyAverages.forEach((month, average) {
      buffer.writeln('$month 月: ${average.toStringAsFixed(2)} 元');
    });

    buffer.writeln('全年平均工资: ${overallAverage.toStringAsFixed(2)} 元');

    return buffer.toString();
  }

  /// 查询所有年份中某月份的平均工资
  Future<String> _searchAverageSalaryByMonth(int month) async {
    final isar = _database.isar!;

    // 查询所有工资数据，然后过滤月份
    final salaryLists = await isar.salaryLists
        .filter()
        .monthEqualTo(month)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $month 月的工资记录。';
    }

    final Map<int, double> yearlyAverages = {};
    double totalAverage = 0;
    int validYears = 0;

    for (var salaryList in salaryLists) {
      double totalSalary = 0;
      int count = 0;

      for (var record in salaryList.records) {
        if (record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;
          totalSalary += salary;
          count++;
        }
      }

      if (count > 0) {
        final average = totalSalary / count;
        yearlyAverages[salaryList.year] = average;
        totalAverage += average;
        validYears++;
      }
    }

    if (yearlyAverages.isEmpty) {
      return '未找到 $month 月的有效工资记录。';
    }

    final overallAverage = totalAverage / validYears;

    final buffer = StringBuffer();
    buffer.writeln('所有年份 $month 月平均工资：');

    yearlyAverages.forEach((year, average) {
      buffer.writeln('$year 年: ${average.toStringAsFixed(2)} 元');
    });

    buffer.writeln('该月份历年平均工资: ${overallAverage.toStringAsFixed(2)} 元');

    return buffer.toString();
  }

  /// 查询所有记录的平均工资
  Future<String> _searchAverageSalaryAll() async {
    final isar = _database.isar!;

    // 查询所有工资数据
    final salaryLists = await isar.salaryLists.where().findAll();

    if (salaryLists.isEmpty) {
      return '未找到任何工资记录。';
    }

    double totalSalary = 0;
    int totalCount = 0;
    final Map<String, double> yearlyAverages = {};

    // 按年份计算平均工资
    final Map<int, List<double>> yearlySalaries = {};

    for (var salaryList in salaryLists) {
      double yearTotal = 0;
      int yearCount = 0;

      for (var record in salaryList.records) {
        if (record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;
          totalSalary += salary;
          yearTotal += salary;
          totalCount++;
          yearCount++;
        }
      }

      if (yearCount > 0) {
        yearlyAverages['${salaryList.year}年'] = yearTotal / yearCount;
      }
    }

    if (totalCount == 0) {
      return '未找到任何有效工资记录。';
    }

    final overallAverage = totalSalary / totalCount;

    final buffer = StringBuffer();
    buffer.writeln('所有时间平均工资统计：');
    buffer.writeln('总体平均工资: ${overallAverage.toStringAsFixed(2)} 元');

    buffer.writeln('\n各年度平均工资：');
    yearlyAverages.forEach((year, average) {
      buffer.writeln('$year: ${average.toStringAsFixed(2)} 元');
    });

    return buffer.toString();
  }

  /// 处理工资总和查询
  Future<String> _handleTotalSalaryQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;

    // 如果提供了年份但没有提供月份，查询该年份的所有记录
    if (year != null && month == null) {
      return await _searchTotalSalaryByYear(year);
    }

    // 如果提供了月份但没有提供年份，查询所有年份中该月份的记录
    if (year == null && month != null) {
      return await _searchTotalSalaryByMonth(month);
    }

    // 如果既没有提供年份也没有提供月份，查询所有记录
    if (year == null && month == null) {
      return await _searchTotalSalaryAll();
    }

    // 如果提供了完整的年份和月份，按原逻辑查询
    final totalSalary = await _queryService.getTotalSalary(
      year: year!,
      month: month!,
    );

    return '$year 年 $month 月所有员工的工资总和为: ${totalSalary.toStringAsFixed(2)} 元';
  }

  /// 查询某年所有月份的工资总和
  Future<String> _searchTotalSalaryByYear(int year) async {
    final isar = _database.isar!;

    // 查询指定年份的所有工资数据
    final salaryLists = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $year 年的工资记录。';
    }

    final Map<int, double> monthlyTotals = {};
    double annualTotal = 0;

    for (var salaryList in salaryLists) {
      double monthTotal = 0;

      for (var record in salaryList.records) {
        if (record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;
          monthTotal += salary;
        }
      }

      monthlyTotals[salaryList.month] = monthTotal;
      annualTotal += monthTotal;
    }

    final buffer = StringBuffer();
    buffer.writeln('$year 年各月份工资总和：');

    monthlyTotals.forEach((month, total) {
      buffer.writeln('$month 月: ${total.toStringAsFixed(2)} 元');
    });

    buffer.writeln('全年工资总和: ${annualTotal.toStringAsFixed(2)} 元');

    return buffer.toString();
  }

  /// 查询所有年份中某月份的工资总和
  Future<String> _searchTotalSalaryByMonth(int month) async {
    final isar = _database.isar!;

    // 查询所有工资数据，然后过滤月份
    final salaryLists = await isar.salaryLists
        .filter()
        .monthEqualTo(month)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $month 月的工资记录。';
    }

    final Map<int, double> yearlyTotals = {};
    double monthTotal = 0;

    for (var salaryList in salaryLists) {
      double yearTotal = 0;

      for (var record in salaryList.records) {
        if (record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;
          yearTotal += salary;
        }
      }

      yearlyTotals[salaryList.year] = yearTotal;
      monthTotal += yearTotal;
    }

    final buffer = StringBuffer();
    buffer.writeln('所有年份 $month 月工资总和：');

    yearlyTotals.forEach((year, total) {
      buffer.writeln('$year 年: ${total.toStringAsFixed(2)} 元');
    });

    buffer.writeln('该月份历年工资总和: ${monthTotal.toStringAsFixed(2)} 元');

    return buffer.toString();
  }

  /// 查询所有记录的工资总和
  Future<String> _searchTotalSalaryAll() async {
    final isar = _database.isar!;

    // 查询所有工资数据
    final salaryLists = await isar.salaryLists.where().findAll();

    if (salaryLists.isEmpty) {
      return '未找到任何工资记录。';
    }

    double grandTotal = 0;
    final Map<String, double> yearlyTotals = {};

    // 按年份计算工资总和
    for (var salaryList in salaryLists) {
      double yearTotal = 0;

      for (var record in salaryList.records) {
        if (record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;
          yearTotal += salary;
          grandTotal += salary;
        }
      }

      yearlyTotals['${salaryList.year}年'] = yearTotal;
    }

    final buffer = StringBuffer();
    buffer.writeln('所有时间工资总和统计：');
    buffer.writeln('总体工资总和: ${grandTotal.toStringAsFixed(2)} 元');

    buffer.writeln('\n各年度工资总和：');
    yearlyTotals.forEach((year, total) {
      buffer.writeln('$year: ${total.toStringAsFixed(2)} 元');
    });

    return buffer.toString();
  }

  /// 处理部门平均工资查询
  Future<String> _handleDepartmentAverageQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;

    // 如果提供了年份但没有提供月份，查询该年份的所有记录
    if (year != null && month == null) {
      return await _searchDepartmentAverageByYear(year);
    }

    // 如果提供了月份但没有提供年份，查询所有年份中该月份的记录
    if (year == null && month != null) {
      return await _searchDepartmentAverageByMonth(month);
    }

    // 如果既没有提供年份也没有提供月份，查询所有记录
    if (year == null && month == null) {
      return await _searchDepartmentAverageAll();
    }

    // 如果提供了完整的年份和月份，按原逻辑查询
    final departmentAverages = await _queryService
        .getAverageSalaryByDepartments(year: year!, month: month!);

    if (departmentAverages.isEmpty) {
      return '未找到 $year 年 $month 月各部门的工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('$year 年 $month 月各部门平均工资：');

    departmentAverages.forEach((department, average) {
      buffer.writeln('$department: ${average.toStringAsFixed(2)} 元');
    });

    return buffer.toString();
  }

  /// 查询某年所有月份各部门的平均工资
  Future<String> _searchDepartmentAverageByYear(int year) async {
    final isar = _database.isar!;

    // 查询指定年份的所有工资数据
    final salaryLists = await isar.salaryLists
        .filter()
        .yearEqualTo(year)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $year 年的工资记录。';
    }

    // 按部门和月份收集数据
    final Map<String, Map<int, List<double>>> deptMonthlyData = {};

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.department != null && record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;

          final department = record.department!;
          final month = salaryList.month;

          if (!deptMonthlyData.containsKey(department)) {
            deptMonthlyData[department] = {};
          }

          if (!deptMonthlyData[department]!.containsKey(month)) {
            deptMonthlyData[department]![month] = [];
          }

          deptMonthlyData[department]![month]!.add(salary);
        }
      }
    }

    if (deptMonthlyData.isEmpty) {
      return '未找到 $year 年各部门的有效工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('$year 年各部门平均工资统计：');

    deptMonthlyData.forEach((department, monthlyData) {
      buffer.writeln('\n$department:');

      double deptTotal = 0;
      int deptCount = 0;
      final monthlyAverages = <int, double>{};

      monthlyData.forEach((month, salaries) {
        final monthTotal = salaries.reduce((a, b) => a + b);
        final monthAverage = monthTotal / salaries.length;
        monthlyAverages[month] = monthAverage;
        deptTotal += monthTotal;
        deptCount += salaries.length;
      });

      final deptAverage = deptCount > 0 ? deptTotal / deptCount : 0;

      monthlyAverages.forEach((month, average) {
        buffer.writeln('  $month 月: ${average.toStringAsFixed(2)} 元');
      });

      buffer.writeln('  年度平均: ${deptAverage.toStringAsFixed(2)} 元');
    });

    return buffer.toString();
  }

  /// 查询所有年份中某月份各部门的平均工资
  Future<String> _searchDepartmentAverageByMonth(int month) async {
    final isar = _database.isar!;

    // 查询所有工资数据，然后过滤月份
    final salaryLists = await isar.salaryLists
        .filter()
        .monthEqualTo(month)
        .findAll();

    if (salaryLists.isEmpty) {
      return '未找到 $month 月的工资记录。';
    }

    // 按部门和年份收集数据
    final Map<String, Map<int, List<double>>> deptYearlyData = {};

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.department != null && record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;

          final department = record.department!;
          final year = salaryList.year;

          if (!deptYearlyData.containsKey(department)) {
            deptYearlyData[department] = {};
          }

          if (!deptYearlyData[department]!.containsKey(year)) {
            deptYearlyData[department]![year] = [];
          }

          deptYearlyData[department]![year]!.add(salary);
        }
      }
    }

    if (deptYearlyData.isEmpty) {
      return '未找到 $month 月各部门的有效工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('所有年份 $month 月各部门平均工资统计：');

    deptYearlyData.forEach((department, yearlyData) {
      buffer.writeln('\n$department:');

      double deptTotal = 0;
      int deptCount = 0;
      final yearlyAverages = <int, double>{};

      yearlyData.forEach((year, salaries) {
        final yearTotal = salaries.reduce((a, b) => a + b);
        final yearAverage = yearTotal / salaries.length;
        yearlyAverages[year] = yearAverage;
        deptTotal += yearTotal;
        deptCount += salaries.length;
      });

      final deptAverage = deptCount > 0 ? deptTotal / deptCount : 0;

      yearlyAverages.forEach((year, average) {
        buffer.writeln('  $year 年: ${average.toStringAsFixed(2)} 元');
      });

      buffer.writeln('  该月份历年平均: ${deptAverage.toStringAsFixed(2)} 元');
    });

    return buffer.toString();
  }

  /// 查询所有记录各部门的平均工资
  Future<String> _searchDepartmentAverageAll() async {
    final isar = _database.isar!;

    // 查询所有工资数据
    final salaryLists = await isar.salaryLists.where().findAll();

    if (salaryLists.isEmpty) {
      return '未找到任何工资记录。';
    }

    // 按部门收集所有数据
    final Map<String, List<double>> deptAllData = {};

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.department != null && record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;

          final department = record.department!;

          if (!deptAllData.containsKey(department)) {
            deptAllData[department] = [];
          }

          deptAllData[department]!.add(salary);
        }
      }
    }

    if (deptAllData.isEmpty) {
      return '未找到各部门的有效工资记录。';
    }

    final buffer = StringBuffer();
    buffer.writeln('所有时间各部门平均工资统计：');

    final List<MapEntry<String, double>> sortedDepts = [];

    deptAllData.forEach((department, salaries) {
      final total = salaries.reduce((a, b) => a + b);
      final average = total / salaries.length;
      sortedDepts.add(MapEntry(department, average));
    });

    // 按平均工资排序
    sortedDepts.sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedDepts) {
      buffer.writeln('${entry.key}: ${entry.value.toStringAsFixed(2)} 元');
    }

    return buffer.toString();
  }
}
