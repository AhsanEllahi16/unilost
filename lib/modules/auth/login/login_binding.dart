import 'package:get/get.dart';
import '../../../repositories/auth_repository.dart';
import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<LoginControllerX>(
          () => LoginControllerX(Get.find<AuthRepository>()),
    );
  }
}
