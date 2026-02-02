import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../repositories/auth_repository.dart';

class ForgotControllerX extends GetxController {
  final AuthRepository _repo;

  ForgotControllerX(this._repo);

  final email = ''.obs;
  final sending = false.obs;

  Future<void> sendReset() async {
    final e = email.value.trim();

    if (e.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e)) {
      Get.snackbar('Error', 'Enter a valid email');
      return;
    }

    try {
      sending.value = true;

      await _repo.sendPasswordReset(e);

      Get.snackbar('Sent', 'Reset email sent');

      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(Routes.auth);
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      sending.value = false;
    }
  }
}
