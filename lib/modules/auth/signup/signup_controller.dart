// lib/modules/auth/signup/signup_controller.dart
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../repositories/auth_repository.dart';
import '../../../utils/snackbars.dart';

class SignupControllerX extends GetxController {
  final AuthRepository _repo;

  SignupControllerX(this._repo);

  final name     = ''.obs;
  final email    = ''.obs;
  final password = ''.obs;
  final phone    = ''.obs;
  final rollNo   = ''.obs;

  final loading = false.obs;
  final obscure = true.obs;

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your name';
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter password';
    if (v.length < 6) return 'Minimum 6 characters required';
    return null;
  }

  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter phone number';
    return null;
  }

  String? validateRollNo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter roll number';
    return null;
  }

  Future<void> signup() async {
    final nameVal  = name.value.trim();
    final emailVal = email.value.trim();
    final passVal  = password.value;
    final phoneVal = phone.value.trim();
    final rollVal  = rollNo.value.trim();

    // ── Basic field checks first (fast, no network needed) ──
    if (validateRollNo(rollVal) != null) {
      AppSnackbar.warning('Please enter your roll number.');
      return;
    }
    if (validateName(nameVal) != null) {
      AppSnackbar.warning('Please enter your full name.');
      return;
    }
    if (validateEmail(emailVal) != null) {
      AppSnackbar.warning('Please enter a valid email address.');
      return;
    }
    if (validatePhone(phoneVal) != null) {
      AppSnackbar.warning('Please enter your phone number.');
      return;
    }
    if (validatePassword(passVal) != null) {
      AppSnackbar.warning('Password must be at least 6 characters.');
      return;
    }

    try {
      loading.value = true;

      // ── Roll number gets checked against valid_students inside
      // repo.signup() BEFORE any account is created. If it's not a
      // recognized COMSATS Sahiwal roll number, or it's already used,
      // this throws before Firebase Auth is ever touched. ──
      await _repo.signup(
        name:     nameVal,
        email:    emailVal,
        password: passVal,
        phone:    phoneVal,
        rollNo:   rollVal,
      );

      AppSnackbar.success('Account created successfully! Welcome 🎉');
      Get.offAllNamed(Routes.home);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      // Show the specific roll-number message if that's what failed,
      // otherwise fall back to the friendly Firebase error translator.
      if (msg.contains('roll number') || msg.contains('already exists')) {
        AppSnackbar.error(msg);
      } else {
        AppSnackbar.error(AppSnackbar.friendlyFirebaseError(e));
      }
    } finally {
      loading.value = false;
    }
  }

  void togglePassword() => obscure.value = !obscure.value;
}