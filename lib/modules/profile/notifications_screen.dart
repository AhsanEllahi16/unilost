// lib/modules/profile/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../models/notification_model.dart';
import '../../viewmodels/notification_controller.dart';
import '../../routes/app_routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  final NotificationController c =
  Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    // ✅ Mark all as read when screen opens
    // This clears the badge count automatically
    Future.delayed(const Duration(milliseconds: 500), () {
      _markAllAsRead();
    });
  }

  Future<void> _markAllAsRead() async {
    for (final n in c.notifications) {
      if (!n.read) {
        await c.markRead(n.id);
      }
    }
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: UniLostTheme.primary,
        actions: [
          // ✅ Clear all button
          Obx(() => c.notifications.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear all',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Notifications'),
                  content: const Text(
                    'Delete all notifications?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await c.clearAll();
              }
            },
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (c.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You will be notified when a match is found',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: c.notifications.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 4),
          itemBuilder: (context, i) {
            final NotificationModel n = c.notifications[i];

            // ✅ Swipe to delete
            return Dismissible(
              key: Key(n.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              onDismissed: (_) => c.markRead(n.id),
              child: Container(
                decoration: BoxDecoration(
                  color: n.read
                      ? Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      : UniLostTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: n.read
                      ? null
                      : Border.all(
                    color: UniLostTheme.primary
                        .withOpacity(0.3),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: n.read
                          ? Colors.grey.shade200
                          : UniLostTheme.primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      n.read
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: n.read
                          ? Colors.grey
                          : UniLostTheme.primary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.read
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        style: const TextStyle(fontSize: 12),
                      ),
                      // ✅ Tap to chat link
                      if (n.title.contains('Match'))
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 6),
                          child: GestureDetector(
                            onTap: () {
                              c.markRead(n.id);
                              Get.toNamed(Routes.chatsList);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 14,
                                  color: UniLostTheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap to open chat →',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: UniLostTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    _timeAgo(n.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  onTap: () {
                    c.markRead(n.id);
                    // ✅ If match notification tap → open chats
                    if (n.title.contains('Match')) {
                      Get.toNamed(Routes.chatsList);
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}