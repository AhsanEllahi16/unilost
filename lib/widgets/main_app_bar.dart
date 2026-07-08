// lib/widgets/main_app_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';
import '../routes/app_routes.dart';
import '../viewmodels/notification_controller.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MainAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final NotificationController notifC =
    Get.find<NotificationController>();

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: UniLostTheme.primary,
      automaticallyImplyLeading: false,
      actions: [
        // Search
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => Get.toNamed(Routes.search),
        ),

        // Chat
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () => Get.toNamed(Routes.chatsList),
        ),

        // ✅ Notifications with red badge
        Obx(() {
          final count = notifC.unreadCount;
          return Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => Get.toNamed(Routes.notifications),
              ),
              if (count > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 9 ? '9+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),

        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}