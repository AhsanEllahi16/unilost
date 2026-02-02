import 'package:get/get.dart';
import '../../../repositories/auth_repository.dart';
import 'forgot_controller.dart';

class ForgotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<ForgotControllerX>(
          () => ForgotControllerX(Get.find<AuthRepository>()),
    );
  }
}
