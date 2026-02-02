import 'package:get/get.dart';

import '../repositories/chat_repository.dart';
import '../models/chat_model.dart';

class ChatController extends GetxController {
  final ChatRepository _repo;

  ChatController(this._repo);

  List<ChatModel> get chats => _repo.chats;

  int get unreadCount => _repo.unreadCount;

  void addChat({
    required Map<String, dynamic> item,
    String? title,
    String? postedBy,
  }) {
    _repo.addChat(
      item: item,
      title: title,
      postedBy: postedBy,
    );
  }

  void markRead(String id) {
    _repo.markRead(id);
  }

  void markAllRead() {
    _repo.markAllRead();
  }

  void removeChat(String id) {
    _repo.removeChat(id);
  }

  void clear() {
    _repo.clear();
  }
}
