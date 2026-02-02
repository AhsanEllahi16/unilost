// lib/modules/chat/chats_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../viewmodels/chat_controller.dart';
import '../../routes/app_routes.dart';
import '../../models/chat_model.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatC = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: Obx(() {
        final List<ChatModel> chats = chatC.chats;

        if (chats.isEmpty) {
          return const Center(
            child: Text('No chats yet. Start a conversation from an item.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chat = chats[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                chat.unread ? Colors.redAccent : Colors.grey,
                child: const Icon(Icons.chat_bubble_outline,
                    color: Colors.white),
              ),
              title: Text(chat.title),
              subtitle: Text('with ${chat.postedBy}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    chat.createdAt.toString().split('.').first,
                    style: const TextStyle(fontSize: 11),
                  ),
                  if (chat.unread)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 10, color: Colors.red),
                    ),
                ],
              ),
              onTap: () {
                chatC.markRead(chat.id);
                Get.toNamed(
                  Routes.chat,
                  arguments: {'chatWith': chat.postedBy},
                );
              },
            );
          },
        );
      }),
    );
  }
}
