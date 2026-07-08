// lib/repositories/chat_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final _db = FirebaseFirestore.instance;

  /// Generates a deterministic chat ID from two UIDs.
  /// Sorting ensures uid1_uid2 and uid2_uid1 produce the same ID.
  String chatId(String myUid, String otherUid) {
    final ids = [myUid, otherUid]..sort();
    return ids.join('_');
  }

  /// Real-time stream of messages for a conversation
  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      final data = d.data();
      // ✅ Convert Firestore Timestamp → DateTime for UI
      final ts = data['createdAt'];
      return {
        ...data,
        'createdAt':
        ts is Timestamp ? ts.toDate() : DateTime.now(),
      };
    }).toList());
  }

  /// Send a message and update chat metadata
  Future<void> sendMessage({
    required String chatId,
    required String fromUid,
    required String fromName,
    required String text,
  }) async {
    // ✅ Add message to subcollection
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'from': fromUid,
      'fromName': fromName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ✅ Update chat metadata for ChatsListScreen
    await _db.collection('chats').doc(chatId).set({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream all chats where this user is a participant
  Stream<List<Map<String, dynamic>>> streamUserChats(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .toList());
  }

  /// Called when a chat is initiated from ItemDetailScreen
  Future<void> createChat({
    required String chatId,
    required String myUid,
    required String otherUid,
    required String itemTitle,
  }) async {
    await _db.collection('chats').doc(chatId).set({
      'participants': [myUid, otherUid],
      'itemTitle': itemTitle,
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}