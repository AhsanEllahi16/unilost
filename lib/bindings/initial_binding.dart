import 'package:get/get.dart';

// repos
import '../repositories/posts_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/notification_repository.dart';

// viewmodels
import '../viewmodels/posts_controller.dart';
import '../viewmodels/search_controller.dart';
import '../viewmodels/chat_controller.dart';
import '../viewmodels/profile_controller.dart';
import '../viewmodels/notification_controller.dart';

// state
import '../viewmodels/theme_controller.dart';
import '../viewmodels/settings_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PostsRepository(), fenix: true);
    Get.lazyPut(() => ChatRepository(), fenix: true);
    Get.lazyPut(() => ProfileRepository(), fenix: true);
    Get.lazyPut(() => NotificationRepository(), fenix: true);

    Get.lazyPut(() => PostsController(Get.find()), fenix: true);
    Get.lazyPut(() => SearchControllerX(Get.find()), fenix: true);
    Get.lazyPut(() => ChatController(Get.find()), fenix: true);
    Get.lazyPut(() => ProfileController(Get.find()), fenix: true);
    Get.lazyPut(() => NotificationController(Get.find()), fenix: true);

    Get.lazyPut(() => ThemeController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
  }
}
