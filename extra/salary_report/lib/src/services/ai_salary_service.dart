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
      _llmClient = LLMClient() {
    logger.info('AISalaryService initialized');
  }

  // 缓存基础查询方法的结果
  final Map<String, dynamic> _queryCache = {};

  /// 处理用户查询请求
  Future<String> processUserQuery(
    String userQuery, {
    Function(String)? onProgress,
  }) async {
    logger.info('Processing user query: $userQuery');

    onProgress?.call('🤔 正在分析您的问题...');

    // 1. 首先判断查询的复杂度和类型
    final queryAnalysis = await _analyzeQueryComplexity(userQuery);

    logger.info('Query analysis: $queryAnalysis');

    final queryType = queryAnalysis['type'] as String;

    switch (queryType) {
      case 'simple_intent':
        onProgress?.call('📊 执行简单数据查询...');
        // 简单意图查询，直接处理
        return await _handleSimpleQuery(userQuery);

      case 'complex_analysis':
        onProgress?.call('🔍 执行复杂数据分析...');
        // 复杂分析查询，需要大模型参与分析
        return await _handleComplexAnalysisQuery(
          userQuery,
          queryAnalysis,
          onProgress,
        );

      case 'multi_step':
        onProgress?.call('📋 规划多步骤执行方案...');
        // 多步骤查询，需要规划执行步骤
        return await _handleMultiStepQuery(
          userQuery,
          queryAnalysis,
          onProgress,
        );

      case 'general_chat':
      default:
        onProgress?.call('💬 使用通用对话模式回答...');
        return await _handleGeneralQuery(userQuery);
    }
  }

  /// 分析查询复杂度和类型
  Future<Map<String, dynamic>> _analyzeQueryComplexity(String userQuery) async {
    final prompt =
        '''
你是一个智能查询分析器，需要分析用户问题的复杂度和类型。

首先提取查询中的关键维度：
- 人员维度：具体员工姓名（如"张三1"、"李四2"等）
- 部门维度：部门名称（如"技术部"、"销售部"等）
- 时间维度：年份、月份、时间范围等
- 分析维度：绩效、薪资趋势、考勤等

根据用户问题，判断查询类型：

1. "simple_intent": 简单直接的数据查询
   - 例如："张三1的工资"、"技术部平均工资"、"2024年10月工资最高的员工"
   - 特点：涉及明确的人员/部门/时间维度，可以直接查询数据

2. "complex_analysis": 需要深度分析的查询
   - 例如："张三1的绩效水平怎么样"、"技术部员工薪资趋势分析"
   - 特点：涉及具体的人员/部门维度，需要收集相关数据进行AI分析

3. "multi_step": 多步骤复杂查询
   - 例如："对比各部门平均工资，并分析工资差异原因"、"找出绩效最好的员工，分析他们的共同特点"
   - 特点：需要多个查询步骤，涉及多个维度的数据收集和综合分析

4. "general_chat": 开放性问题
   - 例如："如何提高员工满意度"、"薪资管理的最佳实践"
   - 特点：不涉及具体的人员/部门/时间维度，属于通用咨询问题

用户问题: "$userQuery"

请分析并返回JSON格式：
{
  "type": "查询类型",
  "complexity_level": "low/medium/high",
  "requires_ai_analysis": true/false,
  "key_entities": {
    "employees": ["提取的员工姓名"],
    "departments": ["提取的部门名称"],
    "time_periods": ["提取的时间信息"],
    "analysis_types": ["需要分析的类型"]
  },
  "data_dimensions": ["需要收集的数据维度"]
}
''';

    try {
      final result = await _llmClient.getAnswer(
        prompt,
        format: ResponseFormat.jsonObject(),
      );

      final jsonStart = result.indexOf('{');
      final jsonEnd = result.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = result.substring(jsonStart, jsonEnd + 1);
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      logger.warning('Query analysis failed: $e');
    }

    return {
      'type': 'simple_intent',
      'complexity_level': 'low',
      'requires_ai_analysis': false,
      'key_entities': {
        'employees': [],
        'departments': [],
        'time_periods': [],
        'analysis_types': [],
      },
      'data_dimensions': [],
    };
  }

  /// 处理简单查询
  Future<String> _handleSimpleQuery(String userQuery) async {
    // 使用原有的意图识别逻辑
    final intentResult = await _recognizeIntent(userQuery);
    logger.info('Simple intent: $intentResult');

    final intent = intentResult['intent'] as String;
    final parameters = Map<String, dynamic>.from(intentResult['parameters']);

    // 调用原有的处理方法
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
      case 'performance_analysis':
        return await _handlePerformanceAnalysisQuery(parameters);
      default:
        return '抱歉，我无法理解您的查询请求。请尝试重新表述您的问题。';
    }
  }

  /// 处理复杂分析查询
  Future<String> _handleComplexAnalysisQuery(
    String userQuery,
    Map<String, dynamic> analysis, [
    Function(String)? onProgress,
  ]) async {
    final keyEntities = analysis['key_entities'] as Map<String, dynamic>? ?? {};
    final dataDimensions = analysis['data_dimensions'] as List<dynamic>? ?? [];

    final employees = (keyEntities['employees'] as List<dynamic>? ?? [])
        .cast<String>();
    final departments = (keyEntities['departments'] as List<dynamic>? ?? [])
        .cast<String>();
    final timePeriods = (keyEntities['time_periods'] as List<dynamic>? ?? [])
        .cast<String>();
    final analysisTypes =
        (keyEntities['analysis_types'] as List<dynamic>? ?? []).cast<String>();

    logger.info(
      'Complex analysis - Employees: $employees, Departments: $departments, Analysis: $analysisTypes',
    );

    onProgress?.call('📦 正在收集相关数据...');

    // 根据提取的维度全面收集数据
    final Map<String, dynamic> collectedData = {};

    // 1. 收集员工数据
    if (employees.isNotEmpty) {
      onProgress?.call('👥 正在收集员工 ${employees.join(", ")} 的数据...');
      collectedData['employee_data'] = await _collectEmployeeAllData(employees);
    }

    // 2. 收集部门数据
    if (departments.isNotEmpty) {
      onProgress?.call('🏢 正在收集部门 ${departments.join(", ")} 的数据...');
      collectedData['department_data'] = await _collectDepartmentAllData(
        departments,
      );
    }

    // 3. 根据分析类型收集特定数据
    for (String analysisType in analysisTypes) {
      switch (analysisType) {
        case 'performance':
        case '绩效':
          onProgress?.call('🏆 正在收集绩效数据...');
          if (employees.isNotEmpty) {
            collectedData['performance_data'] = await _collectPerformanceData(
              employees,
            );
          }
          if (departments.isNotEmpty) {
            collectedData['dept_performance_data'] =
                await _collectDepartmentPerformanceData(departments);
          }
          break;
        case 'salary_trend':
        case '薪资趋势':
          onProgress?.call('📈 正在分析薪资趋势...');
          if (employees.isNotEmpty) {
            collectedData['salary_trend_data'] = await _collectSalaryTrendData(
              employees,
            );
          }
          if (departments.isNotEmpty) {
            collectedData['dept_salary_trend_data'] =
                await _collectDepartmentSalaryTrendData(departments);
          }
          break;
        case 'attendance':
        case '考勤':
          onProgress?.call('📊 正在收集考勤数据...');
          if (employees.isNotEmpty) {
            collectedData['attendance_data'] = await _collectAttendanceData(
              employees,
            );
          }
          break;
      }
    }

    // 4. 如果没有具体的分析类型，则收集所有相关数据
    if (analysisTypes.isEmpty &&
        (employees.isNotEmpty || departments.isNotEmpty)) {
      onProgress?.call('📄 正在收集全面数据...');
      if (employees.isNotEmpty) {
        collectedData['performance_data'] = await _collectPerformanceData(
          employees,
        );
        collectedData['salary_trend_data'] = await _collectSalaryTrendData(
          employees,
        );
        collectedData['attendance_data'] = await _collectAttendanceData(
          employees,
        );
      }
      if (departments.isNotEmpty) {
        collectedData['dept_performance_data'] =
            await _collectDepartmentPerformanceData(departments);
        collectedData['dept_salary_trend_data'] =
            await _collectDepartmentSalaryTrendData(departments);
      }
    }

    onProgress?.call('🤖 AI正在分析数据并生成报告...');
    // 让AI分析数据并生成回答
    return await _generateAIAnalysis(userQuery, collectedData);
  }

  /// 处理多步骤查询
  Future<String> _handleMultiStepQuery(
    String userQuery,
    Map<String, dynamic> analysis, [
    Function(String)? onProgress,
  ]) async {
    logger.info('Multi-step query processing');

    onProgress?.call('🧠 智能体正在规划任务步骤...');
    // 让AI规划执行步骤
    final executionPlan = await _planExecution(userQuery, analysis);

    logger.info('Execution plan: $executionPlan');

    final totalSteps = executionPlan['total_steps'] as int? ?? 0;
    final List<dynamic> steps = executionPlan['steps'] as List<dynamic>? ?? [];

    if (steps.isEmpty) {
      return '无法规划执行步骤，请尝试重新表述您的问题。';
    }

    // 展示任务规划
    onProgress?.call('📋 任务规划完成！共 $totalSteps 个步骤：');

    // 展示所有步骤概览
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i] as Map<String, dynamic>;
      final stepDescription = step['description'] as String? ?? '步骤 ${i + 1}';
      onProgress?.call('• 步骤 ${i + 1}: $stepDescription');
    }

    // 给用户一些时间查看规划
    await Future.delayed(const Duration(milliseconds: 1500));

    onProgress?.call('🚀 开始执行任务...');

    final List<Map<String, dynamic>> stepResults = [];

    // 执行每个步骤
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i] as Map<String, dynamic>;
      final stepDescription = step['description'] as String? ?? '执行步骤 ${i + 1}';
      final operation = step['operation'] as String? ?? 'unknown';

      onProgress?.call('🔄 正在执行步骤 ${i + 1}/$totalSteps: $stepDescription');

      try {
        final stepResult = await _executeStep(step, onProgress);

        stepResults.add({
          'step_id': i + 1,
          'description': stepDescription,
          'operation': operation,
          'result': stepResult,
          'success': true,
        });

        // 缓存步骤结果供后续步骤使用
        _queryCache['step_${i}_result'] = stepResult;

        onProgress?.call('✅ 步骤 ${i + 1} 完成！');

        // 给用户一些时间查看结果
        if (i < steps.length - 1) {
          await Future.delayed(const Duration(milliseconds: 800));
        }
      } catch (e) {
        logger.warning('Step ${i + 1} failed: $e');
        stepResults.add({
          'step_id': i + 1,
          'description': stepDescription,
          'operation': operation,
          'result': {'type': 'error', 'data': '步骤执行失败：$e'},
          'success': false,
        });
        onProgress?.call('❌ 步骤 ${i + 1} 执行失败，继续后续步骤...');
      }
    }

    onProgress?.call('🧠 正在综合分析所有步骤结果...');
    // 综合所有步骤结果，生成最终回答
    return await _synthesizeResults(userQuery, stepResults, executionPlan);
  }

  /// 处理一般查询
  Future<String> _handleGeneralQuery(String userQuery) async {
    // 对于无法分类的查询，尝试使用AI直接理解和回答
    final prompt =
        '''
用户询问："$userQuery"

请基于薪资管理系统的上下文，尝试理解用户的问题。如果这是一个关于员工薪资、绩效、考勤等方面的问题，
请说明需要什么样的数据来回答这个问题。如果不是相关问题，请礼貌地说明系统的功能范围。

可用的数据包括：
- 员工基本信息（姓名、部门、职位）
- 薪资数据（实发工资、各种津贴扣除）
- 考勤数据（出勤天数、请假情况、旷工等）
- 绩效数据（绩效得分）

请使用Markdown格式给出简洁明确的回答。确保回答使用markdown语法，包含适当的标题、列表等元素。
''';

    try {
      final result = await _llmClient.getAnswer(prompt);
      // 确保返回内容是markdown格式的
      String markdownResult = result.trim();
      if (!markdownResult.contains('#') && !markdownResult.contains('**')) {
        // 如果内容不包含markdown语法，则包装为markdown
        markdownResult = '## 🤖 AI回答\n\n$markdownResult';
      }
      return markdownResult;
    } catch (e) {
      logger.warning('General query failed: $e');
      return '**抱歉**\n\n我无法处理您的查询。请尝试询问关于员工薪资、绩效或考勤的具体问题。';
    }
  }

  /// 处理绩效分析查询
  Future<String> _handlePerformanceAnalysisQuery(
    Map<String, dynamic> parameters,
  ) async {
    final employeeName = parameters['employeeName'] as String?;
    final year = parameters['year'] as int?;
    final month = parameters['month'] as int?;

    if (employeeName == null) {
      return '请提供员工姓名进行绩效分析。';
    }

    // 收集该员工的绩效数据
    final performanceData = await _getEmployeePerformanceData(
      employeeName,
      year,
      month,
    );

    if (performanceData.isEmpty) {
      return '未找到员工 $employeeName 的绩效记录。';
    }

    // 使用AI分析绩效数据
    return await _analyzeEmployeePerformance(employeeName, performanceData);
  }

  /// 获取员工绩效数据
  Future<List<Map<String, dynamic>>> _getEmployeePerformanceData(
    String employeeName,
    int? year,
    int? month,
  ) async {
    final isar = _database.isar!;
    List<SalaryList> salaryLists;

    if (year != null && month != null) {
      salaryLists = await isar.salaryLists
          .filter()
          .yearEqualTo(year)
          .and()
          .monthEqualTo(month)
          .findAll();
    } else if (year != null) {
      salaryLists = await isar.salaryLists.filter().yearEqualTo(year).findAll();
    } else {
      salaryLists = await isar.salaryLists.where().findAll();
    }

    final List<Map<String, dynamic>> performanceData = [];

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName && record.performanceScore != null) {
          performanceData.add({
            'year': salaryList.year,
            'month': salaryList.month,
            'performanceScore': record.performanceScore,
            'netSalary': record.netSalary,
            'department': record.department,
            'position': record.position,
          });
        }
      }
    }

    return performanceData;
  }

  /// 分析员工绩效
  Future<String> _analyzeEmployeePerformance(
    String employeeName,
    List<Map<String, dynamic>> performanceData,
  ) async {
    // 准备数据摘要
    final dataStr = performanceData
        .map(
          (data) =>
              '${data['year']}年${data['month']}月: 绩效${data['performanceScore']}, 工资${data['netSalary']}',
        )
        .join('\n');

    final prompt =
        '''
请分析员工 $employeeName 的绩效表现：

绩效数据：
$dataStr

请从以下方面进行分析，并用Markdown格式输出：
1. 绩效水平评价（高/中/低）
2. 绩效变化趋势（上升/下降/稳定）
3. 绩效与薪资的关联性
4. 给出改进建议（如果需要）

请使用Markdown格式，包含标题、列表等元素，给出简洁专业的分析报告。
''';

    try {
      final result = await _llmClient.getAnswer(prompt);
      return result.trim();
    } catch (e) {
      logger.warning('Performance analysis failed: $e');
      return '**绩效分析失败**\n\n请稍后重试。';
    }
  }

  /// 收集员工全部数据
  Future<Map<String, dynamic>> _collectEmployeeAllData(
    List<String> employees,
  ) async {
    final Map<String, dynamic> data = {};

    for (String employee in employees) {
      final employeeData = <String, dynamic>{};

      // 收集员工基本薪资数据
      final salaryData = await _getEmployeeAllSalaryData(employee);
      if (salaryData.isNotEmpty) {
        employeeData['salary_records'] = salaryData;
      }

      // 收集员工绩效数据
      final performanceData = await _getEmployeePerformanceData(
        employee,
        null,
        null,
      );
      if (performanceData.isNotEmpty) {
        employeeData['performance_records'] = performanceData;
      }

      // 收集员工考勤数据
      final attendanceData = await _getEmployeeAttendanceData(employee);
      if (attendanceData.isNotEmpty) {
        employeeData['attendance_records'] = attendanceData;
      }

      if (employeeData.isNotEmpty) {
        data[employee] = employeeData;
      }
    }

    return data;
  }

  /// 收集部门全部数据
  Future<Map<String, dynamic>> _collectDepartmentAllData(
    List<String> departments,
  ) async {
    final Map<String, dynamic> data = {};

    for (String department in departments) {
      final deptData = <String, dynamic>{};

      // 收集部门员工列表和薪资数据
      final deptSalaryData = await _getDepartmentAllSalaryData(department);
      if (deptSalaryData.isNotEmpty) {
        deptData['salary_data'] = deptSalaryData;
      }

      // 收集部门绩效统计
      final deptPerformanceData = await _getDepartmentPerformanceStats(
        department,
      );
      if (deptPerformanceData.isNotEmpty) {
        deptData['performance_stats'] = deptPerformanceData;
      }

      if (deptData.isNotEmpty) {
        data[department] = deptData;
      }
    }

    return data;
  }

  /// 收集部门绩效数据
  Future<Map<String, dynamic>> _collectDepartmentPerformanceData(
    List<String> departments,
  ) async {
    final Map<String, dynamic> data = {};

    for (String department in departments) {
      final performanceStats = await _getDepartmentPerformanceStats(department);
      if (performanceStats.isNotEmpty) {
        data[department] = performanceStats;
      }
    }

    return data;
  }

  /// 收集部门薪资趋势数据
  Future<Map<String, dynamic>> _collectDepartmentSalaryTrendData(
    List<String> departments,
  ) async {
    final Map<String, dynamic> data = {};

    for (String department in departments) {
      final trendData = await _getDepartmentSalaryTrend(department);
      if (trendData.isNotEmpty) {
        data[department] = trendData;
      }
    }

    return data;
  }

  /// 获取员工全部薪资数据
  Future<List<Map<String, dynamic>>> _getEmployeeAllSalaryData(
    String employeeName,
  ) async {
    final isar = _database.isar!;
    final salaryLists = await isar.salaryLists.where().findAll();

    final List<Map<String, dynamic>> salaryData = [];

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          salaryData.add({
            'year': salaryList.year,
            'month': salaryList.month,
            'netSalary': record.netSalary,
            'department': record.department,
            'position': record.position,
            'attendance': record.attendance,
            'performanceScore': record.performanceScore,
          });
        }
      }
    }

    return salaryData;
  }

  /// 获取员工考勤数据
  Future<List<Map<String, dynamic>>> _getEmployeeAttendanceData(
    String employeeName,
  ) async {
    final isar = _database.isar!;
    final salaryLists = await isar.salaryLists.where().findAll();

    final List<Map<String, dynamic>> attendanceData = [];

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.name == employeeName) {
          attendanceData.add({
            'year': salaryList.year,
            'month': salaryList.month,
            'attendance': record.attendance,
            'sickLeave': record.sickLeave,
            'personalLeave': record.personalLeave,
            'absence': record.absence,
            'truancy': record.truancy,
            'payDays': record.payDays,
            'actualPayDays': record.actualPayDays,
          });
        }
      }
    }

    return attendanceData;
  }

  /// 获取部门全部薪资数据
  Future<Map<String, dynamic>> _getDepartmentAllSalaryData(
    String department,
  ) async {
    final isar = _database.isar!;
    final salaryLists = await isar.salaryLists.where().findAll();

    final Map<String, List<Map<String, dynamic>>> monthlyData = {};
    final Set<String> employees = {};

    for (var salaryList in salaryLists) {
      final monthKey = '${salaryList.year}-${salaryList.month}';
      monthlyData[monthKey] = [];

      for (var record in salaryList.records) {
        if (record.department == department) {
          employees.add(record.name ?? '');
          monthlyData[monthKey]!.add({
            'name': record.name,
            'netSalary': record.netSalary,
            'position': record.position,
            'performanceScore': record.performanceScore,
          });
        }
      }
    }

    return {
      'monthly_data': monthlyData,
      'employee_list': employees.toList(),
      'employee_count': employees.length,
    };
  }

  /// 获取部门绩效统计
  Future<Map<String, dynamic>> _getDepartmentPerformanceStats(
    String department,
  ) async {
    final isar = _database.isar!;
    final salaryLists = await isar.salaryLists.where().findAll();

    final List<double> allScores = [];
    final Map<String, List<double>> monthlyScores = {};

    for (var salaryList in salaryLists) {
      final monthKey = '${salaryList.year}-${salaryList.month}';
      monthlyScores[monthKey] = [];

      for (var record in salaryList.records) {
        if (record.department == department &&
            record.performanceScore != null) {
          final score = double.tryParse(record.performanceScore!) ?? 0;
          allScores.add(score);
          monthlyScores[monthKey]!.add(score);
        }
      }
    }

    if (allScores.isEmpty) {
      return {};
    }

    allScores.sort();
    final avgScore = allScores.reduce((a, b) => a + b) / allScores.length;
    final maxScore = allScores.last;
    final minScore = allScores.first;

    return {
      'average_score': avgScore,
      'max_score': maxScore,
      'min_score': minScore,
      'total_records': allScores.length,
      'monthly_scores': monthlyScores,
    };
  }

  /// 获取部门薪资趋势
  Future<List<Map<String, dynamic>>> _getDepartmentSalaryTrend(
    String department,
  ) async {
    final isar = _database.isar!;
    final salaryLists = await isar.salaryLists.where().findAll();

    final Map<String, List<double>> monthlyAverage = {};

    for (var salaryList in salaryLists) {
      final monthKey = '${salaryList.year}-${salaryList.month}';
      final List<double> salaries = [];

      for (var record in salaryList.records) {
        if (record.department == department && record.netSalary != null) {
          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;
          if (salary > 0) {
            salaries.add(salary);
          }
        }
      }

      if (salaries.isNotEmpty) {
        final average = salaries.reduce((a, b) => a + b) / salaries.length;
        monthlyAverage[monthKey] = salaries;
      }
    }

    final List<Map<String, dynamic>> trendData = [];
    monthlyAverage.forEach((monthKey, salaries) {
      final parts = monthKey.split('-');
      final average = salaries.reduce((a, b) => a + b) / salaries.length;
      trendData.add({
        'year': int.parse(parts[0]),
        'month': int.parse(parts[1]),
        'average_salary': average,
        'employee_count': salaries.length,
        'total_salary': salaries.reduce((a, b) => a + b),
      });
    });

    // 按时间排序
    trendData.sort((a, b) {
      final aDate = DateTime(a['year'], a['month']);
      final bDate = DateTime(b['year'], b['month']);
      return aDate.compareTo(bDate);
    });

    return trendData;
  }

  Future<Map<String, dynamic>> _collectPerformanceData(
    List<String> entities,
  ) async {
    final Map<String, dynamic> data = {};

    for (String entity in entities) {
      final performanceData = await _getEmployeePerformanceData(
        entity,
        null,
        null,
      );
      if (performanceData.isNotEmpty) {
        data[entity] = performanceData;
      }
    }

    return data;
  }

  /// 收集薪资趋势数据
  Future<Map<String, dynamic>> _collectSalaryTrendData(
    List<String> entities,
  ) async {
    final Map<String, dynamic> data = {};
    final isar = _database.isar!;

    for (String entity in entities) {
      final salaryLists = await isar.salaryLists.where().findAll();
      final List<Map<String, dynamic>> salaryTrend = [];

      for (var salaryList in salaryLists) {
        for (var record in salaryList.records) {
          if (record.name == entity && record.netSalary != null) {
            salaryTrend.add({
              'year': salaryList.year,
              'month': salaryList.month,
              'salary': record.netSalary,
            });
          }
        }
      }

      if (salaryTrend.isNotEmpty) {
        salaryTrend.sort((a, b) {
          final aDate = DateTime(a['year'], a['month']);
          final bDate = DateTime(b['year'], b['month']);
          return aDate.compareTo(bDate);
        });
        data[entity] = salaryTrend;
      }
    }

    return data;
  }

  /// 收集考勤数据
  Future<Map<String, dynamic>> _collectAttendanceData(
    List<String> entities,
  ) async {
    final Map<String, dynamic> data = {};
    final isar = _database.isar!;

    for (String entity in entities) {
      final salaryLists = await isar.salaryLists.where().findAll();
      final List<Map<String, dynamic>> attendanceData = [];

      for (var salaryList in salaryLists) {
        for (var record in salaryList.records) {
          if (record.name == entity) {
            attendanceData.add({
              'year': salaryList.year,
              'month': salaryList.month,
              'attendance': record.attendance,
              'sickLeave': record.sickLeave,
              'personalLeave': record.personalLeave,
              'absence': record.absence,
              'truancy': record.truancy,
            });
          }
        }
      }

      if (attendanceData.isNotEmpty) {
        data[entity] = attendanceData;
      }
    }

    return data;
  }

  /// 收集部门数据
  Future<Map<String, dynamic>> _collectDepartmentData() async {
    final isar = _database.isar!;
    final salaryLists = await isar.salaryLists.where().findAll();

    final Map<String, Map<String, List<double>>> deptData = {};

    for (var salaryList in salaryLists) {
      for (var record in salaryList.records) {
        if (record.department != null && record.netSalary != null) {
          final dept = record.department!;
          final period = '${salaryList.year}-${salaryList.month}';

          if (!deptData.containsKey(dept)) {
            deptData[dept] = {};
          }

          if (!deptData[dept]!.containsKey(period)) {
            deptData[dept]![period] = [];
          }

          final salary =
              double.tryParse(
                record.netSalary!.replaceAll(RegExp(r'[^\d.-]'), ''),
              ) ??
              0;

          deptData[dept]![period]!.add(salary);
        }
      }
    }

    return deptData;
  }

  /// 生成AI分析
  Future<String> _generateAIAnalysis(
    String userQuery,
    Map<String, dynamic> collectedData,
  ) async {
    final dataStr = collectedData.entries
        .map((entry) {
          return '${entry.key}: ${entry.value.toString()}';
        })
        .join('\n');

    final prompt =
        '''
用户问题："$userQuery"

相关数据：
$dataStr

请基于以上数据，对用户的问题进行深度分析并给出专业的回答。
请使用Markdown格式输出，分析应该包括：

## 📈 数据概况

## 🔍 关键发现

## 📈 趋势分析

## 💡 建议和结论

请给出结构化、专业的分析报告。
''';

    try {
      final result = await _llmClient.getAnswer(prompt);
      return result.trim();
    } catch (e) {
      logger.warning('AI analysis failed: $e');
      return '**数据分析失败**\n\n请稍后重试。';
    }
  }

  /// 规划执行步骤
  Future<Map<String, dynamic>> _planExecution(
    String userQuery,
    Map<String, dynamic> analysis,
  ) async {
    final keyEntities = analysis['key_entities'] as Map<String, dynamic>? ?? {};
    final employees = (keyEntities['employees'] as List<dynamic>? ?? [])
        .cast<String>();
    final departments = (keyEntities['departments'] as List<dynamic>? ?? [])
        .cast<String>();
    final analysisTypes =
        (keyEntities['analysis_types'] as List<dynamic>? ?? []).cast<String>();

    final prompt =
        '''
你是一个智能任务规划器，需要为复杂的薪资查询任务规划执行步骤。

用户查询："$userQuery"
关键实体信息：
- 员工：$employees
- 部门：$departments  
- 分析类型：$analysisTypes

可用的查询操作包括：
1. **employee_salary** - 查询员工薪资数据
   - 参数：employeeName, year?, month?
   - 示例：查询张三1的工资情况

2. **department_salary** - 查询部门薪资数据  
   - 参数：department, year?, month?
   - 示例：查询技术部的薪资情况

3. **performance_analysis** - 绩效分析
   - 参数：employeeName?, department?, year?, month?
   - 示例：分析员工或部门绩效表现

4. **salary_trend** - 薪资趋势分析
   - 参数：employeeName?, department?
   - 示例：分析薪资变化趋势

5. **attendance_analysis** - 考勤分析
   - 参数：employeeName?, department?, year?, month?
   - 示例：分析考勤情况

6. **department_comparison** - 部门对比分析
   - 参数：year?, month?
   - 示例：对比各部门数据

7. **top_salary** - 查询最高薪资
   - 参数：limit?, year?, month?
   - 示例：找出薪资最高的员工

8. **data_collection** - 综合数据收集
   - 参数：employees?, departments?, data_types?
   - 示例：收集特定实体的全面数据

**规划原则：**
1. 如果问题涉及具体员工或部门，必须先收集相关数据
2. 复杂对比分析需要先收集数据，再进行分析
3. 每个步骤都应该有明确的目标和描述
4. 步骤之间应该有逻辑关系，从简单到复杂

请返回JSON格式的执行计划：
{
  "total_steps": 步骤数量,
  "complexity": "low/medium/high",
  "estimated_time": "预计时间",
  "steps": [
    {
      "step_id": 1,
      "operation": "操作类型",
      "parameters": {
        "具体参数": "参数值"
      },
      "description": "步骤的详细描述",
      "purpose": "步骤的目标"
    }
  ]
}
''';

    try {
      final result = await _llmClient.getAnswer(
        prompt,
        format: ResponseFormat.jsonObject(),
      );

      final jsonStart = result.indexOf('{');
      final jsonEnd = result.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = result.substring(jsonStart, jsonEnd + 1);
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      logger.warning('Execution planning failed: $e');
    }

    // 默认返回简单的执行计划
    return {
      'total_steps': 2,
      'complexity': 'medium',
      'estimated_time': '30秒',
      'steps': [
        {
          'step_id': 1,
          'operation': 'data_collection',
          'parameters': {
            'employees': employees,
            'departments': departments,
            'data_types': analysisTypes,
          },
          'description': '收集相关数据',
          'purpose': '为后续分析准备数据',
        },
        {
          'step_id': 2,
          'operation': 'general_analysis',
          'parameters': {'query': userQuery},
          'description': '进行综合分析',
          'purpose': '生成最终分析报告',
        },
      ],
    };
  }

  /// 从描述中提取参数
  Map<String, dynamic> _extractParametersFromDescription(String description) {
    final Map<String, dynamic> params = {};

    // 提取员工姓名 - 支持多种格式
    final employeePatterns = [
      RegExp(
        r'员工["'
        '](.*?)["'
        ']',
      ),
      RegExp(r'(张三\d*|李四\d*|王五\d*|[\u4e00-\u9fa5]+\d*)(?=的|薪资|绩效|考勤)'),
      RegExp(r'查询(.*?)的'),
    ];

    for (final pattern in employeePatterns) {
      final match = pattern.firstMatch(description);
      if (match != null && match.group(1)?.isNotEmpty == true) {
        params['employee'] = match.group(1)!.trim();
        break;
      }
    }

    // 提取部门 - 支持多种格式
    final departmentPatterns = [
      RegExp(
        r'部门["'
        '](.*?)["'
        ']',
      ),
      RegExp(r'(技术部|人事部|财务部|销售部|市场部|运营部|[\u4e00-\u9fa5]+部)'),
      RegExp(r'所有部门'),
    ];

    for (final pattern in departmentPatterns) {
      final match = pattern.firstMatch(description);
      if (match != null) {
        if (match.group(0)?.contains('所有部门') == true) {
          params['allDepartments'] = true;
        } else {
          params['department'] =
              match.group(1)?.trim() ?? match.group(0)?.trim();
        }
        break;
      }
    }

    // 如果是部门相关的步骤，默认查询所有部门
    if (description.contains('部门') &&
        !params.containsKey('department') &&
        !params.containsKey('allDepartments')) {
      params['allDepartments'] = true;
    }

    // 提取年份
    final yearRegex = RegExp(r'(\d{4})年');
    final yearMatch = yearRegex.firstMatch(description);
    if (yearMatch != null) {
      params['year'] = int.tryParse(yearMatch.group(1)!);
    }

    // 提取月份
    final monthRegex = RegExp(r'(\d{1,2})月');
    final monthMatch = monthRegex.firstMatch(description);
    if (monthMatch != null) {
      params['month'] = int.tryParse(monthMatch.group(1)!);
    }

    // 如果没有指定时间，添加默认参数
    if (!params.containsKey('year') && !params.containsKey('month')) {
      params['latest'] = true; // 标记获取最新数据
    }

    return params;
  }

  /// 执行单个步骤
  Future<Map<String, dynamic>> _executeStep(
    Map<String, dynamic> step,
    void Function(String)? onProgress,
  ) async {
    final operation = step['operation'] as String;
    final parameters = step['parameters'] as Map<String, dynamic>? ?? {};
    final description = step['description'] as String? ?? '';
    final purpose = step['purpose'] as String? ?? '';

    logger.info(
      'Executing step: $operation - $description ($purpose); Parameters: $parameters',
    );
    onProgress?.call('执行任务: $description');

    // 如果参数为空，尝试从描述中提取参数
    if (parameters.isEmpty) {
      final extractedParams = _extractParametersFromDescription(description);
      parameters.addAll(extractedParams);
      logger.info('Extracted parameters: $extractedParams');
    }

    try {
      switch (operation) {
        case 'employee_salary':
          final result = await _handleEmployeeSalaryQuery(parameters);
          return {'type': 'text_result', 'data': result};
        case 'department_salary':
          final result = await _handleDepartmentSalaryQuery(parameters);
          return {'type': 'text_result', 'data': result};
        case 'performance_analysis':
          final result = await _handlePerformanceAnalysisQuery(parameters);
          return {'type': 'text_result', 'data': result};
        case 'salary_trend':
          final result = await _handleSalaryTrendAnalysis(parameters);
          return {'type': 'text_result', 'data': result};
        case 'attendance_analysis':
          final result = await _handleEmployeeAttendanceQuery(parameters);
          return {'type': 'text_result', 'data': result};
        case 'department_comparison':
          final result = await _handleDepartmentAverageQuery(parameters);
          return {'type': 'text_result', 'data': result};
        case 'top_salary':
          final result = await _handleTopSalaryQuery(parameters);
          return {'type': 'text_result', 'data': result};
        case 'data_collection':
          final result = await _handleDataCollection(parameters, onProgress);
          return {'type': 'data_collection', 'data': result};
        case 'general_analysis':
          final result = await _handleGeneralAnalysis(parameters, onProgress);
          return {'type': 'analysis_result', 'data': result};
        default:
          return {'type': 'error', 'data': '执行步骤失败：未知的操作类型 $operation'};
      }
    } catch (e) {
      logger.warning('Step execution failed: $e');
      return {'type': 'error', 'data': '步骤执行失败：$e'};
    }
  }

  /// 处理数据收集
  Future<Map<String, dynamic>> _handleDataCollection(
    Map<String, dynamic> parameters,
    Function(String)? onProgress,
  ) async {
    final employees = (parameters['employees'] as List<dynamic>? ?? [])
        .cast<String>();
    final departments = (parameters['departments'] as List<dynamic>? ?? [])
        .cast<String>();
    final dataTypes = (parameters['data_types'] as List<dynamic>? ?? [])
        .cast<String>();

    // 如果参数为空，尝试检查 allDepartments 标志
    if (departments.isEmpty && parameters.containsKey('allDepartments')) {
      onProgress?.call('📊 收集所有部门数据...');
    }

    final Map<String, dynamic> collectedData = {};
    final List<String> collectionSummary = [];

    onProgress?.call('📦 正在收集相关数据...');

    // 收集员工数据
    if (employees.isNotEmpty) {
      onProgress?.call('👥 收集员工数据：${employees.join(", ")}');
      final employeeData = await _collectEmployeeAllData(employees);
      collectedData['employee_data'] = employeeData;
      collectionSummary.add(
        '已收集 ${employees.length} 名员工数据：${employees.join(", ")}',
      );
    }

    // 收集部门数据
    if (departments.isNotEmpty || parameters.containsKey('allDepartments')) {
      if (departments.isNotEmpty) {
        onProgress?.call('🏢 收集部门数据：${departments.join(", ")}');
        final departmentData = await _collectDepartmentAllData(departments);
        collectedData['department_data'] = departmentData;
        collectionSummary.add(
          '已收集 ${departments.length} 个部门数据：${departments.join(", ")}',
        );
      } else {
        onProgress?.call('🏢 收集所有部门数据...');
        final departmentData = await _collectDepartmentAllData([]);
        collectedData['department_data'] = departmentData;
        collectionSummary.add('已收集所有部门数据');
      }
    }

    // 根据数据类型收集特定数据
    if (dataTypes.isNotEmpty) {
      for (String dataType in dataTypes) {
        switch (dataType) {
          case 'performance':
          case '绩效':
            onProgress?.call('🏆 收集绩效数据...');
            if (employees.isNotEmpty) {
              collectedData['performance_data'] = await _collectPerformanceData(
                employees,
              );
            }
            if (departments.isNotEmpty) {
              collectedData['dept_performance_data'] =
                  await _collectDepartmentPerformanceData(departments);
            }
            collectionSummary.add('已收集绩效数据');
            break;
          case 'salary_trend':
          case '薪资趋势':
            onProgress?.call('📈 收集薪资趋势数据...');
            if (employees.isNotEmpty) {
              collectedData['salary_trend_data'] =
                  await _collectSalaryTrendData(employees);
            }
            if (departments.isNotEmpty) {
              collectedData['dept_salary_trend_data'] =
                  await _collectDepartmentSalaryTrendData(departments);
            }
            collectionSummary.add('已收集薪资趋势数据');
            break;
          case 'attendance':
          case '考勤':
            onProgress?.call('📊 收集考勤数据...');
            if (employees.isNotEmpty) {
              collectedData['attendance_data'] = await _collectAttendanceData(
                employees,
              );
            }
            collectionSummary.add('已收集考勤数据');
            break;
        }
      }
    }

    // 将数据存储到缓存中供后续步骤使用
    _queryCache['collected_data'] = collectedData;

    onProgress?.call('✅ 数据收集完成');

    return {
      'collection_summary': collectionSummary,
      'data': collectedData,
      'employee_count': employees.length,
      'department_count': departments.isNotEmpty
          ? departments.length
          : (parameters.containsKey('allDepartments') ? -1 : 0), // -1 表示所有部门
      'data_types': dataTypes,
    };
  }

  /// 处理通用分析
  Future<Map<String, dynamic>> _handleGeneralAnalysis(
    Map<String, dynamic> parameters,
    Function(String)? onProgress,
  ) async {
    final query = parameters['query'] as String? ?? '';
    final collectedData =
        _queryCache['collected_data'] as Map<String, dynamic>? ?? {};

    onProgress?.call('🧠 正在进行数据分析...');

    if (collectedData.isEmpty) {
      onProgress?.call('📄 使用通用分析模式...');
      // 如果没有收集到数据，尝试直接回答
      final result = await _handleGeneralQuery(query);
      return {
        'analysis_type': 'general_query',
        'result': result,
        'has_data': false,
      };
    }

    onProgress?.call('📊 基于收集数据进行AI分析...');
    // 使用收集到的数据进行AI分析
    final result = await _generateAIAnalysis(query, collectedData);
    return {
      'analysis_type': 'data_based_analysis',
      'result': result,
      'has_data': true,
      'data_summary': collectedData.keys.toList(),
    };
  }

  /// 处理薪资趋势分析
  Future<String> _handleSalaryTrendAnalysis(
    Map<String, dynamic> parameters,
  ) async {
    final employeeName = parameters['employeeName'] as String?;
    final department = parameters['department'] as String?;

    if (employeeName != null) {
      final trendData = await _collectSalaryTrendData([employeeName]);
      if (trendData.isEmpty) {
        return '未找到员工 $employeeName 的薪资趋势数据。';
      }

      return await _analyzeSalaryTrend(employeeName, trendData[employeeName]);
    } else if (department != null) {
      // 部门薪资趋势分析
      return await _analyzeDepartmentSalaryTrend(department);
    }

    return '请提供员工姓名或部门名称进行薪资趋势分析。';
  }

  /// 分析个人薪资趋势
  Future<String> _analyzeSalaryTrend(
    String employeeName,
    List<Map<String, dynamic>> trendData,
  ) async {
    final dataStr = trendData
        .map((data) => '${data['year']}年${data['month']}月: ${data['salary']}')
        .join('\n');

    final prompt =
        '''
请分析员工 $employeeName 的薪资变化趋势：

薪资数据：
$dataStr

请使用Markdown格式进行分析：

## 📈 整体趋势分析

## 📊 变化幅度和规律

## 🤔 可能的影响因素

## 💮 预测和建议

请给出专业的趋势分析报告。
''';

    try {
      final result = await _llmClient.getAnswer(prompt);
      return result.trim();
    } catch (e) {
      logger.warning('Salary trend analysis failed: $e');
      return '**薪资趋勿分析失败**\n\n请稍后重试。';
    }
  }

  /// 分析部门薪资趋势
  Future<String> _analyzeDepartmentSalaryTrend(String department) async {
    // 实现部门薪资趋势分析逻辑
    return '部门 $department 的薪资趋势分析功能正在开发中。';
  }

  /// 综合结果
  Future<String> _synthesizeResults(
    String userQuery,
    List<Map<String, dynamic>> stepResults,
    Map<String, dynamic> executionPlan,
  ) async {
    final resultsStr = stepResults
        .map((stepResult) {
          final stepId = stepResult['step_id'] ?? '';
          final description = stepResult['description'] ?? '';
          final result = stepResult['result'] ?? {};
          final success = stepResult['success'] ?? false;

          final status = success ? '✅' : '❌';

          // 处理不同类型的结果
          String resultText = '';
          if (result is Map<String, dynamic>) {
            final resultType = result['type'] as String? ?? 'unknown';
            final resultData = result['data'];

            switch (resultType) {
              case 'text_result':
                resultText = resultData.toString();
                break;
              case 'data_collection':
                if (resultData is Map<String, dynamic>) {
                  final summary =
                      resultData['collection_summary'] as List<dynamic>? ?? [];
                  resultText = '数据收集：\n${summary.join('\n')}';
                } else {
                  resultText = '数据收集完成';
                }
                break;
              case 'analysis_result':
                if (resultData is Map<String, dynamic>) {
                  resultText = resultData['result']?.toString() ?? '分析完成';
                } else {
                  resultText = resultData.toString();
                }
                break;
              case 'error':
                resultText = resultData.toString();
                break;
              default:
                resultText = result.toString();
            }
          } else {
            resultText = result.toString();
          }

          return '步骤$stepId ($status): $description\n$resultText';
        })
        .join('\n\n');

    final prompt =
        '''
用户原始问题："$userQuery"

执行步骤结果：
$resultsStr

请基于以上所有步骤的结果，综合分析并给出最终的完整回答。
请使用Markdown格式，回答应该：

## 🎯 问题回答
直接回答用户的问题

## 📊 数据整合
整合所有相关信息

## 📋 结论摘要
给出清晰的结论

## 💡 价值洞察
提供有价值的洞察

请给出结构化、完整的最终答案。
''';

    try {
      final result = await _llmClient.getAnswer(prompt);
      return result.trim();
    } catch (e) {
      logger.warning('Result synthesis failed: $e');
      // 如果AI综合失败，返回简单的markdown格式结果
      return '## 📊 查询结果\n\n$resultsStr';
    }
  }

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

**重要提醒：**
- 员工姓名可能包含数字或特殊标识，如"张三1"、"张三2"、"李四_A"、"王五-01"等
- 请完整保留用户提到的员工姓名，包括所有数字、下划线、连字符等标识符
- 如果用户说"张三1的工资"，参数中employeeName应该是"张三1"，而不是"张三"
- 如果用户说"李四2绩效如何"，参数中employeeName应该是"李四2"，而不是"李四"
- 员工姓名的匹配必须完全精确，不允许任何截取或模糊匹配

可用的查询意图包括：

1. "employee_salary": 查询某年某月某员工的工资详情
   - 关键词: 工资, 薪资, 员工, 姓名
   - 示例: "查询2023年10月张三1的工资", "2023年10月李四2薪资多少"

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
   - 示例: "查询2023年10月张三1的考勤情况", "李四2的出勤记录"

6. "average_salary": 查询某年某月所有员工的平均工资
   - 关键词: 平均, 平均工资, 人均薪资
   - 示例: "2023年10月的平均工资是多少", "查询人均薪资"

7. "total_salary": 查询某年某月所有员工的工资总和
   - 关键词: 总和, 总计, 工资总额
   - 示例: "2023年10月工资总和", "薪资总额是多少"

8. "department_average": 查询某年某月各部门的平均工资
   - 关键词: 部门, 平均, 工资对比
   - 示例: "各部门平均工资对比", "2023年10月各部门薪资情况"

9. "performance_analysis": 分析某员工的绩效表现
   - 关键词: 绩效, 表现, 绩效分析, 绩效水平, 绩效评价
   - 示例: "张三1的绩效水平怎么样", "分析李四2的绩效表现", "王五_A绩效如何"

请根据用户的问题，识别出对应的查询意图，并提取相关的参数：
- 年份(year): 四位数字年份
- 月份(month): 1-12的数字
- 员工姓名(employeeName): 员工的完整姓名（包括数字、下划线等标识）
- 部门(department): 部门名称
- 数量(limit): 前N名中的N值，默认为10

用户问题: {{question}}

请以以下JSON格式输出结果:
{
  "intent": "查询意图",
  "parameters": {
    "year": 年份,
    "month": 月份,
    "employeeName": "完整的员工姓名",
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
      return '## 📄 查询结果\n\n未找到 $year 年 $month 月员工 **$employeeName** 的工资记录。';
    }

    // 返回Markdown格式的结果
    return '''
## 💰 员工薪资详情

**员工姓名:** $employeeName  
**查询时间:** $year 年 $month 月

### 💼 基本信息
- **部门:** ${record.department ?? "未知"}
- **职位:** ${record.position ?? "未知"}
- **实发工资:** ${record.netSalary ?? "未知"}

### 📅 考勤情况
- **出勤情况:** ${record.attendance ?? "未知"}
- **计薪日天数:** ${record.payDays ?? "未知"}
- **实际出勤折算天数:** ${record.actualPayDays ?? "未知"}

### 😷 请假统计
- **病假天数:** ${record.sickLeave ?? "未知"}
- **事假小时数:** ${record.personalLeave ?? "未知"}
- **缺勤次数:** ${record.absence ?? "未知"}
- **旷工天数:** ${record.truancy ?? "未知"}

### 🏆 绩效评价
- **绩效得分:** ${record.performanceScore ?? "未知"}
''';
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
      return '## 📄 查询结果\n\n未找到 $year 年员工 **$employeeName** 的工资记录。';
    }

    return '''
## 📈 员工年度工资记录

**员工姓名:** $employeeName  
**查询年份:** $year 年

### 📊 月度工资详情
${results.join('\n')}
''';
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
      return '## 📄 查询结果\n\n未找到 $month 月员工 **$employeeName** 的工资记录。';
    }

    return '''
## 📈 员工月度工资记录

**员工姓名:** $employeeName  
**查询月份:** 所有年份 $month 月

### 📊 历年工资详情
${results.join('\n')}
''';
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
      return '## 📄 查询结果\n\n未找到员工 **$employeeName** 的任何工资记录。';
    }

    return '''
## 📈 员工全部工资记录

**员工姓名:** $employeeName  
**查询范围:** 所有年月

### 📊 历史工资详情
${results.join('\n')}
''';
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
    final year = int.tryParse(parameters['year'].toString());
    final month = int.tryParse(parameters['month'].toString());

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
