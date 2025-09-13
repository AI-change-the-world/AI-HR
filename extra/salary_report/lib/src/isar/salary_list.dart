import 'package:isar_community/isar.dart';

part 'salary_list.g.dart';

@collection
class SalaryList {
  Id id = Isar.autoIncrement;

  late int year;
  late int month;

  late List<SalaryListRecord> records;
}

@embedded
class SalaryListRecord {
  String? name;
  // 部门
  String? department;
  // 职位
  String? position;
  // 出勤情况
  String? attendance;
  // 实发工资
  String? netSalary;

  // extra
  // 计薪日天数
  String? payDays;
  // 实际出勤折算天数
  String? actualPayDays;
  // 病假/天
  String? sickLeave;
  // 事假/天
  String? leave;
  // 缺勤/次
  String? absence;
  // 旷工/天
  String? truancy;

  // 绩效得分
  String? performanceScore;
}
