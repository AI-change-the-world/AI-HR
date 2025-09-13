import 'package:riverpod/riverpod.dart';
import 'package:isar_community/isar.dart';
import '../isar/database.dart';
import '../isar/years.dart';
import '../isar/salary_list.dart';

// 年份数据模型
class YearInfo {
  final int year;
  final bool isActivated;
  final int uploadedCount;
  final List<MonthInfo> months;

  YearInfo({
    required this.year,
    required this.isActivated,
    required this.uploadedCount,
    required this.months,
  });
}

// 月份数据模型
class MonthInfo {
  final int month;
  final bool hasData;

  MonthInfo({required this.month, required this.hasData});
}

// 年份状态管理
final yearDataProvider = NotifierProvider<YearDataNotifier, List<YearInfo>>(
  YearDataNotifier.new,
);

class YearDataNotifier extends Notifier<List<YearInfo>> {
  @override
  List<YearInfo> build() {
    // 初始化时从数据库加载数据
    _loadYearsFromDatabase();
    return [];
  }

  // 从数据库加载年份数据
  Future<void> _loadYearsFromDatabase() async {
    final isar = IsarDatabase().isar;
    if (isar == null) return;

    try {
      // 获取所有激活的年份
      final activatedYears = await isar.activatedYears.where().findAll();
      final activatedYearList = activatedYears.map((e) => e.year).toList();

      // 获取所有年份的薪资数据以统计上传数量
      final salaryLists = await isar.salaryLists.where().findAll();
      final salaryMap = <int, List<SalaryList>>{};

      for (var salary in salaryLists) {
        if (!salaryMap.containsKey(salary.year)) {
          salaryMap[salary.year] = [];
        }
        salaryMap[salary.year]!.add(salary);
      }

      // 构建年份信息列表
      final years = <int>{};
      years.addAll(activatedYearList);
      years.addAll(salaryMap.keys);

      final yearInfoList = years.map((year) {
        final uploadedCount = salaryMap[year]?.length ?? 0;

        // 创建12个月的信息
        final months = List.generate(12, (index) {
          final month = index + 1;
          final hasData =
              salaryMap[year]?.any((salary) => salary.month == month) ?? false;
          return MonthInfo(month: month, hasData: hasData);
        });

        return YearInfo(
          year: year,
          isActivated: activatedYearList.contains(year),
          uploadedCount: uploadedCount,
          months: months,
        );
      }).toList();

      // 按年份降序排列
      yearInfoList.sort((a, b) => b.year.compareTo(a.year));

      state = yearInfoList;
    } catch (e) {
      // 处理错误
      print('加载年份数据失败: $e');
    }
  }

  // 添加新年份
  Future<void> addYear(int year) async {
    final isar = IsarDatabase().isar;
    if (isar == null) return;

    try {
      // 检查年份是否已存在
      final existingActivated = await isar.activatedYears
          .where()
          .yearEqualTo(year)
          .findFirst();

      if (existingActivated != null) {
        // 年份已存在，不需要重复添加
        return;
      }

      // 添加新的激活年份
      final newActivatedYear = ActivatedYear()..year = year;
      await isar.writeTxn(() async {
        await isar.activatedYears.put(newActivatedYear);
      });

      // 更新状态
      await _loadYearsFromDatabase();
    } catch (e) {
      print('添加年份失败: $e');
    }
  }

  // 激活年份
  Future<void> activateYear(int year) async {
    final isar = IsarDatabase().isar;
    if (isar == null) return;

    try {
      // 检查年份是否已激活
      final existingActivated = await isar.activatedYears
          .where()
          .yearEqualTo(year)
          .findFirst();

      if (existingActivated != null) {
        // 年份已激活，不需要重复激活
        return;
      }

      // 添加新的激活年份
      final newActivatedYear = ActivatedYear()..year = year;
      await isar.writeTxn(() async {
        await isar.activatedYears.put(newActivatedYear);
      });

      // 更新状态
      await _loadYearsFromDatabase();
    } catch (e) {
      print('激活年份失败: $e');
    }
  }

  // 取消激活年份
  Future<void> deactivateYear(int year) async {
    final isar = IsarDatabase().isar;
    if (isar == null) return;

    try {
      // 查找要取消激活的年份
      final activatedYear = await isar.activatedYears
          .where()
          .yearEqualTo(year)
          .findFirst();

      if (activatedYear == null) {
        // 年份未激活，无需操作
        return;
      }

      // 删除激活记录
      await isar.writeTxn(() async {
        await isar.activatedYears.delete(activatedYear.id);
      });

      // 更新状态
      await _loadYearsFromDatabase();
    } catch (e) {
      print('取消激活年份失败: $e');
    }
  }

  // 刷新数据
  Future<void> refresh() async {
    await _loadYearsFromDatabase();
  }
}
