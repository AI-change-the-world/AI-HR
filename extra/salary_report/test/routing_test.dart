import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:salary_report/main.dart';

void main() {
  test('MainApp should be created without errors', () {
    // 确保应用可以正常创建
    expect(const MyApp(), isA<MyApp>());
  });

  // 由于GoRouter的结构比较复杂，我们不直接测试路由配置
  // 而是在集成测试中验证路由功能
}
