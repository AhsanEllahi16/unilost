// lib/modules/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../repositories/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final String chatWith;     // display name of other user
  final String chatWithUid;  // UID of other user

  const ChatScreen({
    super.key,
    required this.chatWith,
    required this.chatWithUid,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ChatRepository _repo = Get.find<ChatRepository>();

  late final String _myUid;
  late final String _myName;
  late final String _chatId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _myUid   = user.uid;
    _myName  = user.displayName ?? 'User';
    _chatId  = _repo.chatId(_myUid, widget.chatWithUid);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();

    await _repo.sendMessage(
      chatId:   _chatId,
      fromUid:  _myUid,
      fromName: _myName,
      text:     text,
    );

    // ✅ Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.chatWith}'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: Column(
        children: [

          // ✅ Real-time Firestore stream
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _repo.streamMessages(_chatId),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Say hello! 👋'),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg  = messages[index];
                    final isMe = msg['from'] == _myUid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.72,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? UniLostTheme.primary
                              : Theme.of(context)
                              .colorScheme
                              .surfaceVariant,
                          borderRadius: BorderRadius.only(
                            topLeft:     const Radius.circular(14),
                            topRight:    const Radius.circular(14),
                            bottomLeft:  Radius.circular(isMe ? 14 : 2),
                            bottomRight: Radius.circular(isMe ? 2 : 14),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ Show sender name on received messages
                            if (!isMe)
                              Padding(
                                padding:
                                const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  msg['fromName'] ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ✅ Message input bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: UniLostTheme.primary,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}