// lib/viewmodels/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme_manager.dart';

class ThemeController extends GetxController {
  final RxBool _isDark = false.obs;

  bool get isDark => _isDark.value;

  @override
  void onInit() {
    super.onInit();
    // ✅ Sync with whatever ThemeManager loaded from SharedPreferences
    _isDark.value = ThemeManager.themeMode.value == ThemeMode.dark;
  }

  void toggleTheme() => setDark(!_isDark.value);

  void setDark(bool value) {
    _isDark.value = value;
    // ✅ Persists to SharedPreferences + notifies ValueListenableBuilder
    ThemeManager.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    // ✅ Also updates GetX theme for any Get.changeTheme calls elsewhere
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}