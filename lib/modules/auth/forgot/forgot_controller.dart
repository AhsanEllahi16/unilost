// lib/modules/auth/forgot/forgot_controller.dart
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../repositories/auth_repository.dart';
import '../../../utils/snackbars.dart';

class ForgotControllerX extends GetxController {
  final AuthRepository _repo;

  ForgotControllerX(this._repo);

  final email   = ''.obs;
  final sending = false.obs;

  Future<void> sendReset() async {
    final e = email.value.trim();

    if (e.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e)) {
      AppSnackbar.warning('Please enter a valid email address.');
      return;
    }

    try {
      sending.value = true;
      await _repo.sendPasswordReset(e);
      AppSnackbar.success(
        'Reset link sent! Check your email inbox 📧',
      );
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(Routes.auth);
      });
    } catch (e) {
      AppSnackbar.error(AppSnackbar.friendlyFirebaseError(e));
    } finally {
      sending.value = false;
    }
  }
}