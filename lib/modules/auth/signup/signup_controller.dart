import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../repositories/auth_repository.dart';

class SignupControllerX extends GetxController {
  final AuthRepository _repo;

  SignupControllerX(this._repo);

  final name = ''.obs;
  final email = ''.obs;
  final password = ''.obs;

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

  Future<void> signup() async {
    final nameVal = name.value.trim();
    final emailVal = email.value.trim();
    final passVal = password.value;

    if (validateName(nameVal) != null ||
        validateEmail(emailVal) != null ||
        validatePassword(passVal) != null) {
      Get.snackbar("Error", "Enter valid name, email, and password");
      return;
    }

    try {
      loading.value = true;
      await _repo.signup(
        name: nameVal,
        email: emailVal,
        password: passVal,
      );
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('Signup Failed', e.toString());
    } finally {
      loading.value = false;
    }
  }

  void togglePassword() {
    obscure.value = !obscure.value;
  }
}
