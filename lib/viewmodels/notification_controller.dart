import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repo;

  NotificationController(this._repo);

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    notifications.assignAll(_repo.fetchAll());
  }

  void markRead(String id) {
    _repo.markRead(id);
    load();
  }

  void clearAll() {
    _repo.clearAll();
    notifications.clear();
  }

  int get unreadCount =>
      notifications.where((n) => !n.read).length;
}
