import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../models/notification_model.dart';
import '../../viewmodels/notification_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: UniLostTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: c.clearAll,
          ),
        ],
      ),
      body: Obx(() {
        if (c.notifications.isEmpty) {
          return const Center(child: Text('No notifications'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: c.notifications.length,
          itemBuilder: (context, i) {
            final NotificationModel n = c.notifications[i];

            return ListTile(
              leading: Icon(
                n.read
                    ? Icons.notifications_none
                    : Icons.notifications_active,
                color:
                n.read ? Colors.grey : UniLostTheme.primary,
              ),
              title: Text(
                n.title,
                style: TextStyle(
                  fontWeight:
                  n.read ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(n.body),
              trailing: Text(_timeAgo(n.createdAt)),
              onTap: () => c.markRead(n.id),
            );
          },
        );
      }),
    );
  }
}
