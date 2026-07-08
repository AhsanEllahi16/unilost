// lib/modules/auth/login/login_controller.dart
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../repositories/auth_repository.dart';
import '../../../utils/snackbars.dart';

class LoginControllerX extends GetxController {
  final AuthRepository _repo;

  LoginControllerX(this._repo);

  final rollNo   = ''.obs;
  final password = ''.obs;
  final loading  = false.obs;
  final obscure  = true.obs;

  void toggleObscure() => obscure.value = !obscure.value;

  Future<void> login() async {
    final r = rollNo.value.trim();
    final p = password.value;

    if (r.isEmpty) {
      AppSnackbar.warning('Please enter your roll number.');
      return;
    }

    if (p.length < 6) {
      AppSnackbar.warning('Password must be at least 6 characters.');
      return;
    }

    try {
      loading.value = true;
      await _repo.loginWithRollNo(rollNo: r, password: p);
      AppSnackbar.success('Welcome back! Login successful 👋');
      Get.offAllNamed(Routes.home);
    } catch (e) {
      AppSnackbar.error(AppSnackbar.friendlyFirebaseError(e));
    } finally {
      loading.value = false;
    }
  }
}