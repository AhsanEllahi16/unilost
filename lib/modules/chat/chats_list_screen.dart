// lib/modules/chat/chats_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme.dart';
import '../../viewmodels/chat_controller.dart';
import '../../routes/app_routes.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatC = Get.find<ChatController>();
    // ✅ Get current user uid to filter out from participants
    final String myUid =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: Obx(() {
        final chats = chatC.chats;

        if (chats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No chats yet.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start a conversation from any item.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chat = chats[index];

            final String chatId      = chat['id'] ?? '';
            final String itemTitle   = chat['itemTitle'] ?? 'Chat';
            final String lastMessage = chat['lastMessage'] ?? '';

            // ✅ Find the OTHER participant — not current user
            final List participants =
                chat['participants'] as List? ?? [];
            final String otherUid = participants.firstWhere(
                  (uid) => uid != myUid,
              orElse: () => '',
            );

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: UniLostTheme.primary,
                child: Text(
                  itemTitle.isNotEmpty
                      ? itemTitle[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                itemTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                lastMessage.isEmpty
                    ? 'No messages yet'
                    : lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
              onTap: () {
                // ✅ Correctly passes other user's uid
                Get.toNamed(
                  Routes.chat,
                  arguments: {
                    'chatWith': itemTitle,
                    'uid': otherUid,
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}