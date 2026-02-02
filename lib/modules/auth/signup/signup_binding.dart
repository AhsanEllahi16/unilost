import 'package:get/get.dart';
import '../../../repositories/auth_repository.dart';
import 'signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<SignupControllerX>(
          () => SignupControllerX(Get.find<AuthRepository>()),
    );
  }
}
