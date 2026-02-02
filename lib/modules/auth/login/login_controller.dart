import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../repositories/auth_repository.dart';

class LoginControllerX extends GetxController {
  final AuthRepository _repo;

  LoginControllerX(this._repo);

  final email = ''.obs;
  final password = ''.obs;
  final loading = false.obs;

  Future<void> login() async {
    final e = email.value.trim();
    final p = password.value;

    if (e.isEmpty || p.length < 6) {
      Get.snackbar('Error', 'Enter valid email and password');
      return;
    }

    try {
      loading.value = true;

      await _repo.login(email: e, password: p);

      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('Login failed', e.toString());
    } finally {
      loading.value = false;
    }
  }
}
