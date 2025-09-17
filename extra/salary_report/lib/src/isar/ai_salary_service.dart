import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:salary_report/src/common/llm_client.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/salary_query_service.dart';

class AISalaryService {
  final SalaryQueryService _queryService;
  final LLMClient _llmClient;

  AISalaryService(IsarDatabase database)
    : _queryService = SalaryQueryService(database),
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
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;
    final employeeName = parameters['employeeName'] as String?;

    if (year == null || month == null || employeeName == null) {
      return '查询参数不完整，请提供年份、月份和员工姓名。';
    }

    final record = await _queryService.getEmployeeSalaryByYearMonth(
      year: year,
      month: month,
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
        '事假天数: ${record.leave ?? "未知"}\n'
        '缺勤次数: ${record.absence ?? "未知"}\n'
        '旷工天数: ${record.truancy ?? "未知"}\n'
        '绩效得分: ${record.performanceScore ?? "未知"}';
  }

  /// 处理部门工资查询
  Future<String> _handleDepartmentSalaryQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;
    final department = parameters['department'] as String?;

    if (year == null || month == null || department == null) {
      return '查询参数不完整，请提供年份、月份和部门名称。';
    }

    final records = await _queryService.getDepartmentSalaryByYearMonth(
      year: year,
      month: month,
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

  /// 处理最高工资查询
  Future<String> _handleTopSalaryQuery(Map<String, dynamic> parameters) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;
    final limit = parameters['limit'] as int? ?? 10;

    if (year == null || month == null) {
      return '查询参数不完整，请提供年份和月份。';
    }

    final records = await _queryService.getTopSalaryEmployees(
      year: year,
      month: month,
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

  /// 处理最低工资查询
  Future<String> _handleBottomSalaryQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;
    final limit = parameters['limit'] as int? ?? 10;

    if (year == null || month == null) {
      return '查询参数不完整，请提供年份和月份。';
    }

    final records = await _queryService.getBottomSalaryEmployees(
      year: year,
      month: month,
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

  /// 处理员工考勤查询
  Future<String> _handleEmployeeAttendanceQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;
    final employeeName = parameters['employeeName'] as String?;

    if (year == null || month == null || employeeName == null) {
      return '查询参数不完整，请提供年份、月份和员工姓名。';
    }

    final attendance = await _queryService.getEmployeeAttendance(
      year: year,
      month: month,
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

  /// 处理平均工资查询
  Future<String> _handleAverageSalaryQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;

    if (year == null || month == null) {
      return '查询参数不完整，请提供年份和月份。';
    }

    final averageSalary = await _queryService.getAverageSalary(
      year: year,
      month: month,
    );

    return '$year 年 $month 月所有员工的平均工资为: ${averageSalary.toStringAsFixed(2)} 元';
  }

  /// 处理工资总和查询
  Future<String> _handleTotalSalaryQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;

    if (year == null || month == null) {
      return '查询参数不完整，请提供年份和月份。';
    }

    final totalSalary = await _queryService.getTotalSalary(
      year: year,
      month: month,
    );

    return '$year 年 $month 月所有员工的工资总和为: ${totalSalary.toStringAsFixed(2)} 元';
  }

  /// 处理部门平均工资查询
  Future<String> _handleDepartmentAverageQuery(
    Map<String, dynamic> parameters,
  ) async {
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;

    if (year == null || month == null) {
      return '查询参数不完整，请提供年份和月份。';
    }

    final departmentAverages = await _queryService
        .getAverageSalaryByDepartments(year: year, month: month);

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
}
