import 'package:f_clean_template/core/i_local_preferences.dart';
import 'package:f_clean_template/features/auth/auth_dependencies.dart';
import 'package:f_clean_template/features/create_project/create_project_dependencies.dart';
import 'package:f_clean_template/features/home/home_dependencies.dart';
import 'package:f_clean_template/features/my_projects/my_projects_dependencies.dart';
import 'package:f_clean_template/features/product/product_dependencies.dart';
import 'package:f_clean_template/features/shared_projects/shared_projects_dependencies.dart';
import 'package:f_clean_template/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<ILocalPreferences>(_MemoryPreferences(), permanent: true);
    registerAuth();
    registerProduct();
    registerSharedProjects();
    registerHome();
    registerMyProjects();
    registerCreateProject();
  });

  testWidgets('opens the login screen when there is no valid session', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Innovation Hub'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });
}

class _MemoryPreferences implements ILocalPreferences {
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<double?> getDouble(String key) async => _values[key] as double?;

  @override
  Future<int?> getInt(String key) async => _values[key] as int?;

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<List<String>?> getStringList(String key) async =>
      (_values[key] as List<String>?)?.toList();

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;

  @override
  Future<void> setDouble(String key, double value) async =>
      _values[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _values[key] = value;

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _values[key] = value.toList();
}
