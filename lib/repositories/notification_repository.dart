import '../models/notification_model.dart';

class NotificationRepository {
  final List<NotificationModel> _data = [
    NotificationModel(
      id: '1',
      title: 'New Lost Item',
      body: 'Someone reported a lost wallet near cafeteria',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    NotificationModel(
      id: '2',
      title: 'Item Matched',
      body: 'Your lost phone has a possible match',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  List<NotificationModel> fetchAll() {
    return List.from(_data);
  }

  void markRead(String id) {
    final n = _data.firstWhere((e) => e.id == id);
    n.read = true;
  }

  void clearAll() {
    _data.clear();
  }
}
