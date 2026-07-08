// lib/viewmodels/chat_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/chat_repository.dart';

class ChatController extends GetxController {
  final ChatRepository _repo;

  ChatController(this._repo);

  final chats      = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    // ✅ Listen to auth state — reload chats when user logs in
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadChats(user.uid);
      } else {
        chats.clear();
        _sub?.cancel();
      }
    });
  }

  void _loadChats(String uid) {
    _sub?.cancel();
    _sub = _repo.streamUserChats(uid).listen(
          (list) {
        chats.assignAll(list);
      },
      onError: (e) {
        // Silent fail
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> startChat({
    required String otherUid,
    required String itemTitle,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final chatId = _repo.chatId(user.uid, otherUid);
    await _repo.createChat(
      chatId:    chatId,
      myUid:     user.uid,
      otherUid:  otherUid,
      itemTitle: itemTitle,
    );
  }

  String getChatId(String otherUid) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';
    return _repo.chatId(user.uid, otherUid);
  }
}