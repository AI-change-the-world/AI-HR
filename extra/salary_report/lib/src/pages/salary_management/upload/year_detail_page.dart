import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/common/toast.dart';
import 'package:salary_report/src/rust/api/salary_api.dart';
import 'package:salary_report/src/isar/database.dart';
import 'package:salary_report/src/isar/salary_list.dart';
import 'upload_page.dart';
import '../../../providers/year_provider.dart';

class YearDetailPage extends ConsumerStatefulWidget {
  final YearData yearData;

  const YearDetailPage({super.key, required this.yearData});

  @override
  ConsumerState<YearDetailPage> createState() => _YearDetailPageState();
}

class _YearDetailPageState extends ConsumerState<YearDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  static XTypeGroup xlsxTypeGroup = XTypeGroup(
    label: 'Excel文件',
    extensions: ['xlsx'],
  );

  Future<void> _selectFile(int month) async {
    final List<XFile> files = await openFiles(
      acceptedTypeGroups: [xlsxTypeGroup],
    );

    if (files.isNotEmpty) {
      // 选择文件后直接开始上传，传递文件路径和月份
      _uploadFile(files.first.path, month);
    }
  }

  Future<void> _uploadFile([String? filePath, int? month]) async {
    if (filePath == null || month == null) {
      ToastUtils.error(null, title: '请选择文件和月份');
      return;
    }

    try {
      final result = await getCaculateResult(filePath: filePath);
      if (result.$1 == "") {
        logger.info(result.$2!.summaryData);

        // 将解析结果保存到Isar数据库
        final isar = IsarDatabase().isar;

        if (isar != null) {
          // 删除已有数据
          await isar.writeTxn(() async {
            final r = await isar.salaryLists
                .filter()
                .monthEqualTo(month)
                .yearEqualTo(widget.yearData.year)
                .deleteAll();
            logger.info("$r件数据已删除");
          });

          // 创建SalaryList对象
          final salaryList = SalaryList()
            ..year = widget.yearData.year
            ..month = month
            ..records = result.$2!.records.map((record) {
              return SalaryListRecord()
                ..name = record.name
                ..department = record.department
                ..position = record.position
                ..attendance = record.attendance
                ..netSalary = record.netSalary
                ..preTaxSalary = record.preTaxSalary
                ..socialSecurityTax = record.socialSecurityTax
                ..payDays = record.payrollDays
                ..actualPayDays = record.attendance
                ..sickLeave = record.sickLeave
                ..personalLeave = record.personalLeave
                ..absence = record.absence
                ..truancy = record.truancy
                ..performanceScore = record.performanceScore
                ..serialNumber = record.serialNumber
                ..hireDate = record.hireDate
                ..terminationDate = record.terminationDate
                ..gender = record.gender
                ..idNumber = record.idNumber
                ..regularizationDate = record.regularizationDate
                ..contractType = record.contractType
                ..financialAggregation = record.financialAggregation
                ..secondaryDepartment = record.secondaryDepartment
                ..jobLevel = record.jobLevel
                ..basicSalary = record.basicSalary
                ..positionSalary = record.positionSalary
                ..performanceSalary = record.performanceSalary
                ..allowanceSalary = record.allowanceSalary
                ..comprehensiveSalary = record.comprehensiveSalary
                ..currentMonthBasic = record.currentMonthBasic
                ..currentMonthPosition = record.currentMonthPosition
                ..currentMonthPerformance = record.currentMonthPerformance
                ..currentMonthAllowance = record.currentMonthAllowance
                ..currentMonthSickDeduction = record.currentMonthSickDeduction
                ..currentMonthPersonalLeaveDeduction =
                    record.currentMonthPersonalLeaveDeduction
                ..currentMonthAbsenceDeduction =
                    record.currentMonthAbsenceDeduction
                ..currentMonthTruancyDeduction =
                    record.currentMonthTruancyDeduction
                ..mealAllowance = record.mealAllowance
                ..computerAllowance = record.computerAllowance
                ..otherAdjustments = record.otherAdjustments
                ..monthlyPayrollSalary = record.monthlyPayrollSalary
                ..socialSecurityBase = record.socialSecurityBase
                ..providentFundBase = record.providentFundBase
                ..personalPension = record.personalPension
                ..personalMedical = record.personalMedical
                ..personalUnemployment = record.personalUnemployment
                ..personalProvidentFund = record.personalProvidentFund
                ..monthlyPersonalIncomeTax = record.monthlyPersonalIncomeTax
                ..severancePay = record.severancePay
                ..postTaxAdjustments = record.postTaxAdjustments
                ..bank = record.bank
                ..bankAccount = record.bankAccount;
            }).toList()
            ..total = result.$2!.totalRecords.toString()
            ..extraInfo = jsonEncode(result.$2!.summaryData);

          // 保存到数据库
          await isar.writeTxn(() async {
            await isar.salaryLists.put(salaryList);
          });
        }
      } else {
        ToastUtils.error(null, title: "文件上传失败 ${result.$1}");
        return;
      }

      if (mounted) {
        ToastUtils.success(null, title: '文件上传成功');

        // 上传成功后，刷新年份数据
        ref.read(yearDataProvider.notifier).refresh();

        // 返回上一页
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.error(null, title: '上传失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.yearData.year}年薪资数据'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 年度概览
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withValues(alpha: 0.1),
                      const Color(0xFF26D0CE).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF26D0CE)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.yearData.year.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '年',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '已上传 ${widget.yearData.uploadedCount}/12 个月',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: widget.yearData.uploadedCount / 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6C63FF),
                                      Color(0xFF26D0CE),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 月份网格
              const Text(
                '月份详情',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final monthData = widget.yearData.months[index];
                  return _buildMonthCard(month, monthData);
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthCard(int month, MonthData monthData) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (month * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            // 如果该月份已经有数据，不执行任何操作
            if (monthData.hasData) {
              ToastUtils.info(context, title: "已有数据，重新上传将覆盖");
            }

            // 直接触发文件选择
            _selectFile(month);
          },
          child: Container(
            decoration: BoxDecoration(
              color: monthData.hasData
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: monthData.hasData
                    ? const Color(0xFF10B981)
                    : Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: monthData.hasData
                        ? const Color(0xFF10B981)
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    monthData.hasData ? Icons.check : Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$month月',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: monthData.hasData
                        ? const Color(0xFF10B981)
                        : Colors.grey[600],
                  ),
                ),
                if (monthData.hasData)
                  Text(
                    '已上传',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  )
                else
                  Text(
                    '点击上传',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
