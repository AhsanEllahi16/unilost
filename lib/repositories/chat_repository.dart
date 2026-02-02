import 'dart:math';
import 'package:get/get.dart';

import '../models/chat_model.dart';

class ChatRepository {
  final RxList<ChatModel> _chats = <ChatModel>[].obs;

  List<ChatModel> get chats => _chats.reversed.toList();

  int get unreadCount =>
      _chats.where((c) => c.unread == true).length;

  void addChat({
    required Map<String, dynamic> item,
    String? title,
    String? postedBy,
  }) {
    final id =
        DateTime.now().millisecondsSinceEpoch.toString() +
            Random().nextInt(999).toString();

    _chats.add(
      ChatModel(
        id: id,
        title: title ?? 'Chat about ${item['title'] ?? 'item'}',
        postedBy: postedBy ?? item['postedByName'] ?? 'User',
        unread: true,
        createdAt: DateTime.now(),
        item: item,
      ),
    );
  }

  void markRead(String id) {
    final index = _chats.indexWhere((c) => c.id == id);
    if (index != -1 && _chats[index].unread) {
      _chats[index] = _chats[index].copyWith(unread: false);
    }
  }

  void markAllRead() {
    for (int i = 0; i < _chats.length; i++) {
      if (_chats[i].unread) {
        _chats[i] = _chats[i].copyWith(unread: false);
      }
    }
  }

  void removeChat(String id) {
    _chats.removeWhere((c) => c.id == id);
  }

  void clear() {
    _chats.clear();
  }
}
