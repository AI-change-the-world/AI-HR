import 'package:isar_community/isar.dart';

part 'salary_list.g.dart';

@collection
class SalaryList {
  Id id = Isar.autoIncrement;

  late int year;
  late int month;

  late List<SalaryListRecord> records;
  // 用来判断数据对不对
  late String total;

  late String extraInfo = '{}';
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
  // 税前工资
  String? preTaxSalary;
  // 社保公积金个人部分合计
  String? socialSecurityTax;

  // extra
  // 计薪日天数
  String? payDays;
  // 实际出勤折算天数
  String? actualPayDays;
  // 病假/天
  String? sickLeave;
  // 事假/小时
  String? personalLeave;
  // 缺勤/次
  String? absence;
  // 旷工/天
  String? truancy;
  // 绩效得分
  String? performanceScore;

  // 序号
  String? serialNumber;
  // 入职日期
  String? hireDate;
  // 离职日期
  String? terminationDate;
  // 性别
  String? gender;
  // 身份证号
  String? idNumber;
  // 转正日期
  String? regularizationDate;
  // 合同类型
  String? contractType;
  // 财务归集
  String? financialAggregation;
  // 二级部门
  String? secondaryDepartment;
  // 职级
  String? jobLevel;
  // 基本工资
  String? basicSalary;
  // 岗位工资
  String? positionSalary;
  // 绩效工资
  String? performanceSalary;
  // 补贴工资
  String? allowanceSalary;
  // 综合薪资标准
  String? comprehensiveSalary;
  // 当月基本工资
  String? currentMonthBasic;
  // 当月岗位工资
  String? currentMonthPosition;
  // 当月绩效工资
  String? currentMonthPerformance;
  // 当月补贴工资
  String? currentMonthAllowance;
  // 当月病假扣减
  String? currentMonthSickDeduction;
  // 当月事假扣减
  String? currentMonthPersonalLeaveDeduction;
  // 当月缺勤扣减
  String? currentMonthAbsenceDeduction;
  // 当月旷工扣减
  String? currentMonthTruancyDeduction;
  // 饭补
  String? mealAllowance;
  // 电脑补贴等
  String? computerAllowance;
  // 其他增减
  String? otherAdjustments;
  // 当月计薪工资
  String? monthlyPayrollSalary;
  // 社保基数
  String? socialSecurityBase;
  // 公积金基数
  String? providentFundBase;
  // 个人养老
  String? personalPension;
  // 个人医疗
  String? personalMedical;
  // 个人失业
  String? personalUnemployment;
  // 个人公积金
  String? personalProvidentFund;
  // 当月个人所得税
  String? monthlyPersonalIncomeTax;
  // 离职补偿金
  String? severancePay;
  // 税后增减
  String? postTaxAdjustments;
  // 所属银行
  String? bank;
  // 银行卡号
  String? bankAccount;
}
