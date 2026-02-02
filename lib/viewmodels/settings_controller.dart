// lib/viewmodels/settings_controller.dart
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxBool autoMatchEnabled = true.obs;

  void setNotifications(bool v) => notificationsEnabled.value = v;
  void setAutoMatch(bool v) => autoMatchEnabled.value = v;

  Future<void> resetToDefaults() async {
    notificationsEnabled.value = true;
    autoMatchEnabled.value = true;
    await Future<void>.value();
  }
}