// lib/viewmodels/settings_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {

  // Keys for SharedPreferences
  static const _keyNotifications = 'notifications_enabled';
  static const _keyAutoMatch     = 'auto_match_enabled';

  final RxBool notificationsEnabled = true.obs;
  final RxBool autoMatchEnabled     = true.obs;

  @override
  void onInit() {
    super.onInit();
    // ✅ Load saved settings when controller starts
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ Read saved values — default to true if not set yet
    notificationsEnabled.value =
        prefs.getBool(_keyNotifications) ?? true;
    autoMatchEnabled.value =
        prefs.getBool(_keyAutoMatch) ?? true;
  }

  // ✅ Save to SharedPreferences when user toggles
  Future<void> setNotifications(bool v) async {
    notificationsEnabled.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, v);
  }

  // ✅ Save to SharedPreferences when user toggles
  Future<void> setAutoMatch(bool v) async {
    autoMatchEnabled.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoMatch, v);
  }

  // ✅ Reset both settings and clear from SharedPreferences
  Future<void> resetToDefaults() async {
    notificationsEnabled.value = true;
    autoMatchEnabled.value     = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, true);
    await prefs.setBool(_keyAutoMatch, true);
  }
}